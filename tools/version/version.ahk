#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk
#Include ..\..\libs\LockCheck.ahk

verapp := Version()
fixapp := FixPatch()

fixs := fixapp.Fixs
requiredVersions := verapp.requiredVersion
gameLocation := verapp.gameLocation

versionGui := GuiEx(, verapp.name)
versionGui.initiate()

versionGui.AddText('BackgroundTrans xm cRed w150 Center h30', 'The Age of Kings').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'aok.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

versions := Map(
    'Version', []
)

requiredVersions['aok'] := Map()
Loop Files, verapp.versionLocation '\aok\*', 'D' {
    H := versionGui.AddButtonEx('w150', AOK := A_LoopFileName, Button().checkedDisabled, applyVersion)
    requiredVersions['aok'][H] := 1
    versions['Version'].Push(H)
}

versionGui.AddText('BackgroundTrans cBlue ym w150 Center h30', 'The Conquerors').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'aoc.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

requiredVersions['aoc'] := Map()
Loop Files, verapp.versionLocation '\aoc\*', 'D' {
    H := versionGui.addButtonEx('w150', AOC := A_LoopFileName, Button().checkedDisabled, applyVersion)
    requiredVersions['aoc'][H] := 2
    versions['Version'].Push(H)
}

versionGui.AddText('BackgroundTrans cGreen ym w150 Center h30', 'Forgotten Empires').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'fe.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

requiredVersions['fe'] := Map()
Loop Files, verapp.versionLocation '\fe\*', 'D' {
    H := versionGui.addButtonEx('w150', FE := A_LoopFileName, Button().checkedDisabled, applyVersion)
    requiredVersions['fe'][H] := 3
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

versionGui.showEx(, 1)

verapp.isGameFolderSelected(versionGui)

verapp.isCommandLineCall({
    wnd: versionGui,
    versionList: requiredVersions,
    callback: applyVersion
}
)

analyzeVersion()

findGame(ctrl) {
    fGame := ''
    If requiredVersions['aok'].Has(ctrl) {
        fGame := 'aok'
    }
    If requiredVersions['aoc'].Has(ctrl) {
        fGame := 'aoc'
    }
    If requiredVersions['fe'].Has(ctrl) {
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
    If requiredVersions.Has(fGame 'Combine') && requiredVersions[fGame 'Combine'].Has(ctrl.Text) {
        For version in requiredVersions[fGame 'Combine'][ctrl.Text] {
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
    verapp.enableOptions(requiredVersions[FGame := findGame(ctrl)], 0)
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
            verapp.enableOptions(requiredVersions[FGame])
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
            For control in requiredVersions[location] {
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
    If FileExist(gameLocation '\empires2.exe') {
        version := appliedVersionLookUp('aok')
        If Type(version) = 'Array' {
            verapp.enableOptions(requiredVersions['aok'])
            version[2].Enabled := False
        }
    }
    If FileExist(gameLocation '\age2_x1\age2_x1.exe') {
        version := appliedVersionLookUp('aoc')
        If Type(version) = 'Array' {
            verapp.enableOptions(requiredVersions['aoc'])
            version[2].Enabled := False
        }
    }
    If FileExist(gameLocation '\age2_x1\age2_x2.exe') {
        version := appliedVersionLookUp('fe')
        If Type(version) = 'Array' {
            verapp.enableOptions(requiredVersions['fe'])
            version[2].Enabled := False
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