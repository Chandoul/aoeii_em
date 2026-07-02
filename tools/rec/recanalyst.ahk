#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

recapp := Recanalyst()
recapp.__Startup()

recGui := GuiEx(, recapp.name)
recGui.initiate()

vr := recGui.addButtonEx('xm ym+20 w450 Disabled', 'View Record Details', , viewRecordDetails)
vrdetails := recGui.AddEdit('xp y+5 wp Center BackgroundE1B15A -E0x200')

recList := recGui.AddListView('xm y+5 wp r20 BackgroundE1B15A -E0x200', ['Record'])

recapp.isGameFolderSelected()

recGui.showEx(, 1)

recordsList := []

vr.TextEx := 'Loading the records...'
loadRecord()

vr.TextEx := 'Starting the php server...'
phpPID := recapp.initiateServer(recGui)

vr.TextEx := 'View Record Details'
vr.Enabled := True

loadRecord() {
    recList.Delete()
    records := Map()
    Loop Files, recapp.gameLocation '\SaveGame\*.*' {
        If !(A_LoopFileExt ~= 'i)MGL|MGX|MGZ') {
            Continue
        }
        creationDate := FileGetTime(A_LoopFileFullPath, 'C')
        records[creationDate] := A_LoopFileFullPath
    }
    For time, record in records {
        vrdetails.Text := 'Loaded records - [ ' A_Index ' ]'
        mgxFixCheck(record)
        SplitPath(record, &outFileName)
        recordsList.Push(record)
        recList.Add(, outFileName)
    }
}

viewRecordDetails(Ctrl, Info) {
    Selected := recList.GetNext()
    If !Selected {
        MsgBoxEx('Please select a record first!', recapp.name, , 0x30)
        Return
    }
    FileOpen(recapp.ra '\linker.txt', 'w').Write(recordsList[Selected])
    Run('http://localhost:8000')
}

mgxFixCheck(filepath) {
    header := FileRead(filepath, 'RAW m4')
    If !headerLen := NumGet(header, 0, 'Int') {
        RunWait(recapp.mgxfix ' -f "' filepath '"', , 'Hide')
    }
}