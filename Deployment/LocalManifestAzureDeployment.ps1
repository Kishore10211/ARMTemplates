#Login-AzureRmAccount

#region Parameters
$resourceGroupName='KZEU-ARMTMP-SB-DEV-RGP-01'
$location='eastus'
#$parametersUri='https://raw.githubusercontent.com/Kishore10211/ARMTemplates/master/Parameters/StorageAccount.parameters.json'
$parametersUri='E:\Kishore\Kishore GitHub\ARMTemplates\Parameters\StorageAccount.parameters.json'
$templateUri='https://raw.githubusercontent.com/Kishore10211/ARMTemplates/master/Templates/StorageAccount.json?access_token=2fa1b86c588ba5d701d3041c320bf61c1423fa54'
#$templateUri='https://kzeuarmtmpsbdevsto01.blob.core.windows.net/mastertemplates/StorageAccount.json?sp=r&st=2018-11-06T09:03:01Z&se=2018-11-06T17:03:01Z&spr=https&sv=2017-11-09&sig=9%2FWHwrXT4%2FK7QH75oVVNw5gUQChIJV9hEZy%2Fro4ZdZ0%3D&sr=b'
$clientID = "2c5f5bb4-ea19-4208-af44-417f629a5236"
$key = "CPQ0Hsri+yw/EU+qQUYnBgI+ZioWAzB/oZQGziH9rcI="
#endregion

#region Login into Azure
$SecurePassword = $key | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential `
     -argumentlist $clientID, $SecurePassword

Add-AzureRmAccount -Credential $cred -Tenant "b13b12a7-853e-4a15-ad3c-6ae4c3e19da8" -ServicePrincipal

Set-AzureRmContext -SubscriptionID '55c8b769-eb89-41a0-86c7-ba2ae87ffcda'
#endregion

#region Check or Create Resource Group
Get-AzureRmResourceGroup -Name $resourceGroupName -ev notPresent -ea 0
if($notPresent){ 
    Write-Host "Failover RG '$resourceGroupName' doesn't exist. Creating a new in $location...." -ForegroundColor Yellow
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}else{
	Write-Host "Using existing resource group '$resourceGroupName'" -ForegroundColor Yellow;
}

#endregion

#region Validate & Deploy ARM Templates
try{
$templateValidationResult= Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateUri -TemplateParameterFile $parametersUri -Verbose
	if($templateValidationResult[0].Code-eq"InvalidTemplateDeployment"){
		Write-Host "Failed to validate ARM template"
        exit 1
	}else{
		Write-Host "Successfully completed to validate ARM template"
        $deploymentResult= New-AzureRmResourceGroupDeployment -Name StorageAccount-Deployment -ResourceGroupName $resourceGroupName -TemplateFile $templateUri -TemplateParameterFile $parametersUri -Verbose
        if($deploymentResult.ProvisioningState-eq"Succeeded"){
			Write-Host "Successfully completed to deploy ARM template"
		}else{				
			Write-Host "Failed to deploy ARM template"
			exit 1
		}       
	}
}
catch{
 $ex = $_.Exception | Format-List -Force
 Write-Host $ex
}

#endregion