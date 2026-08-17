#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\libs\Base.ahk

app := Base()

appver := app.version
rc := RunWait(A_ComSpec ' /c iscc aoeii_em_setup.iss /DAPP_VERSION=' appver)

If !rc {
    Size := FileGetSize('aoeii_em_setup_latest.exe', 'M')
    FileOpen('aoeii_em_setup_size.txt', 'w').Write(Size)
    ; Run setup
    Run('aoeii_em_setup_latest.exe')
}