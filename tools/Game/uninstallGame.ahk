#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\Libs\Base.ahk

app := Base()

InstallRegKey := app.gameRegLocation

If A_Args.Length < 1 || !Game().isValidGameDirectory(location := A_Args[1]) {
    MsgBox('Please specify a game folder when you run this script as the first argument!', 'Uninstall', 0x30)
    ExitApp()
}
uninstallGui := GuiEx(, Game().name)
uninstallGui.initiate()

uninstallGui.AddButtonEx(
    'xm w300 h150',
    'By clicking on this button you agree to delete your game forever'
    . '`n`nGame location:`n"' location '"'
    ,
    ,
    UninstallGame
)
uninstallGui.showEx(, 1)

UninstallGame(Ctrl, Info) {
    If InStr(Ctrl.Text, 'completed') {
        ExitApp()
    }
    If !Game().isValidGameDirectory(Location) {
        Msgbox('"' Location '" does not seems to be a valid game location`nUninstall aborted!', 'Uninstall', 0x30)
        Return
    }
    Ctrl.TextEx := 'Uninstalling...'
    Ctrl.Enabled := False
    Sleep(1000)
    DirDelete(Location, 1)
    If RegRead(InstallRegKey, 'InstallLocation', '') = Location {
        RegDeleteKey(InstallRegKey)
    }
    Ctrl.Enabled := True
    Ctrl.TextEx := 'Uninstall is completed by now!`n`nQuit'
    Return
}