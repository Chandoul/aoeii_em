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
    configuration => This.workDirectory '\configuration.ini'
    tools => {
        game: {
            title: 'My Game',
            file: This.workDirectory '\tools\game\game.ahk'
        },
        version: {
            title: 'Versions',
            file: This.workDirectory '\tools\version\version.ahk'
        },
        fix: {
            title: 'Patchs & Fixs',
            file: This.workDirectory '\tools\fix\fix.ahk'
        },
    }
    ddraw => This.workDirectory '\externals\cnc-ddraw.2'
    _7zrLink => 'https://www.7-zip.org/a/7zr.exe'
    _7zrCsle => This.workDirectory '\externals\7zr.exe'
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
        OnError(handleError)
        This.avoidVoobly()
        This._7zrGet()

        handleError(Thrown, Mode) {
            MsgBoxEx(
                'An error occured:`n`nMessage: ' Thrown.Message .
                '`n`nWhat: ' Thrown.What .
                '`n`nExtra: ' Thrown.Extra .
                '`n`nFile: ' Thrown.File .
                '`n`nLine: ' Thrown.Line .
                '`n`nStack: ' Thrown.Stack,
                This.name,
                0,
                0x10
            )
            ExitApp()
        }
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
            _7zrExist := This._7zrSHA256 == This.hashFile('SHA256', This._7zrCsle)
        }
        If (!_7zrExist) {
            Msgbox This._7zrCsle
            Download(This._7zrLink, This._7zrCsle)
        }
        _7zrExist := This._7zrSHA256 == This.hashFile('SHA256', This._7zrCsle)
        If (!_7zrExist) {
            Msgbox(
                'Unable to get the correct 7zr.exe (x86) : 7-Zip console executable v' This._7zrVersion ' from "https://www.7-zip.org/download.html"`nTo fix this, download it manually and place it, into the "externals\" directory.'
                , '7-Zip console executable'
                , 0x30
            )
            ExitApp()
        }
    }

    /**
     * Return the hashsum of a file
     * @param {string} Alg 
     * @param {string} file 
     * @returns {string} 
     */
    hashFile(Alg := 'MD5', file := '') {
        Return FileExist(file) ? Hash.File(Alg, file) : ''
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
            Return 1
        }

        If !This.getConnectedState() {
            MsgboxEx('Make sure you are connected to the internet!', "Can't download!", , 0x30).result
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
        Return 1
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
        RC := RunWait('"' This._7zrCsle '" x "' package '" -o"' destination '" -aoa', , hide ? 'Hide' : '', &PID)
        If progressText {
            SplitPath(package, &OutFileName)
            progressText.Text := 'Extracting "' OutFileName '" - Done'
        }
        Return RC = 0
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

    /**
     * Verify is the game folder is correctly selected
     */
    isGameFolderSelected(wnd := 0) {
        If !Game().isValidGameDirectory(gameLocation) {
            If wnd {
                wnd.Opt('Disabled')
            }
            If 'Yes' = MsgBoxEx('Game is not yet located!, want to select now?', 'Game', 0x4, 0x40).result
                Try Run(This.tools.game.file)
            ExitApp()
        }
    }

    /**
     * Apply the direct draw configuration to the game
     */
    applyDDrawFix() {
        DirCopy(This.ddraw, This.gameLocation '\', 1)
        If DirExist(gameLocation '\age2_x1')
            DirCopy(This.ddraw, This.gameLocation '\age2_x1\', 1)
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
        T := This.AddText(options ' BackgroundTrans c4C4C4C', text)
        T.OnEvent('Click', toggleValue)
        T.GetPos(&X, &Y, &Width, &Height)
        T.Move(X + Height + 5, Y, Width, Height)
        T.cbValue := 0

        P := This.AddPicture('BackgroundTrans x' X ' y' Y ' h' Height ' w' Height, This.uncheckedImage)
        P.cbValue := T.cbValue

        P.OnEvent('Click', toggleValue)
        toggleValue(*) {
            T.cbValue := !T.cbValue
            P.cbValue := T.cbValue
            If T.cbValue {
                T.Opt('cBlack')
                P.Value := This.checkedImage
            } Else {
                P.Value := This.uncheckedImage
                T.Opt('c4C4C4C')
            }
            T.Redraw()
        }

        If clickCallBack {
            T.OnEvent('Click', clickCallBack)
            P.OnEvent('Click', clickCallBack)
        }

        T.DefineProp('Checked', { Get: getValue, Set: setValue })
        P.DefineProp('Checked', { Get: getValue, Set: setValue })

        getValue(ctrl) {
            Return T.cbValue
        }
        setValue(ctrl, value) {
            T.cbValue := value ? 1 : 0
            P.cbValue := T.cbValue
            If T.cbValue {
                T.Opt('cBlack')
                P.Value := This.checkedImage
            } Else {
                P.Value := This.uncheckedImage
                T.Opt('c4C4C4C')
            }
            T.Redraw()
            If clickCallBack {
                clickCallBack.Call(T, '')
            }
        }
        Return T
    }

    addPictureEx(options := '', filename := '', clickcallback := 0) {
        If !FileExist(filename) {
            filename := This.workDirectory '\assets\' filename
        }
        If !FileExist(filename) {
            filename := ''
        }
        P := This.AddPicture(options ' BackgroundTrans', filename)
        if clickcallback {
            P.OnEvent('click', clickcallback)
        }
        Return P
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

        This.hText := This.msgGui.AddEdit('xm Center ReadOnly BackgroundE1B15A -E0x200 -VScroll Border', Text)

        Switch Function {
            Case 0:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'OK', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
            Case 1:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'OK', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
            Case 2:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Abort', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Retry', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Ignore', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
            Case 3:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Yes', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
            Case 4:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Yes', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
            Case 5:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Retry', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
            Case 6:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Cancel', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Try Again', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Continue', , updateResult)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , updateResult).Focus()
        }

        This.msgGui.showEx(, 1)
        This.centerControls()
        This.result := ''

        (TimeOut) ? WinWaitClose(This.msgGui, , TimeOut) : WinWaitClose(This.msgGui)

        If This.msgGui
            This.msgGui.Destroy()

        updateResult(Ctrl, Info) {
            This.result := Ctrl.Text
            If This.result = 'Copy Message' {
                A_Clipboard := This.hText.Value
                Return
            }
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

Class Game extends Base {
    name => 'My Game'
    gamePackage => This.workDirectory '\Tools\Game\Age of Empires II.7z'
    addShortcuts => This.readConfiguration('AddShortcuts')
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

Class FixPatch extends Base {
    fixLocation => This.workDirectory '\Tools\Fixs'
    fixTool => This.fixLocation '\Fix.ahk'
    Fixs => This.getFixs()

    getFixs() {
        F := []
        Loop Files, This.fixLocation '\*', 'D' {
            F.Push(A_LoopFileFullPath)
        }
        Return F
    }

    fixExist(name, location) {
        Return 1
    }
}

#Include LockCheck.ahk
Class Version extends Base {
    name => 'Game Versions'
    versionLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/Tools/Version/Version.7z'
    requiredVersion => Map(
        "aokCombine", Map(
            "2.0b", [
                "2.0a"
            ]
        ),
        "aocCombine", Map(
            "1.0e", [
                "1.0c"
            ],
            "1.1", [
                "1.0c"
            ],
            "1.5", [
                "1.0c"
            ],
            "1.6", [
                "1.0c",
                "1.5"
            ]
        )
    )
    versionLocation => This.workDirectory '\Tools\Version'
    versionTool => This.fixLocation '\version.ahk'
    forceDownload => This.readConfiguration('versionForceDownload')

    __New() {
        If This.forceDownload {
            This.downloadPackage(This.versionLink, This.versionLocation '\Version.7z')
            This.extractPackage(This.versionLocation '\Version.7z', This.versionLocation)
        } Else {
            If !FileExist(This.versionLocation '\Version.7z')
            {
                This.downloadPackage(This.versionLink, This.versionLocation '\Version.7z')
                This.extractPackage(This.versionLocation '\Version.7z', This.versionLocation)
            }
            If !DirExist(This.versionLocation '\aok')
                This.extractPackage(This.versionLocation '\Version.7z', This.versionLocation)

        }
    }

    /**
     * Check if it a command line call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
            options.wnd.Hide()
            For H in options.versionList['aok'] {
                If H.Text = A_Args[1] {
                    options.callback.Call(H, '')
                    MsgBoxEx(H.Text ' version is applied successfully!', 'Version', , 0x40, 2)

                }
            }
            For H in options.versionList['aoc'] {
                If H.Text = A_Args[1] {
                    options.callback.Call(H, '')
                    MsgBoxEx(H.Text ' version is applied successfully!', 'Version', , 0x40, 2)
                }
            }
            For H in options.versionList['fe'] {
                If H.Text = A_Args[1] {
                    options.callback.Call(H, '')
                    MsgBoxEx(H.Text ' version is applied successfully!', 'Version', , 0x40, 2)
                }
            }
            Quit()
        }
        /**
         * Exit the app from a commandline call
         * @returns {void} 
         */
        Quit() => ExitApp()

    }
}