#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

fixapp := FixPatch()
fixapp.__Startup()

fixapp.ensurePackage()

verapp := Version()

fixGui := GuiEx(, fixapp.name)
fixGui.initiate()

fixs := fixapp.fixs
fixRegKey := fixapp.fixRegKey
fixRegKey2 := fixapp.fixRegKey2
fixRegName := fixapp.fixRegName
userRegLayer := fixapp.userRegLayer
machineRegLayer := fixapp.machineRegLayer
gameLocation := fixapp.gameLocation

fixOptions := Map(
    'Fixs', [],
    'FIXHandle', Map()
)
fixGui.AddText('xm ym+10 w200 Center h25 BackgroundTrans', 'Select one of the fixes below').SetFont('Bold')
fixGui.SetFont('s9')

For each, fix in fixs {
    fixName := fixGui.addButtonEx((!Mod(each, 7) ? 'ym+40 ' : 'y+5 ') 'w200', fix, Button().checkedDisabled)
    fixName.OnEvent('Click', applyFix)
    fixOptions['Fixs'].Push(fixName)
    fixOptions['FIXHandle'][fix] := fixName
}

if !fixapp.configurationExists() {
    fixapp.writeConfiguration('ddrAuto', 1)
}
ddrAuto := fixGui.addCheckBoxEx('xm', 'Enable direct draw fix', fixDDREnable)
ddrAuto.Checked := fixapp.readConfiguration('ddrAuto')

center := fixGui.addCheckBoxEx(, 'Center the game window', centerGameWindow)
center.Checked := fixapp.readConfiguration('center')

;features := fixGui.addButtonEx('xm w200', 'Features list', , showFeatures)
;showFeatures(*) => MsgBoxEx(FileRead('features.txt'), 'katsuie`'s patch features', , 64)

fixGui.SetFont('s9')
fixGui.AddText('xm+450 ym+15 BackgroundTrans', 'Options to enable along with the widescreen patch:').SetFont('Bold')
fixGui.MarginY := 10

; Water animation
waterAni := fixGui.addCheckBoxEx(, 'Water animation', waterAnimation)
waterAni.Checked := RegRead(fixRegKey, 'WaterAnnimation', 0) = 1 ? 1 : 0
waterAnimation(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'WaterAnnimation')
}

; Advanced interface
resInt := fixGui.addCheckBoxEx(, 'Show villagers count on each resource`nShow civilizations upgrades levels`nShow civlization next to score names', resourceInterface, 2)
If RegRead(fixRegKey, 'Aoe2Patch', 0) = 2 {
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
zoomFunc := fixGui.addCheckBoxEx(, 'Zoom functionality`n[Note] Set the hotkey in the game hotkeys!`n(Fix v5 and above required) ', (Ctrl, *) => RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'Zoom'))
If RegRead(fixRegKey, 'Zoom', 0) = 1 {
    zoomFunc.Checked := 1
}

; Fog of war 1

;nativeFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Native Fog of war', nativeFog, -1)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 1 {
;    nativeFow.Checked := 1
;}
;nativeFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue = -1 ? 0 : 0, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}
;
;; Fog of war 2
;gridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Grid Fog of war', gridFog)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 1 {
;    nativeFow.Checked := 1
;}
;gridFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}
;
;; Fog of war 3
;lightFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Light Fog of war ', lightFog, 2)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 2 {
;    lightFow.Checked := 1
;}
;lightFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}
;
;; Fog of war 4
;lightgridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Light grid Fog of war ', lightgridFog, 3)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 3 {
;    lightgridFow.Checked := 1
;}
;lightgridFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}
;
;; Fog of war 5
;ultraLightGridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Ultra light grid Fog of war ', ultraLightGridFog, 4)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 4 {
;    ultraLightGridFow.Checked := 1
;}
;ultraLightGridFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}
;
;; Fog of war 6
;hatchGridFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - Hatching Fog of war ', ultraLightGridFog, 5)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 5 {
;    hatchGridFow.Checked := 1
;}
;hatchGridFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}
;
;; Fog of war 7
;noFow := fixGui.addCheckBoxEx(, '(Fix v7 required) - No Fog of war ', noFog, 6)
;If RegRead(fixRegKey, 'FogOfWar', 0) = 6 {
;    noFow.Checked := 1
;}
;noFog(Ctrl, Info) {
;    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'FogOfWar')
;}

;fixapp.groupCheckBoxs([
;    nativeFow,
;    gridFow,
;    lightFow,
;    lightgridFow,
;    ultraLightGridFow,
;    hatchGridFow,
;    noFow
;])

; New castle foundation

nCastle := fixGui.addCheckBoxEx(, 'New Castle Mod + Fundation Mod`n(Fix v7 and above required)', newCastle)
nCastle.Checked := RegRead(fixRegKey, 'New Castle', 0) = 1 ? 1 : 0
newCastle(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'New Castle')
}

darkenMinimap := fixGui.addCheckBoxEx(, 'Darken mini-map colors [ Gray, Red, Orange ]`n(Fix v10 required)', darkMinimap, 34)
darkenMinimap.Checked := RegRead(fixRegKey, 'Mini-map Colors', 64) = 34 && RegRead(fixRegKey2, 'Mini-map Colors', 64) = 34
darkMinimap(Ctrl, *) {
    value := Ctrl.cbValue ? Ctrl.cbValue : 64
    RegWrite(value, 'REG_DWORD', fixRegKey, 'Mini-map Colors')
    RegWrite(value, 'REG_DWORD', fixRegKey2, 'Mini-map Colors')
}

fixGui.MarginY := 20

fixapp.isGameFolderSelected(fixGui)
fixapp.isCommandLineCall({
    wnd: fixGui,
    callback: applyFix
})

fixGui.showEx(, 1, fixapp)
analyzeFix()

fixDDREnable(Ctrl, Info) {
    fixapp.writeConfiguration('ddrAuto', Ctrl.cbValue)
    fixapp.applyDDrawFix(, Ctrl.cbValue ? 1 : 0)
    SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
}
centerGameWindow(Ctrl, Info) {
    fixapp.writeConfiguration('center', Ctrl.cbValue)
    fixapp.applyDDrawFix(, Ctrl.cbValue ? 1 : 0)
    SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
}

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
        If fixVersion = 'Update v00' {
            fixCleanUp()
            workdir := fixapp.fixLocation '\' fixVersion
            gameVersions := verapp.getGameVersions()
            If !gameVersions['aok'] && !gameVersions['aoc'] {
                MsgBoxEx('No compatible game version found for this patch!', fixapp.name, , 0x30)
                Return
            }
            If gameVersions['aok'] {
                RunWait(Format('"{}" "{}" "{}"', workdir '\patcher.exe', gameLocation '\empires2.exe', workdir '\AoK_' gameVersions['aok'] '.patch'), , 'Hide')
                FileDelete('*.ws')
                FileMove(gameLocation '\empires2_' A_ScreenWidth 'x' A_ScreenHeight '.exe', gameLocation '\empires2.exe', 1)
            } 
            If gameVersions['aoc'] ~= '1.0|1.0c|1.0e' {
                RunWait(Format('"{}" "{}" "{}"', workdir '\patcher.exe', gameLocation '\age2_x1\age2_x1.exe', workdir '\AoC_' gameVersions['aoc'] '.patch'), , 'Hide')
                FileDelete('*.ws')
                FileMove(gameLocation '\age2_x1\age2_x1_' A_ScreenWidth 'x' A_ScreenHeight '.exe', gameLocation '\age2_x1\age2_x1.exe', 1)
            } 
            
            DirCopy(workdir '\Bmp', workdir '\', 1)
            RunWait(workdir "\ResizeFrames.exe", workdir '\', 'Hide')

            Loop Files workdir '\int*.bmp'
                RunWait(Format('"{}" "{}"', workdir '\Bmp2Slp.exe', A_LoopFileFullPath), , 'Hide')
            
            drsbuild := fixapp.workDirectory '\externals\drsbuild.exe'
            drsref := Format('{:05}', A_ScreenWidth) Format('{:04}', A_ScreenHeight)

            FileCopy(gameLocation '\Data\interfac.drs', gameLocation '\Data\interfac_.drs', 1)
            RunWait(Format('"{}" /r "{}" "{}\*.slp"', drsbuild, gameLocation '\Data\interfac_.drs', workdir), , 'Hide')

            FileMove(gameLocation '\Data\interfac_.drs', gameLocation '\Data\' drsref '.ws', 1)

            FileDelete(workdir '\*.bmp')
            FileDelete(workdir '\*.slp')

            fixapp.enableOptions(fixOptions['Fixs'])
            SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
            Return
        }
        fixCleanUp()
        fixapp.applyUserFix(fixapp.fixLocation '\' fixVersion)
        If ddrAuto.cbValue {
            fixapp.applyDDrawFix(, center.cbValue ? 1 : 0)
        }
    } Catch {
        If !LockCheck(gameLocation) || fixVersion = 'Update v00' {
            analyzeFix()
            Return 0
        }
        fixCleanUp()
        fixapp.applyUserFix(fixapp.fixLocation '\' fixVersion)
        If ddrAuto.cbValue {
            fixapp.applyDDrawFix(, center.cbValue ? 1 : 0)
        }
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