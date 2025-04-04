<#
This script is intended to be used to facilitate the use of the Plaster module to create a new ADT package based on an installer that uses an MSI file.
Because we can read the contents of the MSI, we can automate the population of many of the variables.

Populate the variables as directed and then execute the script.\

Keep in mind that variable values will be injected into the ADT via Plaster, so it is necessary to be consious about the use of
single (') and double (") quotes. This is particularly true for the code blocks that are injected into the ADT package. The code
blocks are injected as strings, so if you use double quotes in the code block, you will need to escape them properly with a
backtick (`) or use single quotes.

#>

#Specify the path to the plaster template. (Folder that contains PSADT4Plaster.xml and the rest of the template files)
$TemplatePath = "$PSSCRIPTROOT\PSADT4Plaster_Template\"

#Output path for the ADT package
$DestinationPath = "$PSScriptRoot"


#region Read MSI
<#
We can populate many template variables using information from the MSI

AppArch and AppScriptAuthor will need to be specified manually, along with any other modifications that are desired.
The Install, Uninstall and Repair code blocks will be populated automatically and only require modifications if additional steps or special modifications are needed.

Be sure to populate any custom arguments that need to be added for the MSI install/uninstall operations below.
The default MSI params will still be used as defined in the PSADT config.psd1 file.
#>

$msifilepath = "" #Populate with the path to the MSI file that will be used in the ADT package.
$MSIProperties = Get-ADTMsiTableProperty -path $msifilepath -Table 'Property'
#endregion

#region define installation files

#Populate installer files and arguments
$InstallFile = $msifilepath | split-path -leaf #Executable file to install. Be sure it's in the Files directory.
$InstallArguments = " "

$UninstallFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$UninstallArguments = " "

$RepairFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$RepairArguments = " " #This will probably remain empty for an MSI installer. The Repair codeblock will use the built in 'repair' action via Start-ADTMsiProcess.
#endregion

#region ADTSession

#Populate values in the $adtSession hashtable of Invoke-AppDeployToolkit.ps1
#Note that empty values MUST be populated.

$AppVendor = $msiproperties.Manufacturer #Application's publisher.
$AppName = $msiproperties.ProductName #Application's friendly name.
$AppVersion = $MSIProperties.ProductVersion #Application's version number.
$appArch = "x64" #x86 or x64
$AppLang = "EN" #Specify the language code. See PSADT documentation for a list
$AppRevision = "01" #Application revision
$AppSuccessExitCodes = '@(0)' #Exit codes that indicate success. This is typically 0, but some installers may return other codes.
$AppRebootExitCodes = '@(1641, 3010)' #Exit codes that indicate a reboot is required. This is typically 3010, but some installers may return other codes.
$AppscriptVersion = "1.0.0" #Version of this script.
$AppScriptDate = "$(Get-Date -format g)" #Date the script was created
$AppScriptAuthor = "YourName" #Probably you
$InstallTitle = "$($AppVendor) $($AppName) - $($AppVersion)" #Title of the installation. This will be shown in the dialog boxes during installation.

#Completion dialog shown when the installation completes. This value is populated in the Install-ADTDeployment section of Invoke-AppDeployToolkit.ps1
$InstallCompleteDialog = "Installation is complete."

#Create a filename friendly string that will be used for the parent folder when the template is generated. This generally doesn't need to be changed, but you can edit it if you'd like the folder name to be something other than 'PSADT-AppVendor AppName - AppVersion'
$InstallTitleFileName = $InstallTitle.split([IO.Path]::GetInvalidFileNameChars()) -join "-"
#endregion

#region config.psd1
<#
Values that will populate into config.psd1.
These typically don't need to be changed, but be aware of a few.
    -Change RequireAdmin to $false for non-admin installs.
    -InstallParams, SilentParams, UninstallParams can be used to change the default MSI installation behavior
    -LogDebugMessage is useful when debugging a new package
    -BalloonNotifications can be set to $false if you don't want the balloon notifications to show up during installation.
    -DialogStyle can be set to 'Classic' if you want the old style PSADT dialogs.
#>

#MSI
$MSIInstallParams = 'REBOOT=ReallySuppress /QB-!'
$MSILoggingOptions = '/L*V'
$MSILogPath = '$envWinDir\Logs\Software'
$MSILogPathNoAdminRights = '$envProgramData\Logs\Software'
$MSIMutexWaitTime = '600'
$MSISilentParams = 'REBOOT=ReallySuppress /QN'
$MSIUninstallParams = 'REBOOT=ReallySuppress /QN'

#Toolkit
$ToolkitCachePath = '$envProgramData\SoftwareCache'
$ToolkitCompressLogs = '$false'
$ToolkitFileCopyMode = 'Native'
$ToolkitLogAppend = '$true'
$ToolkitLogDebugMessage = '$false'
$ToolkitLogMaxHistory = '10'
$ToolkitLogMaxSize = '10'
$ToolkitLogPath = '$envWinDir\Logs\Software'
$ToolkitLogPathNoAdminRights = '$envProgramData\Logs\Software'
$ToolkitLogToSubfolder = '$false'
$ToolkitLogStyle = 'CMTrace'
$ToolkitLogWriteToHost = '$true'
$ToolkitLogHostOutputToStdStreams = '$false'
$ToolkitOobeDetection = '$true'
$ToolkitRegPath = 'HKLM:\SOFTWARE'
$ToolkitRegPathNoAdminRights = 'HKCU:\SOFTWARE'
$ToolkitRequireAdmin = '$true'
$ToolkitSessionDetection = '$true'
$ToolkitTempPath = '$envTemp'
$ToolkitTempPathNoAdminRights = '$envTemp'

#UI
$UIBalloonNotifications = '$true'
$UIBalloonTitle = 'PSAppDeployToolkit'
$UIDialogStyle = 'Fluent'
$UIDefaultExitCode = '1618'
$UIDefaultPromptPersistInterval = '60'
$UIDefaultTimeout = '3300'
$UIDeferExitCode = '60012'
$UIDynamicProcessEvaluation = '$true'
$UIDynamicProcessEvaluationInterval = '2'
$UILanguageOverride = '$null'
$UIPromptToSaveTimeout = '120'
$UIRestartPromptPersistInterval = '600'

#endregion


#Region code blocks


<#
These code blocks will be populated the Install-ADTDeployment, Uninstall-ADTDeployment and Repair-ADTDeployment functions in Invoke-AppDeployToolkit.ps1
For basic installs, there shouldn't need to be much work done here. The installer files and their arguments will be inserted as they aredefined above.

You can use this section to add any other custom code that is needed such as copying configuration files, executing multiple installers, etc.

Tip: Use -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`" when calling Write-ADTLogEntry to indicate that the messages are generated from the
code blocks created by this script.
#>

#Pre-Installation tasks
$PreInstallCodeBlock = @"
    #PreInstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Pre-Installation tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Installation tasks
$InstallCodeBlock = @"
    #InstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Installation from PSADTBuilder Template using $InstallFile`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"

    if (![string]::isnullorempty("$InstallArguments")) {
        `$installProcess = Start-ADTMsiProcess -filepath '$InstallFile' -Action Install -AdditionalArgumentList '$InstallArguments'
    } else {
        `$installProcess = Start-ADTMsiProcess -filepath '$InstallFile' -Action Install -PassThru
    }

    Write-ADTLogEntry -Message `"EXITCODE:`$(`$InstallProcess.ExitCode)``nSTDOUT:`$(`$InstallProcess.StdOut)``nSTDERR:`$(`$InstallProcess.StdErr)" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Post-Installation tasks
$PostInstallCodeBlock = @"
    #PostInstallCodeBlock from PSADTBuilder
    Write-ADTLogEntry -Message `"Beginning Post-Installation tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@


#Pre-Uninstallation tasks
$PreUninstallCodeBlock = @"
    #PreInstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Pre-Uninstallation tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Uninstall tasks
$UninstallCodeBlock = @"
    #UninstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Uninstallation from PSADTBuilder Template using $UninstallFile`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"

    if (![string]::isnullorempty("$UninstallArguments")) {
        `$uninstallProcess = Start-ADTMsiProcess -filepath '$UninstallFile' -Action Uninstall -AdditionalArgumentList '$UninstallArguments'
    } else {
        `$uninstallProcess = Start-ADTMsiProcess -filepath '$UninstallFile' -Action Uninstall -PassThru
    }

    Write-ADTLogEntry -Message `"EXITCODE:`$(`$UninstallProcess.ExitCode)``nSTDOUT:`$(`$UninstallProcess.StdOut)``nSTDERR:`$(`$UninstallProcess.StdErr)" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Post-Uninstall tasks
$PostUninstallCodeBlock = @"
    #PostUninstallCodeBlock from PSADTBuilder
    Write-ADTLogEntry -Message `"Beginning Post-Uninstallation tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@



#Pre-Repair tasks
$PreRepairCodeBlock = @"
    #PreRepairCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Pre-Repair tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Repair tasks
$RepairCodeBlock = @"
    #RepairodeBlock from PSADTBuildHelper

    Write-ADTLogEntry -Message `"Beginning Repair from PSADTBuilder Template using $RepairFile`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
        if (![string]::isnullorempty("$RepairArguments")) {
        `$repairProcess = Start-ADTMsiProcess -filepath '$RepairFile' -Action Repair -AdditionalArgumentList '$RepairArguments'
    } else {
        `$RepairProcess = Start-ADTMsiProcess -filepath '$RepairFile' -Action Repair -PassThru
    }

    Write-ADTLogEntry -Message `"EXITCODE:`$(`$RepairProcess.ExitCode)``nSTDOUT:`$(`$RepairProcess.StdOut)``nSTDERR:`$(`$RepairProcess.StdErr)" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Post-Repair tasks
$PostRepairCodeBlock = @"
    #PostRepairCodeBlock from PSADTBuilder
    Write-ADTLogEntry -Message `"Beginning Post-Repair tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#endregion

<#
Invokes Plaster to build the new ADT package. This section shouldn't need to be changed.
#>
$plasterParams = @{
    TemplatePath = $TemplatePath
    DestinationPath = $DestinationPath
    AppVendor = $AppVendor
    AppName = $AppName
    AppVersion = $AppVersion
    AppArch = $appArch
    AppLang = $AppLang
    AppRevision = $AppRevision
    AppSuccessExitCodes = $AppSuccessExitCodes
    AppRebootExitCodes = $AppRebootExitCodes
    AppScriptVersion = $AppscriptVersion
    AppScriptDate = $AppScriptDate
    AppScriptAuthor = $AppScriptAuthor
    InstallTitle = $InstallTitle
    InstallCompleteDialog = $InstallCompleteDialog
    InstallTitleFileName = $InstallTitleFileName
    MSIInstallParams = $MSIInstallParams
    MSILoggingOptions = $MSILoggingOptions
    MSILogPath = $MSILogPath
    MSILogPathNoAdminRights = $MSILogPathNoAdminRights
    MSIMutexWaitTime = $MSIMutexWaitTime
    MSISilentParams = $MSISilentParams
    MSIUninstallParams = $MSIUninstallParams
    ToolkitCachePath = $ToolkitCachePath
    ToolkitCompressLogs = $ToolkitCompressLogs
    ToolkitFileCopyMode = $ToolkitFileCopyMode
    ToolkitLogAppend = $ToolkitLogAppend
    ToolkitLogDebugMessage = $ToolkitLogDebugMessage
    ToolkitLogMaxHistory = $ToolkitLogMaxHistory
    ToolkitLogMaxSize = $ToolkitLogMaxSize
    ToolkitLogPath = $ToolkitLogPath
    ToolkitLogPathNoAdminRights = $ToolkitLogPathNoAdminRights
    ToolkitLogToSubfolder = $ToolkitLogToSubfolder
    ToolkitLogStyle = $ToolkitLogStyle
    ToolkitLogWriteToHost = $ToolkitLogWriteToHost
    ToolkitLogHostOutputToStdStreams = $ToolkitLogHostOutputToStdStreams
    ToolkitOobeDetection = $ToolkitOobeDetection
    ToolkitRegPath = $ToolkitRegPath
    ToolkitRegPathNoAdminRights = $ToolkitRegPathNoAdminRights
    ToolkitRequireAdmin = $ToolkitRequireAdmin
    ToolkitSessionDetection = $ToolkitSessionDetection
    ToolkitTempPath = $ToolkitTempPath
    ToolkitTempPathNoAdminRights = $ToolkitTempPathNoAdminRights
    UIBalloonNotifications = $UIBalloonNotifications
    UIBalloonTitle = $UIBalloonTitle
    UIDialogStyle = $UIDialogStyle
    UIDefaultExitCode = $UIDefaultExitCode
    UIDefaultPromptPersistInterval = $UIDefaultPromptPersistInterval
    UIDefaultTimeout = $UIDefaultTimeout
    UIDeferExitCode = $UIDeferExitCode
    UIDynamicProcessEvaluation = $UIDynamicProcessEvaluation
    UIDynamicProcessEvaluationInterval = $UIDynamicProcessEvaluationInterval
    UILanguageOverride = $UILanguageOverride
    UIPromptToSaveTimeout = $UIPromptToSaveTimeout
    UIRestartPromptPersistInterval = $UIRestartPromptPersistInterval
    PreInstallCodeBlock = $PreInstallCodeBlock
    InstallCodeBlock = $InstallCodeBlock
    PostInstallCodeBlock = $PostInstallCodeBlock
    PreUninstallCodeBlock = $PreUninstallCodeBlock
    UninstallCodeBlock = $UninstallCodeBlock
    PostUninstallCodeBlock = $PostUninstallCodeBlock
    PreRepairCodeBlock = $PreRepairCodeBlock
    RepairCodeBlock = $RepairCodeBlock
    PostRepairCodeBlock = $PostRepairCodeBlock
}

Invoke-plaster @plasterparams -verbose


<#
Use this section to add any additional automations.
For example, one could create an Application in Configuration Manager or Intune or copy files to another destination.
#>

#Copy the MSI to the files folder in the new ADT package
Copy-Item -Path $msifilepath -Destination "$DestinationPath\PSADT4-$($InstallTitleFileName)\Files\" -Force