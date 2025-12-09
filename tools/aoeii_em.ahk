#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\Libs\Base.ahk

aoeiiapp := Base()
aoeiiapp.__Startup()

features := Map()

aoeiiGui := GuiEx(, aoeiiapp.name)
aoeiiGui.initiate()

about := aoeiiGui.AddButtonEx(
    'xm w100', 'About', , (*) => MsgBoxEx(
        'A homemade tool humbly made by Smile, enjoy!'
        . '`n> Description: ' aoeiiapp.description
        . '`n> Scripting Language: AutoHotkey'
        . '`n> Name: ' aoeiiapp.name
        . '`n> Version: ' aoeiiapp.version
        . '`n> License: ' aoeiiapp.license
        , aoeiiapp.name, , 0x40
    ))
gameLocation := aoeiiGui.AddButtonEx('x+20', '...', , (*) => Run(aoeiiapp.gameLocation))
aoeiiGui.SetFont('Bold s10 Bold')
reloadApp := aoeiiGui.AddButtonEx('yp w100', 'Reload', , (*) => Reload())

aoeiiGui.SetFont('Bold s18')
title := aoeiiGui.AddText('xm c522800 Center BackgroundTrans y70', aoeiiapp.name ' v' aoeiiapp.version)

aoeiiGui.SetFont('Bold s8')
appUpdate := aoeiiGui.addButtonEx('x+5', 'Check for updates', , updateCheck)

gamepicaok := aoeiiGui.AddPictureEx('xm+90 y+50', 'aoklogo.png')
gamepicaoc := aoeiiGui.AddPictureEx('x+20', 'aoclogo.png')
gamepichd := aoeiiGui.AddPictureEx('x+20', 'hdlogo.png')
; gamepicde := aoeiiGui.AddPictureEx('x+20', 'delogo.png')

aoeiiGui.SetFont('Bold s8')
perform := aoeiiGui.addButtonEx('xm w200 y+10', 'Game Status Check', , performGameAnalyze)

aoeiiGui.SetFont('Bold s10')

aoeiiGui.MarginY := 30
index := 0
For key, tool in aoeiiapp.tools {
    if key = '00_ungame'
        Continue
    if ++index = 2
        aoeiiGui.MarginY := 10
    h := aoeiiGui.addButtonEx('x' (!Mod(index - 1, 4) ? "m" : "+20") ' w180', tool["title"], , launchSubApp)
    features[h] := { run: tool['file'], workdir: tool['workdir'] }
}
aoeiiGui.MarginY := 20

launchSubApp(h, *) => Run(features[h].run, features[h].workdir)

aoeiiGui.ShowEx(, 1)

aoeiiapp.isGameFolderSelected()

aoeiiGui.GetPos(, , &W, &H)

title.GetPos(&tX, &tY, &tWidth)
title.Move((W - tWidth - 20) / 2)
title.Redraw()
title.GetPos(&tX, &tY, &tWidth)
appUpdate.Move(tX + tWidth - 110, tY + 35)

gamepicX := (W - 424 - 20) / 2
gamepicaok.Move(gamepicX)
gamepicaok.Redraw()
gamepicaoc.Move(gamepicX + 148)
gamepicaoc.Redraw()
gamepichd.Move(gamepicX + 148 * 2)
gamepichd.Redraw()
;gamepicde.Move(gamepicX + 132 * 3)
;gamepicde.Redraw()

gameLocation.Move(, , W - 56 - 240)
gameLocation.GetPos(&X, &Y, &Width)
reloadApp.Move(X + Width + 20, Y)
perform.Move(X + ((Width - 200) / 2))

gameLocation.TextEx := 'Selected Game: "' aoeiiapp.gameLocation '"'

; Game folder check
MatrixGreyScale := "0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1"
If !FileExist(aoeiiapp.gameLocation '\empires2.exe') {
    pBitmap := Gdip_CreateBitmapFromFile(aoeiiapp.workDirectory '\assets\aoklogo.png')
    graphic := Gdip_GraphicsFromImage(pBitmap)
    Gdip_DrawImage(graphic, pBitmap, , , , , , , , , MatrixGreyScale)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    gamepicaok.value := "HBITMAP:*" hBitmap
    Gdip_DeleteGraphics(graphic)
    Gdip_DisposeImage(pBitmap)
} Else gamepicaok.OnEvent('click', (*) => Run(aoeiiapp.gameLocation '\empires2.exe', aoeiiapp.gameLocation))

If !FileExist(aoeiiapp.gameLocation '\age2_x1\age2_x1.exe') {
    pBitmap := Gdip_CreateBitmapFromFile(aoeiiapp.workDirectory '\assets\aoclogo.png')
    graphic := Gdip_GraphicsFromImage(pBitmap)
    Gdip_DrawImage(graphic, pBitmap, , , , , , , , , MatrixGreyScale)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    gamepicaoc.value := "HBITMAP:*" hBitmap
    Gdip_DeleteGraphics(graphic)
    Gdip_DisposeImage(pBitmap)
} Else gamepicaoc.OnEvent('click', (*) => Run(aoeiiapp.gameLocation '\age2_x1\age2_x1.exe', aoeiiapp.gameLocation))

If !FileExist(aoeiiapp.gameLocation '\age2_x1\age2_x2.exe') {
    pBitmap := Gdip_CreateBitmapFromFile(aoeiiapp.workDirectory '\assets\hdlogo.png')
    graphic := Gdip_GraphicsFromImage(pBitmap)
    Gdip_DrawImage(graphic, pBitmap, , , , , , , , , MatrixGreyScale)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    gamepichd.value := "HBITMAP:*" hBitmap
    Gdip_DeleteGraphics(graphic)
    Gdip_DisposeImage(pBitmap)
} Else gamepichd.OnEvent('click', (*) => Run(aoeiiapp.gameLocation '\age2_x1\age2_x2.exe', aoeiiapp.gameLocation))
; If !FileExist(aoeiiapp.gameLocation '\age2_x1\age2_x1.exe') {
;     pBitmap := Gdip_CreateBitmapFromFile(aoeiiapp.workDirectory '\assets\delogo.png')
;     graphic := Gdip_GraphicsFromImage(pBitmap)
;     Gdip_DrawImage(graphic, pBitmap, , , , , , , , , MatrixGreyScale)
;     hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
;     gamepicde.value := "HBITMAP:*" hBitmap
;     Gdip_DeleteGraphics(graphic)
;     Gdip_DisposeImage(pBitmap)
; }

; Update check
updateCheck(*) {
    appUpdate.TextEx := 'Checking...'
    aoeiiapp.appUpdateCheck()
    appUpdate.TextEx := 'Check for updates'
    MsgBoxEx('You are up to date!, no newer versions found.', 'Update Check', , 0x40)
}

performGameAnalyze(*) {
    issueList := Map(
        "exist", 0,
        "01gameux", 0,
        "02corrupteddll", 0,
        "03age2_x1", 0,
        "04multi", 0,
        "05fix", 0
    )

    ; Gameux Win7/Vista auto fix
    GEs := [
        A_WinDir '\System32\gameux.dll',
        A_WinDir '\SysWOW64\gameux.dll'
    ]
    For GE in GEs {
        Switch SubStr(A_OSVersion, 1, 3) {
            Case '6.0', '6.1':
                If FileExist(GE) {
                    issueList['exist'] := 1
                    issueList['01gameux'] := 1
                }
        }
    }

    ; Check for corrupted file
    md5 := '7c1ae22e8f9d385d51b4f2eadd2a6d76'
    dlltargets := [aoeiiapp.gameLocation '\dsound.dll', aoeiiapp.gameLocation '\age2_x1\dsound.dll']
    For target in dlltargets {
        if FileExist(target) && md5 = aoeiiapp.hashFile(, target) {
            issueList['exist'] := 1
            issueList['02corrupteddll'] := 1
        }
    }

    ; Fix aoc wrong exe location
    aocexe := aoeiiapp.gameLocation '\age2_x1.exe'
    If FileExist(aocexe) {
        issueList['exist'] := 1
        issueList['03age2_x1'] := 1
    }

    ; Create Multi folder in SaveGame if not exist
    If !DirExist(aoeiiapp.gameLocation '\SaveGame\Multi') {
        issueList['exist'] := 1
        issueList['04multi'] := 1
    }

    ; Check if no fix exists
    fix := ''
    ignoreFiles := Map('wndmode.dll', 1, 'windmode.dll', 1)
    Loop Files, aoeiiapp.workDirectory '\tools\fix\*', 'D' {
        if aoeiiapp.folderMatch(A_LoopFileFullPath, aoeiiapp.gameLocation, ignoreFiles) {
            fix := A_LoopFileName
        }
    }
    If fix = '' {
        issueList['exist'] := 1
        issueList['05fix'] := 1

    }

    ; Issues checkement
    If issueList['exist'] {
        issuesGui := GuiEx(, 'Issues Report')
        issuesGui.initiate(0, , 0)
        For issue, value in issueList {
            if issue = 'exist'
                Continue
            p := issuesGui.addPictureEx('xm w24 h-1', (value ? 'error.png' : 'success.png'))
            if value
                issueList[issue] := p
            Switch issue {
                Case "01gameux": issuesGui.AddText('x+10 BackgroundTrans', 'Fix delayed start of the game (Windows Vista / Windows7).')
                Case "02corrupteddll": issuesGui.AddText('x+10 BackgroundTrans', 'Unwanted/Corrupted file found in your game.')
                Case "03age2_x1": issuesGui.AddText('x+10 BackgroundTrans', 'The Conquerors executable found at a wrong location.')
                Case "04multi": issuesGui.AddText('x+10 BackgroundTrans', 'Fix no restore game found issue.')
                Case "05fix": issuesGui.AddText('x+10 BackgroundTrans', 'Important game enhancement.')
            }
        }
        applyChanges := issuesGui.addButtonEx('xm w240', 'Apply Now!', , agreeToApplyFixs)
        issuesGui.showEx(, 1)
        issuesGui.GetPos(, , &W, &H)
        applyChanges.Move(, , W - 55)
        applyChanges.TextEx := applyChanges.Text
    } Else MsgboxEx('All are set!, no issue found so far.', aoeiiapp.name, , 0x40)

    agreeToApplyFixs(Ctrl, *) {
        ; gameux
        If issueList['01gameux'] {
            For GE in GEs {
                If FileExist(GE) {
                    RunWait(A_ComSpec ' /c takeown /f ' A_WinDir '\System32\gameux.dll && cacls ' A_WinDir '\System32\gameux.dll /E /P %username%:F && ren ' A_WinDir '\System32\gameux.dll gameux_renamed.dll', , 'Hide')
                }
            }
            issueList['01gameux'].ValueEx := 'success.png'
        }
        ; corruption
        If issueList['02corrupteddll'] {
            For target in dlltargets {
                if FileExist(target) && md5 = aoeiiapp.hashFile(, target) {
                    FileDelete(target)
                }
            }
            issueList['02corrupteddll'].ValueEx := 'success.png'
        }

        ; age2_x1
        If issueList['03age2_x1'] {
            if !DirExist(aoeiiapp.gameLocation '\Age2_x1')
                DirCreate(aoeiiapp.gameLocation '\Age2_x1')
            If FileExist(aocexe)
                FileMove(aocexe, aoeiiapp.gameLocation '\Age2_x1\', 1)
            issueList['03age2_x1'].ValueEx := 'success.png'
        }

        ; restoring
        If issueList['04multi'] {
            DirCreate(aoeiiapp.gameLocation '\SaveGame\Multi')
            issueList['04multi'].ValueEx := 'success.png'
        }

        ; fix
        If issueList['05fix'] {
            RunWait(aoeiiapp.tools['02_fix']['run'] ' "Fix v5"')
            aoeiiapp.applyDDrawFix()
            issueList['05fix'].ValueEx := 'success.png'
        }
        Ctrl.Enabled := False
        MsgboxEx('All are set!, all the changed should be applied by now.', aoeiiapp.name, , 0x40)
    }
}

; Multiline chat send
; GameRanger
GroupAdd('GRChat', 'Room ahk_exe GameRanger.exe')
GroupAdd('GRChat', 'Message ahk_exe GameRanger.exe')
; Age of Empires
GroupAdd('AOEII', 'ahk_exe empires2.exe')
GroupAdd('AOEII', 'ahk_exe age2_x1.exe')

chatSpam := aoeiiapp.readConfiguration('chatSpam')

#HotIf (WinActive('ahk_group GRChat') || WinActive('ahk_group AOEII')) && chatSpam
^!v:: {
    For line in StrSplit(A_Clipboard, '`r`n') {
        SendInput('{Raw}' line)
        SendInput('{Enter}')
        Sleep(10)
    }
}
^!b:: {
    text := InputBox('Text to send', , 'h100').Value
    times := InputBox('Number of times to send', , 'h100').Value
    A_Clipboard := ''
    Loop times {
        A_Clipboard .= text '`n'
    }
}
#HotIf