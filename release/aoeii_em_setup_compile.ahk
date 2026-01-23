#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\libs\Base.ahk

appver := Base().version
rc := RunWait(A_ComSpec ' /c iscc aoeii_em_setup.iss /DAPP_VERSION=' appver)

If !rc {
    Size := FileGetSize('aoeii_em_setup_latest.exe')
    Size /= 1024
    Size /= 1024
    Size := Round(Size, 2)
    FileOpen('aoeii_em_setup_size.txt', 'w').Write(Size)
    ; Run setup
    Run('aoeii_em_setup_latest.exe')
}