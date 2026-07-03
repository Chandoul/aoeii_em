TraySetIcon(Base().guiIcon)
Class Base {
    name => 'Age of Empires II Easy Manager'
    namespace => 'aoe_em'
    ahknamespace => 'aoeii_em.ahk'
    description => (
        'An AutoHotkey application holds several useful tools that helps with the game'
    )
    version => '6.9'
    author => 'Smile'
    license => 'MIT'
    packageHashLink => 'https://raw.githubusercontent.com/chandoul/aoeii_em/refs/heads/master/tools/package.json'
    packageHash => this.packageHashGet()
    localPackageHash => JSON.LoadFile(This.workDirectory '\tools\package.json')
    workDirectory => This.workDir()
    configuration => This.workDirectory '\configuration.ini'
    tools => Map(
        '00_game', Map(
            'title', 'My Game',
            'file', This.workDirectory '\tools\game\game.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\game\game.ahk'),
            'workdir', This.workDirectory '\tools\game',
            'pid', 0
        ),
        '00_ungame', Map(
            'title', 'My Game',
            'file', This.workDirectory '\tools\game\uninstallgame.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\game\uninstallgame.ahk'),
            'workdir', This.workDirectory '\tools\game',
            'pid', 0
        ),
        '01_version', Map(
            'title', 'Versions',
            'file', This.workDirectory '\tools\version\version.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\version\version.ahk'),
            'workdir', This.workDirectory '\tools\version',
            'pid', 0
        ),
        '02_fix', Map(
            'title', 'Patchs and Fixs',
            'file', This.workDirectory '\tools\fix\fix.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\fix\fix.ahk'),
            'workdir', This.workDirectory '\tools\fix',
            'pid', 0
        ),
        '03_lng', Map(
            'title', 'Interface Language',
            'file', This.workDirectory '\tools\lng\language.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\lng\language.ahk'),
            'workdir', This.workDirectory '\tools\lng\',
            'pid', 0
        ),
        '04_vm', Map(
            'title', 'Visual Mods',
            'file', This.workDirectory '\tools\vm\visualmods.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\vm\visualmods.ahk'),
            'workdir', This.workDirectory '\tools\vm\',
            'pid', 0
        ),
        '05_dm', Map(
            'title', 'Data Mods',
            'file', This.workDirectory '\tools\dm\datamods.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\dm\datamods.ahk'),
            'workdir', This.workDirectory '\tools\dm\',
            'pid', 0
        ),
        '06_rec', Map(
            'title', 'Recordings',
            'file', This.workDirectory '\tools\rec\recanalyst.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\rec\recanalyst.ahk'),
            'workdir', This.workDirectory '\tools\rec\',
            'pid', 0
        ),
        '07_ahk', Map(
            'title', 'AHK Hotkeys',
            'file', This.workDirectory '\tools\ahk\ahk.ahk',
            'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\ahk\ahk.ahk'),
            'workdir', This.workDirectory '\tools\ahk\',
            'pid', 0
        ),
        ;'08_hai', Map(
        ;    'title', 'Hide ALL IP Reset',
        ;    'file', This.workDirectory '\tools\hai\hideallip.ahk',
        ;    'run', cmdJoin(A_AhkPath, This.workDirectory '\tools\hai\hideallip.ahk'),
        ;    'workdir', This.workDirectory '\tools\hai\',
        ;    'pid', 0
        ;),
    )
    ddrawLocation => This.workDirectory '\externals\cnc-ddraw.2'
    ddrawLink => 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/externals/cnc-ddraw.2.7z'
    ddrawPackage => This.workDirectory '\externals\cnc-ddraw.2.7z'
    _7zrLink => 'https://www.7-zip.org/a/7zr.exe'
    _7zrCsle => This.workDirectory '\externals\7za.exe'
    _7zrVersion => '25.01'
    _7zrSHA256 => '27cbe3d5804ad09e90bbcaa916da0d5c3b0be9462d0e0fb6cb54be5ed9030875'
    gameLocation => This.readConfiguration('GameLocation')
    gameLocationHistory => This.readConfiguration('GameLocationHistory')
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
    guiIcon => This.workDirectory '\assets\aoeii_em-icon-2.ico'
    /**
     * Make sure the app base is correctly found
     */
    __Startup() {
        This.avoidVoobly()
        OnError(handleError)
        handleError(Thrown, Mode) {
            MsgBoxEx(
                'An error occured:`n`nMessage: ' Thrown.Message .
                '`n`nWhat: ' Thrown.What .
                '`n`nExtra: ' Thrown.Extra .
                '`n`nFile: ' Thrown.File .
                '`n`nLine: ' Thrown.Line .
                '`n`nStack: ' Thrown.Stack,
                'An error occured',
                0,
                0x10
            )
            ExitApp()
        }

        If !(A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            ExitApp()
        }

        If !A_IsAdmin {
            MsgBoxEx('Script must be ran as an administrator!', This.name, , 0x30)
            ExitApp()
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
    readConfiguration(key) => IniRead(This.configuration, This.namespace, key, '')

    /**
     * Write user configuration
     * @param key 
     * @param value 
     */
    writeConfiguration(key, value) => IniWrite(value, This.configuration, This.namespace, key)

    /**
     * Check if the config file exists
     * @returns {bool} 
     */
    configurationExists() => FileExist(This.configuration)

    /**
     * Check if there is internet connection
     * @returns {bool}
     */
    getConnectedState() => DllCall("Wininet.dll\InternetGetConnectedState", "Str", Flag := 0x40, "Int", 0)

    cleanUp(location) {
        Loop Files, location '\*', 'D'
            DirDelete(A_LoopFileFullPath, 1)
    }

    downloadPackage(link, file, fileSize := 0, progressText := 0, progressBar := 0, update := 0) {
        Static infoGui := InfoBar := infoText := 0
        if !update && FileExist(file) {
            Return 1
        }
        If !This.getConnectedState() {
            MsgboxEx('Make sure you are connected to the internet!', "Can't download!", , 0x30).result
            Return
        }

        If !infoGui || !InfoBar || !infoText {
            infoGui := GuiEx(, 'Package Download')
            infoGui.initiate(, , 0)
            infoGui.OnEvent('Close', (*) => Reload())
            infoText := infoGui.AddEdit('-E0x200 Border ReadOnly xm ym+20 w350 Center -VScroll BackgroundFFAD59', '...')
            InfoBar := infoGui.AddProgress('-smooth wp h18')
        }

        If !progressText && !progressBar {
            progressText := infoText
            progressBar := InfoBar
            infoGui.ShowEx(, 1)
        }

        If !fileSize {
            Try {
                fileSize := This.fileSizeLink(link)
                fileSize /= 1024
                fileSize /= 1024
            }
        }

        if fileSize && !progressText.Visible {
            progressText.Visible := 1
            progressBar.Visible := 1
        }

        SplitPath(file, &OutFileName)
        SetTimer(fileWatch, 1000)
        Download(link, file)
        SetTimer(fileWatch, 0)
        If progressBar
            progressBar.value := 100
        If progressText
            progressText.Text := 'Download complete! "' OutFileName '" [ ' progressBar.value ' % ]...'
        infoGui.Hide()

        fileWatch() {
            if FileExist(file) {
                currentSize := FileGetSize(file, 'M')
                If fileSize {
                    progress := Round(currentSize / fileSize * 100, 2)
                    if progressText {
                        progressText.Text := 'Downloading "' OutFileName '" [ ' progress ' % ]...'
                    }
                    if progressBar {
                        progressBar.Value := progress
                    }
                } Else if progressText {
                    progressText.Text := 'Downloading "' OutFileName '" [ ' currentSize ' MB ]...'
                }
            }
        }
        Return 1
    }

    extractPackage(
        package, destination, hide := 1, informMe := 1, overwrite := 'aoa',
        info := { text: '', subtext: '' }
    ) {
        Static infoGui := 0
        If !infoGui {
            infoGui := GuiEx(, 'Package Extraction')
            infoGui.OnEvent('Close', terminate)
            infoGui.initiate(, , 0)
            SplitPath(package, &name)
            size := FileGetSize(package, 'M')
            infoText := infoGui.AddEdit('-E0x200 Border ReadOnly xm ym+20 w350 Center r3 -VScroll BackgroundFFAD59',
                (!info.text) ? 'Please Wait...`nExtracting ' name '`n( ' size ' MB )' : info.text
            )
            InfoBar := infoGui.AddProgress('wp h18 0x00000008')
            InfoBar.Focus()
            DllCall("User32.dll\SendMessage", "Ptr", InfoBar.Hwnd, "Int", 0x00000400 + 10, "Ptr", 1, "Ptr", 50)
        }
        RC := 0
        If hide && informMe {
            infoGui.showEx(, 1)
        }
        closed := 0
        terminate(*) {
            If ProcessExist(PID)
                ProcessClose(PID)
            infoGui.Destroy()
            infoGui := 0
            closed := 1
        }
        If RC := RunWait(Format('"{}" x "{}" -o"{}" -{}', This._7zrCsle, package, destination, overwrite), , hide ? 'Hide' : '', &PID) {
            choice := MsgBoxEx('An error occured while trying to extract the package`nError code: ' RC '`nDo you wish to cancel now?', This.name, 0x5, 0x10).result
            If 'Cancel' = choice
                ExitApp()
            If 'Retry' {
                FileDelete(package)
                Reload()
            }
        }
        If infoGui {
            infoGui.Destroy()
            infoGui := 0
        }
        Return (RC || closed) = 0
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
                Run(This.tools['00_game']['file'])
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
        If !DirExist(This.ddrawLocation)
            This.extractPackage(This.ddrawPackage, This.ddrawLocation)
    }

    /**
     * Apply the direct draw configuration to the game
     */
    applyDDrawFix(
        locations := [
            This.gameLocation '\',
            This.gameLocation '\age2_x1\'
        ], centerWindow := 0
    ) {
        For location in locations {
            If DirExist(location) {
                DirCopy(This.ddrawLocation, location, 1)
                If centerWindow {
                    IniWrite(-32000, location '\ddraw.ini', 'ddraw', 'posX')
                    IniWrite(-32000, location '\ddraw.ini', 'ddraw', 'posY')
                }
            }
        }
        This.reviewWindowModeCompatibility()
        This.compatibilityClear(, This.gameLocation '\empires2.exe')
        This.compatibilityClear(, This.gameLocation '\age2_x1\age2_x1.exe')
    }

    clearDDrawFix(
        paths := [
            This.gameLocation '\ddraw.dll',
            This.gameLocation '\age2_x1\ddraw.dll'
        ]
    ) {
        For path in paths {
            If FileExist(path) {
                FileDelete(path)
            }
        }
    }

    reviewWindowModeCompatibility(
        locations := [
            This.gameLocation '\',
            This.gameLocation '\age2_x1\'
        ]
    ) {
        For location in locations {
            If !FileExist(location '\dsound.dll') || !FileExist(location '\ddraw.dll') {
                Continue
            }
            If FileExist(location '\wndmode.dll') {
                FileDelete(location '\wndmode.dll')
            }
            If FileExist(location '\windmode.dll') {
                FileDelete(location '\windmode.dll')
            }
        }
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
        This.compatibilitySet(, This.gameLocation '\empires2.exe', '~ RUNASADMIN WINXPSP3')
        This.compatibilitySet(, This.gameLocation '\age2_x1\age2_x1.exe', '~ RUNASADMIN WINXPSP3')
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
    compatibilityClear(layers := [This.userRegLayer, This.machineRegLayer], valueName := '') {
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
    compatibilitySet(layers := [This.userRegLayer, This.machineRegLayer], valueName := '', value := '') {
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

    reloadApp() => Reload()

    appUpdateCheck() {
        baseLib := This.rawTextContent('https://github.com/chandoul/aoeii_em/raw/refs/heads/master/libs/Base.ahk')
        RegExMatch(baseLib, "version \=\> \'(.*)\'", &version)
        updversion := StrReplace(version.1, '.')
        currversion := StrReplace(This.version, '.')
        if updversion > currversion && 'Yes' = MsgBoxEx('New update is found!`n`n' This.name ' v' version.1 ' is now available`n`nUpdate now?', 'New update', 0x4, 0x40).result {
            This.downloadPackage('https://github.com/chandoul/aoeii_em/raw/refs/heads/master/release/aoeii_em_setup_latest.exe', 'aoeii_em_setup_latest.exe', , , , 1)
            Try Run('aoeii_em_setup_latest.exe')
            ExitApp()
        } Else MsgBoxEx('You are up to date!, no newer versions found.', 'Update Check', , 0x40)
    }

    rawTextContent(link) {
        Try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", link, True)
            whr.Send()
            whr.WaitForResponse()
            response := whr.ResponseText
            whr := ''
        } Catch {
            Download(link, A_Temp '\link.txt')
            response := FileRead(A_Temp '\link.txt')
        }
        Return response
    }

    fileSizeLink(link) {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("HEAD", link, True)
        whr.Send()
        whr.WaitForResponse()
        size := whr.GetResponseHeader("Content-Length")
        whr := ''
        Return size
    }

    packageHashGet() {
        try return JSON.Load(this.rawTextContent(this.packageHashLink))
        catch
            return JSON.LoadFile(This.workDirectory '\tools\package.json')
    }
}


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
    cbChecked => [
        [This.workDirectory '\assets\cb2\checked.png']
    ]
    cbUnChecked => [
        [This.workDirectory '\assets\cb2\unchecked.png']
    ]
}


Class GuiEx extends Gui {
    workDirectory => Base().workDirectory
    backImage => This.workDirectory '\assets\000_50127.bmp'
    transColor => 0xFFFFFE
    checkedImage => This.workDirectory '\assets\cb2\checked.png'
    uncheckedImage => This.workDirectory '\assets\cb2\unchecked.png'
    click => This.workDirectory '\assets\wav\50300.wav'
    initiate(qA := 1, Scrollable := 0, footer := 1, header := 0) {
        This.BackColor := 0xFFFFFF
        If qA
            This.OnEvent('Close', (*) => ExitApp())
        This.MarginX := This.MarginY := 20
        This.SetFont('s10 Bold', 'Segoe UI')
        This.backGroundImage := This.AddPicture('xm-' This.MarginX ' ym-' This.MarginY)
        If Scrollable {
            This.scrollableGui()
        }
        If header {
            This.addButtonEx('xm w80', 'Reload', , appReload)
            This.MarginX := 5
            This.addButtonEx('xp+85 yp', 'Exit', , appQuit)
            This.MarginX := 20
        }
        This.footer := footer
        appReload(Ctrl, Info) => Reload()
        appQuit(Ctrl, Info) => ExitApp()

        ;OnMessage(0x200, OnMouseMove)
        OnMouseMove(wParam, lParam, msg, hwnd) {
            MouseGetPos(&x, &y, , &control)
            Static px := 0, py := 0,
                WM_SETCURSOR := 0x20,
                IDC_HAND := 32649,
                lastControl := '',
                hCursor := DllCall("LoadCursor", "Ptr", 0, "Int", IDC_HAND, "Ptr")
            If (control = lastControl) {
                DllCall("SetCursor", "Ptr", hCursor)
                Return
            }
            If x = px && y = py
                Return
            px := x
            py := y
            If InStr(control, 'Button') {
                DllCall("SetCursor", "Ptr", hCursor)
                lastControl := control
            }
        }
    }
    scrollableGui() {
        vmGuiSB := ScrollBar(this, 200, 400)
        HotIfWinActive("ahk_id " This.Hwnd)
        Hotkey("WheelUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("WheelDown", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+WheelUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+WheelDown", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("Up", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("Down", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+Up", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+Down", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("PgUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("PgDn", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+PgUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("+PgDn", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("Home", (*) => vmGuiSB.ScrollMsg(6, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        Hotkey("End", (*) => vmGuiSB.ScrollMsg(7, 0, GetKeyState("Shift") ? 0x114 : 0x115, This.Hwnd))
        HotIfWinActive
    }
    showEx(options := '', backImage := 0, app := 0) {
        This.Opt('-Caption')
        If This.footer
            This.addAOEFooter(app)
        This.Show(options)
        ; Handling the background image (repeat x, y)
        If backImage {
            This.GetPos(&X, &Y, &bWidth, &bHeight)
            For Control in this {
                Control.GetPos(&X, &Y, &Width, &Height)
                Width += X
                Height += Y
                If Width > bWidth {
                    bWidth := Width
                }
                If Height > bHeight {
                    bHeight := Height
                }
            }

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

            pBrush := Gdip_BrushCreateSolid(0xff480000)

            Gdip_FillRectangle(G, pBrush, 0, 0, bWidth, 3)
            Gdip_FillRectangle(G, pBrush, bWidth - 3, 0, 3, bHeight)
            Gdip_FillRectangle(G, pBrush, 0, 0, 3, bHeight)
            Gdip_FillRectangle(G, pBrush, 0, bHeight - 3, bWidth, 3)

            pBrush2 := Gdip_CreateLineBrushFromRect(0, 0, bWidth, 25, 0xff804000, 0xffDB6D00, 0)
            Gdip_FillRectangle(G, pBrush2, 3, 3, bWidth - 6, 25)

            OnMessage(0x0201, WM_LBUTTONDOWN)
            WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
                X := lParam & 0xFFFF
                Y := lParam >> 16

                if (X > 3 && X < bWidth - 6 && Y > 3 && Y < 28) {
                    PostMessage(0xA1, 2, 0, , hwnd)
                    return
                }
            }

            This.SetFont('s10')
            This.addButtonEx(Format('x{} y{} w20 h18', bWidth - 27, 7), 'X', , (*) => WinClose(This.hwnd))

            If !This.HasProp('aoemain') && !This.HasProp('aoemsg')
                This.addButtonEx(Format('x{} y{} w60 h18', bWidth - 90, 7), '◄ Back', , (*) => goMain())

            goMain() {
                Run(Base().workDirectory '\tools\aoeii_em.ahk')
                WinClose(This.hwnd)
            }

            hBitmap := Gdip_CreateHBITMAPFromBitmap(bBitmap)
            This.backGroundImage.Value := 'HBITMAP:* ' hBitmap

            Gdip_DeleteGraphics(G)
            Gdip_DisposeImage(bBitmap)

            If This.footer {
                This.GetPos(, , &W, &H)
                This.split.Move(, , W - 60)
                This.ft.Move(, , W - 188)
                ;If This.HasProp('updatePackage') {
                ;    This.updatePackage.Move(, , W - 55)
                ;    This.updatePackage.Update()
                ;}
            }
        }
    }
    addButtonEx(options := '', text := '', theme := Button().default, clickCallBack := 0) {
        b := This.AddButton(options, text)
        CreateImageButton(b, 0, theme*)
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
        B := This.addButtonEx('h28 w24 ' options, , Button().cbUnChecked)
        B.GetPos(&X1, &Y1, , &Height1)

        T := This.AddText('BackgroundTrans c4C4C4C x+5', text)
        T.GetPos(&X2, &Y2, , &Height2)

        B.cbValue := 0

        B.OnEvent('Click', (*) => toggleValue())

        toggleValue(*) {
            B.cbValue := (B.cbValue := !B.cbValue) ? defaultValue : B.cbValue
            If clickCallBack {
                clickCallBack(B)
            }
            ;linkedCheck()
            updateStatus()
        }

        B.DefineProp('Checked', { Get: getValue, Set: setValue })

        getValue(ctrl) => B.cbValue

        setValue(ctrl, value) {
            B.cbValue := value ? defaultValue : value
            ;linkedCheck()
            updateStatus()
        }
        updateStatus() {
            If B.cbValue {
                T.Opt('cBlack')
                B.Update(Button().cbChecked)
            } Else {
                B.Update(Button().cbUnChecked)
                T.Opt('c4C4C4C')
            }
            T.Redraw()
            B.Redraw()
        }
        linkedCheck() {
            If T.HasProp('group') {
                For cb in T.group {
                    If cb != T
                        cb.Checked := 0
                }
            }
        }
        Return B
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

        P.DefineProp('ValueEx', { Set: ValueEx })
        ValueEx(ctrl, value) {
            If !FileExist(value) {
                value := This.workDirectory '\assets\' value
            }
            If !FileExist(value) {
                value := ''
            }
            ctrl.Value := value
        }
        Return P
    }

    addGif(options := '', gif := '') {
        If !FileExist(gif) {
            gif := This.workDirectory '\assets\' gif
        }
        If !FileExist(gif) {
            gif := ''
        }
        ;pic := This.addPictureEx(options, gif)
        ;gif := ImageShow(gif, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , pic.Hwnd)
        pGif := Gdip_CreateBitmapFromFile(gif)
        Gdip_GetDimensions(pGif, &width, &height)
        Gdip_DisposeImage(pGif)
        html := Format('<img src="{}" style="position:absolute;left: 0;top: 0;">', gif)
        AX := This.AddActiveX(options ' w' width ' h' height, 'mshtml:' html)
        Return AX
    }

    /**
     * Add a footer that displays some (important) info
     */
    addAOEFooter(app := 0) {
        This.SetFont('s10')
        This.split := This.addText('xm w420 0x10')
        This.MarginY := 0
        This.addPictureEx('xm', 'aok_c.png').OnEvent('Click', (*) => FileExist(gameLocation '\empires2.exe') ? Run(gameLocation '\empires2.exe', gameLocation) : '')
        This.addPictureEx('yp', 'aoc_c.png').OnEvent('Click', (*) => FileExist(gameLocation '\age2_x1\age2_x1.exe') ? Run(gameLocation '\age2_x1\age2_x1.exe', gameLocation) : '')
        This.addPictureEx('yp', 'fe_c.png').OnEvent('Click', (*) => FileExist(gameLocation '\age2_x1\age2_x2.exe') ? Run(gameLocation '\age2_x1\age2_x2.exe', gameLocation) : '')
        gameLocation := Base().gameLocation
        If Game().isValidGameDirectory(gameLocation)
            This.ft := This.AddEdit('BackgroundBlack yp+10 x+20 cWhite w280 -E0x200 h20 Center ReadOnly', Base().gameLocation)
        Else This.ft := This.AddEdit('Backgroundff0000 yp+10 x+20 cWhite w280 -E0x200 h20 Center ReadOnly', Base().gameLocation)
        This.MarginY := 20
        ;If app && app.HasMethod('ensurePackage') {
        ;    This.SetFont('s8')
        ;    This.updatePackage := This.addButtonEx('xm w280', 'Update Package', , update)
        ;    update(*) {
        ;        app.ensurePackage(1)
        ;        Reload()
        ;    }
        ;}
    }
}

Class MsgBoxEx {
    workDirectory => Base().workDirectory

    errorIcon => This.workDirectory '\assets\error.png'
    errorSound => This.workDirectory '\assets\mp3\error.mp3'

    questionIcon => This.workDirectory '\assets\question.png'
    questionSound => This.workDirectory '\assets\mp3\question.mp3'

    exclamationIcon => This.workDirectory '\assets\exclamation.png'
    exclamationSound => This.workDirectory '\assets\mp3\exclamation.mp3'

    infoIcon => This.workDirectory '\assets\info.png'
    infoSound => This.workDirectory '\assets\mp3\info.mp3'

    btnWidth => 100
    /**
     * App specific message box theme
     * @param Text 
     * @param Title 
     * @param {number} Function 
     * @param {number} Icon 
     * @param {number} TimeOut 
     */
    __New(Text := '', Title := A_ScriptName, Function := 0, Icon := 0, TimeOut := 0, minWidth := 400) {

        This.msgGui := GuiEx(, Title)
        This.msgGui.aoemsg := true
        This.msgGui.initiate(0, , 0)
        This.msgGui.AddText('x0 y0 h1 BackgroundTrans w' minWidth)
        This.hIcon := 0

        Switch Icon {
            Case 16:
                This.hIcon := This.msgGui.AddPicture('xm ym+20 w48 h48 BackgroundTrans', This.errorIcon)
                SoundPlay(This.errorSound)
            Case 32:
                This.hIcon := This.msgGui.AddPicture('xm ym+20 w48 h48 BackgroundTrans', This.questionIcon)
                SoundPlay(This.questionSound)
            Case 48:
                This.hIcon := This.msgGui.AddPicture('xm ym+20 w48 h48 BackgroundTrans', This.exclamationIcon)
                SoundPlay(This.exclamationSound)
            Case 64:
                This.hIcon := This.msgGui.AddPicture('xm ym+20 w48 h48 BackgroundTrans', This.infoIcon)
                SoundPlay(This.infoSound)
        }
        If Text = '' {
            Switch Function {
                Case 2: Text := 'Press Abort to stop'
                Case 3, 4: Text := 'Press Yes to agree'
                Case 5, 6: Text := 'Press Cancel to stop'
                Default: Text := 'Press OK to continue'
            }
        }

        This.hText := This.msgGui.AddEdit('xm Center ReadOnly BackgroundE1B15A -E0x200 Border', '`n' Text '`n')

        Switch Function {
            Case 0:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'OK', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 1:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'OK', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 2:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'Abort', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Retry', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Ignore', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 3:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'Yes', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 4:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'Yes', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'No', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 5:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'Retry', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 6:
                This.msgGui.addButtonEx('xm y+20 w' This.btnWidth, 'Cancel', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Try Again', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Continue', , takeAction)
                This.msgGui.addButtonEx('yp w' This.btnWidth, 'Copy Message', , takeAction).Focus()
        }

        This.msgGui.showEx(, 1)
        This.result := ''
        arrangeControls()

        If TimeOut {
            This.hText.Value := '`n' text '`nQuitting in ' (TimeOut) ' second' ((TimeOut > 1) ? 's' : '')
            This.hText.GetPos(, , , &H)
            This.hText.Move(, , , H + 10)
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

        arrangeControls() {
            This.msgGui.GetClientPos(&X, &Y, &Width, &Height)
            If This.hIcon {
                This.hIcon.GetPos(&cX, &cY, &cWidth, &cHeight)
                This.hIcon.Move((Width - cWidth) // 2)
            }

            This.hText.GetPos(&cX, &cY, &cWidth, &cHeight)
            cWidth := cWidth > minWidth ? cWidth : minWidth
            This.hText.Move((Width - cWidth) // 2, , cWidth)

            buttons := []
            For Obj in This.msgGui {
                If !InStr(Type(Obj), 'Gui.Button') || Obj.Text = 'X'
                    Continue
                buttons.Push(Obj)
            }
            X := buttons.Length * This.btnWidth + (buttons.Length - 1) * This.msgGui.MarginX
            X := (Width - X) // 2
            For btn in buttons {
                btn.Move(X + (A_Index - 1) * (This.msgGui.MarginX + This.btnWidth), cY + cHeight + 20)
                btn.Redraw()
            }
        }
    }
}

Class Game extends Base {
    name => 'My Game'
    gamePackage => This.workDirectory '\packages\Age of Empires II.7z'
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
    versionLocation => This.workDirectory '\tools\version'
    versionTool => This.versionLocation '\version.ahk'
    packageLink => 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/Version.7z'
    packageName => 'Version.7z'
    packageLocation => This.workDirectory '\packages'
    packagePath => This.packageLocation '\' This.packageName

    __New() {
        hashs := this.packageHash
        if !FileExist(This.packagePath)
            || !DirExist(this.versionLocation '\aok')
            || !DirExist(this.versionLocation '\aoc')
            || !DirExist(this.versionLocation '\fe')
            || hashs[this.packageName] != this.hashFile(, This.packagePath) {
                This.cleanUp(this.versionLocation)
                This.downloadPackage(This.packageLink, This.packagePath, , , , true)
                This.extractPackage(This.packagePath, This.versionLocation)
        }
    }

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage(update := 0) {
        If !FileExist(This.packagePath) || update {
            This.downloadPackage(This.packageLink, This.packagePath, , , , update)
            This.extractPackage(This.packagePath, This.versionLocation)
        } ;Else This.extractPackage(This.packagePath, This.versionLocation, , , 'aos', { text: 'Verifying the files', subtext: 'Making sure all necessary files are correctly exist before startup!' })
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

    getGameVersions() {
        versions := Map(
            'aok', '',
            'aoc', '',
            'fe', ''
        )
        lookFor := 'gamedata.drs'

        If FileExist(This.gameLocation '\empires2.exe') {
            empires2 := FileOpen(This.gameLocation '\empires2.exe', 'r')

            ; 2.0
            If This.readString(empires2, 2479104, 12) = lookFor {
                versions['aok'] := '2.0'
            }

            ; 2.0a
            If This.readString(empires2, 2475104, 12) = lookFor {
                versions['aok'] := '2.0a'
            }

            ; 2.0b
            If versions['aok'] = '2.0a'
                && FileExist(This.gameLocation '\on.ini')
                && FileRead(This.gameLocation '\on.ini') = 'on' {
                    versions['aok'] := '2.0b'
            }
            empires2.Close()
        }

        If FileExist(This.gameLocation '\age2_x1\age2_x1.exe') {
            age2_x1 := FileOpen(This.gameLocation '\age2_x1\age2_x1.exe', 'r')

            ; 1.0
            If This.readString(age2_x1, 2604672, 12) = lookFor {
                versions['aoc'] := '1.0'
            }

            ; 1.0c
            If This.readString(age2_x1, 2551432, 12) = lookFor {
                versions['aoc'] := '1.0c'
            }

            ; 1.0e
            If versions['aoc'] = '1.0c'
                && FileExist(This.gameLocation '\age2_x1\on.ini')
                && FileRead(This.gameLocation '\age2_x1\on.ini') = 'onon' {
                    versions['aoc'] := '1.0e'
            }

            ; 1.1
            If age2_x1.Length = 2969600 {
                versions['aoc'] := '1.1'
            }

            ; 1.5
            If age2_x1.Length = 3145728 {
                versions['aoc'] := '1.5'
            }
            age2_x1.Close()
        }

        If FileExist(This.gameLocation '\age2_x1\age2_x2.exe') {
            age2_x2 := FileOpen(This.gameLocation '\age2_x1\age2_x2.exe', 'r')
            age2_x2.Pos := 278
            ; 2.2
            If age2_x2.ReadChar() = 39 {
                versions['fe'] := '2.2'
            }
            age2_x2.Close()
        }
        Return versions
    }
    /**
     * Read string from buffer
     * @param {buffer} buff 
     * @param {number} pos
     * @param {number} len
     * @returns {string} 
     */
    readString(buff, pos := 0, len := 1) {
        str := ''
        buff.Pos := pos
        Loop len {
            Try str .= Chr(buff.ReadChar())
        }

        Return str
    }

    availableVersions() {
        aver := Map(
            'aok', [],
            'aoc', [],
            'fe', []
        )
        Loop Files, This.versionLocation '\aok\*', 'D' {
            aver['aok'].Push(A_LoopFileName)
        }
        Loop Files, This.versionLocation '\aoc\*', 'D' {
            aver['aoc'].Push(A_LoopFileName)
        }
        Loop Files, This.versionLocation '\fe\*', 'D' {
            aver['fe'].Push(A_LoopFileName)
        }
        Return aver
    }
}

Class FixPatch extends Base {
    name => 'Game Patchs/Fixs'
    fixLocation => This.workDirectory '\tools\fix'
    fixTool => This.fixLocation '\fix.ahk'
    fixs => This.getFixs()
    fixRegKey => 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Microsoft Games\Age of Empires'
    fixRegKey2 => 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Microsoft Games\Age of Empires II: The Conquerors Expansion\1.0'
    fixRegName => 'Aoe2Patch'
    packageLink => 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/Fix.7z'
    packageLocation => This.workDirectory '\packages'
    packageName => 'Fix.7z'
    packagePath => This.packageLocation '\' This.packageName

    __New() {
        hashs := this.packageHash
        if !FileExist(This.packagePath)
            || !DirExist(this.fixLocation '\Update v*')
            || hashs[this.packageName] != this.hashFile(, This.packagePath) {
                This.cleanUp(this.fixLocation)
                This.downloadPackage(This.packageLink, This.packagePath, , , , true)
                This.extractPackage(This.packagePath, This.fixLocation)
        }
    }
    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage(update := 0) {
        If !FileExist(This.packagePath) || update {
            This.downloadPackage(This.packageLink, This.packagePath, , , , update)
            This.extractPackage(This.packagePath, This.fixLocation)
        } ;Else This.extractPackage(This.packagePath, This.fixLocation, , , 'aos', { text: 'Verifying the files', subtext: 'Making sure all necessary files are correctly exist before startup!' })
    }

    /**
     * Return a list of the available fixs
     * @returns {array} 
     */
    getFixs() {
        F := ['None']
        Loop Files, This.fixLocation '\*', 'D' {
            If InStr(A_LoopFileName, 'Fix')
                Continue
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
    vmLocation => This.workDirectory '\tools\vm'
    packageLocation => This.workDirectory '\packages'
    packageLink => 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/VisualMods.7z'
    packageName => 'VisualMods.7z'
    packagePath => This.packageLocation '\' This.packageName

    __New() {
        hashs := this.packageHash
        if !FileExist(This.packagePath)
            || !DirExist(this.vmLocation '\999 Taunts')
            || hashs[this.packageName] != this.hashFile(, This.packagePath) {
                This.cleanUp(this.vmLocation)
                This.downloadPackage(This.packageLink, This.packagePath, , , , true)
                This.extractPackage(This.packagePath, This.vmLocation)
        }
    }
}

Class DataMod extends Base {
    name => 'Data Mods'
    dmLocation => This.workDirectory '\packages'
    packageLocation => This.workDirectory '\packages'
    dmPackages => Map(
        'The Conquerors Updated', Map(
            'type', 'xml',
            'gameName', 'The Conquerors Updated',
            'gameLinker', 'age2_x1_up',
            'packageName', 'DEBalance.7z',
            'packagePath', This.packageLocation '\DEBalance.7z',
            'packageVersion', '6.1.2',
            'packageSizeMB', '81',
            'packageLink', 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/DEBalance.7z',
            'description', "by _everaoc_`n'The Conquerors Updated' mod with shared allies' line of sight.",
            'thumbnail', This.workDirectory '\assets\DE Balance.png'
        ),
        'WololoKingdoms', Map(
            'type', 'xml',
            'gameName', 'WololoKingdoms',
            'gameLinker', 'age2_x1_wk',
            'packageName', 'WololoKingdoms.7z',
            'packagePath', This.packageLocation '\WololoKingdoms.7z',
            'packageVersion', '5.8.1',
            'packageSizeMB', '225',
            'packageLink', 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/WololoKingdoms.7z',
            'description', "by Tails8521, Jineapple, TriRem, TWest\nPlay the HD Expansions on Voobly.",
            'thumbnail', This.workDirectory '\assets\WololoKingdoms.png'
        ),
        'Elemental TD', Map(
            'type', 'xml',
            'gameName', 'Elemental TD',
            'gameLinker', 'age2_x1_e_td',
            'packageName', 'ElementalTD.7z',
            'packagePath', This.packageLocation '\ElementalTD.7z',
            'packageVersion', '2.13',
            'packageSizeMB', '65.7',
            'packageLink', 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/ElementalTD.7z',
            'description', "by BinaryPotka`nNew 2023 TD mod with Elemental Towers.",
            'thumbnail', This.workDirectory '\assets\Elemental TD.png'
        ),
        'Sheep vs Wolf 3', Map(
            'type', 'xml',
            'gameName', 'Sheep vs Wolf 3',
            'gameLinker', 'age2_x1_svw3',
            'packageName', 'SheepVSWolf.7z',
            'packagePath', This.packageLocation '\SheepVSWolf.7z',
            'packageVersion', '3.0.7',
            'packageSizeMB', '13.2',
            'packageLink', 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/SheepVSWolf.7z',
            'description', "by Gallas`nSheep vs Wolf 3 is a random map based hunter / prey game with unique UP v1.5 RC mechanics. Hide in forest and build a fortress, or hunt for animals and search for Sheep as the Wolf!.",
            'thumbnail', This.workDirectory '\assets\svsw3mini.jpg'
        ),
        'Vampire Revenge', Map(
            'type', 'xml',
            'gameName', 'Vampire Revenge',
            'gameLinker', 'age2_x1_vr',
            'packageName', 'VampireRevenge.7z',
            'packagePath', This.packageLocation '\VampireRevenge.7z',
            'packageVersion', '1.8',
            'packageSizeMB', '18.1',
            'packageLink', 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/VampireRevenge.7z',
            'description', "This mod is an undead/demon themed, random map based hunter / prey game. New civ bonuses, units, buildings, graphics, sounds and gameplay! Must have Userpatch 1.5!.",
            'thumbnail', This.workDirectory '\assets\Vampire.png'
        )
    )
}

Class Language extends Base {
    name => 'Game Interface Language'
    lngLocation => This.workDirectory '\tools\lng'
    packageName => 'Language.7z'
    packagePath => This.packageLocation '\' This.packageName
    packageLocation => This.workDirectory '\packages'
    packageLink => 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/Language.7z'

    __New() {
        hashs := this.packageHash
        if !FileExist(This.packagePath)
            || !DirExist(this.lngLocation '\English')
            || hashs[this.packageName] != this.hashFile(, This.packagePath) {
                This.cleanUp(this.lngLocation)
                This.downloadPackage(This.packageLink, This.packagePath, , , , true)
                This.extractPackage(This.packagePath, This.lngLocation)
        }
    }
    /**
     * Check if it a command line call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
            If options.callback.Call(A_Args[1], '')
                MsgBoxEx(A_Args[1] ' The language is applied successfully!', options.wnd.Title, , 0x40, 2)
            Quit()
        }
        /**
         * Exit the app from a commandline call
         * @returns {void} 
         */
        Quit() => ExitApp()
    }
}

Class AHK extends Base {
    name => 'Custom Shortcuts'
    ahkLocation => This.workDirectory '\tools\ahk'
    hotkeys => This.workDirectory '\tools\ahk\hotkeys.json'
    defaulthotkeys => This.workDirectory '\tools\ahk\default.json'
}

Class Recanalyst extends Base {
    name => 'Age of Empires II: Record Analyzer'
    php => This.workDirectory '\tools\rec\php\php.exe'
    ra => This.workDirectory '\tools\rec\recanalyst'
    recLocation => This.workDirectory '\tools\rec'
    packageName => 'Rec.7z'
    packageLocation => This.workDirectory '\packages'
    packagePath => This.packageLocation '\' This.packageName
    packageLink => 'https://github.com/chandoul/aoeii_em/raw/refs/heads/master/packages/Rec.7z'

    __New() {
        hashs := this.packageHash
        if !FileExist(This.packagePath)
            || !DirExist(this.recLocation '\php')
            || hashs[this.packageName] != this.hashFile(, This.packagePath) {
                This.cleanUp(this.recLocation)
                This.downloadPackage(This.packageLink, This.packagePath, , , , true)
                This.extractPackage(This.packagePath, This.recLocation)
        }
    }

    /**
     * Start the php server and return it PID
     * @returns {number} 
     */
    initiateServer(parent) {
        Run(Format('"{}" -S localhost:8000 -t "{}"', This.php, This.ra), , 'Hide', &phpPid)
        SplitPath(This.php, &phpexe)
        ProcessWait(phpexe)
        Run(Format('"{}\tools\rec\closephp.ahk" {} {}', This.workDirectory, ProcessExist(), phpPid))
    }
}

Class HoldOn {
    name => "Hold on"
    __New() {
        This.infoGui := 0
    }
    start(text := '') {
        This.stop()
        This.infoGui := GuiEx('-SysMenu', This.name)
        This.infoGui.initiate(0, , 0, 0)
        This.infoGui.addGif('xm+90', 'bored.gif')
        This.infoGui.AddText('BackgroundTrans xm w400 Center cRed', 'Please Wait...')
        This.infoGui.SetFont('s9')
        This.infoGui.AddText('BackgroundTrans xm w400 Center', text)
        This.infoGui.showEx(, 1)
    }
    stop() {
        If This.infoGui {
            This.infoGui.Destroy()
        }
    }
}

cmdJoin(args*) {
    argsJoined := ''
    For arg in args {
        argsJoined .= '"' arg '" '
    }
    return argsJoined
}

; external libs
#Include CNG.ahk
#Include ImageButton.ahk
#Include Gdip.ahk
#Include ScrollBars.ahk
#Include LockCheck.ahk
#Include JSON.ahk