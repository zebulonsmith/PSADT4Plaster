@{
    Assets = @{
        # Specify filename of the logo.
        Logo = '..\Assets\AppIcon.png'

        # Specify filename of the logo (for dark mode).
        LogoDark = '..\Assets\AppIcon.png'

        # Specify filename of the banner (Classic-only).
        Banner = '..\Assets\Banner.Classic.png'
    }

    MSI = @{
        # MSI install parameters used in interactive mode.
        InstallParams = '<%=$PLASTER_PARAM_MSIInstallParams%>'

        # Logging level used for MSI logging.
        LoggingOptions = '<%=$PLASTER_PARAM_MSILoggingOptions%>'

        # Log path used for MSI logging. Uses the same path as Toolkit when null or empty.
        LogPath = '<%=$PLASTER_PARAM_MSILogPath%>'

        # Log path used for MSI logging when RequireAdmin is False. Uses the same path as Toolkit when null or empty.
        LogPathNoAdminRights = '<%=$PLASTER_PARAM_MSILogPathNoAdminRights%>'

        # The length of time in seconds to wait for the MSI installer service to become available. Default is 600 seconds (10 minutes).
        MutexWaitTime = <%=$PLASTER_PARAM_MSIMutexWaitTime%>

        # MSI install parameters used in silent mode.
        SilentParams = '<%=$PLASTER_PARAM_MSISilentParams%>'

        # MSI uninstall parameters.
        UninstallParams = '<%=$PLASTER_PARAM_MSIUninstallParams%>'
    }

    Toolkit = @{
        # Specify the path for the cache folder.
        CachePath = '<%=$PLASTER_PARAM_ToolkitCachePath%>'

        # The name to show by default for dialog subtitles, balloon notifications, etc.
        CompanyName = '<%=$PLASTER_PARAM_ToolkitCompanyName%>'

        # Specify if the log files should be bundled together in a compressed zip file.
        CompressLogs = <%=$PLASTER_PARAM_ToolkitCompressLogs%>

        # Choose from either 'Native' for native PowerShell file copy via Copy-ADTFile, or 'Robocopy' to use robocopy.exe.
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

        # Specifies that logging should be to a hierarchical structure of AppVendor\AppName\AppVersion. Takes precident over "LogToSubfolder" if both are set.
        LogToHierarchy = <%=$PLASTER_PARAM_ToolkitLogToHierarchy%>

        # Specifies that a subfolder based on InstallName should be used for all log capturing.
        LogToSubfolder = <%=$PLASTER_PARAM_ToolkitLogToSubfolder%>

        # Specify if log file should be a CMTrace compatible log file or a Legacy text log file.
        LogStyle = '<%=$PLASTER_PARAM_ToolkitLogStyle%>'

        # Specify if log messages should be written to the console.
        LogWriteToHost = <%=$PLASTER_PARAM_ToolkitLogWriteToHost%>

        # Specify if console log messages should bypass PowerShell's subsystems and be sent direct to stdout/stderr.
        # This only applies if "LogWriteToHost" is true, and the script is being ran in a ConsoleHost (not the ISE, or another host).
        LogHostOutputToStdStreams = <%=$PLASTER_PARAM_ToolkitLogHostOutputToStdStreams%>

        # Registry key used to store toolkit information (with PSAppDeployToolkit as child registry key), e.g. deferral history.
        RegPath = '<%=$PLASTER_PARAM_ToolkitRegPath%>'

        # Same as RegPath but used when RequireAdmin is False. Bear in mind that since this Registry Key should be writable without admin permission, regular users can modify it also.
        RegPathNoAdminRights = '<%=$PLASTER_PARAM_ToolkitRegPathNoAdminRights%>'

        # Path used to store temporary Toolkit files (with PSAppDeployToolkit as subdirectory), e.g. cache toolkit for cleaning up blocked apps. Normally you don't want this set to a path that is writable by regular users, this might lead to a security vulnerability. The default Temp variable for the LocalSystem account is C:\Windows\Temp.
        TempPath = '<%=$PLASTER_PARAM_ToolkitTempPath%>'

        # Same as TempPath but used when RequireAdmin is False.
        TempPathNoAdminRights = '<%=$PLASTER_PARAM_ToolkitTempPathNoAdminRights%>'
    }

    UI = @{
        # Used to turn automatic balloon notifications on or off.
        BalloonNotifications = <%=$PLASTER_PARAM_UIBalloonNotifications%>

        # Choose from either 'Fluent' for contemporary dialogs, or 'Classic' for PSAppDeployToolkit 3.x WinForms dialogs.
        DialogStyle = '<%=$PLASTER_PARAM_UIDialogStyle%>'

        # Specify the Accent Color in hex (with the first two characters for transparency, 00 = 0%, FF = 100%), e.g. 0xFF0078D7.
        # The value specified here should be literally typed (i.e. `FluentAccentColor = 0xFF0078D7`) and not wrapped in quotes.
        FluentAccentColor = <%=$PLASTER_PARAM_UIFluentAccentColor%>

        # Exit code used when a UI prompt times out.
        DefaultExitCode = <%=$PLASTER_PARAM_UIDefaultExitCode%>

        # Time in seconds after which the prompt should be repositioned centre screen when the -PersistPrompt parameter is used. Default is 60 seconds.
        DefaultPromptPersistInterval = <%=$PLASTER_PARAM_UIDefaultPromptPersistInterval%>

        # Time in seconds to automatically timeout installation dialogs. Default is 55 minutes so that dialogs timeout before Intune times out.
        DefaultTimeout = <%=$PLASTER_PARAM_UIDefaultTimeout%>

        # Exit code used when a user opts to defer.
        DeferExitCode = <%=$PLASTER_PARAM_UIDeferExitCode%>

        <# Specify a static UI language using the one of the Language Codes listed below to override the language culture detected on the system.
            Language Code    Language
            =============    ========
            ar               Arabic
            bg               Bulgarian
            cs               Czech
            da               Danish
            de               German
            en               English
            el               Greek
            es               Spanish
            fi               Finnish
            fr               French
            he               Hebrew
            hu               Hungarian
            it               Italian
            ja               Japanese
            ko               Korean
            lv               Latvian
            nl               Dutch
            nb               Norwegian (Bokmål)
            pl               Polish
            pt               Portuguese (Portugal)
            pt-BR            Portuguese (Brazil)
            ru               Russian
            sk               Slovak
            sv               Swedish
            tr               Turkish
            zh-CN            Chinese (Simplified)
            zh-HK            Chinese (Traditional)
        #>
        LanguageOverride = <%=$PLASTER_PARAM_UILanguageOverride%>

        # Time in seconds after which to re-prompt the user to close applications in case they ignore the prompt or they cancel the application's save prompt.
        PromptToSaveTimeout = <%=$PLASTER_PARAM_UIPromptToSaveTimeout%>

        # Time in seconds after which the restart prompt should be re-displayed/repositioned when the -NoCountdown parameter is specified. Default is 600 seconds.
        RestartPromptPersistInterval = <%=$PLASTER_PARAM_UIRestartPromptPersistInterval%>
    }
}
