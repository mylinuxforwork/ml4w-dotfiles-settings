import Quickshell
import Quickshell.Io
import "SettingsApp"
import "CustomTheme"

ShellRoot {

    IpcHandler {
        target: "theme-manager" 
        function reload(): void {
            Theme.reloadTheme()
        }
    }

    SettingsWindow {}
}