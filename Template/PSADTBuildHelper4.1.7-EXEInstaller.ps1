<#
This script is intended to be used to facilitate the use of the Plaster module to create a new ADT package based on an installer that uses an executable file.

Populate the variables as directed and then execute the script.\

Keep in mind that variable values will be injected into the ADT via Plaster, so it is necessary to be consious about the use of
single (') and double (") quotes. This is particularly true for the code blocks that are injected into the ADT package. The code
blocks are injected as strings, so if you use double quotes in the code block, you will need to escape them properly with a
backtick (`) or use single quotes.

#>

#Ensure that the PSAppDeployToolkit module is available
#See https://psappdeploytoolkit.com/ for installation instructions
Try {
    Import-module PSAppDeployToolkit -Force -ErrorAction Stop
} catch {
    Throw "PSAppDeployToolkit module not found. Please ensure that the PSAppDeployToolkit module is available in the PowerShell module path."
}

$PSADTModule = Get-Module -name psappdeploytoolkit
If ( $PSADTModule.version -ne '4.1.7') {
    Write-Warning "PSAppDeployToolkit version 4.1.7 is required. The current version is $(($PSADTModule).version). Please update the module."
    exit
}


#region Step1 - Define template paths
#Specify the path to the plaster template. (Folder that contains PSADT4Plaster.xml and the rest of the template files)
$TemplatePath = "$PSSCRIPTROOT\PSADT4Plaster_Template_4.1.7\"
if (-not (Test-Path -Path $TemplatePath -PathType Container)) {
    Throw "Template path $TemplatePath not found. Please ensure that the path is correct and that the Plaster template files are present."
}

#Output path for the ADT package
$DestinationPath = "$PSScriptRoot"
#endregion

#region Step2 - Define Installation Files and Arguments
#Populate installer files and arguments
$InstallFile = " " #Executable file to install. Be sure it's in the Files directory.
$InstallArguments = ""

$UninstallFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$UninstallArguments = ""

$RepairFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$RepairArguments = ""
#endregion

#region Step3 - Populate ADTSession

#Populate values in the $adtSession hashtable of Invoke-AppDeployToolkit.ps1
#Note that empty values MUST be populated.

$AppVendor = "" #Application's publisher.
$AppName = "" #Application's friendly name.
$AppVersion = "" #Application's version number.
$appArch = "x64" #x86 or x64
$AppLang = "EN" #Specify the language code. See PSADT documentation for a list
$AppRevision = "01" #Application revision
$AppSuccessExitCodes = '@(0)' #Exit codes that indicate success. This is typically 0, but some installers may return other codes.
$AppRebootExitCodes = '@(1641, 3010)' #Exit codes that indicate a reboot is required. This is typically 3010, but some installers may return other codes.
$AppscriptVersion = "1.0.0" #Version of this script.
$AppScriptDate = "$(Get-Date -format g)" #Date the script was created
$AppScriptAuthor = "" #Probably you
$InstallTitle = "$($AppVendor) $($AppName) - $($AppVersion)" #Title of the installation. This will be shown in the dialog boxes during installation.
$RequireAdmin = '$true' #Set to $false to allow non-admin installs

If ([string]::isnullorempty($AppScriptAuthor)) {
    Write-Warning "AppScriptAuthor is not populated. Please set this variable to the name of the script author, otherwise the ADT script will not execute."
    exit
}

<#
Processes to close before installation/uninstallation.
If this is defined and Deploymode is not set or 'Auto,' the deployment will default to Interactive Mode unless it is executing during OOBE or ESP when a process needs to close.
Example: '@('excel', @{ Name = 'winword'; Description = 'Microsoft Word' })'
Must be a literal string!

$AppProcessesToClose = @'
    @('7-zip')
'@

#>

$AppProcessesToClose = @'

'@

#endregion

#region Step4 - Script Customization

#This section contains customizations that apply to variable changes that would normally be made within Invoke-AppDeployToolkit.ps1

#Parameters passed to Show-ADTInstallationWelcome. These are the default options specified in Invoke-AppDeployToolkit.ps1
$AllowDefer = '$true' #Allow deferrals when using Interactive mode
$DeferTimes = '3' #Number of times the user can defer installation
$CheckDiskSpace = '$true' #Check for disk space before installation
$PersistPrompt = '$false' #Sets the installation prompt to persist on the screen


<#
Completion dialog shown when the installation completes.
This value is populated in the Install-ADTDeployment section of Invoke-AppDeployToolkit.ps1
Set to $null or an empty string to tell the ADT do skip the dialog.
#>
$InstallCompleteDialog = "Installation is complete."

#Set the timeout (in seconds) when closing a process during uninstallation
$UninstallAppProcessCloseCountdown = '60'

#Create a filename friendly string that will be used for the parent folder when the template is generated. This generally doesn't need to be changed, but you can edit it if you'd like the folder name to be something other than 'PSADT-AppVendor AppName - AppVersion'
$InstallTitleFileName = $InstallTitle.split([IO.Path]::GetInvalidFileNameChars()) -join "-"

#endregion

#region Step5 - config.psd1
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
$ToolkitCompanyName = 'PSAppDeployToolkit'
$ToolkitCompressLogs = '$false'
$ToolkitFileCopyMode = 'Native'
$ToolkitLogAppend = '$true'
$ToolkitLogDebugMessage = '$false'
$ToolkitLogMaxHistory = '10'
$ToolkitLogMaxSize = '10'
$ToolkitLogPath = '$envWinDir\Logs\Software'
$ToolkitLogPathNoAdminRights = '$envProgramData\Logs\Software'
$ToolkitLogToHierarchy = '$false'
$ToolkitLogToSubfolder = '$false'
$ToolkitLogStyle = 'CMTrace'
$ToolkitLogWriteToHost = '$true'
$ToolkitLogHostOutputToStdStreams = '$false'
$ToolkitRegPath = 'HKLM:\SOFTWARE'
$ToolkitRegPathNoAdminRights = 'HKCU:\SOFTWARE'
$ToolkitTempPath = '$envTemp'
$ToolkitTempPathNoAdminRights = '$envTemp'

#UI
$UIBalloonNotifications = '$true'
$UIBalloonTitle = 'PSAppDeployToolkit'
$UIDialogStyle = 'Fluent'
$UIFluentAccentColor = '$null'
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


#region Step6 - Customize Code Blocks


<#
These code blocks will be populated the Install-ADTDeployment, Uninstall-ADTDeployment and Repair-ADTDeployment functions in Invoke-AppDeployToolkit.ps1
For basic installs, there shouldn't need to be much work done here. The installer files and their arguments will be inserted as they aredefined above.

You can use this section to add any other custom code that is needed such as copying configuration files, executing multiple installers, etc.

Tip: Use -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`" when calling Write-ADTLogEntry to indicate that the messages are generated from the
code blocks created by this script.
#>

#Pre-Installation tasks
#Initial log entry for pre-install
$PreInstallCodeBlock = @'
    #PreInstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message "Beginning Pre-Installation tasks from PSADTBuilder Template" -Source "$($adtsession.InstallPhase)-PSADTHelper"
    Write-ADTLogEntry -message "$($adtsession | Out-String)" -Source "$($adtsession.InstallPhase)-PSADTHelper"
'@

#Add your code here for pre-installation tasks.
$PreInstallCodeBlock += @'

'@


#Installation tasks
#Execute installer
$InstallCodeBlock = @"
    #InstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Installation from PSADTBuilder Template using $InstallFile`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
    `$InstallProcess = Start-ADTProcess -FilePath '$InstallFile' -ArgumentList '$InstallArguments' -PassThru

    Write-ADTLogEntry -Message `"EXITCODE:`$(`$InstallProcess.ExitCode)``nSTDOUT:`$(`$InstallProcess.StdOut)``nSTDERR:`$(`$InstallProcess.StdErr)" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Add your code here for additional installation tasks.
$installCodeBlock += @'

'@

#Post-Installation tasks
#Initial log entry for post-install
$PostInstallCodeBlock = @'
    #PostInstallCodeBlock from PSADTBuilder
    Write-ADTLogEntry -Message "Beginning Post-Installation tasks from PSADTBuilder Template" -Source "$($adtsession.InstallPhase)-PSADTHelper"
'@

#Add your code here for post-installation tasks.
$PostInstallCodeBlock += @'

'@


#Pre-Uninstallation tasks
#Initial log entry for pre-uninstall
$PreUninstallCodeBlock = @'
    #PreInstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message "Beginning Pre-Uninstallation tasks from PSADTBuilder Template" -Source "$($adtsession.InstallPhase)-PSADTHelper"
    Write-ADTLogEntry -message "$($adtsession | Out-String)" -Source "$($adtsession.InstallPhase)-PSADTHelper"
'@

#Add your code here for pre-uninstallation tasks.
$PreUninstallCodeBlock += @'

'@


#Uninstall tasks
$UninstallCodeBlock = @"
    #UninstallCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message `"Beginning Uninstallation from PSADTBuilder Template using $UninstallFile`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"

    `$UninstallProcess = Start-ADTProcess -FilePath '$UninstallFile' -ArgumentList '$UninstallArguments' -PassThru

    Write-ADTLogEntry -Message `"EXITCODE:`$(`$UninstallProcess.ExitCode)``nSTDOUT:`$(`$UninstallProcess.StdOut)``nSTDERR:`$(`$UninstallProcess.StdErr)" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Add your code here for additional uninstallation tasks.
$UninstallCodeBlock += @'

'@

#Post-Uninstall tasks
$PostUninstallCodeBlock = @'
    #PostUninstallCodeBlock from PSADTBuilder
    Write-ADTLogEntry -Message "Beginning Post-Uninstallation tasks from PSADTBuilder Template" -Source "$($adtsession.InstallPhase)-PSADTHelper"
'@

#Add your code here for post-uninstallation tasks.
$PostInstallCodeBlock += @'

'@

#Pre-Repair tasks
$PreRepairCodeBlock = @'
    #PreRepairCodeBlock from PSADTBuildHelper
    Write-ADTLogEntry -Message "Beginning Pre-Repair tasks from PSADTBuilder Template" -Source "$($adtsession.InstallPhase)-PSADTHelper"
'@

#Add your code here for pre-repair tasks.
$PreRepairCodeBlock += @'

'@

#Repair tasks
#Choose one of the two methods below and uncomment the associated code.
$RepairCodeBlock = @"
    #RepairodeBlock from PSADTBuildHelper

    #Uninstall/Reinstall using built in ADT functions
    
    Write-ADTLogEntry -Message `"Beginning Repair from PSADTBuilder Template using Uninstall/Reinstall method." -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
    Uninstall-ADTDeployment
    Install-ADTDeployment
    


    #Alternate Method: Use an executable with command line arguments
    <#
    Write-ADTLogEntry -Message `"Beginning Repair from PSADTBuilder Template using $RepairFile`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
    Write-ADTLogEntry -message `"`$(`$adtsession | Out-String)`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
    `$RepairProcess = Start-ADTProcess -FilePath '$RepairFile' -ArgumentList '$RepairArguments -PassThru

    Write-ADTLogEntry -Message `"EXITCODE:`$(`$RepairProcess.ExitCode)``nSTDOUT:`$(`$RepairProcess.StdOut)``nSTDERR:`$(`$RepairProcess.StdErr)" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
    #>

    #Method two: Uninstall/Reinstall using built in ADT functions
    <#
    Write-ADTLogEntry -Message `"Beginning Repair from PSADTBuilder Template using Uninstall/Reinstall method." -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
    Uninstall-ADTDeployment
    Install-ADTDeployment
    #>
"@

#Add your code here for additional repair tasks.
$RepairCodeBlock += @'

'@

#Post-Repair tasks
$PostRepairCodeBlock = @"
    #PostRepairCodeBlock from PSADTBuilder
    Write-ADTLogEntry -Message `"Beginning Post-Repair tasks from PSADTBuilder Template`" -Source `"`$(`$adtsession.InstallPhase)-PSADTHelper`"
"@

#Add your code here for post-repair tasks.
$PostRepairCodeBlock += @'

'@

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
    RequireAdmin = $RequireAdmin
    AppProcessesToClose = $AppProcessesToClose
    AllowDefer = $AllowDefer
    DeferTimes = $DeferTimes
    CheckDiskSpace = $CheckDiskSpace
    PersistPrompt = $PersistPrompt
    UninstallAppProcessCloseCountdown = $UninstallAppProcessCloseCountdown
    MSIInstallParams = $MSIInstallParams
    MSILoggingOptions = $MSILoggingOptions
    MSILogPath = $MSILogPath
    MSILogPathNoAdminRights = $MSILogPathNoAdminRights
    MSIMutexWaitTime = $MSIMutexWaitTime
    MSISilentParams = $MSISilentParams
    MSIUninstallParams = $MSIUninstallParams
    ToolkitCachePath = $ToolkitCachePath
    ToolkitCompanyName = $ToolkitCompanyName
    ToolkitCompressLogs = $ToolkitCompressLogs
    ToolkitFileCopyMode = $ToolkitFileCopyMode
    ToolkitLogAppend = $ToolkitLogAppend
    ToolkitLogDebugMessage = $ToolkitLogDebugMessage
    ToolkitLogMaxHistory = $ToolkitLogMaxHistory
    ToolkitLogMaxSize = $ToolkitLogMaxSize
    ToolkitLogPath = $ToolkitLogPath
    ToolkitLogPathNoAdminRights = $ToolkitLogPathNoAdminRights
    ToolkitLogToSubfolder = $ToolkitLogToSubfolder
    ToolkitLogToHierarchy=$ToolkitLogToHierarchy
    ToolkitLogStyle = $ToolkitLogStyle
    ToolkitLogWriteToHost = $ToolkitLogWriteToHost
    ToolkitLogHostOutputToStdStreams = $ToolkitLogHostOutputToStdStreams
    ToolkitRegPath = $ToolkitRegPath
    ToolkitRegPathNoAdminRights = $ToolkitRegPathNoAdminRights
    ToolkitTempPath = $ToolkitTempPath
    ToolkitTempPathNoAdminRights = $ToolkitTempPathNoAdminRights
    UIBalloonNotifications = $UIBalloonNotifications
    UIBalloonTitle = $UIBalloonTitle
    UIDialogStyle = $UIDialogStyle
    UIFluentAccentColor = $UIFluentAccentColor
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