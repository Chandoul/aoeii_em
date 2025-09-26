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
    ddrawLocation => This.workDirectory '\externals\cnc-ddraw.2'
    ddrawLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/externals/cnc-ddraw.2.7z'
    ddrawPackage => This.workDirectory '\externals\cnc-ddraw.2.7z'
    _7zrLink => 'https://www.7-zip.org/a/7zr.exe'
    _7zrCsle => This.workDirectory '\externals\7za.exe'
    _7zrVersion => '25.01'
    _7zrSHA256 => '27cbe3d5804ad09e90bbcaa916da0d5c3b0be9462d0e0fb6cb54be5ed9030875'
    gameLocation => this.readConfiguration('GameLocation')
    gameLocationHistory => this.readConfiguration('GameLocationHistory')
    gameRangerExecutable => A_AppData '\GameRanger\GameRanger\GameRanger.exe'
    gameRangerSetting => A_AppData '\GameRanger\GameRanger Prefs\Settings'
    gameRegLocation => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Age of Empires II AIO'
    userRegLayer => "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    machineRegLayer => "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    drsBuild => This.workDirectory '\externals\drsbuild.exe'
    mgxfix => This.workDirectory '\externals\mgxfix.exe'
    revealfix => This.workDirectory '\externals\revealfix.exe'
    lngLoader => This.workDirectory '\externals\language_x1_p1.dll'
    mmodsDLL => This.workDirectory '\externals\mmods'
    /**
     * Make sure the app base is correctly found
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

        If This.HasMethod('ensurePackage') {
            This.ensurePackage()
        }

        SetRegView(A_Is64bitOS ? 64 : 32)
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
            Download(This._7zrLink, This._7zrCsle)
        }
        _7zrExist := This._7zrSHA256 == This.hashFile('SHA256', This._7zrCsle)
        If (!_7zrExist) {
            MsgboxEx(
                'Unable to get the correct 7zr.exe (x86) : 7-Zip console executable v' This._7zrVersion ' from "https://www.7-zip.org/download.html"`nTo fix this, download it manually and place it, into the "externals\" directory.'
                , '7-Zip console executable'
                , , 0x30
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
     * @param {number} hide 
     * @param {number} progressText 
     * @param {string} overwrite 
     * @returns {number} 
     */
    extractPackage(package, destination, hide := 1, informMe := 1, overwrite := 'aoa') {
        Static infoGui := 0
        RC := 0
        If hide && informMe {
            If !infoGui {
                infoGui := GuiEx('-SysMenu', This.name)
                infoGui.initiate(0)
                infoGui.addGif('xm+90', 'bored.gif')
                infoGui.AddText(
                    'BackgroundTrans xm w400 Center cRed',
                    'Please Wait...`nThe archive is being extracted!')
                infoGui.SetFont('s9')
                infoGui.AddText(
                    'BackgroundTrans xm w400 Center',
                    '`nPackage: ' package .
                    '`nDestination: ' destination
                )
                infoGui.OnEvent('Close', terminate)
                terminate(*) {
                    If ProcessExist(PID) {
                        ProcessClose(PID)
                    }
                }
            }
            infoGui.showEx(, 1)
        }
        RC := RunWait('"' This._7zrCsle '" x "' package '" -o"' destination '" -' overwrite, , hide ? 'Hide' : '', &PID)
        If RC && 'Yes' = MsgBoxEx('An error occured while trying to extract the package`nError code: ' RC '`nDo you wish to exit now?', This.name, 0x4, 0x10).result {
            ExitApp()
        }
        infoGui.Hide()
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
        If !Game().isValidGameDirectory(This.gameLocation) {
            If wnd {
                wnd.Opt('Disabled')
            }
            If 'Yes' = MsgBoxEx('Game is not yet located!, want to select now?', 'Game', 0x4, 0x40).result
                Try Run(This.tools.game.file)
            ExitApp()
        }
    }

    /**
     * Ensure the required package is correctly exist
     */
    ensureDDrawPackage() {
        If !FileExist(This.ddrawPackage) {
            This.downloadPackage(This.ddrawLink, This.ddrawPackage)
        }
        If !DirExist(this.ddrawLocation)
            This.extractPackage(This.ddrawPackage, This.ddrawLocation)
    }

    /**
     * Apply the direct draw configuration to the game
     */
    applyDDrawFix(
        locations := [
            This.gameLocation '\',
            This.gameLocation '\age2_x1\'
        ]
    ) {
        This.ensureDDrawPackage()
        For location in locations {
            If DirExist(location)
                DirCopy(This.ddrawLocation, location, 1)
            If FileExist(location '\wndmode.dll') {
                FileDelete(location '\wndmode.dll')
            }
            If FileExist(location '\windmode.dll') {
                FileDelete(location '\windmode.dll')
            }
        }
        This.compatibilityClear([This.userRegLayer, This.machineRegLayer], This.gameLocation '\empires2.exe')
        This.compatibilityClear([This.userRegLayer, This.machineRegLayer], This.gameLocation '\age2_x1\age2_x1.exe')
    }

    /**
     * Apply a userpatch patch fix (made by katsuie/rohan)
     * @param {array} locations 
     * @param {string} fix 
     * @returns {void} 
     */
    applyUserFix(
        fix := 'None',
        locations := [
            This.gameLocation '\'
        ]
    ) {
        If fix = 'None'
            Return
        For location in locations {
            If DirExist(location)
                DirCopy(fix, location, 1)
            If FileExist(location '\ddraw.dll') {
                FileDelete(location '\ddraw.dll')
            }
            If FileExist(location '\age2_x1\ddraw.dll') {
                FileDelete(location '\age2_x1\ddraw.dll')
            }
        }
        This.compatibilitySet([This.userRegLayer, This.machineRegLayer], This.gameLocation '\empires2.exe', 'RUNASADMIN WINXPSP3')
        This.compatibilitySet([This.userRegLayer, This.machineRegLayer], This.gameLocation '\age2_x1\age2_x1.exe', 'RUNASADMIN WINXPSP3')
    }

    /**
     * Enables a versions list
     * @param controls 
     */
    enableOptions(controls, enabled := 1) {
        For control in controls {
            control.Enabled := enabled
        }
    }

    /**
     * Clears out a compatibility to an executable
     * @param ValueName 
     */
    compatibilityClear(layers := [], valueName := '') {
        If !valueName {
            Return
        }
        For layer in layers {
            If RegRead(layer, valueName, '')
                RegDelete(layer, valueName)
        }
    }

    /**
     * Sets a compatibility to an executable
     * @param ValueName 
     * @param Value 
     */
    compatibilitySet(layers := [], valueName := '', value := '') {
        If !valueName {
            Return
        }
        For layer in layers {
            RegWrite(value, 'REG_SZ', layer, valueName)
        }
    }

    /**
     * Check if folder files exists in another folder
     * @param folder
     * @param anotherFolder 
     */
    folderMatch(folder, anotherFolder, ignoreFiles := Map()) {
        Loop Files, folder '\*.*', 'R' {
            If ignoreFiles.Has(A_LoopFileName)
                Continue
            PathFile := StrReplace(A_LoopFileFullPath, folder '\')
            If !FileExist(anotherFolder '\' PathFile) {
                Return 0
            }
            currentHash := This.hashFile(, A_LoopFileFullPath)
            foundHash := This.hashFile(, anotherFolder '\' PathFile)
            If (currentHash != foundHash) {
                Return 0
            }
        }
        Return 1
    }

    /**
     * Allow a single choice from group of checkboxs
     * @param {array} group 
     */
    groupCheckBoxs(group := []) {
        For cb in group {
            cb.group := group
        }
    }
}

#Include ImageButton.ahk
Class Button {
    workDirectory => Base().workDirectory
    default => [
        [This.workDirectory '\assets\000_50212.bmp', , 0xFFFFFF]
    ]
    checkedDisabled => [
        [This.workDirectory '\assets\000_50212.bmp', , 0xFFFFFF],
        [],
        [],
        [This.workDirectory '\assets\000_50212_check.bmp', , 0xFFFFFF]
    ]
}

#Include Gdip.ahk
#Include ScrollBars.ahk
#Include ImagePut.ahk

Class GuiEx extends Gui {
    workDirectory => Base().workDirectory
    backImage => This.workDirectory '\assets\000_50127.bmp'
    transColor => 0xFFFFFE
    checkedImage => This.workDirectory '\assets\cb\checked.png'
    uncheckedImage => This.workDirectory '\assets\cb\unchecked.png'
    click => This.workDirectory '\assets\wav\50300.wav'
    initiate(qA := 1, Scrollable := 0) {
        This.BackColor := 0xFFFFFF
        If qA
            This.OnEvent('Close', (*) => ExitApp())
        This.MarginX := This.MarginY := 20
        This.SetFont('s10 Bold', 'Segoe UI')
        This.backGroundImage := This.AddPicture('xm-' This.MarginX ' ym-' This.MarginY)
        If Scrollable {
            This.scrollableGui()
        }
    }
    scrollableGui() {
        vmGuiSB := ScrollBar(This, 200, 400)
        HotIfWinActive("ahk_id " This.Hwnd)
        Hotkey("WheelUp", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("WheelDown", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+WheelUp", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+WheelDown", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("Up", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("Down", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+Up", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+Down", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("PgUp", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("PgDn", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+PgUp", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+PgDn", (*) => vmGuiSB.ScrollMsg((InStr(A_ThisHotkey, "Down") || InStr(A_ThisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("Home", (*) => vmGuiSB.ScrollMsg(6, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("End", (*) => vmGuiSB.ScrollMsg(7, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        HotIfWinActive
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
            update(b, theme)
        }

        b.DefineProp('update', { Call: update })
        update(b, theme := Button().default) {
            CreateImageButton(
                b,
                0,
                theme*
            )
            b.Redraw()
        }

        b.OnEvent('Click', (*) => SoundPlay(This.click))

        If clickCallBack {
            b.OnEvent('Click', clickCallBack)
        }
        Return b
    }
    addCheckBoxEx(options := '', text := '', clickCallBack := 0, defaultValue := 1) {
        T := This.AddText(options ' BackgroundTrans c4C4C4C', text)
        T.OnEvent('Click', toggleValue)
        T.GetPos(&X, &Y, &Width, &Height)

        StrReplace(text, '`n', , , &Count)
        nHeight := Height / (Count + 1)

        T.Move(X + nHeight + 5, Y, Width, Height)
        T.cbValue := 0

        P := This.AddPicture('BackgroundTrans x' X ' y' Y ' h' nHeight ' w' nHeight, This.uncheckedImage)
        P.cbValue := T.cbValue

        P.OnEvent('Click', toggleValue)
        toggleValue(*) {
            T.cbValue := !T.cbValue
            If T.cbValue {
                T.cbValue := defaultValue
                linkedCheck()
            }
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
            If T.cbValue {
                T.cbValue := defaultValue
                linkedCheck()
            }
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

        linkedCheck() {
            If T.HasProp('group') {
                For cb in T.group {
                    If cb != T
                        cb.Checked := 0
                }
            }
        }
        This.AddText('x' X ' y' Y + Height - This.MarginY ' w1 h1 BackgroundTrans')
        Return T
    }

    addPictureEx(options := '', filename := 'blankmod.png', clickcallback := 0) {
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

    addGif(options := '', gif := '') {
        If !FileExist(gif) {
            gif := This.workDirectory '\assets\' gif
        }
        pic := This.addPictureEx(options, gif)
        gif := ImageShow(gif, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , pic.Hwnd)
        Return pic
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

        This.hText := This.msgGui.AddEdit('xm Center ReadOnly BackgroundE1B15A -E0x200 -VScroll Border', '`n' Text '`n`n')

        Switch Function {
            Case 0:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'OK', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 1:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'OK', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 2:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Abort', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Retry', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Ignore', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 3:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Yes', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 4:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Yes', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 5:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Retry', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 6:
                This.msgGui.addButtonEx('xm w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Try Again', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Continue', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
        }

        This.msgGui.showEx(, 1)
        This.centerControls()
        This.result := ''

        If TimeOut {
            This.hText.Value := '`n' text '`nQuitting in ' (TimeOut) ' second' ((TimeOut > 1) ? 's' : '')
            SetTimer(countdown, 1000)
            countdown() {
                This.hText.Value := '`n' text '`nQuitting in ' (--TimeOut) ' second' ((TimeOut > 1) ? 's' : '')
            }
            WinWaitClose(This.msgGui, , TimeOut)
        } Else WinWaitClose(This.msgGui)

        SetTimer(countdown, 0)
        If This.msgGui
            This.msgGui.Destroy()

        /**
         * Take action according to the result
         * @param Ctrl 
         * @param Info 
         * @returns {void} 
         */
        takeAction(Ctrl, Info) {
            This.result := Ctrl.Text
            If This.result = 'Copy Message' {
                A_Clipboard := This.hText.Value
                Return
            }
            SetTimer(countdown, 0)
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
    gamePackage => This.workDirectory '\tools\Game\Age of Empires II.7z'
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

#Include LockCheck.ahk
Class Version extends Base {
    name => 'Game Versions'
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
    versionLocation => This.workDirectory '\tools\Version'
    versionTool => This.versionLocation '\version.ahk'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/Version/Version.7z'
    packageName => 'Version.7z'
    packageLocation => This.workDirectory '\tools\Version'
    packagePath => This.packageLocation '\' This.packageName

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(This.packagePath) {
            This.downloadPackage(This.packageLink, This.packagePath)
            This.extractPackage(This.packagePath, This.packageLocation)
        }
        ;This.extractPackage(This.packagePath, This.packageLocation, 0, , 'aos')
    }

    /**
     * Check there is a commandline call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
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

Class FixPatch extends Base {
    name => 'Game Patchs/Fixs'
    fixLocation => This.workDirectory '\tools\fix'
    fixTool => This.fixLocation '\fix.ahk'
    fixs => This.getFixs()
    fixRegKey => 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Microsoft Games\Age of Empires'
    fixRegName => 'Aoe2Patch'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/fix/Fix.7z'
    packageLocation => This.workDirectory '\tools\fix'
    packageName => 'Fix.7z'
    packagePath => This.packageLocation '\' This.packageName

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(This.packagePath) {
            This.downloadPackage(This.packageLink, This.packagePath)
            This.extractPackage(This.packagePath, This.packageLocation)
        }
        ;This.extractPackage(This.packagePath, This.fixLocation, 1, , 'aos')
    }

    /**
     * Return a list of the available fixs
     * @returns {array} 
     */
    getFixs() {
        F := ['None']
        Loop Files, This.fixLocation '\*', 'D' {
            F.Push(A_LoopFileName)
        }
        Return F
    }

    fixExist(name) {
        Return DirExist(This.fixLocation '\' name)
    }

    /**
     * Check if it a command line call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
            If options.callback.Call(A_Args[1], '')
                MsgBoxEx(A_Args[1] ' fix is applied successfully!', options.wnd.Title, , 0x40, 2)
            Quit()
        }
        /**
         * Exit the app from a commandline call
         * @returns {void} 
         */
        Quit() => ExitApp()

    }
}

Class VisualMod extends Base {
    name => 'Visual Mods'
    drsMap => Map(
        "gra", "graphics.drs",
        "int", "interfac.drs",
        "ter", "terrain.drs"
    )
    vmLocation => This.workDirectory '\tools\vm\VisualMods'
    packageLocation => This.workDirectory '\tools\vm'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/vm/VisualMods.7z'
    packageName => 'VisualMods.7z'
    packagePath => This.packageLocation '\' This.packageName

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(This.packagePath) {
            This.downloadPackage(This.packageLink, This.packagePath)
        }
        If !DirExist(This.vmLocation)
            This.extractPackage(This.packagePath, This.packageLocation)
    }
}

Class DataMod extends Base {
    name => 'Data Mods'
    dmLocation => This.workDirectory '\tools\dm'
    packageLocation => This.workDirectory '\tools\dm'
    dmPackages => Map(
        'The Conquerors Updated', Map(
            'type', 'xml',
            'gameName', 'The Conquerors Updated',
            'gameLinker', 'age2_x1_up',
            'packageName', 'DEBalance-6.1.2.7z',
            'packagePath', This.packageLocation '\DEBalance-6.1.2.7z',
            'packageVersion', '6.1.2',
            'packageSizeMB', '81',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/DEBalance-6.1.2.7z',
            'description', "by _everaoc_`n'The Conquerors Updated' mod with shared allies' line of sight.",
            'thumbnail', This.workDirectory '\assets\DE Balance.png'
        ),
        'WololoKingdoms', Map(
            'type', 'xml',
            'gameName', 'WololoKingdoms',
            'gameLinker', 'age2_x1_wk',
            'packageName', 'WololoKingdoms-5.8.1.7z',
            'packagePath', This.packageLocation '\WololoKingdoms-5.8.1.7z',
            'packageVersion', '5.8.1',
            'packageSizeMB', '225',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/WololoKingdoms-5.8.1.7z',
            'description', "by Tails8521, Jineapple, TriRem, TWest\nPlay the HD Expansions on Voobly.",
            'thumbnail', This.workDirectory '\assets\WololoKingdoms.png'
        ),
        'Elemental TD', Map(
            'type', 'xml',
            'gameName', 'Elemental TD',
            'gameLinker', 'age2_x1_e_td',
            'packageName', 'ElementalTD-2.02.7z',
            'packagePath', This.packageLocation '\ElementalTD-2.02.7z',
            'packageVersion', '2.02',
            'packageSizeMB', '46',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/ElementalTD-2.02.7z',
            'description', "by BinaryPotka\nNew 2023 TD mod with Elemental Towers.",
            'thumbnail', This.workDirectory '\assets\Elemental TD.png'
        )
    )
}