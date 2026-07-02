#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\Libs\Base.ahk
#Include ..\libs\JSON.ahk


aoeiiapp := Base()
aoeiiapp.__Startup()
gameapp := Game()

features := Map()

aoeiiGui := GuiEx(, aoeiiapp.name)
aoeiiGui.aoemain := true
aoeiiGui.initiate()

about := aoeiiGui.AddButtonEx(
    'xm ym+20 w100', 'About', , (*) => MsgBoxEx(
        'A homemade tool humbly made by Smile, enjoy!'
        . '`n> Description: ' aoeiiapp.description
        . '`n> Scripting Language: AutoHotkey'
        . '`n> Name: ' aoeiiapp.name
        . '`n> Version: ' aoeiiapp.version
        . '`n> License: ' aoeiiapp.license
        , aoeiiapp.name, , 0x40
    ))

aoeiiGui.SetFont('Bold s10 Bold')

gameLocation := aoeiiGui.AddText('x+20 yp Center ReadOnly -E0x200 BackgroundTrans h35', '...')
gameLocation.OnEvent('Click', (*) => Run(aoeiiapp.gameLocation))

aoeiiGui.SetFont('s10')

reloadApp := aoeiiGui.AddButtonEx('yp w100', 'Reload', , (*) => Reload())

aoeiiGui.SetFont('Bold s18')
title := aoeiiGui.AddText('xm c522800 Center BackgroundTrans y70', aoeiiapp.name ' v' aoeiiapp.version)

aoeiiGui.SetFont('Bold s8')
perform := aoeiiGui.addButtonEx('xm y+10', 'Game Repair', , performGameAnalyze)
appUpdate := aoeiiGui.addButtonEx('x+5 w70', 'Update?', , updateCheck)

gamepicaok := aoeiiGui.AddPictureEx('xm+90 y+5', 'aoklogo.png')
gamepicaoc := aoeiiGui.AddPictureEx('x+20', 'aoclogo.png')
gamepichd := aoeiiGui.AddPictureEx('x+20', 'hdlogo.png')
; gamepicde := aoeiiGui.AddPictureEx('x+20', 'delogo.png')

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

launchSubApp(h, *) => Run(Format('{}', features[h].run), features[h].workdir)

aoeiiGui.ShowEx(, 1)

aoeiiapp.isGameFolderSelected()

aoeiiGui.GetPos(, , &W, &H)

title.GetPos(&tX, &tY, &tWidth)
title.Move((W - tWidth - 20) / 2)
title.Redraw()
title.GetPos(&tX, &tY, &tWidth)
perform.Move(tX, tY + 35)
appUpdate.Move(tX + tWidth - 70, tY + 35)
appUpdate.Redraw()

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

gameLocation.Text := 'The Selected Game @ "' aoeiiapp.gameLocation '"'

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
    appUpdate.TextEx := 'Update?'
}

performGameAnalyze(*) {
    choice := MsgBoxEx(
        Format(
            'Check list:`n`n{}`n{}`n{}`n{}`n{}`n{}`n`n{}',
            '1 - Delayed start (Windows Vista/7)',
            '2 - Corrupted file',
            '3 - The Conquerors Application location',
            '4 - The Game Save Folder',
            '5 - The Game Update',
            '6 - The Game Corrupted Files',
            'The app will try to fix these issues, do you wish to continue?'
        ), 'Check list', 1, 0x40
    ).result

    If choice != 'OK'
        return

    ; Gameux Win7/Vista auto fix
    GEs := [
        A_WinDir '\System32\gameux.dll',
        A_WinDir '\SysWOW64\gameux.dll'
    ]
    For GE in GEs {
        Switch SubStr(A_OSVersion, 1, 3) {
            Case '6.0', '6.1':
                If FileExist(GE) {
                    RunWait(Format(A_ComSpec ' /c takeown /f {}', GE), , 'Hide')
                    RunWait(Format(A_ComSpec ' /c cacls {} /E /P %username%:F', GE), , 'Hide')
                    RunWait(Format(A_ComSpec ' /c ren {} gameux_renamed.dll', GE), , 'Hide')
                }
        }
    }

    ; Check for a corrupted file
    md5 := '7c1ae22e8f9d385d51b4f2eadd2a6d76'
    dlltargets := [aoeiiapp.gameLocation '\dsound.dll', aoeiiapp.gameLocation '\age2_x1\dsound.dll']
    For target in dlltargets {
        if FileExist(target) && md5 = aoeiiapp.hashFile(, target) {
            FileDelete(target)
        }
    }

    ; Fix aoc wrong exe location
    aocexe := aoeiiapp.gameLocation '\age2_x1.exe'
    If FileExist(aocexe) {
        if !DirExist(aoeiiapp.gameLocation '\Age2_x1')
            DirCreate(aoeiiapp.gameLocation '\Age2_x1')
        FileMove(aocexe, aoeiiapp.gameLocation '\Age2_x1\', 1)
    }

    ; Create Multi folder in SaveGame if not exist
    If !DirExist(aoeiiapp.gameLocation '\SaveGame\Multi') {
        DirCreate(aoeiiapp.gameLocation '\SaveGame\Multi')
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
        RunWait(aoeiiapp.tools['02_fix']['run'] ' "Update v05"')
        aoeiiapp.applyDDrawFix()
    }

    ; Check for missing files
    gameLink := 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/Age%20of%20Empires%20II.7z'
    files := JSON.LoadFile('gamefiles.json')
    
    For file in files {
        if !FileExist(aoeiiapp.gameLocation '\' file['path']) {
            If !aoeiiapp.downloadPackage(gameLink, gameapp.gamePackage)
                Return
            RunWait(Format('"{}" x "{}" "{}" -o"{}"', aoeiiapp._7zrCsle, gameapp.gamePackage, file['path'], aoeiiapp.gameLocation))
        }
    }

    MsgBoxEx(
        'Verification is done, you should be able to play your game normally by now!'
        , aoeiiapp.name, , 0x40
    )
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