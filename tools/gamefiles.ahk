#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\libs\CNG.ahk
#Include ..\libs\JSON.ahk

files := []
dir := FileSelect('D')
Loop Files, dir '\*.*', 'R' {
    path := StrReplace(A_LoopFileFullPath, dir '\')
    md5 := Hash.File('MD5', A_LoopFileFullPath)
    files.Push({path: path, md5: md5})
}

JSON.DumpFile(files, 'gamefiles.json', '`t')
Msgbox 'Done!'