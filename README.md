# PSADT4Plaster
This repo contains a Plaster template for PSADT 4 as well as some "helper" scripts that can be used for building ADT packages.

The goal is to make it easy to standardize app packaging processes and reduce development time.

Before using this module, ensure that you're familiar both with the [Powershell App Deploy Toolkit](https://psappdeploytoolkit.com/) and [Plaster module](https://github.com/PowerShellOrg/Plaster).

# How it Works
The included Plaster template will copy the contents of the PSADT (Currently version 4.0.3) and make edits to config.psd1 and Invoke-AppDeployToolkit.ps1 as defined in the Plaster invocation.

All of the configuration options in config.psd1 have been defined in the template and can be easily modified as needed.

Blocks of code for the pre/post install, uninstall and repair actions can be defined that will be passed to invoke-appdeploytoolkit.ps1.



# How to Use it
Inside of this repo, there are two folders. The Template folder contains the Plaster template itself and two "Helper" scripts, which are meant to be copied and then modified as needed. The modified helper script can be kept and updated for future version updates to a given application.


## Example: Package an MSI installer
Create a copy of the PSADTBuildHelper-MSIInstaller.ps1 file and modify it as follows:

#### Ensure that the $TemplatePath variable points to the PSADT4Plaster_Template directory
```powershell
#Specify the path to the plaster template. (Folder that contains PSADT4Plaster.xml and the rest of the template files)
$TemplatePath = "$PSSCRIPTROOT\PSADT4Plaster_Template\"
```

#### Edit the $msifilepath variable to point to the MSI file.
The easiest way to handle this is to put the MSI in the same directory as the helper script. The script will use the Get-ADTMsiTableProperty function to read the properties table in the MSI and populate values such as $AppVendor, $AppName, etc.
```powershell
$msifilepath = "YourInstaller.msi" #Populate with the path to the MSI file that will be used in the ADT package.
```


#### Edit MSI Installation Properties as needed
Add any additional parameters to pass to the installer. In this example, our installer accepts RemoveDesktopShortcut=True as an additional property. It will be added to the Start-ADTMSIProcess command. If a different executable needs to be launched for uninstall or repair, change the $UninstallFile or $RepairFile variables as needed.
```powershell
#Populate installer files and arguments
$InstallFile = $msifilepath | split-path -leaf #Executable file to install. Be sure it's in the Files directory.
$InstallArguments = "RemoveDesktopShortcut=True"

$UninstallFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$UninstallArguments = " "

$RepairFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$RepairArguments = " " #This will probably remain empty for an MSI installer. The Repair codeblock will use the built in 'repair' action via Start-ADTMsiProcess.
#endregion
```

#### Run additional Pre and Post actions
There is a herestring for each install phase that can be used to add additional steps to the package. Be wary of single vs double quotes and escape them properly.

Using the Install phase as an example, there is a block of code in double-quotes so that variables from higher up in the build helper script can be referenced and a second herestring utilizing single quotes that's intended to be used for customizations.
```powershell
#Installation tasks
#Execute the MSI installer using the provided install arguments.
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

#Add your code here for additional installation tasks.
$installCodeBlock += @'
    #Sample code to copy a file. This code will be copied exactly as-is to invoke-psappdeploytoolkit.ps1

    $SourceFile = "$($ADTSession.DirSupportFiles)\Samplefile.txt"
    $Destination = "$($env:programfiles)\SampleVendor\Samplefile.txt"

    Copy-ADTFile -Path $SourceFile -Destination $Destination
'@
```

#### Execute the Script
Once any additional customizations are made, execute the script. A new PSADT folder structure will be built using the source files in the PSADT4Plaster_Template and the referenced MSI file will be copied to the Files directory.



## Example: Package an EXE installer
Packaging an executable installer is similar to an MSI, with a few additional steps. Primarily, because we can't easily read information from within the installer, things like the AppVendor, AppVersion, etc will need to be filled out manually. To begin, create a copy of the PSADTBuildHelper-EXEInstaller.ps1 file and modify it as follows:

#### Configure the Installer File Names
Similar to building from an MSI, the installer must be specified. If a different executable is used for Uninstall or Repair, be sure to change those values. Add any additional arguments

```powershell
#Populate installer files and arguments
$InstallFile = "SampleSetup.exe" #Executable file to install. Be sure it's in the Files directory.
$InstallArguments = "-Install -Silent -NoRestart"

$UninstallFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$UninstallArguments = "-Uninstall -Noisy -RestartWithoutWarningBecauseWhyNot "

$RepairFile = "$($InstallFile)" #This is usually the same as the installation file. Change it if needed.
$RepairArguments = " "
```

#### Specify Additional Package Information
With an executable installer, we can't read things like the Publisher and Version so those need to be populated manually. Collectively, as software packagers, we should all publicly shame vendors who don't provide us with MSI installers as a standard practice.

```Powershell
#Populate values in the $adtSession hashtable of Invoke-AppDeployToolkit.ps1
#Note that empty values MUST be populated.

$AppVendor = "VendorName" #Application's publisher.
$AppName = "NotAnMSI" #Application's friendly name.
$AppVersion = "4.3.2" #Application's version number.
$appArch = "x64" #x86 or x64
$AppLang = "EN" #Specify the language code. See PSADT documentation for a list
$AppRevision = "01" #Application revision
$AppSuccessExitCodes = '@(0)' #Exit codes that indicate success. This is typically 0, but some installers may return other codes.
$AppRebootExitCodes = '@(1641, 3010)' #Exit codes that indicate a reboot is required. This is typically 3010, but some installers may return other codes.
$AppscriptVersion = "1.0.0" #Version of this script.
$AppScriptDate = "$(Get-Date -format g)" #Date the script was created
$AppScriptAuthor = "" #Probably you
$InstallTitle = "$($AppVendor) $($AppName) - $($AppVersion)" #Title of the installation. This will be shown in the dialog boxes during installation.
```

#### Complete Other Customizations
Finally, add any custom code as needed using the same process as with an MSI.

