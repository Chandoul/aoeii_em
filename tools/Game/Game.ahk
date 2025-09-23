#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\Libs\Base.ahk

app := Base()

gameLocation := app.gameLocation
gameLocationHistory := app.gameLocationHistory
gameRangerExecutable := app.gameRangerExecutable
gameRangerSetting := app.gameRangerSetting
gameRegLocation := app.gameRegLocation
gameLink := 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/Tools/Game/AGE%20OF%20EMPIRES%20II.7z'

gameGui := GuiEx(, Game().name)
gameGui.initiate()

select := gameGui.addButtonEx('xm w200', 'Select', , selectDirectory)

gameGui.addButtonEx('w200 yp', 'Open the selected', , (*) => DirExist(gameDirectory.Value) ? Run(gameDirectory.Value '\') : '')

gameDirectory := gameGui.AddEdit('cWhite xm ReadOnly w420 -E0x200 Border Background000000 Center')

selectFromGR := gameGui.addButtonEx('xm w200', 'Select from GameRanger', , selectDirectoryGR)

gameGui.addButtonEx('w200 yp Disabled', 'Set into GameRanger').OnEvent('Click', setDirectoryGR)

gameGui.addButtonEx('xm w420', 'Download the game').OnEvent('Click', downloadGame)

gameGui.addButtonEx('xm w420', 'Delete the game').OnEvent('Click', deleteGame)

gameGui.SetFont('s9')

desktopShortcuts := gameGui.AddCheckBoxEx('BackgroundTrans', 'Notify to add the game desktop shortcuts', gameShortcuts)

PBT := gameGui.AddText('Center w410 Hidden BackgroundTrans')
PB := gameGui.AddProgress('-Smooth wp Hidden')

gameGui.showEx(, 1)

userGameLocation := app.gameLocation
If !Game().isValidGameDirectory(userGameLocation) {
    selectDirectoryGR(selectFromGR, '')
}
userGameLocation := app.gameLocation
If !Game().isValidGameDirectory(userGameLocation) {
    If 'Yes' = MsgboxEx('Do you want to select the game folder manually?', 'Game Location', 0x4, 0x40).result
        selectDirectory(select, '')
}

userGameLocation := app.gameLocation
If !Game().isValidGameDirectory(userGameLocation) {
    Return
}

gameDirectory.Value := userGameLocation
If Game().addShortcuts && app.gameLocation {
    desktopShortcuts.Checked := 1
    addGameShortcuts()
    Return
} Else desktopShortcuts.Checked := 0

gameShortcuts(Ctrl, Info) {
    app.writeConfiguration('AddShortcuts', desktopShortcuts.Checked)
    If !desktopShortcuts.Checked
        Return
    If Game().isValidGameDirectory(gameDirectory.Value) {
        addGameShortcuts()
    }
}

setDirectoryGR(Ctrl, Info) {
    Ctrl.Enabled := False
    If !Game().isValidGameDirectory(gameDirectory.Value) {
        If 'Yes' != MsgboxEx('Game is not yet located!, want to select now?', 'Game', 0x4, 0x40).result {
            Ctrl.Enabled := True
            Return
        }
        selectDirectory(select, '')
    }
    If !ProcessExist('GameRanger.exe') {
        MsgboxEx('Make sure GameRanger is running!', 'Invalid', , 0x30)
        Ctrl.Enabled := True
        Return
    }

    MacroSelect(Game, Row) {
        If !FileExist(gameDirectory.Value '\' Game) {
            Ctrl.Enabled := True
            Return False
        }
        Run(gameRangerExecutable)
        WinActivate('ahk_exe GameRanger.exe')
        If !WinWaitActive('ahk_exe GameRanger.exe', , 5) {
            MsgboxEx('Unable to get the GameRanger window!', 'Invalid', , 0x30)
            Ctrl.Enabled := True
            Return False
        }
        Sleep(500)
        SendInput('^e')
        Sleep(500)
        If !WinWaitActive('Options ahk_exe GameRanger.exe', , 5) {
            MsgboxEx('Unable to get the GameRanger option window!', 'Invalid', , 0x30)
            Ctrl.Enabled := True
            Return False
        }
        ControlChooseIndex(1, 'SysTabControl321', 'Options ahk_exe GameRanger.exe')
        ControlFocus('SysListView321', 'Options ahk_exe GameRanger.exe')
        SendInput('{Home}')
        SendInput('{Down ' Row '}')
        WinGetPos(&X, &Y, &W, &H, 'Options ahk_exe GameRanger.exe')
        MouseClick('Left', W - 115, H - 65)
        If !WinWaitActive('Choose ahk_exe GameRanger.exe', , 5) {
            MsgboxEx('Unable to get the GameRanger selection window!', 'Invalid', , 0x30)
            Ctrl.Enabled := True
            Return False
        }
        ControlSetText(gameDirectory.Value '\' Game, 'Edit1', 'Choose ahk_exe GameRanger.exe')
        WinGetPos(&X, &Y, &W, &H, 'Choose ahk_exe GameRanger.exe')
        MouseClick('Left', W - 50, H - 120)
        WinClose('Options ahk_exe GameRanger.exe')
        Return True
    }
    If !MacroSelect('empires2.exe', 12)
        || !MacroSelect('age2_x1\age2_x1.exe', 14)
        || !MacroSelect('age2_x1\age2_x2.exe', 11) {
            MsgboxEx('No game was found!', 'Invalid', , 0x30)
            Ctrl.Enabled := True
            Return False
    }
    MsgboxEx('Game selected successfully!`n`nNow GameRanger must restart to unlock the game excutables`nRestarting in 5 seconds...', 'Game select', , 0x40, 5)
    ProcessClose('GameRanger.exe')
    Run(gameRangerExecutable)
    Ctrl.Enabled := True
}

writeNewLocation(Location) {
    Location := StrUpper(Location)
    app.writeConfiguration('GameLocation', Location)
}

selectDirectoryGR(Ctrl, Info) {
    Ctrl.Enabled := False
    Text := binGrabText(gameRangerSetting)
    Locations := textGrabPath(Text, ['empires2.exe', 'age2_x1.exe', 'age2_x2.exe'])
    For Location in Locations {
        If RC := Game().isValidGameDirectory(Location) {
            Choice := MsgboxEx('Do you want to select this location? (Grabbed from GameRanger setting)`n`n"' Location '"', 'Game Location', 0x4, 0x40).result
            If Choice = 'Yes' {
                gameDirectory.Value := Location
                writeNewLocation(Location)
                addGameShortcuts()
                Break
            }
        }
    }
    Ctrl.Enabled := True
}

selectDirectory(Ctrl, Info) {
    Ctrl.Enabled := False
    If SelectedDirectory := FileSelect('D') {
        If !Valid := Game().isValidGameDirectory(SelectedDirectory) {
            SelectedDirectoryEx := SelectedDirectory
            SelectedDirectory := ''
            SplitPath(SelectedDirectoryEx, &_, &ParentSelectedDirectory)
            If Valid := Game().isValidGameDirectory(ParentSelectedDirectory) {
                Choice := MsgboxEx('Want to select this location?`n`n' ParentSelectedDirectory, 'Game Location', 0x4, 0x40).result
                If Choice = 'Yes' {
                    SelectedDirectory := ParentSelectedDirectory
                }
            }
        }
        If !Valid {
            Loop Files, SelectedDirectoryEx '\*', 'D' {
                If Game().isValidGameDirectory(A_LoopFileFullPath) {
                    Choice := MsgboxEx('Want to select this location?`n`n' A_LoopFileFullPath, 'Game Location', 0x4, 0x40).result
                    If Choice = 'Yes' {
                        SelectedDirectory := A_LoopFileFullPath
                        Break
                    }
                }
            }
        }
        If SelectedDirectory != '' {
            gameDirectory.Value := StrUpper(SelectedDirectory)
            writeNewLocation(SelectedDirectory)
            addGameShortcuts()
        } Else {
            MsgboxEx("Game still not selected/found, please a valid location!", 'Game location', , 0x30)
        }
    }
    Ctrl.Enabled := True
}

deleteGame(Ctrl, Info) {
    Ctrl.Enabled := False
    If FileExist('UninstallGame.ahk') {
        Run('UninstallGame.ahk "' gameDirectory.Value '"')
    }
    Ctrl.Enabled := True
}

downloadGame(Ctrl, Info) {
    If !app.getConnectedState() {
        MsgboxEx('Make sure you are connected to the internet!', "Can't download!", , 0x30).result
        Return
    }
    If (selectedDestination := FileSelect('D', , 'Game install location')) &&
        downloadAgree := 'Yes' == MsgboxEx(
            'Are you sure want to install at this location?`n' selectedDestination,
            'Game install location', 0x4, 0x40
        ).result
        if downloadAgree {
            selectedDestination := RegExReplace(selectedDestination, "\$")
            selectedDestination := selectedDestination '\Age of Empires II'
            If !DirExist(selectedDestination) {
                DirCreate(selectedDestination)
            }

            If Game().isValidGameDirectory(selectedDestination) && ('Yes' != MsgboxEx('It seems like the game already installed at this location!`nWant to continue? (overwite)', 'Game location install', 0x4, 0x30).result) {
                Return
            }

            Ctrl.Enabled := False

            app.downloadPackage(gameLink, Game().gamePackage, 269, PBT, PB)

            app.extractPackage(Game().gamePackage, selectedDestination, , PBT)

            updateGameRegInfo(selectedDestination)

            If 'Yes' = MsgboxEx('Game exportation should be completed by now!`nDo you want to select this location "' selectedDestination '" ?', 'Game install location', 0x4, 0x40).result {
                gameDirectory.Value := StrUpper(selectedDestination)
                writeNewLocation(selectedDestination)
                addGameShortcuts()
            }
            Ctrl.Enabled := True
            PBT.Visible := False
        }
}

updateGameRegInfo(location, description := '20.10.22') {
    RegWrite('Age of Empires II AIO', 'REG_SZ', gameRegLocation, 'DisplayName')
    RegWrite(description, 'REG_SZ', gameRegLocation, 'DisplayVersion')
    RegWrite(location '\age2_x1\age2_x1.exe', 'REG_SZ', gameRegLocation, 'DisplayIcon')
    RegWrite(location, 'REG_SZ', gameRegLocation, 'InstallLocation')
    RegWrite(1, 'REG_DWORD', gameRegLocation, 'NoModify')
    RegWrite(1, 'REG_DWORD', gameRegLocation, 'NoRepair')
    RegWrite(app.folderGetSize(location), 'REG_DWORD', gameRegLocation, 'EstimatedSize')
    RegWrite('Microsoft Corporation', 'REG_SZ', gameRegLocation, 'Publisher')
    RegWrite('"' A_AhkPath '" "' A_ScriptDir '\UninstallGame.ahk" "' location '"', 'REG_SZ', gameRegLocation, 'UninstallString')
}

binGrabText(filepath) {
    Text := ''
    bufferObj := FileRead(filepath, 'RAW')
    Loop bufferObj.Size {
        Address := A_Index - 1
        Byte := NumGet(bufferObj, Address, 'UChar')
        If (C := Chr(Byte)) != '' {
            Text .= C
        }
    }
    Return Text
}

textGrabPath(textFound, executables) {
    resultMap := Map()
    For Each, executable in executables {
        P := InStr(textFound, LFE := executable, , -1)
        Loop {
            Char := SubStr(textFound, P - (I := A_Index), 1)
            LFE := Char LFE
        } Until (Char = ':' || Ord(Char) = 10 || Ord(Char) = 13)
        foundPath := SubStr(textFound, P - (I + 1), 1) LFE
        foundPath := StrReplace(foundPath, '\' executables[1])
        foundPath := StrReplace(foundPath, '\age2_x1\' executables[2])
        foundPath := StrReplace(foundPath, '\age2_x1\' executables[3])
        if DirExist(foundPath)
            resultMap[StrUpper(foundPath)] := True
    }
    Return resultMap
}

addGameShortcuts() {
    location := app.gameLocation
    addShortcuts := Game().addShortcuts
    If addShortcuts && Game().isValidGameDirectory(location) {
        createShortcut := False
        If FileExist(location '\empires2.exe') {
            If !FileExist(A_Desktop '\The Age of Kings.lnk') {
                createShortcut := True
            } Else {
                FileGetShortcut(A_Desktop '\The Age of Kings.lnk', &outTarget)
                If outTarget != location '\empires2.exe' {
                    createShortcut := True
                } Else {
                    createShortcut := False
                }
            }
        }
        If FileExist(location '\age2_x1\age2_x1.exe') && !createShortcut {
            If !FileExist(A_Desktop '\The Conquerors.lnk') {
                createShortcut := True
            } Else {
                FileGetShortcut(A_Desktop '\The Conquerors.lnk', &outTarget)
                If outTarget != location '\age2_x1\age2_x1.exe' {
                    createShortcut := True
                } Else {
                    createShortcut := False
                }
            }
        }
        If FileExist(location '\age2_x1\age2_x2.exe') && !createShortcut {
            If !FileExist(A_Desktop '\Forgotten Empires.lnk') {
                createShortcut := True
            } Else {
                FileGetShortcut(A_Desktop '\Forgotten Empires.lnk', &outTarget)
                If outTarget != location '\age2_x1\age2_x2.exe' {
                    createShortcut := True
                } Else {
                    createShortcut := False
                }
            }
        }
        If createShortcut {
            If 'Yes' = MsgboxEx('Want to create the game desktop shortcuts?', 'Game', 0x4, 0x40, 5).result {
                FileCreateShortcut(location '\empires2.exe', A_Desktop '\The Age of Kings.lnk', location)
                FileCreateShortcut(location '\age2_x1\age2_x1.exe', A_Desktop '\The Conquerors.lnk', location '\age2_x1')
                FileCreateShortcut(location '\age2_x1\age2_x2.exe', A_Desktop '\Forgotten Empires.lnk', location '\age2_x1')
            }
        }
    }
}