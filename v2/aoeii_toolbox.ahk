#SingleInstance Force
#Requires AutoHotkey v2

#Include <WebView2\WebView2>
#Include <cJson>
#Include <CNG>

class aoeii_toolbox {
    static name => 'Age of Empires II Tools Box'
    static tools => {
        01: { desc: 'Manage the game location', title: 'My Game' },
        02: { desc: 'Change the game`'s version', title: 'Versions' },
        03: { desc: 'Add/Remove some of the game`'s visual mods', title: 'Visual Mods' },
        04: { desc: 'Add/Remove some of the game`'s data mods', title: 'Data Mods' },
        05: { desc: 'Change the game`'s interface language', title: 'Language' },
        06: { desc: 'Patch up the game for a better gaming experience', title: 'Patchs and Fixs' },
        07: { desc: 'View a resume for the recorded games', title: 'Recordings' },
        08: { desc: 'Enable your custom macros', title: 'AHK Macros' },
        09: { desc: 'Reset HAI trial period', title: 'HAI VPN' },
    }
    static webUI := Gui(, this.name)
    static show := this.webUI.Show('w800 h400')
    static wv := WebView2
    static wvController := this.wv.CreateControllerAsync(this.webUI.hwnd).await()
    static wvCore := this.wvController.CoreWebView2
    static package := JSON.LoadFile('package.json')

    static ahkBridge := {
        title: this.name,
        about: 'Version: ' this.package['version'] ' | Humbly made by Smile 💚',
        tools: JSON.Dump(this.tools),
        click: (*) => SoundPlay('renderer\assets\50300.wav'),
        message: (params*) => MsgBox(params*)
    }

    /**
     * contruct the webview2 interface and run the application
     */
    static __New() {
        this.webUI.OnEvent('Close', (*) => (this.wvCore := this.wvController := this.wv := 0, ExitApp()))
        this.webUI.OnEvent('Size', (*) => this.wvController.Fill())
        this.webUIMarginX := this.webUI.MarginY := 0
        this.wvCore.AddHostObjectToScript('ahk', this.ahkBridge)
        this.wvCore.Navigate(A_ScriptDir '\renderer\index.html')
    }

    /**
     * generate a files hashing of a selected folder
     */
    static hashData() {
        files := []
        dir := FileSelect('D')
        SplitPath(dir, &dirname, &parentdir)
        Loop Files, dir '\*.*', 'R' {
            path := StrReplace(A_LoopFileFullPath, dir '\')
            md5 := Hash.File('MD5', A_LoopFileFullPath)
            files.Push({ path: path, md5: md5 })
        }
        JSON.DumpFile(files, parentdir '\' dirname '.json', '`t')
    }
}