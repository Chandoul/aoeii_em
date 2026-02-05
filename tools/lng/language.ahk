#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

lngapp := Language()
lngapp.__Startup()

lngapp.ensurePackage()

gameLocation := lngapp.gameLocation

lngGui := GuiEx(, lngapp.name)
lngGui.initiate(, 1)

lngGui.AddText('xm BackgroundTrans', 'Change the game interface language by selecting one of the options below:')
btnMap := Map()
Loop Files, lngapp.lngLocation '\*', 'D' {
    btnMap[A_LoopFileName] := {
        btn: lngGui.AddButtonEx('xm w400', A_LoopFileName, , applyLanguage),
        img: lngGui.AddPictureEx('xp+410 yp+1 Border', lngapp.lngLocation '\' A_LoopFileName '\Flag\' A_LoopFileName '.png', applyLanguage)
    }
}

lngapp.isGameFolderSelected()

lngapp.isCommandLineCall({
    wnd: lngGui,
    callback: applyLanguage
})

lngGui.showEx('h600', 1, lngapp)
analyzeLanguage()

/**
 * Analyzes game languages
 */
analyzeLanguage() {
    Loop Files, lngapp.lngLocation '\*', 'D' {
        btnMap[A_LoopFileName].btn.Enabled := 1
        btnMap[A_LoopFileName].img.Enabled := 1
        If lngapp.folderMatch(A_LoopFileFullPath, gameLocation) {
            btnMap[A_LoopFileName].btn.Enabled := 0
            btnMap[A_LoopFileName].img.Enabled := 0
        }
    }
}
cleanUp() {
    Loop Files, lngapp.lngLocation '\*', 'D' {
        Language := A_LoopFileName
        Loop Files, lngapp.lngLocation '\' Language '\*.*', 'R' {
            pathFile := StrReplace(A_LoopFileDir '\' A_LoopFileName, 'DB\Lng\' Language '\')
            If FileExist(gameLocation '\' pathFile) {
                FileDelete(gameLocation '\' pathFile)
            }
        }
    }
}

applyLanguage(Ctrl, Info) {
    Try {
        Switch Type(Ctrl) {
            Case 'String': Language := Ctrl
            Case 'Gui.Pic': SplitPath(Ctrl.Value, , , , &Language)
            Default: Language := Ctrl.Text
        }
        cleanUp()
        DirCopy(lngapp.lngLocation '\' Language, gameLocation, 1)
        analyzeLanguage()
        SoundPlay(lngapp.workDirectory '\assets\mp3\30 Wololo.mp3')
        Return 1
    } Catch {
        MsgBoxEx('Error occured while trying to install ' Language, lngapp.name, , 0x10)
    }
}