@{
    Assets = @{
        # Specify filename of the logo.
        Logo = '..\Assets\AppIcon.png'

        # Specify filename of the banner (Classic-only).
        Banner = '..\Assets\Banner.Classic.png'
    }

    MSI = @{
        # Installation parameters used for non-silent MSI actions.
        InstallParams = '<%=$PLASTER_PARAM_MSIInstallParams%>'

        # Logging level used for MSI logging.
        LoggingOptions = '<%=$PLASTER_PARAM_MSILoggingOptions%>'

        # Log path used for MSI logging.
        LogPath = '<%=$PLASTER_PARAM_MSILogPath%>'

        # Log path used for MSI logging when RequireAdmin is False.
        LogPathNoAdminRights = '<%=$PLASTER_PARAM_MSILogPathNoAdminRights%>'

        # The length of time in seconds to wait for the MSI installer service to become available. Default is 600 seconds (10 minutes).
        MutexWaitTime = <%=$PLASTER_PARAM_MSIMutexWaitTime%>

        # Installation parameters used for silent MSI actions.
        SilentParams = '<%=$PLASTER_PARAM_MSISilentParams%>'

        # Installation parameters used for MSI uninstall actions.
        UninstallParams = '<%=$PLASTER_PARAM_MSIUninstallParams%>'
    }

    Toolkit = @{
        # Specify the path for the cache folder.
        CachePath = '<%=$PLASTER_PARAM_ToolkitCachePath%>'

        # Specify if the log files should be bundled together in a compressed zip file.
        CompressLogs = <%=$PLASTER_PARAM_ToolkitCompressLogs%>

        # Choose from either 'Native' for native PowerShell file copy via Copy-ADTItem, or 'Robocopy' to use robocopy.exe.
        FileCopyMode = '<%=$PLASTER_PARAM_ToolkitFileCopyMode%>'

        # Specify if an existing log file should be appended to.
        LogAppend = <%=$PLASTER_PARAM_ToolkitLogAppend%>

        # Specify if debug messages such as bound parameters passed to a function should be logged.
        LogDebugMessage = <%=$PLASTER_PARAM_ToolkitLogDebugMessage%>

        # Specify maximum number of previous log files to retain.
        LogMaxHistory = <%=$PLASTER_PARAM_ToolkitLogMaxHistory%>

        # Specify maximum file size limit for log file in megabytes (MB).
        LogMaxSize = <%=$PLASTER_PARAM_ToolkitLogMaxSize%>

        # Log path used for Toolkit logging.
        LogPath = '<%=$PLASTER_PARAM_ToolkitLogPath%>'

        # Same as LogPath but used when RequireAdmin is False.
        LogPathNoAdminRights = '<%=$PLASTER_PARAM_ToolkitLogPathNoAdminRights%>'

        # Specifies that a subfolder based on InstallName should be used for all log capturing.
        LogToSubfolder = <%=$PLASTER_PARAM_ToolkitLogToSubfolder%>

        # Specify if log file should be a CMTrace compatible log file or a Legacy text log file.
        LogStyle = '<%=$PLASTER_PARAM_ToolkitLogStyle%>'

        # Specify if log messages should be written to the console.
        LogWriteToHost = <%=$PLASTER_PARAM_ToolkitLogWriteToHost%>

        # Specify if console log messages should bypass PowerShell's subsystems and be sent direct to stdout/stderr.
        # This only applies if "LogWriteToHost" is true, and the script is being ran in a ConsoleHost (not the ISE, or another host).
        LogHostOutputToStdStreams = <%=$PLASTER_PARAM_ToolkitLogHostOutputToStdStreams%>

        # Automatically changes DeployMode to Silent during the OOBE.
        OobeDetection = <%=$PLASTER_PARAM_ToolkitOobeDetection%>

        # Registry key used to store toolkit information (with PSAppDeployToolkit as child registry key), e.g. deferral history.
        RegPath = '<%=$PLASTER_PARAM_ToolkitRegPath%>'

        # Same as RegPath but used when RequireAdmin is False. Bear in mind that since this Registry Key should be writable without admin permission, regular users can modify it also.
        RegPathNoAdminRights = '<%=$PLASTER_PARAM_ToolkitRegPathNoAdminRights%>'

        # Specify if Administrator Rights are required. Note: Some functions won't work if this is set to false, such as deferral, block execution, file & registry RW access and potentially logging.
        RequireAdmin = <%=$PLASTER_PARAM_ToolkitRequireAdmin%>

        # Automatically changes DeployMode for session zero (SYSTEM) operations.
        SessionDetection = <%=$PLASTER_PARAM_ToolkitSessionDetection%>

        # Path used to store temporary Toolkit files (with PSAppDeployToolkit as subdirectory), e.g. cache toolkit for cleaning up blocked apps. Normally you don't want this set to a path that is writable by regular users, this might lead to a security vulnerability. The default Temp variable for the LocalSystem account is C:\Windows\Temp.
        TempPath = '<%=$PLASTER_PARAM_ToolkitTempPath%>'

        # Same as TempPath but used when RequireAdmin is False.
        TempPathNoAdminRights = '<%=$PLASTER_PARAM_ToolkitTempPathNoAdminRights%>'
    }

    UI = @{
        # Used to turn automatic balloon notifications on or off.
        BalloonNotifications = <%=$PLASTER_PARAM_UIBalloonNotifications%>

        # The name to show by default for all balloon notifications.
        BalloonTitle = '<%=$PLASTER_PARAM_UIBalloonTitle%>'

        # Choose from either 'Fluent' for contemporary dialogs, or 'Classic' for PSAppDeployToolkit 3.x WinForms dialogs.
        DialogStyle = '<%=$PLASTER_PARAM_UIDialogStyle%>'

        # Exit code used when a UI prompt times out.
        DefaultExitCode = <%=$PLASTER_PARAM_UIDefaultExitCode%>

        # Time in seconds after which the prompt should be repositioned centre screen when the -PersistPrompt parameter is used. Default is 60 seconds.
        DefaultPromptPersistInterval = <%=$PLASTER_PARAM_UIDefaultPromptPersistInterval%>

        # Time in seconds to automatically timeout installation dialogs. Default is 55 minutes so that dialogs timeout before Intune times out.
        DefaultTimeout = <%=$PLASTER_PARAM_UIDefaultTimeout%>

        # Exit code used when a user opts to defer.
        DeferExitCode = <%=$PLASTER_PARAM_UIDeferExitCode%>

        # Specify whether to re-enumerate running processes dynamically while displaying Show-ADTInstallationWelcome.
        # If the CloseProcesses items were not running when the prompt was displayed, and are subsequently detected to be running, the prompt will be updated with the apps to close.
        # If the CloseProcesses items were running when the prompt was displayed and are subsequently detected not to be running then the installation will automatically continue if deferral is not available.
        # If the running applications change (new CloseProcesses launched or running processes closed), the list box will dynamically update to reflect the currently running applications.
        DynamicProcessEvaluation = <%=$PLASTER_PARAM_UIDynamicProcessEvaluation%>

        # Time in seconds after which to re-enumerate running processes while displaying the Show-ADTInstallationWelcome prompt. Default is 2 seconds.
        DynamicProcessEvaluationInterval = <%=$PLASTER_PARAM_UIDynamicProcessEvaluationInterval%>

        <# Specify a static UI language using the one of the Language Codes listed below to override the language culture detected on the system.
            Language Code    Language       |       Language Code    Language
            =============    ========       |       =============    ========
            AR               Arabic         |       KO               Korean
            CZ               Czech          |       NL               Dutch
            DA               Danish         |       NB               Norwegian (Bokmål)
            DE               German         |       PL               Polish
            EN               English        |       PT               Portuguese (Portugal)
            EL               Greek          |       PT-BR            Portuguese (Brazil)
            ES               Spanish        |       RU               Russian
            FI               Finnish        |       SK               Slovak
            FR               French         |       SV               Swedish
            HE               Hebrew         |       TR               Turkish
            HU               Hungarian      |       ZH-Hans          Chinese (Simplified)
            IT               Italian        |       ZH-Hant          Chinese (Traditional)
            JA               Japanese       |
        #>
        LanguageOverride = <%=$PLASTER_PARAM_UILanguageOverride%>

        # Time in seconds after which to re-prompt the user to close applications in case they ignore the prompt or they cancel the application's save prompt.
        PromptToSaveTimeout = <%=$PLASTER_PARAM_UIPromptToSaveTimeout%>

        # Time in seconds after which the restart prompt should be re-displayed/repositioned when the -NoCountdown parameter is specified. Default is 600 seconds.
        RestartPromptPersistInterval = <%=$PLASTER_PARAM_UIRestartPromptPersistInterval%>
    }
}
