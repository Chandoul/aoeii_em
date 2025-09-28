#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

fixapp := FixPatch()

fixGui := GuiEx(, fixapp.name)
fixGui.initiate()

fixs := fixapp.fixs
fixRegKey := fixapp.fixRegKey
fixRegName := fixapp.fixRegName
userRegLayer := fixapp.userRegLayer
machineRegLayer := fixapp.machineRegLayer
gameLocation := fixapp.gameLocation

fixOptions := Map(
    'Fixs', [],
    'FIXHandle', Map()
)
fixGui.AddText('xm w200 Center h25 BackgroundTrans', 'Select one of the fixes below').SetFont('Bold')
fixGui.SetFont('s9')
For each, fix in fixs {
    fixName := fixGui.addButtonEx('w200', fix, Button().checkedDisabled)
    fixName.OnEvent('Click', applyFix)
    fixOptions['Fixs'].Push(fixName)
    fixOptions['FIXHandle'][fix] := fixName
}

fixGui.SetFont('s9')
fixGui.AddText('xm+250 ym+5 BackgroundTrans', 'Options to enable along with the widescreen patch:').SetFont('Bold')
fixGui.MarginY := 10

; Water animation
waterAni := fixGui.addCheckBoxEx(, 'Water animation', waterAnimation)
waterAni.Checked := RegRead(fixRegKey, 'WaterAnnimation', 0) = 1 ? 1 : 0
waterAnimation(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'WaterAnnimation')
}

; Advanced interface
resInt := fixGui.addCheckBoxEx(, 'Show villagers count on each resource`nShow civilizations upgrades levels`nShow civlization next to score names', resourceInterface)
If RegRead(fixRegKey, 'Aoe2Patch', 0) = 1 {
    resInt.Checked := 1
}
resourceInterface(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'Aoe2Patch')
}

; Widescreen
centerInt := fixGui.addCheckBoxEx(, 'Centered widescreen', centeredlayInterface, 4)
If RegRead(fixRegKey, 'Aoe2Patch', 0) = 4 {
    centerInt.Checked := 4
}
centeredlayInterface(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'Aoe2Patch')
}

fixapp.groupCheckBoxs([
    resInt,
    centerInt
])

; Zooming functionality
zoomFunc := fixGui.addCheckBoxEx(, '(Fix v5 and above required) Zoom functionality`n[Note] Set the hotkey in the game commands!', zoomFunctionality)
If RegRead(fixRegKey, 'Zoom', 0) = 1 {
    zoomFunc.Checked := 1
}
zoomFunctionality(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'Zoom')
}

; Fog of war 1
nativeFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Native Fog of war', nativeFog, -1)
If RegRead(fixRegKey, 'FogOfWar', 0) = 1 {
    nativeFow.Checked := 1
}
nativeFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue = -1 ? 0 : 0, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

; Fog of war 2
gridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Grid Fog of war', gridFog)
If RegRead(fixRegKey, 'FogOfWar', 0) = 1 {
    nativeFow.Checked := 1
}
gridFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

; Fog of war 3
lightFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Light Fog of war ', lightFog, 2)
If RegRead(fixRegKey, 'FogOfWar', 0) = 2 {
    lightFow.Checked := 1
}
lightFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

; Fog of war 4
lightgridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Light grid Fog of war ', lightgridFog, 3)
If RegRead(fixRegKey, 'FogOfWar', 0) = 3 {
    lightgridFow.Checked := 1
}
lightgridFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

; Fog of war 5
ultraLightGridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Ultra light grid Fog of war ', ultraLightGridFog, 4)
If RegRead(fixRegKey, 'FogOfWar', 0) = 4 {
    ultraLightGridFow.Checked := 1
}
ultraLightGridFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

; Fog of war 6
hatchGridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Hatching Fog of war ', ultraLightGridFog, 5)
If RegRead(fixRegKey, 'FogOfWar', 0) = 5 {
    hatchGridFow.Checked := 1
}
hatchGridFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

; Fog of war 7
noFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - No Fog of war ', noFog, 6)
If RegRead(fixRegKey, 'FogOfWar', 0) = 6 {
    noFow.Checked := 1
}
noFog(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
}

fixapp.groupCheckBoxs([
    nativeFow,
    gridFow,
    lightFow,
    lightgridFow,
    ultraLightGridFow,
    hatchGridFow,
    noFow
])

;Msgbox noFow.HasProp('group')

; 12
;newCastl := fixGui.addCheckBoxEx(, '(Fix v7 required) - New castle', newCastle)
;If RegRead(fixRegKey, 'New Castle', 0) = 1 {
;    newCastl.Checked := 1
;}
;newCastle(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'New Castle')
;}

fixGui.MarginY := 20

fixapp.isGameFolderSelected(fixGui)
fixapp.isCommandLineCall({
    wnd: fixGui,
    callback: applyFix
})

fixGui.showEx(, 1)
analyzeFix()

/**
 * Apply the fix
 * @param Ctrl
 * @param Info
 * @returns {number} 
 */
applyFix(Ctrl, Info) {
    fixVersion := Type(Ctrl) = 'String' ? Ctrl : Ctrl.Text
    If fixVersion = 'None' {
        fixCleanUp()
        analyzeFix()
        fixapp.enableOptions(fixOptions['Fixs'])
        SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
        fixapp.compatibilityClear([userRegLayer, machineRegLayer], gameLocation '\empires2.exe')
        fixapp.compatibilityClear([userRegLayer, machineRegLayer], gameLocation '\age2_x1\age2_x1.exe')
        Return 1
    }

    If !fixapp.fixExist(fixVersion) {
        MsgBoxEx('The fix you requested to apply does not exist!', fixapp.name, , 0x30)
        Return 0
    }

    fixapp.enableOptions(fixOptions['Fixs'], 0)
    Try {
        ;If fixVersion = 'Fix v0' {
        ;    If VersionExist('aoc', '1.0', gameLocation) {
        ;        RunWait('"DB\Fix\Fix v0\Patcher.exe" "' gameLocation '\age2_x1\age2_x1.exe" "DB\Fix\Fix v0\AoC_10.patch"', , 'Hide')
        ;        FileDelete('*.ws')
        ;    } Else If VersionExist('aoc', '1.0c', gameLocation) || VersionExist('aoc', '1.0e', gameLocation) {
        ;        RunWait('"DB\Fix\Fix v0\Patcher.exe" "' gameLocation '\age2_x1\age2_x1.exe" "DB\Fix\Fix v0\AoC_10ce.patch"', , 'Hide')
        ;        FileDelete('*.ws')
        ;    } Else Return
        ;    fixapp.enableOptions(fixOptions['Fixs'], 0)
        ;    FileMove(gameLocation '\age2_x1\age2_x1_' A_ScreenWidth 'x' A_ScreenHeight '.exe', gameLocation '\age2_x1\age2_x1.exe', 1)
        ;    DirCopy(fixapp.fixLocation '\Fix v0\Bmp\', fixapp.fixLocation '\Fix v0\', 1)
        ;    RunWait("DB\Fix\Fix v0\ResizeFrames.exe", fixapp.fixLocation '\Fix v0', 'Hide')
        ;    Loop Files fixapp.fixLocation '\Fix v0\int*.bmp' {
        ;        RunWait('"DB\Fix\Fix v0\Bmp2Slp.exe" "' A_LoopFileFullPath '"', , 'Hide')
        ;    }
        ;    DRSBuild := '"DB\Fix\Fix v0\DrsBuild.exe"'
        ;    DRSRef := Format('{:05}', A_ScreenWidth) Format('{:04}', A_ScreenHeight)
        ;    FileCopy(gameLocation '\Data\interfac.drs', gameLocation '\Data\interfac_.drs', 1)
        ;    RunWait(DRSBuild ' /r "' gameLocation '\Data\interfac_.drs" "DB\Fix\Fix v0\*.slp"', , 'Hide')
        ;    FileMove(gameLocation '\Data\interfac_.drs', gameLocation '\Data\' DRSRef '.ws', 1)
        ;    FileDelete(fixapp.fixLocation '\Fix v0\*.bmp')
        ;    FileDelete(fixapp.fixLocation '\Fix v0\*.slp')
        ;    fixapp.enableOptions(fixOptions['Fixs'])
        ;    SoundPlay('DB\Base\30 Wololo.mp3')
        ;    Return
        ;}
        fixCleanUp()
        fixapp.applyUserFix(fixapp.fixLocation '\' fixVersion)
    } Catch {
        If !LockCheck(gameLocation) {
            fixapp.enableOptions(fixOptions['Fixs'])
            Return 0
        }
        fixCleanUp()
        fixapp.applyUserFix(fixapp.fixLocation '\' fixVersion)
    }
    analyzeFix()
    SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
    Return 1
}
analyzeFix(ignoreFiles := Map('wndmode.dll', 1, 'windmode.dll', 1)) {
    fixapp.enableOptions(fixOptions['Fixs'])
    matchFix := ''
    Loop Files, fixapp.fixLocation '\*', 'D' {
        fix := A_LoopFileName
        If fixapp.folderMatch(A_LoopFileFullPath, gameLocation, ignoreFiles) {
            fixOptions['FIXHandle'][fix].Enabled := False
            Return
        }
    }
}

/**
 * Cleans up a fix if found any
 */
fixCleanUp() {
    Loop Files, fixapp.fixLocation '\*', 'D' {
        Fix := A_LoopFileName
        Loop Files, fixapp.fixLocation '\' Fix '\*.*', 'R' {
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, fixapp.fixLocation '\' Fix '\')
            If FileExist(gameLocation '\' PathFile) {
                FileDelete(gameLocation '\' PathFile)
            }
        }
    }
}