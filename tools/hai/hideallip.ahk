#SingleInstance Force
#Requires AutoHotkey v2

#Include ..\..\libs\Base.ahk

haiapp := Base()
haiapp.__Startup()

osVers := Map(
    '13_WIN95', { version: '4.00', title: 'Windows 95' },
    '12_WINNT4SP5', { version: '4.0', title: 'Windows NT4' },
    '11_WIN98', { version: '4.10', title: 'Windows 98' },
    '10_WIN2000', { version: '5.0', title: 'Windows 2000' },
    '09_WINXPSP2', { version: '5.1', title: 'Windows XP SP2' },
    '08_WINXPSP3', { version: '5.1', title: 'Windows XP SP3' },
    '07_VISTARTM', { version: '6.0', title: 'Windows Vista' },
    '06_VISTASP1', { version: '6.0', title: 'Windows Vista SP1' },
    '05_VISTASP2', { version: '6.0', title: 'Windows Vista SP2' },
    '04_WIN7RTM', { version: '6.1', title: 'Windows 7' },
    '03_WIN8RTM', { version: '6.2', title: 'Windows 8' },
    '02_WIN81RTM', { version: '6.3', title: 'Windows 8.1' },
    '01_WIN10RTM', { version: '10.0', title: 'Windows 10' },
)


haiGui := GuiEx(, 'Hide All IP Trial Reset')
haiGui.initiate(, , 0)
haiGui.addButtonEx('xm w500', 'Reset Trial Period', , resetTrial)
haiGui.AddText('wp Center BackgroundTrans', 'Manually set a compatibility')
manualList := haiGui.AddListView('xm Checked r10 wp -Hdr BackgroundFFD4A8', ['options', 'name'])
manualList.ModifyCol(1, 478)
manualList.ModifyCol(2, 0)
manualList.OnEvent('ItemCheck', itemCheck)
haiGui.SetFont('s8')
autoStart := haiGui.addCheckBoxEx(, 'Auto start [ Hide All IP ] after each change', autoStartEnable)
autoStart.Checked := haiapp.readConfiguration('haiAutoStart')

haiGui.showEx(, 1)
loadList()

autoStartEnable(Ctrl, *) => haiapp.writeConfiguration('haiAutoStart', Ctrl.cbValue)

itemCheck(Ctrl, Item, Checked) {
    Static haiPath := (A_Is64bitOS ? EnvGet('ProgramFiles(x86)') : EnvGet('ProgramFiles')) '\Hide All IP\HideALLIP.exe'
    If !FileExist(haiPath) {
        If !haiPath := FileSelect(, , 'Select hide all ip application', 'Application (*.exe; *.lnk)') {
            manualList.Modify(Item, '-Check')
            MsgBoxEx("Hide All IP not found!`nYou must install Hide All IP first", 'Hide All IP Trial Reset', , 0x30)
            Return
        }
    }
    R := 0
    Switch Checked {
        Case 0: haiapp.compatibilityClear(, haiPath)
        Case 1:
            While R := manualList.GetNext(R, 'C') {
                If R != Item {
                    manualList.Modify(R, '-Check')
                }
            }
            compatibility := manualList.GetText(Item, 2)
            haiapp.compatibilitySet(, haiPath, compatibility)
    }
    if autoStart.cbValue {
        ProcessCloseEx('HideALLIP.exe')
        Run(haiPath)
    }
}

resetTrial(*) {
    Static compatibilities := getCompatibilities()
    Static haiPath := (A_Is64bitOS ? EnvGet('ProgramFiles(x86)') : EnvGet('ProgramFiles')) '\Hide All IP\HideALLIP.exe'
    If !FileExist(haiPath) {
        If !haiPath := FileSelect(, , 'Select hide all ip application', 'Application (*.exe; *.lnk)') {
            MsgBoxEx("Hide All IP not found!`nYou must install Hide All IP first", 'Hide All IP Trial Reset', , 0x30)
            Return
        }
    }
    attempt := 0
    For compatibilityArr in compatibilities {
        For compatibility in compatibilityArr {
            applyReset(compatibility)
            attempt += 1
            if "Yes" != MsgBoxEx(
                'Attempt [ ' attempt ', ' compatibility ' ] :`nStill not working?, give this another try?`nYou still got [ ' (compatibilities.Length * 2) - attempt ' ] attempts left.',
                'Hide All IP Trial Reset', 0x4, 0x20
            ).result {
                Return
            }
        }
    }
}

ProcessCloseEx(PN) {
    If ProcessExist(PN) {
        ProcessClose(PN)
        ProcessWaitClose(PN, 3)
    }
}

getCompatibilities() {
    list := []
    currOSVer := StrSplit(A_OSVersion, '.')
    currOSVer := currOSVer[1] '.' currOSVer[2]
    For compat, osVer in osVers {
        if osVer.version >= currOSVer {
            Continue
        }
        compatibilityValue := StrSplit(compat, '_')[2]
        list.Push([compatibilityValue, compatibilityValue ' RUNASADMIN'])
    }
    Return list
}

loadList() {
    currOSVer := StrSplit(A_OSVersion, '.')
    currOSVer := currOSVer[1] '.' currOSVer[2]
    For compatibility, info in osVers {
        if info.version >= currOSVer {
            Continue
        }
        name := StrSplit(compatibility, '_')[2]
        manualList.add(, info.title ' ( ' name ' )', name)
    }
    For compatibility, info in osVers {
        if info.version >= currOSVer {
            Continue
        }
        name := StrSplit(compatibility, '_')[2]
        manualList.add(, info.title ' + Run as admin ( ' name ' RUNASADMIN )', name ' RUNASADMIN')
    }
}

applyReset(compatibility) {
    Static haiPath := (A_Is64bitOS ? EnvGet('ProgramFiles(x86)') : EnvGet('ProgramFiles')) '\Hide All IP\HideALLIP.exe'
    ProcessCloseEx('HideALLIP.exe')

    Loop Parse, "HKCU|HKLM", '|' {
        hk := A_LoopField
        Loop Parse, "Software\HideAllIP|Software\Wow6432Node\HideAllIP", '|' {
            Loop Reg, hk "\" A_LoopField {
                RegDeleteKey(A_LoopRegkey)
            }
        }
    }
    haiapp.compatibilityClear(, haiPath)

    Run(haiPath)
    If !WinWait('ahk_class THintTimeForm ahk_exe HideALLIP.exe', , 20) {
        MsgBoxEx("Activation attempt failed!`nThe Hint Time Form wasn't found.", 'Hide All IP Trial Reset', , 0x30)
        Return
    }
    ProcessCloseEx('HideALLIP.exe')

    haiapp.compatibilitySet(, haiPath, compatibility)

    Run(haiPath)
    If !WinWait('ahk_class THintTimeForm ahk_exe HideALLIP.exe', , 20) {
        MsgBoxEx("Activation attempt failed!`nThe Hint Time Form wasn't found.", 'Hide All IP Trial Reset', , 0x30)
        Return
    }

    ProcessCloseEx('HideALLIP.exe')

    haiapp.compatibilityClear(, haiPath)

    Run(haiPath)
}