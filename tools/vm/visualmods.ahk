#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

vmapp := VisualMod()

gameLocation := vmapp.gameLocation
drsMap := vmapp.drsMap

vmGui := GuiEx('Resize', vmapp.name)
vmGui.initiate()

vmGui.AddText('xm w200 BackgroundTrans', 'Search')
search := vmGui.AddEdit('Border -E0x200 w200')
search.OnEvent('Change', quickSearch)

modsList := vmGui.AddListBox('wp r20 BackgroundE1B15A -E0x200')
modsList.OnEvent('Change', showInfo)

quickSearch(ctrl, info) {
    modsList.Delete()
    searchValue := ctrl.Text
    Loop Files, vmapp.vmLocation '\*', 'D' {
        If searchValue != '' && !InStr(A_LoopFileName, searchValue) {
            Continue
        }
        modsList.Add([A_LoopFileName])
    }
}

Loop Files, vmapp.vmLocation '\*', 'D' {
    modsList.Add([A_LoopFileName])
}
vmThumbnail := vmGui.addPictureEx('ym+37 Border')
vmGui.SetFont('s8')
vmDescription := vmGui.addEdit('ym+37 w300 hp Backgrounddcb670 ReadOnly -E0x200')
vmGui.SetFont('s10')
vmInstall := vmGui.addButtonEx('xp-170 yp+140 w225', 'Install', , updateVM)
vmUninstall := vmGui.addButtonEx('wp yp', 'Uninstall', , updateVM)
vmGui.showEx(, 1)

vmapp.isGameFolderSelected(vmGui)

modsList.Choose(1)
showInfo(modsList, '')

showInfo(ctrl, info) {
    modName := ctrl.Text
    vmThumbnail.Value := FileExist(vmapp.vmLocation '\' modName '\img.png') ? vmapp.vmLocation '\' modName '\img.png' : vmThumbnail.Value
    vmDescription.Value := FileExist(vmapp.vmLocation '\' modName '\info.txt') ? FileRead(vmapp.vmLocation '\' modName '\info.txt') : ''
}

/**
 * Install or uninstall a game visual mod
 * @param ctrl 
 * @param info 
 */
updateVM(ctrl, info) {
    vmapp.enableOptions([vmInstall, vmUninstall], 0)
    vmName := modsList.Text
    apply := ctrl.Text = 'Install'
    If apply {
        ctrl.TextEx := 'Installing...'
        workDir := vmapp.vmLocation '\' vmName
        copyFolder := vmapp.vmLocation '\' vmName '\Install'
    } Else {
        workDir := vmapp.vmLocation '\' vmName '\U'
        copyFolder := vmapp.vmLocation '\' vmName '\Uninstall'
        ctrl.TextEx := 'Uninstalling...'
    }

    If FileExist(workDir '\gra*.slp')
        RunWait('"' vmapp.drsBuild '" /a "' gameLocation '\Data\' drsMap['gra'] '" "' workDir '\gra*.slp"', , 'Hide')
    If FileExist(workDir '\int*.slp')
        RunWait('"' vmapp.drsBuild '" /a "' gameLocation '\Data\' drsMap['int'] '" "' workDir '\int*.slp"', , 'Hide')
    If FileExist(workDir '\ter*.slp')
        RunWait('"' vmapp.drsBuild '" /a "' gameLocation '\Data\' drsMap['ter'] '" "' workDir '\ter*.slp"', , 'Hide')

    If DirExist(copyFolder) {
        Loop Files, copyFolder '\*', 'RFD' {
            pathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, copyFolder '\')
            If DirExist(gameLocation '\' pathFile)
                DirDelete(gameLocation '\' pathFile, 1)
            If FileExist(gameLocation '\' pathFile)
                FileDelete(gameLocation '\' pathFile)
        }
        DirCopy(copyFolder, gameLocation, 1)
    }

    ctrl.TextEx := StrReplace(ctrl.Text, 'ing...')

    vmapp.enableOptions([vmInstall, vmUninstall])
    MsgBoxEx(vmName ' should be ' ctrl.Text 'ed by now!', vmapp.name, , 0x40, 5)
}