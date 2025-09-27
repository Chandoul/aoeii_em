#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk
#Include ..\..\libs\LockCheck.ahk

verapp := Version()
fixapp := FixPatch()

fixs := fixapp.Fixs
availableVersions := verapp.requiredVersion
gameLocation := verapp.gameLocation

versionGui := GuiEx(, verapp.name)
versionGui.initiate()

versionGui.AddText('BackgroundTrans xm cRed w150 Center h30', 'The Age of Kings').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'aok.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

versions := Map(
    'Version', []
)

availableVersions['aok'] := Map()
Loop Files, verapp.versionLocation '\aok\*', 'D' {
    H := versionGui.AddButtonEx('w150', AOK := A_LoopFileName, Button().checkedDisabled, applyVersion)
    availableVersions['aok'][H] := 1
    versions['Version'].Push(H)
}

versionGui.AddText('BackgroundTrans cBlue ym w150 Center h30', 'The Conquerors').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'aoc.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

availableVersions['aoc'] := Map()
Loop Files, verapp.versionLocation '\aoc\*', 'D' {
    H := versionGui.addButtonEx('w150', AOC := A_LoopFileName, Button().checkedDisabled, applyVersion)
    availableVersions['aoc'][H] := 2
    versions['Version'].Push(H)
}

versionGui.AddText('BackgroundTrans cGreen ym w150 Center h30', 'Forgotten Empires').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'fe.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

availableVersions['fe'] := Map()
Loop Files, verapp.versionLocation '\fe\*', 'D' {
    H := versionGui.addButtonEx('w150', FE := A_LoopFileName, Button().checkedDisabled, applyVersion)
    availableVersions['fe'][H] := 3
    versions['Version'].Push(H)
}

versionGui.SetFont('s9')
versionGui.AddText('xm+550 ym+85 BackgroundTrans', 'Options to apply after each change:').SetFont('Bold')
versionGui.MarginY := 10

autoFix := versionGui.addCheckBoxEx(, 'Auto enable a fix:', patchEnable)
fixChoice := versionGui.AddDropDownList('w200 Disabled Choose6', fixs)
autoFix.Checked := verapp.readConfiguration('autoFix')

ddrAuto := versionGui.addCheckBoxEx(, 'Auto enable direct draw fix', ddrEnable)
ddrAuto.Checked := verapp.readConfiguration('ddrAuto')

versionGui.MarginY := 20


verapp.isGameFolderSelected(versionGui)

verapp.isCommandLineCall({
    wnd: versionGui,
    versionList: availableVersions,
    callback: applyVersion
}
)

versionGui.showEx(, 1)
analyzeVersion()

findGame(ctrl) {
    fGame := ''
    If availableVersions['aok'].Has(ctrl) {
        fGame := 'aok'
    }
    If availableVersions['aoc'].Has(ctrl) {
        fGame := 'aoc'
    }
    If availableVersions['fe'].Has(ctrl) {
        fGame := 'fe'
    }
    Return fGame
}

cleansUp(fGame) {
    Loop Files, verapp.versionLocation '\' fGame '\*', 'D' {
        version := A_LoopFileName
        Loop Files, verapp.versionLocation '\' fGame '\' version '\*.*', 'R' {
            pathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, verapp.versionLocation '\' fGame '\' version '\')
            If FileExist(gameLocation '\' pathFile) {
                FileDelete(gameLocation '\' pathFile)
            }
        }
    }
}

applyReqVersion(ctrl, fGame) {
    If availableVersions.Has(fGame 'Combine') && availableVersions[fGame 'Combine'].Has(ctrl.Text) {
        For version in availableVersions[fGame 'Combine'][ctrl.Text] {
            If DirExist(verapp.versionLocation '\' fGame '\' version) {
                DirCopy(verapp.versionLocation '\' fGame '\' version, gameLocation, 1)
            }
        }
    }
    If DirExist(verapp.versionLocation '\' fGame '\' ctrl.Text) {
        DirCopy(verapp.versionLocation '\' fGame '\' ctrl.Text, gameLocation, 1)
    }
}

applyVersion(ctrl, info) {
    verapp.enableOptions(availableVersions[FGame := findGame(ctrl)], 0)
    Try {
        cleansUp(FGame)
        applyReqVersion(ctrl, FGame)
        If autoFix.cbValue && fixChoice.Text != ''
            Try RunWait('"' fixapp.fixTool '" "' fixChoice.Text '"')
        If ddrAuto.cbValue {
            verapp.applyDDrawFix()
        }
    } Catch {
        If !lockCheck(gameLocation) {
            verapp.enableOptions(availableVersions[FGame])
            Return
        }
        cleansUp(FGame)
        applyReqVersion(ctrl, FGame)
        If autoFix.cbValue && fixChoice.Text != ''
            Try RunWait('"' fixapp.fixTool '" "' fixChoice.Text '"')
        If ddrAuto.cbValue {
            verapp.applyDDrawFix()
        }
    }
    analyzeVersion()
    SoundPlay(verapp.workDirectory '\assets\mp3\30 Wololo.mp3')
}

; Return a game version based on the available versions
appliedVersionLookUp(
    location,
    ignoreFiles := Map(
        'wndmode.dll', 1
    )
) {
    matchVersion := ''
    Loop Files, verapp.versionLocation '\' location '\*', 'D' {
        version := A_LoopFileName
        If fixapp.folderMatch(A_LoopFileFullPath, gameLocation, ignoreFiles) {
            For control in availableVersions[location] {
                If control.Text = version {
                    Return [matchVersion, control]
                }
            }
        }
    }
    Return ''
}

; Analyzes game versions
analyzeVersion() {
    result := verapp.getGameVersions()
    If FileExist(gameLocation '\empires2.exe') {
        verapp.enableOptions(availableVersions['aok'])
        For verButton in availableVersions['aok'] {
            verButton.Enabled := result['aok'] != verButton.Text
        }
    }
    If FileExist(gameLocation '\age2_x1\age2_x1.exe') {
        verapp.enableOptions(availableVersions['aoc'])
        For verButton in availableVersions['aoc'] {
            verButton.Enabled := result['aoc'] != verButton.Text
        }
    }
    If FileExist(gameLocation '\age2_x1\age2_x2.exe') {
        verapp.enableOptions(availableVersions['fe'])
        For verButton in availableVersions['fe'] {
            verButton.Enabled := result['fe'] != verButton.Text
        }
    }
}

launchGame(Ctrl, Info) {
    If InStr(Ctrl.Value, 'aok') && FileExist(gameLocation '\empires2.exe') {
        Run(gameLocation '\empires2.exe', gameLocation)
    }
    If InStr(Ctrl.Value, 'aoc') && FileExist(gameLocation '\age2_x1\age2_x1.exe') {
        Run(gameLocation '\age2_x1\age2_x1.exe', gameLocation)
    }
    If InStr(Ctrl.Value, 'fe') && FileExist(gameLocation '\age2_x1\age2_x2.exe') {
        Run(gameLocation '\age2_x1\age2_x2.exe', gameLocation)
    }
}

patchEnable(Ctrl, Info) {
    fixChoice.Enabled := Ctrl.cbValue
    verapp.writeConfiguration('autoFix', Ctrl.cbValue)
}

ddrEnable(Ctrl, Info) {
    verapp.writeConfiguration('ddrAuto', Ctrl.cbValue)
}