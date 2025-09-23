#Include CNG.ahk
Class Base {
    name => 'Age of Empires II Easy Manager'
    namespace => 'aoe_em'
    description => (
        'An AutoHotkey application holds several useful tools that helps with the game'
    )
    version => '4.0'
    author => 'Smile'
    license => 'MIT'
    workDirectory => This.workDir()
    configuration => This.workDirectory '\Configuration.ini'
    _7zrLink => 'https://www.7-zip.org/a/7zr.exe'
    _7zrCsle => This.workDirectory '\Externals\7zr.exe'
    _7zrVersion => '25.01'
    _7zrSHA256 => '27cbe3d5804ad09e90bbcaa916da0d5c3b0be9462d0e0fb6cb54be5ed9030875'
    gameLocation => this.readConfiguration('GameLocation')
    gameLocationHistory => this.readConfiguration('GameLocationHistory')
    gameRangerExecutable => A_AppData '\GameRanger\GameRanger\GameRanger.exe'
    gameRangerSetting => A_AppData '\GameRanger\GameRanger Prefs\Settings'
    gameRegLocation => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Age of Empires II AIO'

    /**
     * Initiate the class
     */
    __New() {
        This.avoidVoobly()
        This._7zrGet()
    }
    /**
     * Gets the default app working directory
     * @returns {string} 
     */
    workDir() {
        WorkDir := A_ScriptDir
        Loop 2
            SplitPath(WorkDir, , &WorkDir)
        Until FileExist(WorkDir '\workDirectory')
        Return FileExist(WorkDir '\workDirectory') ? WorkDir : A_ScriptDir
    }

    /**
     * Download and save 7zr.exe standealone if it doesn't exist
     */
    _7zrGet() {
        _7zrExist := False
        If FileExist(This._7zrCsle) {
            _7zrExist := This._7zrSHA256 == Hash.File('SHA256', This._7zrCsle)
        }
        If (!_7zrExist) {
            Msgbox This._7zrCsle
            Download(This._7zrLink, This._7zrCsle)
        }
        _7zrExist := This._7zrSHA256 == Hash.File('SHA256', This._7zrCsle)
        If (!_7zrExist) {
            Msgbox(
                'Unable to get the correct 7zr.exe (x86) : 7-Zip console executable v' This._7zrVersion ' from "https://www.7-zip.org/download.html"`nTo fix this, download it manually and place it, into the "Externals\" directory.'
                , '7-Zip console executable'
                , 0x30
            )
            ExitApp()
        }
    }

    /**
     * Avoid being banned at Voobly (Voobly bans AutoHotkey)
     */
    avoidVoobly() {
        If ProcessExist('voobly.exe')
            ExitApp()
        SetTimer(vooblyCheck, 1000)
        vooblyCheck() {
            If ProcessExist('voobly.exe')
                ExitApp()
        }
    }

    /**
     * Read user configuration
     * @param key 
     * @returns {string} 
     */
    readConfiguration(key) {
        Return IniRead(This.configuration, This.namespace, key, '')
    }

    /**
     * Write user configuration
     * @param key 
     * @param value 
     */
    writeConfiguration(key, value) {
        IniWrite(value, This.configuration, This.namespace, key)
    }

    /**
     * Check if there is internet connection
     * @returns {bool}
     */
    getConnectedState() {
        Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", Flag := 0x40, "Int", 0)
    }

    /**
     * Download a file with some progress info
     * @param link 
     * @param file 
     * @param {number} fileSize 
     * @param {number} progressText 
     * @param {number} progressBar 
     */
    downloadPackage(link, file, fileSize := 0, progressText := 0, progressBar := 0, update := 0) {
        if !update && FileExist(file) {
            Return
        }
        SplitPath(file, &OutFileName)
        SetTimer(fileWatch, 1000)
        Download(link, file)
        SetTimer(fileWatch, 0)
        fileWatch() {
            if FileExist(file) {
                currentSize := FileGetSize(file, 'M')
                If fileSize {
                    if !progressText.Visible {
                        progressText.Visible := 1
                        progressBar.Visible := 1
                    }
                    progress := Round(currentSize / fileSize * 100, 2)
                    if progressText {
                        progressText.Text := 'Downloading "' OutFileName '" [ ' progress ' % ]...'
                    }
                    if progressBar {
                        progressBar.Value := progress
                    }
                }
            }
        }
    }

    /**
     * Extract a 7zip package into a specified location
     * @param package 
     * @param destination 
     */
    extractPackage(package, destination, hide := 0, progressText := 0) {
        If progressText {
            progressText.Visible := True
            SplitPath(package, &OutFileName)
            progressText.Text := 'Extracting "' OutFileName '"...'
        }
        RunWait('"' This._7zrCsle '" x "' package '" -o"' destination '" -aoa', , hide ? 'Hide' : '', &PID)
        If progressText {
            SplitPath(package, &OutFileName)
            progressText.Text := 'Extracting "' OutFileName '" - Done'
        }
    }

    /**
     * Get a folder size in KB
     * @param location 
     * @returns {number} 
     */
    folderGetSize(location) {
        Size := 0
        Loop Files, location '\*.*', 'R' {
            Size += FileGetSize(A_LoopFileFullPath, 'K')
        }
        Return Size
    }

}

#Include ImageButton.ahk
Class Button {
    workDirectory => Base().workDirectory
    default => [
        [This.workDirectory '\assets\000_50212.bmp', , 0xFFFFFF]
    ]
}

#Include Gdip.ahk
Class GuiEx extends Gui {
    workDirectory => Base().workDirectory
    backImage => This.workDirectory '\assets\000_50127.bmp'
    transColor => 0xFFFFFE
    checkedImage => This.workDirectory '\assets\cb\checked.png'
    uncheckedImage => This.workDirectory '\assets\cb\unchecked.png'
    click => This.workDirectory '\assets\wav\50300.wav'
    initiate(qA := 1) {
        This.BackColor := 0xFFFFFF
        If qA
            This.OnEvent('Close', (*) => ExitApp())
        This.MarginX := This.MarginY := 20
        This.SetFont('s10 Bold', 'Segoe UI')
        This.backGroundImage := This.AddPicture('xm-' This.MarginX ' ym-' This.MarginY)
    }
    showEx(options := '', backImage := 0) {
        This.Show(options)

        ; Handling the background image (repeat x, y)
        If backImage {
            This.GetPos(&X, &Y, &bWidth, &bHeight)
            This.backGroundImage.Move(0, 0, bWidth, bHeight)
            This.backGroundImage.Redraw()

            fBitmap := Gdip_CreateBitmapFromFile(This.backImage)
            Gdip_GetDimensions(fBitmap, &iWidth, &iHeight)

            bBitmap := Gdip_CreateBitmap(bWidth, bHeight)
            G := Gdip_GraphicsFromImage(bBitmap)

            vDrawTimes := bHeight > iHeight ? (bHeight // iHeight) + 1 : 1
            hDrawTimes := bWidth > iWidth ? (bWidth // iWidth) + 1 : 1

            Loop vDrawTimes {
                y := (A_Index - 1) * iHeight
                Loop hDrawTimes {
                    x := (A_Index - 1) * iWidth
                    Gdip_DrawImage(G, fBitmap, x, y, iWidth, iHeight)
                }
            }

            hBitmap := Gdip_CreateHBITMAPFromBitmap(bBitmap)
            This.backGroundImage.Value := 'HBITMAP:* ' hBitmap

            Gdip_DeleteGraphics(G)
            Gdip_DisposeImage(bBitmap)
        }
    }
    addButtonEx(options := '', text := '', theme := Button().default, clickCallBack := 0) {
        b := This.AddButton(options, text)
        CreateImageButton(
            b,
            0,
            theme*
        )
        b.DefineProp('TextEx', { Set: textEx })
        textEx(b, value, text := '', theme := Button().default) {
            b.text := value
            CreateImageButton(
                b,
                0,
                theme*
            )
        }

        b.OnEvent('Click', (*) => SoundPlay(This.click))

        If clickCallBack {
            b.OnEvent('Click', clickCallBack)
        }
        Return b
    }
    addCheckBoxEx(options := '', text := '', clickCallBack := 0) {
        T := This.AddText(options, text)
        T.OnEvent('Click', toggleValue)
        T.GetPos(&X, &Y, &Width, &Height)
        T.Move(X + Height + 5, Y, Width, Height)
        T.cbValue := 0

        P := This.AddPicture('BackgroundTrans x' X ' y' Y ' h' Height ' w' Height, This.uncheckedImage)
        P.OnEvent('Click', toggleValue)
        toggleValue(*) {
            T.cbValue := !T.cbValue
            P.Value := T.cbValue ? This.checkedImage : This.uncheckedImage
        }

        If clickCallBack {
            T.OnEvent('Click', clickCallBack)
            P.OnEvent('Click', clickCallBack)
            once := 0
        }

        T.DefineProp('Checked', { Get: getValue, Set: setValue })
        P.DefineProp('Checked', { Get: getValue, Set: setValue })

        getValue(ctrl) {
            Return T.cbValue
        }
        setValue(ctrl, value) {
            T.cbValue := value ? 1 : 0
            P.Value := T.cbValue ? This.checkedImage : This.uncheckedImage
        }
        Return T
    }
}

Class MsgBoxEx {
    workDirectory => Base().workDirectory
    errorIcon => this.workDirectory '\assets\error.png'
    errorSound => this.workDirectory '\assets\mp3\error.mp3'
    questionIcon => this.workDirectory '\assets\question.png'
    questionSound => this.workDirectory '\assets\mp3\question.mp3'
    exclamationIcon => this.workDirectory '\assets\exclamation.png'
    exclamationSound => this.workDirectory '\assets\mp3\exclamation.mp3'
    infoIcon => this.workDirectory '\assets\info.png'
    infoSound => this.workDirectory '\assets\mp3\info.mp3'
    btnWidth => 100
    /**
     * App specific message box theme
     * @param Text 
     * @param Title 
     * @param {number} Function 
     * @param {number} Icon 
     * @param {number} TimeOut 
     */
    __New(Text := '', Title := A_ScriptName, Function := 0, Icon := 0, TimeOut := 0) {
        This.msgGui := GuiEx(, Title)
        This.msgGui.initiate(0)
        This.hIcon := 0
        Switch Icon {
            Case 16:
                This.hIcon := This.msgGui.AddPicture('xm w48 h48 BackgroundTrans', This.errorIcon)
                SoundPlay(This.errorSound)
            Case 32:
                This.hIcon := This.msgGui.AddPicture('xm w48 h48 BackgroundTrans', This.questionIcon)
                SoundPlay(This.questionSound)
            Case 48:
                This.hIcon := This.msgGui.AddPicture('xm w48 h48 BackgroundTrans', This.exclamationIcon)
                SoundPlay(This.exclamationSound)
            Case 64:
                This.hIcon := This.msgGui.AddPicture('xm w48 h48 BackgroundTrans', This.infoIcon)
                SoundPlay(This.infoSound)
        }

        If Text = '' {
            Switch Function {
                Default: Text := 'Press OK to continue'
                Case 2: Text := 'Press Abort to stop'
                Case 3, 4: Text := 'Press Yes to agree'
                Case 5, 6: Text := 'Press Cancel to stop'
            }
        }

        This.hText := This.msgGui.AddText('xm BackgroundTrans Center', Text)

        Switch Function {
            Case 0: This.msgGui.addButtonEx('xm w100', 'OK', , updateResult)
            Case 1:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'OK', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , updateResult)
            Case 2:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Abort', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Retry', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Ignore', , updateResult)
            Case 3:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Yes', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , updateResult)
            Case 4:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Yes', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , updateResult)
            Case 5:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Retry', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , updateResult)
            Case 6:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Cancel', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Try Again', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Continue', , updateResult)
        }

        This.msgGui.showEx(, 1)
        This.centerControls()
        This.result := ''

        (TimeOut) ? WinWaitClose(This.msgGui, , TimeOut) : WinWaitClose(This.msgGui)

        If This.msgGui
            This.msgGui.Destroy()

        updateResult(Ctrl, Info) {
            This.result := Ctrl.Text
            If This.msgGui
                This.msgGui.Destroy()
        }
    }
    centerControls() {
        This.msgGui.GetClientPos(&X, &Y, &Width, &Height)
        If This.hIcon {
            This.hIcon.GetPos(&cX, &cY, &cWidth, &cHeight)
            This.hIcon.Move((Width - cWidth) // 2)
        }
        This.hText.GetPos(&cX, &cY, &cWidth, &cHeight)
        This.hText.Move((Width - cWidth) // 2)

        buttons := []
        For Obj in This.msgGui {
            If !InStr(Type(Obj), 'Gui.Button')
                Continue
            buttons.Push(Obj)
        }
        X := buttons.Length * This.btnWidth + (buttons.Length - 1) * This.msgGui.MarginX
        X := (Width - X) // 2
        For btn in buttons {
            btn.Move(X + (A_Index - 1) * (This.msgGui.MarginX + This.btnWidth))
            btn.Redraw()
        }
    }
}

Class Game {
    name => 'My Game'
    workDirectory => Base().workDirectory
    gamePackage => this.workDirectory '\Tools\Game\Age of Empires II.7z'
    addShortcuts => Base().readConfiguration('AddShortcuts')
    /**
     * Check if a location is really an aoe ii game
     * @param Location 
     * @returns {string} 
     */
    isValidGameDirectory(Location) {
        Return (
            FileExist(Location '\empires2.exe') &&
            FileExist(Location '\language.dll') &&
            FileExist(Location '\Data\interfac.drs') &&
            FileExist(Location '\Data\graphics.drs') &&
            FileExist(Location '\Data\terrain.drs')
        )
    }
}