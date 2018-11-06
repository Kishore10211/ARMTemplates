#
# ManifestAzureDeployment.ps1
#

##This deployment script is intended for use in deploying the 
##resources within the resource group specified at the top level
##of this repository
#region Parameters

<#
 .SYNOPSIS
    Validate a template to Azure

 .DESCRIPTION
    Validate an Azure Resource Manager template

 .PARAMETER clientId
    The clientId of your azure service principal account.

 .PARAMETER clientSecret
    The clientSecret of your azure service principal account.

 .PARAMETER tenantId
    The tenantId of your azure subscription.

 .PARAMETER subscriptionId
    The subscriptionId of your azure subscription where the templates will be validated.

 .PARAMETER resourceGroupName
    The resource group where the template will be validated. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    The resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER manifestJsonFile
    The path of the Manifest.json file. e.g E:\Kishore\Azuredevops-kishore-Repos\ARMTemplates\ARMTemplates\Deployment\Manifest.json

 .PARAMETER templatesFilePath
	The path of Templates fodler. e.g E:\Kishore\Azuredevops-kishore-Repos\ARMTemplates\ARMTemplates\Templates

 .PARAMETER parametersFilePath
	The path of the Parameters folder with specified environment like Dev, Test, UAT, Staging and Production.
	e.g E:\Kishore\Azuredevops-kishore-Repos\ARMTemplates\ARMTemplates\Parameters
 
 .PARAMETER DeploymentStack
	Pass the DeploymentStack name in Manifest.json files. e.g all and StorageAccount etc....
#>
Param(
	 [Parameter(Mandatory=$True)]
	 [string]
	 $clientId,

	  [Parameter(Mandatory=$True)]
	 [string]
	 $clientSecret,

	  [Parameter(Mandatory=$True)]
	 [string]
	 $tenantId,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $subscriptionId,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $resourceGroupName,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $resourceGroupLocation,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $manifestJsonFile,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $templatesFilePath,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $parametersFilePath,

	 [Parameter(Mandatory=$True)]
	 [string]
	 $DeploymentStack
)
#endregion

#region SubFunctions
	function Run-ManifestValidation{
		param(
		[Parameter(Mandatory=$True,Position=0)]
		[string]$ResourceGroupName,
		[Parameter(Mandatory=$True,Position=1)]
		[string]$DeploymentStackName,
		[Parameter(Mandatory=$True,Position=2)]
		[psobject]$ManifestObject)
    
		try{
			Write-Host "Validating $deploymentStackName"
			Write-Host "$($ManifestObject.$DeploymentStackName.count) deployments in this stack. "
			foreach ($validate in $ManifestObject.$DeploymentStackName){
				#Collect validating details from manifest object
				$TemplateFile = "$templatesFilePath/$($validate.Template)"
				Write-Host "Template File: $TemplateFile"
				$ParameterFile = "$parametersFilePath/$($validate.ParameterSet)"
				Write-Host "Parameter File: $ParameterFile"
				Write-Host "Resource Group Name = $($resourceGroupName)"
				#Validate-StackParameters -resourceGroup $resourceGroupName -parameterFile $deployment.ParameterSet -ManifestObject $ManifestObject
				$templateValidationResult=Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateParameterFile $ParameterFile -TemplateFile $TemplateFile
				if($templateValidationResult[0].Code-eq"InvalidTemplateDeployment"){
					Write-Host "Failed to validate ARM template is $($validate.Template) with the parameter file as $($validate.ParameterSet)"
					exit 1
				}else{
					Write-Host "Successfully completed to validate ARM template is $($validate.Template) with the parameter file as $($validate.ParameterSet)"
				}																										    			
			}
			Write-Host "Completed Run-ManifestValidation function"
		}catch{
			   $ex = $_.Exception | Format-List -Force
		}

	} 
#endregion

#region MainScript
	$ErrorActionPreference = "Stop"

	#Ensure that the deployment script is running in the correct directory. 
	Set-Location $MyInvocation.MyCommand.Path -ErrorAction SilentlyContinue

	# sign in
	Write-Host "Logging in...";
	$SecurePassword = $clientSecret | ConvertTo-SecureString -AsPlainText -Force
	$cred = new-object -typename System.Management.Automation.PSCredential `
		 -argumentlist $clientId, $SecurePassword

	Add-AzureRmAccount -Credential $cred -Tenant $tenantId -ServicePrincipal
	# set azure context with  subscriptionId
	Set-AzureRmContext -SubscriptionID $subscriptionId
	# select subscription
	Write-Host "Selecting subscription '$subscriptionId'";
	Select-AzureRmSubscription -SubscriptionID $subscriptionId;

#region Validate Resource Group Name

	#Validate that the resource group has been created, if it does not exist, create one. 
	$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
	if(!$resourceGroup)
	{
		Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
		if(!$resourceGroupLocation) {
			$resourceGroupLocation = Read-Host "resourceGroupLocation";
		}
		Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
		New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
	}
	else{
		Write-Host "Using existing resource group '$resourceGroupName'";
	}

#endregion

#Use Manifest to identify which deployment set to use for validating
	$manifestDetails = Get-Content $manifestJsonFile | ConvertFrom-Json
	if ($?){
		Write-Host "Manifest file loaded"
	}

	if ($DeploymentStack -like "all"){
		#validate all 
		Write-Host "Deploying Full Manifest"
		foreach ($deploymentStackItem in $manifestDetails.deploymentStacks.value){
			Run-ManifestValidation  -ResourceGroupName $resourceGroupName `
									-DeploymentStackName $deploymentStackItem `
									-ManifestObject $manifestDetails
		}
	}
	else{
		#valdiate only the specified set
		#ensure that the specified deployment set is in the manifest
		Write-Host "Attempting to validate $deploymentStack"
    
		if($deploymentStack -in $manifestDetails.deploymentStacks.value){
        
			Run-ManifestValidation  -ResourceGroupName $resourceGroupName `
									-DeploymentStackName $deploymentStack `
									-ManifestObject $manifestDetails
		}

	}

#endregion
