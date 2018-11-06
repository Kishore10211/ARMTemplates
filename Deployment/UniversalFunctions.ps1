#
# UniversalFunctions.ps1
#

##This deployment script is intended for use in getting the recent deployment details.

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
#>

#region subfunctions

	#by using this function you can get the recent deployment details
	function Retreive-RecentDeploymentDetails{
		
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[string]
			$clientId,
	   
			[Parameter(Mandatory=$True,Position=1)]
			[string]
			$clientSecret,
	   
			[Parameter(Mandatory=$True,Position=2)]
			[string]
			$tenantId,
	   
			[Parameter(Mandatory=$True,Position=3)]
			[string]
			$subscriptionId,

			[Parameter(Mandatory=$True,Position=4)]
			[string]$resourceGroupName
		)

		#region Login in to Azure

		$ErrorActionPreference = "Stop"

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

		#endregion
		$deployments=Get-AzureRmResourceGroupDeployment -ResourceGroupName  $resourceGroupName | Sort Timestamp -Descending
		$deploymentOutputDetails = [System.Collections.ArrayList]@()
		foreach($deployment in $deployments){

			if($deployment.DeploymentName -eq 'LogAnalytics-Deployment'){
				$LogAnalytics = new-object PSObject
  				$LogAnalytics | add-member -type NoteProperty -Name logAnalyticsResourceGroupName -Value $deployment.ResourceGroupName
  				$LogAnalytics | add-member -type NoteProperty -Name logAnalyticsDeploymentName -Value $deployment.DeploymentName
  				$LogAnalytics | add-member -type NoteProperty -Name logAnalyticsPState -Value $deployment.ProvisioningState
  				$LogAnalytics | add-member -type NoteProperty -Name logAnalyticsTimeStamp -Value $deployment.TimeStamp
				$LogAnalytics | add-member -type NoteProperty -Name logAnalyticsDeploymentMode -Value $deployment.Mode
				$LogAnalytics | add-member -type NoteProperty -Name omsWorkspaceName -Value $deployment.Outputs.workspaceName.Value.ToString()
  				$LogAnalytics | add-member -type NoteProperty -Name omsPricingTier -Value $deployment.Outputs.pricingTier.Value.ToString()
  				$LogAnalytics | add-member -type NoteProperty -Name omsPortalUrl -Value $deployment.Outputs.portalUrl.Value.ToString()
				$deploymentOutputDetails.Add($LogAnalytics);
			}
			if($deployment.DeploymentName -eq 'ServiceBus-Deployment'){		
				$ServiceBus = new-object PSObject
				$ServiceBus | add-member -type NoteProperty -Name serviceBusResourceGroupName -Value $deployment.ResourceGroupName
				$ServiceBus | add-member -type NoteProperty -Name serviceBusDeploymentName -Value $deployment.DeploymentName
				$ServiceBus | add-member -type NoteProperty -Name serviceBusPState -Value $deployment.ProvisioningState
				$ServiceBus | add-member -type NoteProperty -Name serviceBusTimeStamp -Value $deployment.TimeStamp
			  	$ServiceBus | add-member -type NoteProperty -Name serviceBusDeploymentMode -Value $deployment.Mode
			  	$ServiceBus | add-member -type NoteProperty -Name serviceBusNamespaceName -Value $deployment.Outputs.serviceBusNamespaceName.Value.ToString()
				$ServiceBus | add-member -type NoteProperty -Name namespaceConnectionString -Value $deployment.Outputs.namespaceConnectionString.Value.ToString()
				$ServiceBus | add-member -type NoteProperty -Name sharedAccessPolicyPrimaryKey -Value $deployment.Outputs.sharedAccessPolicyPrimaryKey.Value.ToString()
			  	$deploymentOutputDetails.Add($ServiceBus);
			}	
			if($deployment.DeploymentName -eq 'StorageAccount-Deployment'){
				$StorageAccount = new-object PSObject
				$StorageAccount | add-member -type NoteProperty -Name storageAccountResourceGroupName -Value $deployment.ResourceGroupName
				$StorageAccount | add-member -type NoteProperty -Name storageAccountDeploymentName -Value $deployment.DeploymentName
				$StorageAccount | add-member -type NoteProperty -Name storageAccountPState -Value $deployment.ProvisioningState
				$StorageAccount | add-member -type NoteProperty -Name storageAccountTimeStamp -Value $deployment.TimeStamp
				$StorageAccount | add-member -type NoteProperty -Name storageAccountDeploymentMode -Value $deployment.Mode
				$StorageAccount | add-member -type NoteProperty -Name storageAccountName -Value $deployment.Outputs.storageAccountName.Value.ToString()
				$deploymentOutputDetails.Add($StorageAccount);
			}
			if($deployment.DeploymentName -eq 'StorageAccount-API-Deployment'){
				$StorageAccountAPI = new-object PSObject
				$StorageAccountAPI | add-member -type NoteProperty -Name storageAccountAPIResourceGroupName -Value $deployment.ResourceGroupName				
				$StorageAccountAPI | add-member -type NoteProperty -Name storageAccountAPIDeploymentName -Value $deployment.DeploymentName
				$StorageAccountAPI | add-member -type NoteProperty -Name storageAccountAPIPState -Value $deployment.ProvisioningState
				$StorageAccountAPI | add-member -type NoteProperty -Name storageAccountAPITimeStamp -Value $deployment.TimeStamp
				$StorageAccountAPI | add-member -type NoteProperty -Name storageAccountAPIDeploymentMode -Value $deployment.Mode
				$StorageAccountAPI | add-member -type NoteProperty -Name storageAccountAPIName -Value $deployment.Outputs.storageAccountName.Value.ToString()
				$deploymentOutputDetails.Add($StorageAccountAPI);
			}if($deployment.DeploymentName -eq 'StorageAccount-Dbs-Deployment'){
				$StorageAccountDbs= new-object PSObject
				$StorageAccountDbs | add-member -type NoteProperty -Name storageAccountDbsResourceGroupName -Value $deployment.ResourceGroupName			
				$StorageAccountDbs | add-member -type NoteProperty -Name storageAccountDbsDeploymentName -Value $deployment.DeploymentName
				$StorageAccountDbs | add-member -type NoteProperty -Name storageAccountDbsPState -Value $deployment.ProvisioningState
				$StorageAccountDbs | add-member -type NoteProperty -Name storageAccountDbsTimeStamp -Value $deployment.TimeStamp
				$StorageAccountDbs | add-member -type NoteProperty -Name storageAccountDbsDeploymentMode -Value $deployment.Mode
				$StorageAccountDbs | add-member -type NoteProperty -Name storageAccountDbsName -Value $deployment.Outputs.storageAccountName.Value.ToString()
				$deploymentOutputDetails.Add($StorageAccountDbs);
			}	
			if($deployment.DeploymentName -eq 'StorageAccount-Hybris-Deployment'){
				$StorageAccountHybris= new-object PSObject
				$StorageAccountHybris | add-member -type NoteProperty -Name storageAccountHybrisResourceGroupName -Value $deployment.ResourceGroupName				
				$StorageAccountHybris | add-member -type NoteProperty -Name storageAccountHybrisDeploymentName -Value $deployment.DeploymentName
				$StorageAccountHybris | add-member -type NoteProperty -Name storageAccountHybrisPState -Value $deployment.ProvisioningState
				$StorageAccountHybris | add-member -type NoteProperty -Name storageAccountHybrisTimeStamp -Value $deployment.TimeStamp
				$StorageAccountHybris | add-member -type NoteProperty -Name storageAccountHybrisDeploymentMode -Value $deployment.Mode
				$StorageAccountHybris | add-member -type NoteProperty -Name storageAccountHybrisName -Value $deployment.Outputs.storageAccountName.Value.ToString()
				$deploymentOutputDetails.Add($StorageAccountHybris);
			}
			if($deployment.DeploymentName -eq 'KeyVault-Deployment'){
				$KeyVault= new-object PSObject
				$KeyVault | add-member -type NoteProperty -Name keyVaultResourceGroupName -Value $deployment.ResourceGroupName				
				$KeyVault | add-member -type NoteProperty -Name keyVaultDeploymentName -Value $deployment.DeploymentName
				$KeyVault | add-member -type NoteProperty -Name keyVaultPState -Value $deployment.ProvisioningState
				$KeyVault | add-member -type NoteProperty -Name keyVaultTimeStamp -Value $deployment.TimeStamp
				$KeyVault | add-member -type NoteProperty -Name keyVaultDeploymentMode -Value $deployment.Mode
				$KeyVault | add-member -type NoteProperty -Name keyVaultUri -Value $deployment.Outputs.keyVaultUri.Value.ToString()
				$deploymentOutputDetails.Add($KeyVault);
			}
			if($deployment.DeploymentName -eq 'AzureSQL-Deployment'){
				$SQLServer= new-object PSObject
				$SQLServer | add-member -type NoteProperty -Name sqlServerResourceGroupName -Value $deployment.ResourceGroupName				
				$SQLServer | add-member -type NoteProperty -Name sqlServerDeploymentName -Value $deployment.DeploymentName
				$SQLServer | add-member -type NoteProperty -Name sqlServerPState -Value $deployment.ProvisioningState
				$SQLServer | add-member -type NoteProperty -Name sqlServerTimeStamp -Value $deployment.TimeStamp
				$SQLServer | add-member -type NoteProperty -Name sqlServerDeploymentMode -Value $deployment.Mode
				$SQLServer | add-member -type NoteProperty -Name sqlServerFqdn -Value $deployment.Outputs.sqlServerFqdn.Value.ToString()
				$SQLServer | add-member -type NoteProperty -Name databaseName -Value $deployment.Outputs.databaseName.Value.ToString()
				$deploymentOutputDetails.Add($SQLServer);
			}
			if($deployment.DeploymentName -eq 'Nsg-API-Deployment'){
				$NsgAPI= new-object PSObject
				$NsgAPI | add-member -type NoteProperty -Name nsgAPIResourceGroupName -Value $deployment.ResourceGroupName				
				$NsgAPI | add-member -type NoteProperty -Name nsgAPIDeploymentName -Value $deployment.DeploymentName
				$NsgAPI | add-member -type NoteProperty -Name nsgAPIPState -Value $deployment.ProvisioningState
				$NsgAPI | add-member -type NoteProperty -Name nsgAPITimeStamp -Value $deployment.TimeStamp
				$NsgAPI | add-member -type NoteProperty -Name nsgAPIDeploymentMode -Value $deployment.Mode
				$NsgAPI | add-member -type NoteProperty -Name nsgAPIId -Value $deployment.Outputs.nsgId.Value.ToString()
				$NsgAPI | add-member -type NoteProperty -Name nsgAPIGroupName -Value $deployment.Outputs.nsgGroupName.Value.ToString()
				$deploymentOutputDetails.Add($NsgAPI);
			}	
			if($deployment.DeploymentName -eq 'Nsg-Data-Deployment'){
				$NsgData= new-object PSObject
				$NsgData | add-member -type NoteProperty -Name nsgDataResourceGroupName -Value $deployment.ResourceGroupName				
				$NsgData | add-member -type NoteProperty -Name nsgDataDeploymentName -Value $deployment.DeploymentName
				$NsgData | add-member -type NoteProperty -Name nsgDataPState -Value $deployment.ProvisioningState
				$NsgData | add-member -type NoteProperty -Name nsgDataTimeStamp -Value $deployment.TimeStamp
				$NsgData | add-member -type NoteProperty -Name nsgDataDeploymentMode -Value $deployment.Mode
				$NsgData | add-member -type NoteProperty -Name nsgDataId -Value $deployment.Outputs.nsgId.Value.ToString()
				$NsgData | add-member -type NoteProperty -Name nsgDataGroupName -Value $deployment.Outputs.nsgGroupName.Value.ToString()
				$deploymentOutputDetails.Add($NsgData);
			}	
			if($deployment.DeploymentName -eq 'Nsg-Hyb-Deployment'){
				$NsgHyb= new-object PSObject
				$NsgHyb | add-member -type NoteProperty -Name nsgHybResourceGroupName -Value $deployment.ResourceGroupName				
				$NsgHyb | add-member -type NoteProperty -Name nsgHybDeploymentName -Value $deployment.DeploymentName
				$NsgHyb | add-member -type NoteProperty -Name nsgHybPState -Value $deployment.ProvisioningState
				$NsgHyb | add-member -type NoteProperty -Name nsgHybTimeStamp -Value $deployment.TimeStamp
				$NsgHyb | add-member -type NoteProperty -Name nsgHybDeploymentMode -Value $deployment.Mode
				$NsgHyb | add-member -type NoteProperty -Name nsgHybId -Value $deployment.Outputs.nsgId.Value.ToString()
				$NsgHyb | add-member -type NoteProperty -Name nsgHybGroupName -Value $deployment.Outputs.nsgGroupName.Value.ToString()
				$deploymentOutputDetails.Add($NsgHyb);
			}		
			if($deployment.DeploymentName -eq 'Udr-Deployment'){
				$Udr= new-object PSObject
				$Udr | add-member -type NoteProperty -Name udrResourceGroupName -Value $deployment.ResourceGroupName				
				$Udr | add-member -type NoteProperty -Name udrDeploymentName -Value $deployment.DeploymentName
				$Udr | add-member -type NoteProperty -Name udrPState -Value $deployment.ProvisioningState
				$Udr | add-member -type NoteProperty -Name udrTimeStamp -Value $deployment.TimeStamp
				$Udr | add-member -type NoteProperty -Name udrDeploymentMode -Value $deployment.Mode
				$Udr | add-member -type NoteProperty -Name udrRouteTableName -Value $deployment.Outputs.routeTableName.Value.ToString()
				$deploymentOutputDetails.Add($Udr);
			}		
			if($deployment.DeploymentName -eq 'Subnets-With-Nsg-Udr-Deployment'){
				$SubnetsWithNsgUdr= new-object PSObject
				$SubnetsWithNsgUdr | add-member -type NoteProperty -Name subnetsWithNsgUdrResourceGroupName -Value $deployment.ResourceGroupName			
				$SubnetsWithNsgUdr | add-member -type NoteProperty -Name subnetsWithNsgUdrDeploymentName -Value $deployment.DeploymentName
				$SubnetsWithNsgUdr | add-member -type NoteProperty -Name subnetsWithNsgUdrPState -Value $deployment.ProvisioningState
				$SubnetsWithNsgUdr | add-member -type NoteProperty -Name subnetsWithNsgUdrTimeStamp -Value $deployment.TimeStamp
				$SubnetsWithNsgUdr | add-member -type NoteProperty -Name subnetsWithNsgUdrDeploymentMode -Value $deployment.Mode
				$SubnetsWithNsgUdr | add-member -type NoteProperty -Name subnetsWithNsgUdrResult -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($SubnetsWithNsgUdr);
			}
			if($deployment.DeploymentName -eq 'ComputeManagedDisks-API01-Deployment'){
				$ComputeManagedDisksAPI01= new-object PSObject
				$ComputeManagedDisksAPI01 | add-member -type NoteProperty -Name computeManagedDisksAPI01ResourceGroupName -Value $deployment.ResourceGroupName				
				$ComputeManagedDisksAPI01 | add-member -type NoteProperty -Name computeManagedDisksAPI01DeploymentName -Value $deployment.DeploymentName
				$ComputeManagedDisksAPI01 | add-member -type NoteProperty -Name computeManagedDisksAPI01PState -Value $deployment.ProvisioningState
				$ComputeManagedDisksAPI01 | add-member -type NoteProperty -Name computeManagedDisksAPI01TimeStamp -Value $deployment.TimeStamp
				$ComputeManagedDisksAPI01 | add-member -type NoteProperty -Name computeManagedDisksAPI01DeploymentMode -Value $deployment.Mode
				$ComputeManagedDisksAPI01 | add-member -type NoteProperty -Name computeManagedDisksAPI01Result -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($ComputeManagedDisksAPI01);
			}	
			if($deployment.DeploymentName -eq 'ComputeManagedDisks-API02-Deployment'){
				$ComputeManagedDisksAPI02= new-object PSObject
				$ComputeManagedDisksAPI02 | add-member -type NoteProperty -Name computeManagedDisksAPI02ResourceGroupName -Value $deployment.ResourceGroupName				
				$ComputeManagedDisksAPI02 | add-member -type NoteProperty -Name computeManagedDisksAPI02DeploymentName -Value $deployment.DeploymentName
				$ComputeManagedDisksAPI02 | add-member -type NoteProperty -Name computeManagedDisksAPI02PState -Value $deployment.ProvisioningState
				$ComputeManagedDisksAPI02 | add-member -type NoteProperty -Name computeManagedDisksAPI02TimeStamp -Value $deployment.TimeStamp
				$ComputeManagedDisksAPI02 | add-member -type NoteProperty -Name computeManagedDisksAPI02DeploymentMode -Value $deployment.Mode
				$ComputeManagedDisksAPI02 | add-member -type NoteProperty -Name computeManagedDisksAPI02Result -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($ComputeManagedDisksAPI02);
			}	
			if($deployment.DeploymentName -eq 'ComputeManagedDisks-API03-Deployment'){
				$ComputeManagedDisksAPI03= new-object PSObject
				$ComputeManagedDisksAPI03 | add-member -type NoteProperty -Name computeManagedDisksAPI03ResourceGroupName -Value $deployment.ResourceGroupName			
				$ComputeManagedDisksAPI03 | add-member -type NoteProperty -Name computeManagedDisksAPI03DeploymentName -Value $deployment.DeploymentName
				$ComputeManagedDisksAPI03 | add-member -type NoteProperty -Name computeManagedDisksAPI03PState -Value $deployment.ProvisioningState
				$ComputeManagedDisksAPI03 | add-member -type NoteProperty -Name computeManagedDisksAPI03TimeStamp -Value $deployment.TimeStamp
				$ComputeManagedDisksAPI03 | add-member -type NoteProperty -Name computeManagedDisksAPI03DeploymentMode -Value $deployment.Mode
				$ComputeManagedDisksAPI03 | add-member -type NoteProperty -Name computeManagedDisksAPI03Result -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($ComputeManagedDisksAPI03);
			}
			if($deployment.DeploymentName -eq 'ComputeManagedDisks-Dbs01-Deployment'){
				$ComputeManagedDisksDbs01= new-object PSObject
				$ComputeManagedDisksDbs01 | add-member -type NoteProperty -Name computeManagedDisksDbs01ResourceGroupName -Value $deployment.ResourceGroupName				
				$ComputeManagedDisksDbs01 | add-member -type NoteProperty -Name computeManagedDisksDbs01DeploymentName -Value $deployment.DeploymentName
				$ComputeManagedDisksDbs01 | add-member -type NoteProperty -Name computeManagedDisksDbs01PState -Value $deployment.ProvisioningState
				$ComputeManagedDisksDbs01 | add-member -type NoteProperty -Name computeManagedDisksDbs01TimeStamp -Value $deployment.TimeStamp
				$ComputeManagedDisksDbs01 | add-member -type NoteProperty -Name computeManagedDisksDbs01DeploymentMode -Value $deployment.Mode
				$ComputeManagedDisksDbs01 | add-member -type NoteProperty -Name computeManagedDisksDbs01Result -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($ComputeManagedDisksDbs01);
			}
			if($deployment.DeploymentName -eq 'ComputeManagedDisks-Hyb01-Deployment'){
				$ComputeManagedDisksHyb01= new-object PSObject
				$ComputeManagedDisksHyb01 | add-member -type NoteProperty -Name computeManagedDisksHyb01ResourceGroupName -Value $deployment.ResourceGroupName				
				$ComputeManagedDisksHyb01 | add-member -type NoteProperty -Name computeManagedDisksHyb01DeploymentName -Value $deployment.DeploymentName
				$ComputeManagedDisksHyb01 | add-member -type NoteProperty -Name computeManagedDisksHyb01PState -Value $deployment.ProvisioningState
				$ComputeManagedDisksHyb01 | add-member -type NoteProperty -Name computeManagedDisksHyb01TimeStamp -Value $deployment.TimeStamp
				$ComputeManagedDisksHyb01 | add-member -type NoteProperty -Name computeManagedDisksHyb01DeploymentMode -Value $deployment.Mode
				$ComputeManagedDisksHyb01 | add-member -type NoteProperty -Name computeManagedDisksHyb01Result -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($ComputeManagedDisksHyb01);
			}
			if($deployment.DeploymentName -eq 'ComputeManagedDisks-Slr01-Deployment'){
				$ComputeManagedDisksSlr01= new-object PSObject
				$ComputeManagedDisksSlr01 | add-member -type NoteProperty -Name computeManagedDisksSlr01ResourceGroupName -Value $deployment.ResourceGroupName				
				$ComputeManagedDisksSlr01 | add-member -type NoteProperty -Name computeManagedDisksSlr01DeploymentName -Value $deployment.DeploymentName
				$ComputeManagedDisksSlr01 | add-member -type NoteProperty -Name computeManagedDisksSlr01PState -Value $deployment.ProvisioningState
				$ComputeManagedDisksSlr01 | add-member -type NoteProperty -Name computeManagedDisksSlr01TimeStamp -Value $deployment.TimeStamp
				$ComputeManagedDisksSlr01 | add-member -type NoteProperty -Name computeManagedDisksSlr01DeploymentMode -Value $deployment.Mode
				$ComputeManagedDisksSlr01 | add-member -type NoteProperty -Name computeManagedDisksSlr01Result -Value $deployment.Outputs.result.Value.ToString()
				$deploymentOutputDetails.Add($ComputeManagedDisksSlr01);
			}
		}
		return $deploymentOutputDetails	
	} 

	#by using this function you can get the recent deployment details of LogAnalytics with HTML content
	function LogAnalyticsDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$logAnalyticsDeploymentDetails
		)
		$logAnalyticsContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($logAnalyticsDeploymentDetails.omsWorkspaceName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($logAnalyticsDeploymentDetails.logAnalyticsResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($logAnalyticsDeploymentDetails.logAnalyticsDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($logAnalyticsDeploymentDetails.logAnalyticsPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($logAnalyticsDeploymentDetails.logAnalyticsTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($logAnalyticsDeploymentDetails.logAnalyticsDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>OMSWorkspaceName:</b></td>
										<td>$($logAnalyticsDeploymentDetails.omsWorkspaceName)</td>
									</tr>
									<tr>
										<td><b>PricingTier:</b></td>
										<td>$($logAnalyticsDeploymentDetails.omsPricingTier)</td>
									</tr>
									<tr>
										<td><b>OMS Portal URL:</b></td>
										<td>$($logAnalyticsDeploymentDetails.omsPortalUrl)</td>
									</tr>
								</table>"
		return $logAnalyticsContent
	}
	#by using this function you can get the recent deployment details of ServiceBus with HTML content
	function ServiceBusDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$servicebusDeploymentDetails
		)
		$serviceBusHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($servicebusDeploymentDetails.serviceBusNamespaceName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($servicebusDeploymentDetails.serviceBusResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($servicebusDeploymentDetails.serviceBusDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($servicebusDeploymentDetails.serviceBusPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($servicebusDeploymentDetails.serviceBusTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($servicebusDeploymentDetails.serviceBusDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>ServiceBusNamespaceName:</b></td>
										<td>$($servicebusDeploymentDetails.serviceBusNamespaceName)</td>
									</tr>
									<tr>
										<td><b>NamespaceConnectionString:</b></td>
										<td>$($servicebusDeploymentDetails.namespaceConnectionString)</td>
									</tr>
									<tr>
										<td><b>SharedAccessPolicyPrimaryKey:</b></td>
										<td>$($servicebusDeploymentDetails.sharedAccessPolicyPrimaryKey)</td>
									</tr>
								</table>"
		return $serviceBusHtmlContent
	}
	#by using this function you can get the recent deployment details of StorageAccount with HTML content
	function StorageAccountDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$storageAccountDeploymentDetails
		)
		$storageAccountHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($storageAccountDeploymentDetails.storageAccountName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($storageAccountDeploymentDetails.storageAccountResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($storageAccountDeploymentDetails.storageAccountDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($storageAccountDeploymentDetails.storageAccountPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($storageAccountDeploymentDetails.storageAccountTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($storageAccountDeploymentDetails.storageAccountDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Storage Account Name:</b></td>
										<td>$($storageAccountDeploymentDetails.storageAccountName)</td>
									</tr>
								</table>"
		return $storageAccountHtmlContent
	}
	#by using this function you can get the recent deployment details of StorageAccountAPI with HTML content
	function StorageAccountAPIDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$storageAccountAPIDeploymentDetails
		)
		$storageAccountAPIHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($storageAccountAPIDeploymentDetails.storageAccountAPIName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($storageAccountAPIDeploymentDetails.storageAccountAPIResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($storageAccountAPIDeploymentDetails.storageAccountAPIDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($storageAccountAPIDeploymentDetails.storageAccountAPIPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($storageAccountAPIDeploymentDetails.storageAccountAPITimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($storageAccountAPIDeploymentDetails.storageAccountAPIDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Storage Account Name:</b></td>
										<td>$($storageAccountAPIDeploymentDetails.storageAccountAPIName)</td>
									</tr>
								</table>"
		return $storageAccountAPIHtmlContent
	}
	#by using this function you can get the recent deployment details of StorageAccountDbs with HTML content
	function StorageAccountDbsDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$storageAccountDbsDeploymentDetails
		)
		$storageAccountDbsHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($storageAccountDbsDeploymentDetails.storageAccountDbsName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($storageAccountDbsDeploymentDetails.storageAccountDbsResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($storageAccountDbsDeploymentDetails.storageAccountDbsDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($storageAccountDbsDeploymentDetails.storageAccountDbsPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($storageAccountDbsDeploymentDetails.storageAccountDbsTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($storageAccountDbsDeploymentDetails.storageAccountDbsDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Storage Account Name:</b></td>
										<td>$($storageAccountDbsDeploymentDetails.storageAccountDbsName)</td>
									</tr>
								</table>"
		return $storageAccountDbsHtmlContent
	}
	#by using this function you can get the recent deployment details of StorageAccountHybris with HTML content
	function StorageAccountHybrisDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$storageAccountHybrisDeploymentDetails
		)
		$storageAccountHybrisHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($storageAccountHybrisDeploymentDetails.storageAccountHybrisName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($storageAccountHybrisDeploymentDetails.storageAccountHybrisResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($storageAccountHybrisDeploymentDetails.storageAccountHybrisDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($storageAccountHybrisDeploymentDetails.storageAccountHybrisPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($storageAccountHybrisDeploymentDetails.storageAccountHybrisTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($storageAccountHybrisDeploymentDetails.storageAccountHybrisDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Storage Account Name:</b></td>
										<td>$($storageAccountHybrisDeploymentDetails.storageAccountHybrisName)</td>
									</tr>
								</table>"
		return $storageAccountHybrisHtmlContent
	}
	#by using this function you can get the recent deployment details of KeyVault with HTML content
	function KeyVaultDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$keyVaultDeploymentDetails
		)
		$keyVaultHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : KeyVault</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($keyVaultDeploymentDetails.keyVaultResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($keyVaultDeploymentDetails.keyVaultDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($keyVaultDeploymentDetails.keyVaultPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($keyVaultDeploymentDetails.keyVaultTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($keyVaultDeploymentDetails.keyVaultDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>KeyVault URI:</b></td>
										<td>$($keyVaultDeploymentDetails.keyVaultUri)</td>
									</tr>
								</table>"
		return $keyVaultHtmlContent
	}
	#by using this function you can get the recent deployment details of SQLServer with HTML content
	function SQLServerDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$sqlServerDeploymentDetails
		)
		$sqlServerHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($sqlServerDeploymentDetails.databaseName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($sqlServerDeploymentDetails.sqlServerResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($sqlServerDeploymentDetails.sqlServerDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($sqlServerDeploymentDetails.sqlServerPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($sqlServerDeploymentDetails.sqlServerTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($sqlServerDeploymentDetails.sqlServerDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>SQLServerName:</b></td>
										<td>$($sqlServerDeploymentDetails.sqlServerFqdn)</td>
									</tr>
									<tr>
										<td><b>DatabaseName:</b></td>
										<td>$($sqlServerDeploymentDetails.databaseName)</td>
									</tr>
								</table>"
		return $sqlServerHtmlContent
	}
	#by using this function you can get the recent deployment details of NSG-API with HTML content
	function NsgAPIDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$NsgAPIDeploymentDetails
		)
		$NsgAPIHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($NsgAPIDeploymentDetails.serviceBusNamespaceName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPIResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPIDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPIPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPITimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPIDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>NSGAPI Id:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPIId)</td>
									</tr>
									<tr>
										<td><b>NSG API Group Name:</b></td>
										<td>$($NsgAPIDeploymentDetails.nsgAPIGroupName)</td>
									</tr>
								</table>"
		return $NsgAPIHtmlContent
	}
	#by using this function you can get the recent deployment details of NSG-Data with HTML content
	function NsgDataDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$NsgDataDeploymentDetails
		)
		$NsgDataHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($NsgDataDeploymentDetails.nsgDataGroupName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>NSGData Id:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataId)</td>
									</tr>
									<tr>
										<td><b>NSG Data Group Name:</b></td>
										<td>$($NsgDataDeploymentDetails.nsgDataGroupName)</td>
									</tr>
								</table>"
		return $NsgDataHtmlContent
	}
	#by using this function you can get the recent deployment details of NSG-Hybris with HTML content
	function NsgHybDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$NsgHybDeploymentDetails
		)
		$NsgHybHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : $($NsgHybDeploymentDetails.nsgHybGroupName)</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>NSGHyb Id:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybId)</td>
									</tr>
									<tr>
										<td><b>NSG Hyb Group Name:</b></td>
										<td>$($NsgHybDeploymentDetails.nsgHybGroupName)</td>
									</tr>
								</table>"
		return $NsgHybHtmlContent
	}
	#by using this function you can get the recent deployment details of UDR with HTML content
	function UdrDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$udrDeploymentDetails
		)
		$udrHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : RouteTable</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($udrDeploymentDetails.udrResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($udrDeploymentDetails.udrDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($udrDeploymentDetails.udrPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($udrDeploymentDetails.udrTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($udrDeploymentDetails.udrDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Route Table Name:</b></td>
										<td>$($udrDeploymentDetails.udrRouteTableName)</td>
									</tr>
								</table>"
		return $udrHtmlContent
	}
	#by using this function you can get the recent deployment details of Subnets with HTML content
	function SubnetsWithNsgAndUDrDeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$subnetsDeploymentDetails
		)
		$subnetsHtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Subnet</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($subnetsDeploymentDetails.subnetsWithNsgUdrResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($subnetsDeploymentDetails.subnetsWithNsgUdrDeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($subnetsDeploymentDetails.subnetsWithNsgUdrPState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($subnetsDeploymentDetails.subnetsWithNsgUdrTimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($subnetsDeploymentDetails.subnetsWithNsgUdrDeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($subnetsDeploymentDetails.subnetsWithNsgUdrResult)</td>
									</tr>
								</table>"
		return $subnetsHtmlContent
	}
	#by using this function you can get the recent deployment details of ComputeManagedDisksAPI01 with HTML content
	function ComputeManagedDisksAPI01DeployementDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$ComputeManagedDisksAPI01DeploymentDetails
		)
		$ComputeManagedDisksAPI01HtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Virtualmachine-API01</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($ComputeManagedDisksAPI01DeploymentDetails.computeManagedDisksAPI01ResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($ComputeManagedDisksAPI01DeploymentDetails.computeManagedDisksAPI01DeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($ComputeManagedDisksAPI01DeploymentDetails.computeManagedDisksAPI01PState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($ComputeManagedDisksAPI01DeploymentDetails.computeManagedDisksAPI01TimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($ComputeManagedDisksAPI01DeploymentDetails.computeManagedDisksAPI01DeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($ComputeManagedDisksAPI01DeploymentDetails.computeManagedDisksAPI01Result)</td>
									</tr>
								</table>"
		return $ComputeManagedDisksAPI01HtmlContent
	}
	#by using this function you can get the recent deployment details of ComputeManagedDisksAPI02 with HTML content
	function ComputeManagedDisksAPI02DeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$ComputeManagedDisksAPI02DeploymentDetails
		)
		$ComputeManagedDisksAPI02HtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Virtualmachine-API02</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($ComputeManagedDisksAPI02DeploymentDetails.computeManagedDisksAPI02ResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($ComputeManagedDisksAPI02DeploymentDetails.computeManagedDisksAPI02DeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($ComputeManagedDisksAPI02DeploymentDetails.computeManagedDisksAPI02PState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($ComputeManagedDisksAPI02DeploymentDetails.computeManagedDisksAPI02TimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($ComputeManagedDisksAPI02DeploymentDetails.computeManagedDisksAPI02DeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($ComputeManagedDisksAPI02DeploymentDetails.computeManagedDisksAPI02Result)</td>
									</tr>
								</table>"
		return $ComputeManagedDisksAPI02HtmlContent
	}
	#by using this function you can get the recent deployment details of ComputeManagedDisksAPI03 with HTML content
	function ComputeManagedDisksAPI03DeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$ComputeManagedDisksAPI03DeploymentDetails
		)
		$ComputeManagedDisksAPI03HtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Virtualmachine-API03</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($ComputeManagedDisksAPI03DeploymentDetails.computeManagedDisksAPI03ResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($ComputeManagedDisksAPI03DeploymentDetails.computeManagedDisksAPI03DeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($ComputeManagedDisksAPI03DeploymentDetails.computeManagedDisksAPI03PState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($ComputeManagedDisksAPI03DeploymentDetails.computeManagedDisksAPI03TimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($ComputeManagedDisksAPI03DeploymentDetails.computeManagedDisksAPI03DeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($ComputeManagedDisksAPI03DeploymentDetails.computeManagedDisksAPI03Result)</td>
									</tr>
								</table>"
		return $ComputeManagedDisksAPI03HtmlContent
	}
	#by using this function you can get the recent deployment details of ComputeManagedDisksDbs01 with HTML content
	function ComputeManagedDisksDbs01DeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$ComputeManagedDisksDbs01DeploymentDetails
		)
		$ComputeManagedDisksDbs01HtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Virtualmachine-Dbs01</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($ComputeManagedDisksDbs01DeploymentDetails.computeManagedDisksDbs01ResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($ComputeManagedDisksDbs01DeploymentDetails.computeManagedDisksDbs01DeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($ComputeManagedDisksDbs01DeploymentDetails.computeManagedDisksDbs01PState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($ComputeManagedDisksDbs01DeploymentDetails.computeManagedDisksDbs01TimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($ComputeManagedDisksDbs01DeploymentDetails.computeManagedDisksDbs01DeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($ComputeManagedDisksDbs01DeploymentDetails.computeManagedDisksDbs01Result)</td>
									</tr>
								</table>"
		return $ComputeManagedDisksDbs01HtmlContent
	}
	#by using this function you can get the recent deployment details of ComputeManagedDisksHyb01 with HTML content
	function ComputeManagedDisksHyb01DeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$ComputeManagedDisksHyb01DeploymentDetails
		)
		$ComputeManagedDisksHyb01HtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Virtualmachine-Hyb01</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($ComputeManagedDisksHyb01DeploymentDetails.computeManagedDisksHyb01ResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($ComputeManagedDisksHyb01DeploymentDetails.computeManagedDisksHyb01DeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($ComputeManagedDisksHyb01DeploymentDetails.computeManagedDisksHyb01PState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($ComputeManagedDisksHyb01DeploymentDetails.computeManagedDisksHyb01TimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($ComputeManagedDisksHyb01DeploymentDetails.computeManagedDisksHyb01DeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($ComputeManagedDisksHyb01DeploymentDetails.computeManagedDisksHyb01Result)</td>
									</tr>
								</table>"
		return $ComputeManagedDisksHyb01HtmlContent
	}
	#by using this function you can get the recent deployment details of ComputeManagedDisksSlr01 with HTML content
	function ComputeManagedDisksSlr01DeploymentDetailsWithHTMLContent{
		param(
			[Parameter(Mandatory=$True,Position=0)]
			[psobject]
			$ComputeManagedDisksSlr01DeploymentDetails
		)
		$ComputeManagedDisksSlr01HtmlContent="<table>
									<tr>
										<th colspan='2' style='background-color:lightgreen'>Resource Details : Virtualmachine-Slr01</th>
									</tr>
									<tr>
										<td><b>ResourceGroupName:</b></td>
										<td>$($ComputeManagedDisksSlr01DeploymentDetails.computeManagedDisksSlr01ResourceGroupName)</td>
									</tr>
									<tr>
										<td><b>DeploymentName:</b></td>
										<td>$($ComputeManagedDisksSlr01DeploymentDetails.computeManagedDisksSlr01DeploymentName)</td>
									</tr>
									<tr>
										<td><b>ProvisioningState:</b></td>
										<td>$($ComputeManagedDisksSlr01DeploymentDetails.computeManagedDisksSlr01PState)</td>
									</tr>
									<tr>
										<td><b>TimeStamp:</b></td>
										<td>$($ComputeManagedDisksSlr01DeploymentDetails.computeManagedDisksSlr01TimeStamp)</td>
									</tr>
									<tr>
										<td><b>Mode:</b></td>
										<td>$($ComputeManagedDisksSlr01DeploymentDetails.computeManagedDisksSlr01DeploymentMode)</td>
									</tr>
									<tr>
										<td><b>Result:</b></td>
										<td>$($ComputeManagedDisksSlr01DeploymentDetails.computeManagedDisksSlr01Result)</td>
									</tr>
								</table>"
		return $ComputeManagedDisksSlr01HtmlContent
	}
#endregion