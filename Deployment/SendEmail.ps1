#
# SendEmail.ps1
#

## This deployment script is intended for sending email with recent deployment details.

<#
 .PARAMETER clientId
    The clientId of your azure service principal account.

 .PARAMETER clientSecret
    The clientSecret of your azure service principal account.

 .PARAMETER tenantId
    The tenantId of your azure subscription.

 .PARAMETER subscriptionId
    The subscriptionId of your azure subscription.

 .PARAMETER resourceGroupName
	Give the name of the resource group, you can get recent deployment details. 
	
 .PARAMETER environmentName
	Give the environementName as Dev, Test, UAT, Staging and Production.

.PARAMETER sendgridUsername
	The sendgridUsername of your azure sendgrid account.
	
.PARAMETER sendgridPassword
	The sendgridPassword of your azure sendgrid account.
	
.PARAMETER toEmailAddress
	Give the valid email address for sending the email with recent deployment details.
	
.PARAMETER ccEmailAddress
	Give the valid email address for sending the email with recent deployment details.
	
.PARAMETER universalFunctionsFilePath
	The path of UniversalFunctions.ps1 file. 
	Example: E:\Kishore\Azuredevops-kishore-Repos\ARMTemplates\ARMTemplates\Deployment\UniversalFunctions.ps1
#>

param(
	
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
	 $environmentName,

 	 #Provide SendGrid user name, if you are using Microsoft azure you will find the same from the portal 
	 [Parameter(Mandatory=$true)]
	 [string]
	 $sendgridUsername,

     [Parameter(Mandatory=$true)]
	 [string]
	 $sendgridPassword,

	 [Parameter(Mandatory=$true)]
	 [string]
	 $toEmailAddress,
	 
	 [Parameter(Mandatory=$true)]
	 [string]
	 $ccEmailAddress,

	 [Parameter(Mandatory=$true)]
	 [string]
	 $universalFunctionsFilePath	
)

#region subfunctions
	
	#By using this fucntion you can send email with recent deployment details to application development team
	function Send-Email{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[string]$To,

			[Parameter(Mandatory=$True,Position=1)]
			[string]$Cc,

			[Parameter(Mandatory=$True,Position=1)]
			[psobject]$DeploymentDetails
			)
	   Process{

		foreach($deploymentOutput in $DeploymentDetails){

			if($deploymentOutput.logAnalyticsDeploymentName -eq 'LogAnalytics-Deployment'){
				
				$logAnalyticsHTMLContent=LogAnalyticsDetailsWithHTMLContent -logAnalyticsDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.serviceBusDeploymentName -eq 'ServiceBus-Deployment'){
				
				$serviceBusHTMLContent=ServiceBusDeploymentDetailsWithHTMLContent -servicebusDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.storageAccountDeploymentName -eq 'StorageAccount-Deployment'){
				
				$storageAccountHTMLContent=StorageAccountDeploymentDetailsWithHTMLContent -storageAccountDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.storageAccountAPIDeploymentName -eq 'StorageAccount-API-Deployment'){
				
				$storageAccountAPIHTMLContent=StorageAccountAPIDeploymentDetailsWithHTMLContent -storageAccountAPIDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.storageAccountDbsDeploymentName -eq 'StorageAccount-Dbs-Deployment'){
				
				$storageAccountDbsHTMLContent=StorageAccountDbsDeploymentDetailsWithHTMLContent -storageAccountDbsDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.storageAccountHybrisDeploymentName -eq 'StorageAccount-Hybris-Deployment'){
				
				$storageAccounthybrisHTMLContent=StorageAccountHybrisDeploymentDetailsWithHTMLContent -storageAccountHybrisDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.keyVaultDeploymentName -eq 'KeyVault-Deployment'){
				
				$keyVaultHTMLContent=KeyVaultDeploymentDetailsWithHTMLContent -keyVaultDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.sqlServerDeploymentName -eq 'AzureSQL-Deployment'){
				
				$sqlServerHTMLContent=SQLServerDeploymentDetailsWithHTMLContent -sqlServerDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.nsgAPIDeploymentName -eq 'Nsg-API-Deployment'){
				
				$nsgAPIHTMLContent=NsgAPIDeploymentDetailsWithHTMLContent -NsgAPIDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.nsgDataDeploymentName -eq 'Nsg-Data-Deployment'){
				
				$nsgDataHTMLContent=NsgDataDeploymentDetailsWithHTMLContent -NsgDataDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.nsgHybDeploymentName -eq 'Nsg-Hyb-Deployment'){
				
				$nsghybHTMLContent=NsgHybDeploymentDetailsWithHTMLContent -NsgHybDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.udrDeploymentName -eq 'Udr-Deployment'){
				
				$udrHTMLContent=UdrDeploymentDetailsWithHTMLContent -udrDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.subnetsWithNsgUdrDeploymentName -eq 'Subnets-With-Nsg-Udr-Deployment'){
				
				$subnetsHTMLContent=SubnetsWithNsgAndUDrDeploymentDetailsWithHTMLContent -subnetsDeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.computeManagedDisksAPI01DeploymentName -eq 'ComputeManagedDisks-API01-Deployment'){
				
				$computeManagedDisksAPI01HTMLContent=ComputeManagedDisksAPI01DeployementDetailsWithHTMLContent -ComputeManagedDisksAPI01DeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.computeManagedDisksAPI02DeploymentName -eq 'ComputeManagedDisks-API02-Deployment'){
				
				$computeManagedDisksAPI02HTMLContent=ComputeManagedDisksAPI02DeploymentDetailsWithHTMLContent -ComputeManagedDisksAPI02DeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.computeManagedDisksAPI03DeploymentName -eq 'ComputeManagedDisks-API03-Deployment'){
				
				$computeManagedDisksAPI03HTMLContent=ComputeManagedDisksAPI03DeploymentDetailsWithHTMLContent -ComputeManagedDisksAPI03DeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.computeManagedDisksDbs01DeploymentName -eq 'ComputeManagedDisks-Dbs01-Deployment'){
				
				$computeManagedDisksDbs01HTMLContent=ComputeManagedDisksDbs01DeploymentDetailsWithHTMLContent -ComputeManagedDisksDbs01DeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.computeManagedDisksHyb01DeploymentName -eq 'ComputeManagedDisks-Hyb01-Deployment'){
				
				$computeManagedDisksHyb01HTMLContent=ComputeManagedDisksHyb01DeploymentDetailsWithHTMLContent -ComputeManagedDisksHyb01DeploymentDetails $deploymentOutput
			}
			if($deploymentOutput.computeManagedDisksSlr01DeploymentName -eq 'ComputeManagedDisks-Slr01-Deployment'){
				
				$computeManagedDisksSlr01HTMLContent=ComputeManagedDisksSlr01DeploymentDetailsWithHTMLContent -ComputeManagedDisksSlr01DeploymentDetails $deploymentOutput
			}

		}
			#Enter the send grid password Note: this is not recommended for production. In production, the password should be encrypted
			$SecurePassword=ConvertTo-SecureString $sendgridPassword –asplaintext –force 
			$cred = New-Object System.Management.Automation.PsCredential($sendgridUsername,$SecurePassword)
			$sub="DCTOMS Application $environmentName Infrastructure Details"
			$body="<html>
						<head>
							<style>
								table {
									border-collapse: collapse;
									border: 1px solid #dddddd;
								}

								td, th {
									border: 1px solid #dddddd;
									text-align: left;
									padding: 8px;
								}
							</style>
						</head>
						<body style='color: #000000; background-color: #ffffff; font-size: 20px; font-family: Arial, Helvetica, sans-serif'>
							Dear Developers Team,
							<p>Your request for creating new application infrastructure was completed.</p>
							<p>DCTOMS Application $environmentName Infrastructure Details:</p>
							<p style='white-space:pre;word-wrap: break-word;overflow: hidden;'></p>
							<p>$logAnalyticsHTMLContent</p></br>
							<p>$serviceBusHTMLContent</p></br>
							<p>$storageAccountHTMLContent</p></br>
							<p>$storageAccountAPIHTMLContent</p></br>
							<p>$storageAccountDbsHTMLContent</p></br>
							<p>$storageAccounthybrisHTMLContent</p></br>
							<p>$keyVaultHTMLContent</p></br>
							<p>$sqlServerHTMLContent</p></br>
							<p>$nsgAPIHTMLContent</p></br>
							<p>$nsgDataHTMLContent</p></br>
							<p>$nsghybHTMLContent</p></br>
							<p>$udrHTMLContent</p></br>
							<p>$subnetsHTMLContent</p></br>
							<p>$computeManagedDisksAPI01HTMLContent</p></br>
							<p>$computeManagedDisksAPI02HTMLContent</p></br>
							<p>$computeManagedDisksAPI03HTMLContent</p></br>
							<p>$computeManagedDisksDbs01HTMLContent</p></br>
							<p>$computeManagedDisksHyb01HTMLContent</p></br>
							<p>$computeManagedDisksSlr01HTMLContent</p></br>
							<p>Thank you </br> Your DevopsTeam</p>
						</body>
					</html>"
				
			$From = "c001543@footlocker.com"
			Send-MailMessage -From $From -To $To -Cc $Cc -Subject $sub -Body $body -Priority High -SmtpServer "smtp.sendgrid.net" -Credential $cred -UseSsl -Port 587 -BodyAsHtml
			Write-Host "Successfully send email to application development team."
	   }
	}
#endregion

#region MainScript

	#******************************************************************************
	# Script body
	# Execution begins here
	#******************************************************************************
	$ErrorActionPreference = "Stop"

	# sign in
	Write-Host "Logging in...";
	#Login-AzureRmAccount;
	$SecurePassword = $clientSecret | ConvertTo-SecureString -AsPlainText -Force
	$cred = new-object -typename System.Management.Automation.PSCredential `
		 -argumentlist $clientId, $SecurePassword

	Add-AzureRmAccount -Credential $cred -Tenant $tenantId -ServicePrincipal
	# set azure context with  subscriptionId
	Set-AzureRmContext -SubscriptionID $subscriptionId
	# select subscription
	Write-Host "Selecting subscription '$subscriptionId'";
	Select-AzureRmSubscription -SubscriptionID $subscriptionId;
	Write-Host "Starting to get the recent deployment details";
	
	. $universalFunctionsFilePath
	$deploymentDetails=Retreive-RecentDeploymentDetails -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -subscriptionId $subscriptionId -resourceGroupName $resourceGroupName 
	if($deploymentDetails -ne 'null'){
		Send-Email -To $toEmailAddress -Cc $ccEmailAddress -DeploymentDetails $deploymentDetails
	}
	
#endregion