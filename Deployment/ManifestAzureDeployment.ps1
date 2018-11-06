#
# ManifestAzureDeployment.ps1
#

##This deployment script is intended for use in deploying the 
##resources within the resource group specified at the top level
##of this repository
#region Parameters

<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER clientId
    The clientId of your azure service principal account.

 .PARAMETER clientSecret
    The clientSecret of your azure service principal account.

 .PARAMETER tenantId
    The tenantId of your azure subscription.

 .PARAMETER subscriptionId
    The subscriptionId of your azure subscription where the templates will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    The resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentMode
    The deploymentMode is either Incremental or Complete. When deploying your resources, you specify that the deployment mode is either an incremental or a complete. 

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
	 $deploymentMode,

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
	function Run-ManifestDeployment{
		param(
		[Parameter(Mandatory=$True,Position=0)]
		[string]$ResourceGroupName,
		[Parameter(Mandatory=$True,Position=1)]
		[string]$DeploymentMode,
		[Parameter(Mandatory=$True,Position=2)]
		[string]$DeploymentStackName,
		[Parameter(Mandatory=$True,Position=3)]
		[psobject]$ManifestObject)
    try{
		Write-Host "Deploying $deploymentStackName"
		Write-Host "$($ManifestObject.$DeploymentStackName.count) deployments in this stack. "
		foreach ($deployment in $ManifestObject.$DeploymentStackName){
			#Collect Deployment details from manifest object
			#$TemplateFile = "../Templates/$($deployment.Template)"
			$TemplateFile = "$templatesFilePath/$($deployment.Template)"
			Write-Host "Template File: $TemplateFile"
			#$ParameterFile = "../Parameters/$($deployment.ParameterSet)"
			$ParameterFile = "$parametersFilePath/$($deployment.ParameterSet)"
			Write-Host "Parameter File: $ParameterFile"
			$DeploymentName = $deployment.DeploymentName
			Write-Host "Deployment Name: $DeploymentName"
			Write-Host "Resource Group Name = $($resourceGroupName)"

			#Validate-StackParameters -resourceGroup $resourceGroupName -parameterFile $deployment.ParameterSet -ManifestObject $ManifestObject

			$deploymentResult = New-AzureRmResourceGroupDeployment -Name $DeploymentName `
										-Mode $DeploymentMode `
										-ResourceGroupName $resourceGroupName `
										-TemplateParameterFile $ParameterFile `
										-TemplateFile $TemplateFile      
			Write-Host $deploymentResult.ProvisioningState
			if($deploymentResult.ProvisioningState-eq"Succeeded"){
				Write-Host "Successfully completed to deploy ARM template is $($deployment.Template) with the parameter file as $($deployment.ParameterSet)"
			}else{				
				Write-Host "Failed to deploy ARM template is $($deployment.Template) with the parameter file as $($deployment.ParameterSet)"
				exit 1
			}	
		}
		#return $deploymentResult.ProvisioningState		
		Write-Host "Completed Run-ManifestDeployment function"
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

#Use Manifest to identify which deployment set to use
	#$manifestDetails = Get-Content ./manifest.json | ConvertFrom-Json
	$manifestDetails = Get-Content $manifestJsonFile | ConvertFrom-Json
	if ($?){
		Write-Host "Manifest file loaded"
	}

	if ($DeploymentStack -like "all"){
		#deploy all 
		Write-Host "Deploying Full Manifest"
		foreach ($deploymentStackItem in $manifestDetails.deploymentStacks.value){
			Run-ManifestDeployment  -ResourceGroupName $resourceGroupName `
									-DeploymentMode $deploymentMode `
									-DeploymentStackName $deploymentStackItem `
									-ManifestObject $manifestDetails
		}
	}
	else{
		#deploy only the specified set
		#ensure that the specified deployment set is in the manifest
		Write-Host "Attempting to deploy $deploymentStack"
    
		if($deploymentStack -in $manifestDetails.deploymentStacks.value){
        
			Run-ManifestDeployment  -ResourceGroupName $resourceGroupName `
									-DeploymentMode $deploymentMode `
									-DeploymentStackName $deploymentStack `
									-ManifestObject $manifestDetails
		}

	}

#endregion
