#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk
#Include ..\..\libs\LockCheck.ahk

ver := Version()
fix := FixPatch()

fixs := fix.Fixs
requiredVersions := ver.requiredVersion
gameLocation := ver.gameLocation
versionLink := ver.versionLink

versionGui := GuiEx(, ver.name)
versionGui.initiate()

versionGui.AddText('BackgroundTrans xm cRed w150 Center h30', 'The Age of Kings').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'aok.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

versions := Map(
    'Version', []
)

requiredVersions['aok'] := Map()
Loop Files, ver.versionLocation '\aok\*', 'D' {
    H := versionGui.AddButtonEx('w150', AOK := A_LoopFileName, , applyVersion)
    requiredVersions['aok'][H] := 1
    versions['Version'].Push(H)
}

versionGui.AddText('BackgroundTrans cBlue ym w150 Center h30', 'The Conquerors').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'aoc.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

requiredVersions['aoc'] := Map()
Loop Files, ver.versionLocation '\aoc\*', 'D' {
    H := versionGui.addButtonEx('w150', AOC := A_LoopFileName, , applyVersion)
    requiredVersions['aoc'][H] := 2
    versions['Version'].Push(H)
}

versionGui.AddText('BackgroundTrans cGreen ym w150 Center h30', 'Forgotten Empires').SetFont('Bold s12')
versionGui.AddPictureEx('xp+59 yp+30', 'fe.png', launchGame)
versionGui.AddText('BackgroundTrans xp-59 yp+35 w1 h1')

requiredVersions['fe'] := Map()
Loop Files, ver.versionLocation '\fe\*', 'D' {
    H := versionGui.addButtonEx('w150', FE := A_LoopFileName, , applyVersion)
    requiredVersions['fe'][H] := 3
    versions['Version'].Push(H)
}

versionGui.SetFont('s8')

autoFix := versionGui.addCheckBoxEx('xm', 'Auto enable a fix after each change:', patchEnable)
versionGui.MarginY := 5

fixChoice := versionGui.AddDropDownList('xm w200 Disabled', fixs)
autoFix.Checked := ver.readConfiguration('autoFix')

versionGui.MarginY := 10

ddrAuto := versionGui.addCheckBoxEx('xm', 'Auto enable direct draw fix after each change', ddrEnable)
ddrAuto.Checked := ver.readConfiguration('ddrAuto')

versionGui.showEx(, 1)

ver.isGameFolderSelected(versionGui)

ver.isCommandLineCall({
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
    Loop Files, ver.versionLocation '\' fGame '\*', 'D' {
        version := A_LoopFileName
        Loop Files, ver.versionLocation '\' fGame '\' version '\*.*', 'R' {
            pathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, ver.versionLocation '\' fGame '\' version '\')
            If FileExist(gameLocation '\' pathFile) {
                FileDelete(gameLocation '\' pathFile)
            }
        }
    }
}

applyReqVersion(ctrl, fGame) {
    If requiredVersions.Has(fGame 'Combine') && requiredVersions[fGame 'Combine'].Has(ctrl.Text) {
        For version in requiredVersions[fGame 'Combine'][ctrl.Text] {
            If DirExist(ver.versionLocation '\' fGame '\' version) {
                DirCopy(ver.versionLocation '\' fGame '\' version, gameLocation, 1)
            }
        }
    }
    If DirExist(ver.versionLocation '\' fGame '\' ctrl.Text) {
        DirCopy(ver.versionLocation '\' fGame '\' ctrl.Text, gameLocation, 1)
    }
}

applyVersion(ctrl, info) {
    disableOptions(FGame := findGame(ctrl))
    Try {
        cleansUp(FGame)
        applyReqVersion(ctrl, FGame)
        If autoFix.cbValue && fixChoice.Text != ''
            Try RunWait('"' fix.fixTool '" "' fixChoice.Text '"')
        If ddrAuto.cbValue {
            ver.applyDDrawFix()
        }
    } Catch {
        If !lockCheck(gameLocation) {
            enableOptions(FGame)
            Return
        }
        cleansUp(FGame)
        applyReqVersion(ctrl, FGame)
        If autoFix.cbValue && fixChoice.Text != ''
            Try RunWait('"' fix.fixTool '" "' fixChoice.Text '"')
        If ddrAuto.cbValue {
            ver.applyDDrawFix()
        }
    }
    analyzeVersion()
    SoundPlay(ver.workDirectory '\assets\mp3\30 Wololo.mp3')
}

; Enables a versions list
enableOptions(Game) {
    For Item in requiredVersions[Game] {
        Item.Enabled := True
    }
}
; Disables a versions list
disableOptions(Game) {
    For item in requiredVersions[Game] {
        item.Enabled := False
    }
}

; Return a game version based on the available versions
appliedVersionLookUp(location) {
    matchVersion := ''
    Loop Files, ver.versionLocation '\' location '\*', 'D' {
        version := A_LoopFileName
        match := True
        Loop Files, ver.versionLocation '\' location '\' version '\*.*', 'R' {
            pathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, ver.versionLocation '\' location '\' version '\')
            If !FileExist(gameLocation '\' pathFile) && match {
                match := False
                Break
            }
            currentHash := ver.hashFile(, A_LoopFileFullPath)
            foundHash := ver.hashFile(, gameLocation '\' pathFile)
            If (currentHash != foundHash) && match {
                match := False
                Break
            }
        }
        If match {
            matchVersion := version
        }
    }
    If matchVersion {
        For control in requiredVersions[location] {
            If control.Text = matchVersion {
                Return [matchVersion, control]
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
            For game, version in requiredVersions['aok'] {
                game.Enabled := True
            }
            version[2].Enabled := False
        }
    }
    If FileExist(gameLocation '\age2_x1\age2_x1.exe') {
        version := appliedVersionLookUp('aoc')
        If Type(version) = 'Array' {
            For game, version in requiredVersions['aoc'] {
                game.Enabled := True
            }
            version[2].Enabled := False
        }
    }
    If FileExist(gameLocation '\age2_x1\age2_x2.exe') {
        version := appliedVersionLookUp('fe')
        If Type(version) = 'Array' {
            For game, version in requiredVersions['fe'] {
                game.Enabled := True
            }
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
    ver.writeConfiguration('autoFix', Ctrl.cbValue)
}

ddrEnable(Ctrl, Info) {
    ver.writeConfiguration('ddrAuto', Ctrl.cbValue)
}