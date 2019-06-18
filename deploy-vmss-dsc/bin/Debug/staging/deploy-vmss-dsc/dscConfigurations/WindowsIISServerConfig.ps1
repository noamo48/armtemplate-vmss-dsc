
<#PSScriptInfo

.VERSION 0.2.0

.GUID a38fa39f-f93d-4cf4-9e08-fa8f880e6187

.AUTHOR Michael Greene

.COMPANYNAME Microsoft

.COPYRIGHT 

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/WindowsIISServerConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/WindowsIISServerConfig

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/WindowsIISServerConfig/blob/master/README.md#releasenotes

.PRIVATEDATA 2016-Datacenter-Server-Core

#>

#Requires -Module @{modulename = 'xWebAdministration'; moduleversion = '2.4.0.0'}

<# 

.DESCRIPTION 
 PowerShell Desired State Configuration for deploying and configuring IIS Servers 

#> 

configuration WindowsIISServerConfig
{

	<# param
    (
		[Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
		$certPass
    ) #>

	Import-DscResource -ModuleName 'xWebAdministration'
	Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'
	Import-DscResource -ModuleName 'CertificateDsc'
	Import-DscResource -ModuleName 'PSDesiredStateConfiguration'	

	$certPass = Get-AutomationPSCredential 'PfxPassword'

	Node $AllNodes.NodeName
    {
		WindowsFeature WebServer
		{
			Ensure  = 'Present'
			Name    = 'Web-Server'
		}

		WindowsFeature WebManagement
		{
			Ensure  = 'Present'
			Name    = 'Web-Mgmt-Console'
			DependsOn = '[WindowsFeature]WebServer'
		}

		WindowsFeature WebASPNet47
		{
			Ensure  = 'Present'
			Name    = 'Web-Asp-Net45'
			DependsOn = '[WindowsFeature]WebServer'
		}

		WindowsFeature WebNetExt
		{
			Ensure  = 'Present'
			Name    = 'Web-Net-Ext45'
			DependsOn = '[WindowsFeature]WebServer'
		}

		# IIS Site Default Settings
		xWebSiteDefaults SiteDefaults
		{
			ApplyTo                 = 'Machine'
			LogFormat               = 'IIS'
			LogDirectory            = 'C:\inetpub\logs\LogFiles'
			TraceLogDirectory       = 'C:\inetpub\logs\FailedReqLogFiles'
			DefaultApplicationPool  = 'DefaultAppPool'
			AllowSubDirConfig       = 'true'
			DependsOn               = '[WindowsFeature]WebServer'
		}

		# IIS App Pool Default Settings
		xWebAppPoolDefaults PoolDefaults
		{
		   ApplyTo               = 'Machine'
		   ManagedRuntimeVersion = 'v4.0'
		   IdentityType          = 'ApplicationPoolIdentity'
		   DependsOn             = '[WindowsFeature]WebServer'
		}

		# Get SSL cert file from Azure Storage using SAS URI
		xRemoteFile CertPfx
		{
			Uri = "https://deployteststorage1.blob.core.windows.net/resources/wlidev.pfx?sp=r&st=2019-06-02T22:00:11Z&se=2019-07-03T06:00:11Z&spr=https&sv=2018-03-28&sig=w8b9%2FmpFq15oG%2BJwdnG4ggBNmDNLOXS0KILIoGEPY6w%3D&sr=b"
			DestinationPath = "C:\temp\wlidev.pfx"
		}
	
		# Import the PFX file which was downloaded to local path
		PfxImport ImportCertPFX
		{
			Ensure     = "Present"
			DependsOn  = "[xRemoteFile]CertPfx"
			Thumbprint = "b124bf740b256316bd7439f89140d6ff6dccf658"
			Path       = "c:\temp\wlidev.pfx"
			Location   = "LocalMachine"
			Store      = "WebHosting"
			Credential = $certPass
		}
	}
}