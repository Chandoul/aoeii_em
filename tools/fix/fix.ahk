#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

fixapp := FixPatch()

fixGui := GuiEx(, 'GAME FIXS')
fixGui.initiate()

fixs := fixapp.fixs
fixRegKey := fixapp.fixRegKey
fixRegName := fixapp.fixRegName
userRegLayer := fixapp.userRegLayer
machineRegLayer := fixapp.machineRegLayer
gameLocation := fixapp.gameLocation

SetRegView(A_Is64bitOS ? 64 : 32)

fixOptions := Map(
    'Fixs', [],
    'FIXHandle', Map()
)
fixGui.AddText('xm w350 Center h25 BackgroundTrans', 'Select one of the fixes below').SetFont('Bold')
fixGui.SetFont('s9')
For each, fix in fixs {
    fixName := fixGui.addButtonEx('w350', fix)
    fixName.OnEvent('Click', applyFix)
    fixOptions['Fixs'].Push(fixName)
    fixOptions['FIXHandle'][fix] := fixName
}

fixGui.AddText('ym w300 BackgroundTrans', 'Options').SetFont('Bold')
GeneralOptions := fixGui.AddListView('r4 -Hdr Checked -E0x200 wp BackgroundE1B15A', [' ', ' '])
For Option in StrSplit(IniRead(fixapp.fixLocation '\general.ini', 'General', , ''), '`n') {
    OptionValue := StrSplit(Option, '=')
    CurrentValue := RegRead(fixRegKey, fixRegName, 0)
    GeneralOptions.Add(CurrentValue = OptionValue[2] ? 'Check' : '', IniRead(fixapp.fixLocation '\general.ini', 'Description', OptionValue[1], ''), OptionValue[1])
    GeneralOptions.ModifyCol(1, 'AutoHdr')
}
GeneralOptions.ModifyCol(2, '0')
GeneralOptions.OnEvent('ItemCheck', UpdateAoe2Patch)
UpdateAoe2Patch(Ctrl, Item, Checked) {
    Loop GeneralOptions.GetCount() {
        GeneralOptions.Modify(A_Index, '-Check')
    }
    GeneralOptions.Modify(Item, 'Check')
    RegWrite(Item, 'REG_DWORD', fixRegKey, fixRegName)
}
waterAni := fixGui.AddCheckBoxEx(, ' Water animation', updateAoe2PatchOptions)

updateAoe2PatchOptions(Ctrl, Info) {
    RegWrite(Ctrl.cbValue, 'REG_DWORD', fixRegKey, 'WaterAnnimation')
}

fixGui.showEx(, 1)

fixapp.isGameFolderSelected(gameLocation)
fixapp.isCommandLineCall({
    wnd: fixGui,
    callback: applyFix
})

analyzeFix()

/**
 * Applys fixes
 * @param Ctrl 
 * @param Info 
 * @returns {void|number} 
 */
applyFix(Ctrl, Info) {
    fixVersion := Type(Ctrl) = 'String' ? Ctrl : Ctrl.Text

    If fixVersion = 'None' {
        cleansUp()
        analyzeFix()
        fixapp.enableOptions(fixOptions['Fixs'])
        SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
        fixapp.compatibilityClear([userRegLayer, machineRegLayer], gameLocation '\empires2.exe')
        fixapp.compatibilityClear([userRegLayer, machineRegLayer], gameLocation '\age2_x1\age2_x1.exe')
        Return
    }

    If !fixapp.fixExist(fixVersion) {
        MsgBoxEx('The fix you requested to apply does not exist!', fixapp.name, , 0x30)
        Return
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
        cleansUp()
        fixapp.applyUserFix(fixapp.fixLocation '\' fixVersion)
        fixapp.compatibilitySet([userRegLayer, machineRegLayer], gameLocation '\empires2.exe', 'WINXPSP3')
        fixapp.compatibilitySet([userRegLayer, machineRegLayer], gameLocation '\age2_x1\age2_x1.exe', 'WINXPSP3')
    } Catch {
        If !LockCheck(gameLocation) {
            fixapp.enableOptions(fixOptions['Fixs'])
            Return
        }
        cleansUp()
        fixapp.applyUserFix(fixapp.fixLocation '\' fixVersion)
        fixapp.compatibilitySet([userRegLayer, machineRegLayer], gameLocation '\empires2.exe', 'WINXPSP3')
        fixapp.compatibilitySet([userRegLayer, machineRegLayer], gameLocation '\age2_x1\age2_x1.exe', 'WINXPSP3')
    }
    analyzeFix()
    SoundPlay(fixapp.workDirectory '\assets\mp3\30 Wololo.mp3')
    Return 1
}
analyzeFix(
    ignoreFiles := Map(
        'wndmode.dll', 1
    )
) {
    fixapp.enableOptions(fixOptions['Fixs'])
    matchFix := ''
    Loop Files, fixapp.fixLocation '\*', 'D' {
        fix := A_LoopFileName
        match := True
        Loop Files, fixapp.fixLocation '\' fix '\*.*', 'R' {
            If ignoreFiles.Has(A_LoopFileName)
                Continue
            PathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, fixapp.fixLocation '\' fix '\')
            If !FileExist(gameLocation '\' PathFile) && match {
                match := False
                Break
            }
            currentHash := fixapp.hashFile(A_LoopFileFullPath)
            foundHash := fixapp.hashFile(gameLocation '\' PathFile)
            If (currentHash != foundHash) && match {
                match := False
                Break
            }
        }
        If match {
            matchFix := fix
        }
    }
    If matchFix {
        fixOptions['FIXHandle'][matchFix].Enabled := False
    }
}

/**
 * Cleans up a fix if found any
 */
cleansUp() {
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