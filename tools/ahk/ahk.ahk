#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk
#Include ..\..\libs\JSON.ahk

ahkapp := AHK()
ahkapp.__Startup()

ahkGui := GuiEx(, ahkapp.name)
ahkGui.initiate()

ahkList := ahkGui.AddListView('xm w600 r5 BackgroundE1B15A -E0x200', ['Hotkey', 'Comment'])
ahkList.OnEvent('Click', showHotkey)
HotkeyDef := readHotkey()
script := "
(
#Requires AutoHotkey v2
#SingleInstance Force
GroupAdd('AOKAOC', 'ahk_exe empires2.exe')
GroupAdd('AOKAOC', 'ahk_exe age2_x1.exe')
GroupAdd('AOKAOC', 'ahk_exe age2_x2.exe')
#HotIf WinActive('ahk_group AOKAOC')

; User section begin

)"
For hotkeyName, hotOpt in HotkeyDef {
    ahkList.Add(, hotkeyName, '# ' hotOpt['Comment'])
    script .= '`n' hotkeyName ':: {`n' hotOpt['Action'] '`n}'
}
script .= '
(


; User section end

#HotIf
If A_Args.Length {
ProcessWaitClose(A_Args[1])
ExitApp()
}
)'
ahkList.ModifyCol(1, 'AutoHdr')
ahkList.ModifyCol(2, 'AutoHdr')

ahkGui.addButtonEx('xm w100', 'Import', , import_v2_4_Hotkeys)
ahkGui.addButtonEx('yp xm+500 w100', 'Save', , updateHotkeys)

ahkGui.SetFont('s10')
addHotName := ahkGui.AddEdit('xm w600 Backgroundblack cWhite -E0x200')
addHotName.OnEvent('Change', (*) => autoSave())
addHotCom := ahkGui.AddEdit('w600 Backgroundblack cWhite -E0x200')
addHotCom.OnEvent('Change', (*) => autoSave())
addHotAction := ahkGui.AddEdit('w600 r10 Backgroundblack cYellow -E0x200')
addHotAction.OnEvent('Change', (*) => autoSave())
addHotAction.SetFont(, 'Consolas')

If FileExist(ahkapp.hotkeys) {
    hashSum := ahkapp.HashFile(, ahkapp.hotkeys)
    hotkeysFile := ahkapp.ahkLocation '\' hashSum '.ahk'
    If !FileExist(hotkeysFile) || FileRead(hotkeysFile) != script {
        FileOpen(hotkeysFile, 'w').Write(script)
    }
    Run(ahkapp.ahkLocation '\' hashSum '.ahk ' ProcessExist())
} Else {
    hashSum := ahkapp.HashFile(, ahkapp.defaulthotkeys)
    hotkeysFile := ahkapp.ahkLocation '\' hashSum '.ahk'
    If !FileExist(hotkeysFile) || FileRead(hotkeysFile) != script {
        FileOpen(hotkeysFile, 'w').Write(script)
    }
    Run(ahkapp.ahkLocation '\' hashSum '.ahk ' ProcessExist())
}

ahkGui.showEx(, 1)

showHotkey(Ctrl, Info) {
    Key := Ctrl.GetNext()
    If !Key {
        Return
    }
    hotkeyDef := readHotkey()
    If hotkeyDef.Has(hk := Ctrl.GetText(Key)) {
        addHotName.Value := hk
        AddHotCom.Value := hotkeyDef[hk]['Comment']
        addHotAction.Value := hotkeyDef[hk]['Action']
    }
}
autoSave() {
    If addHotName.Value != '' {
        HotkeyDef[addHotName.Value] := Map(
            'Action', addHotAction.Value,
            'Comment', AddHotCom.Value
        )
    }
}
updateHotkeys(Ctrl, Info) {
    updateHotkey(HotkeyDef)
    If MsgBoxEx('Changes are saved!`nTo take effect you need to reload the script, reload now?', 'Save', 0x4, 0x40).result = 'Yes' {
        Reload
    }
}
import_v2_4_Hotkeys(Ctrl, Info) {
    searcDir := FileSelect('D')
    hotkeyDef := readHotkey()
    Loop Files, searcDir '\*.ahk' {
        content := FileRead(A_LoopFileFullPath)
        If RegExMatch(content, "\QHotkey('\E(.*)\Q', Action)\E", &hkName) || RegExMatch(content, "(.*)::", &hkName) {
            If hotkeyDef.Has(hkName[1])
                Continue
            hotkeyDef[hkName[1]] := Map()
        }
        If RegExMatch(content, "s)Action\Q(*) \E{(.*)\Q}", &hkAction)
            hotkeyDef[hkName[1]]['Action'] := hkAction[1]
        If RegExMatch(content, ";(.*)", &hkComment)
            hotkeyDef[hkName[1]]['Comment'] := hkComment[1]
    }
    updateHotkey(hotkeyDef)
    Reload()
}
updateHotkey(Keys) => JSON.DumpFile(Keys, ahkapp.hotkeys, '`t')
readHotkey() {
    If FileExist(ahkapp.hotkeys)
        def := JSON.LoadFile(ahkapp.hotkeys)
    Else {
        def := JSON.LoadFile(ahkapp.defaulthotkeys)
    }
    Return def
}