#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\libs\CNG.ahk
#Include ..\libs\JSON.ahk

md5 := Map()
Loop Files, '..\packages\*.7z' {
    md5[A_LoopFileName] := Hash.File('MD5', A_LoopFileFullPath)
}
JSON.DumpFile(md5, 'package.json', '`t')