#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

dmapp := DataMod()

gameLocation := dmapp.gameLocation
dmPackages := dmapp.dmPackages

dmGui := GuiEx(, dmapp.name)
dmGui.initiate()

dmGui.AddText('xm w200 BackgroundTrans', 'Search')
search := dmGui.AddEdit('Border -E0x200 w200')
search.OnEvent('Change', quickSearch)

modsList := dmGui.AddListBox('wp r20 BackgroundE1B15A -E0x200')
modsList.OnEvent('Change', showInfo)

quickSearch(ctrl, info) {
    modsList.Delete()
    searchValue := ctrl.Text
    For modName in dmapp.dmPackages {
        If searchValue != '' && !InStr(modName, searchValue) {
            Continue
        }
        modsList.Add([modName])
    }
}

For modName in dmapp.dmPackages {
    modsList.Add([modName])
}

dmThumbnail := dmGui.addPictureEx('ym+37 Border')
dmGui.SetFont('s8')
dmDescription := dmGui.addEdit('ym+37 w300 hp Backgrounddcb670 ReadOnly -E0x200')
dmGui.SetFont('s10')
dmInstall := dmGui.addButtonEx('xp-170 yp+140 w143', 'Install', , updateDM)
dmUpdateInstall := dmGui.addButtonEx('wp yp', 'Update and Install', , clearDM)
dmUninstall := dmGui.addButtonEx('wp yp', 'Uninstall', , updateDM)

progressText := dmGui.AddText('xp-326 yp+70 Center w469 Hidden BackgroundTrans')

progressBar := dmGui.AddProgress('-Smooth wp Hidden')

dmGui.showEx(, 1)

modsList.Choose(1)
showInfo(modsList, '')

showInfo(ctrl, info) {
    modName := ctrl.Text
    description := dmapp.dmPackages[modName]['description']
    version := dmapp.dmPackages[modName]['packageVersion']
    thumbnail := dmapp.dmPackages[modName]['thumbnail']
    dmThumbnail.Value := thumbnail
    dmDescription.Value := description '`n`nVersion: ' version
}

updateDM(Ctrl, Info) {
    dmapp.enableOptions([dmInstall, dmUninstall], 0)

    dmName := modsList.Text

    dmPackagePath := dmapp.dmPackages[dmName]['packagePath']
    dmPackageLink := dmapp.dmPackages[dmName]['packageLink']
    dmPackageSize := dmapp.dmPackages[dmName]['packageSizeMB']
    dmGameName := dmapp.dmPackages[dmName]['gameName']
    dmGameLinker := dmapp.dmPackages[dmName]['gameLinker']

    apply := ctrl.Text = 'Install'
    If apply {
        ctrl.TextEx := 'Installing...'
    } Else {
        ctrl.TextEx := 'Uninstalling...'
    }
    If apply {
        dmapp.enableOptions([dmInstall, dmUninstall], 0)
        If !FileExist(dmPackagePath) {
            If !dmapp.getConnectedState() {
                MsgBoxEx('Unable to install, you does not seem to be connected to the internet!', dmapp.name, , 0x30)
                dmapp.enableOptions([dmInstall, dmUninstall])
                Return
            }
            dmapp.downloadPackage(dmPackageLink, dmPackagePath, dmPackageSize, progressText, progressBar)
        }
        If !DirExist(gameLocation '\Games\' dmGameName)
            dmapp.extractPackage(dmPackagePath, gameLocation '\')

        ; Change aoc version to 1.5
        RunWait(dmapp.tools.version.file ' 1.5')

        ; Update the linker in the game executable
        FileCopy(gameLocation '\age2_x1\age2_x1.exe', dmapp.dmLocation '\', 1)
        age2_x1 := FileOpen(dmapp.dmLocation '\age2_x1.exe', 'rw')
        age2_x1.Pos := 2821668
        Loop 28 {
            age2_x1.WriteChar(0)
        }
        age2_x1.Pos := 2821668
        Loop StrLen(dmGameLinker) {
            c := SubStr(dmGameLinker, A_Index, 1)
            age2_x1.WriteChar(Ord(c))
        }
        age2_x1.Close()
        FileMove(dmapp.dmLocation '\age2_x1.exe', gameLocation '\age2_x1\', 1)
    } Else {
        If FileExist(gameLocation '\Games\' dmGameLinker '.xml')
            FileDelete(gameLocation '\Games\' dmGameLinker '.xml')
    }
    ctrl.TextEx := StrReplace(ctrl.Text, 'ing...')
    dmapp.enableOptions([dmInstall, dmUninstall])
    MsgBoxEx(dmName ' should be ' ctrl.Text 'ed by now!', dmapp.name, , 0x40, 5)
}

clearDM(Ctrl, Info) {
    dmName := modsList.Text
    dmPackage := dmapp.dmPackages[dmName]['packagePath']
    If FileExist(dmPackage)
        FileDelete(dmPackage)
    updateDM(modsList, Info)
}