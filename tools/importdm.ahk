#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\libs\Base.ahk

imapp := DataMod()

FileEncoding('UTF-8')

drsBuild := imapp.drsBuild
drsData := 'gamedata_x1_p1.drs'
lngDll := imapp.lngLoader
mmodsDLL := imapp.mmodsDLL

leadingZero := 5

selectedMod := FileSelect('D')
SplitPath(selectedMod, &modName)

ToolTip 'Create mode directory'
If DirExist(imapp.dmLocation '\' modName)
    DirDelete(imapp.dmLocation '\' modName, 1)
DirCreate(imapp.dmLocation '\' modName)

ToolTip 'Copy ' selectedMod '\age2_x1.xml'
If FileExist(selectedMod '\age2_x1.xml')
    FileCopy(selectedMod '\age2_x1.xml', imapp.dmLocation '\' modName '\age2_x1.xml')

ToolTip 'Update the mod xml path'
xml := FileRead(imapp.dmLocation '\' modName '\age2_x1.xml')
xml := RegExReplace(xml, '<path>.*</path>', '<path>' modName '</path>')
FileOpen(imapp.dmLocation '\' modName '\age2_x1.xml', 'w').Write(xml)

ToolTip 'Copy ' selectedMod '\Data'
If DirExist(selectedMod '\Data')
    DirCopy(selectedMod '\Data', imapp.dmLocation '\' modName '\Data')

If FileExist(imapp.dmLocation '\' modName '\Data\' drsData) {
    If !DirExist(imapp.dmLocation '\' modName '\Drs')
        DirCreate(imapp.dmLocation '\' modName '\Drs')
    ToolTip 'Extract drs file ' modName '\Data\' drsData
    RunWait(A_ComSpec ' /c ' drsBuild ' /e "' imapp.dmLocation '\' modName '\Data\' drsData '" /o "' imapp.dmLocation '\' modName '\Drs"')
    FileDelete(imapp.dmLocation '\' modName '\Data\' drsData)
}
ToolTip 'Copy ' selectedMod '\Drs'
If DirExist(selectedMod '\Drs') {

    DirCopy(selectedMod '\Drs', imapp.dmLocation '\' modName '\Drs', 1)
    ToolTip 'Adding game prefix'
    Loop Files, imapp.dmLocation '\' modName '\Drs\*.*' {
        FileN := A_LoopFileFullPath
        VooblyCodedSlpCheck(A_LoopFileFullPath)
        SplitPath(FileN, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt)
        If !InStr(OutFileName, 'gam') {
            FileMove(FileN, OutDir '\gam' Format('{:0' leadingZero '}', OutNameNoExt) '.' OutExtension, 1)
        }
        ToolTip(A_Index ' treated')
    }
    RunWait(A_ComSpec ' /c ' drsBuild ' /a "' imapp.dmLocation '\' modName '\Data\' drsData '" "' OutDir '\*.slp"')
    RunWait(A_ComSpec ' /c ' drsBuild ' /a "' imapp.dmLocation '\' modName '\Data\' drsData '" "' OutDir '\*.wav"')
    RunWait(A_ComSpec ' /c ' drsBuild ' /a "' imapp.dmLocation '\' modName '\Data\' drsData '" "' OutDir '\*.bina"')
    RunWait(A_ComSpec ' /c ' drsBuild ' /a "' imapp.dmLocation '\' modName '\Data\' drsData '" "' OutDir '\*.bin"')

    ToolTip 'Delete ' modName '\Drs'
    DirDelete(imapp.dmLocation '\' modName '\Drs', 1)
}

ToolTip 'Copy ' lngDll
If FileExist(lngDll)
    FileCopy(lngDll, imapp.dmLocation '\' modName '\Data\')

ToolTip 'Create ' modName '\mmods'
DirCreate(imapp.dmLocation '\' modName '\mmods')

ToolTip 'Copy ' mmodsDLL
If FileExist(mmodsDLL)
    FileCopy(mmodsDLL, imapp.dmLocation '\' modName '\mmods\')

subFolders := [
    'SaveGame',
    'Scenario',
    'Screenshots',
    'Script.AI',
    'Sound',
    'Taunt'
]

subFiles := [
    'language.ini',
    'version.ini',
    'mod.ini'
]

For subFolder in subFolders {
    ToolTip 'Copy ' selectedMod '\' subFolder
    If DirExist(selectedMod '\' subFolder)
        DirCopy(selectedMod '\' subFolder, imapp.dmLocation '\' modName '\' subFolder)
}

For subFile in subFiles {
    ToolTip 'Copy ' selectedMod '\' subFile
    If FileExist(selectedMod '\' subFile)
        FileCopy(selectedMod '\' subFile, imapp.dmLocation '\' modName '\' subFile)
}

ToolTip 'Finishing up...'
DirCreate(imapp.dmLocation '\tmpMode\Games\')
linkerName := InputBox('Enter the xml mod linker name:', imapp.name, 'w300 h100', 'age2_x1')
FileMove(imapp.dmLocation '\' modName '\age2_x1.xml', imapp.dmLocation '\tmpMode\Games\' linkerName.value '.xml')
DirMove(imapp.dmLocation '\' modName, imapp.dmLocation '\tmpMode\Games\' modName)
DirMove(imapp.dmLocation '\tmpMode', imapp.dmLocation '\' modName)

packageVersion := InputBox('Enter the package version:', imapp.name, 'w300 h100', FileExist(imapp.dmLocation '\' modName '\version.ini') ? FileRead(imapp.dmLocation '\' modName '\version.ini') : '1.0.0')

ToolTip 'Packing it up...'
PackageName := StrReplace(modName, ' ') '-' packageVersion.Value '.7z'
packagePath := imapp.dmLocation '\' PackageName

command := '"' imapp._7zrCsle '" a -mx9 "' imapp.dmLocation '\' PackageName '" "' imapp.dmLocation '\' modName '\*"'

If RC := RunWait(command)
    MsgBoxEx(modName ' Packing error, packing failed!`nCode: ' RC, imapp.name, , 0x10)

DirDelete(imapp.dmLocation '\' modName, 1)
MsgBoxEx(modName ' import complete!', 'Done', , 0x40)
ExitApp()

VooblyCodedSlpCheck(File) {
    If InStr(File, '.slp') {
        Return 0
    }
    Static Header := '0xbe 0xef 0x13 0x37'
    Buff := FileRead(File, 'RAW m4')
    fHeader := ''
    For Val in StrSplit(Header, ' ') {
        Hex := Format('{:#x}', NumGet(Buff, A_Index - 1, 'UChar'))
        fHeader .= fHeader != '' ? ' ' Hex : Hex
    }
    If Header = fHeader
        Msgbox Header ', ' fHeader
    Return Header = fHeader
}