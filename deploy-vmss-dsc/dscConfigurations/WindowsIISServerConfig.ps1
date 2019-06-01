
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

Import-DscResource -ModuleName @{ModuleName = 'xWebAdministration';ModuleVersion = '2.6.0.0'}
Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

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

    # IIS Site Default Values
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

    # IIS App Pool Default Values
    xWebAppPoolDefaults PoolDefaults
    {
       ApplyTo               = 'Machine'
       ManagedRuntimeVersion = 'v4.0'
       IdentityType          = 'ApplicationPoolIdentity'
       DependsOn             = '[WindowsFeature]WebServer'
    }
}