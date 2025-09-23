#Include GetOpenedFiles.ahk
lockCheck(Folder := '') {
    Locks := Map()
    If !FolderLockCheck(Folder, &Locks)
        Return 0
    For Lock in Locks {
        Info := GatherProcessInfo(Lock)
        if Info.Name = 'explorer.exe' && FileExist(EnvGet('windir') '\' Info.Name)
            Continue
        If 'Yes' != MsgBoxEx('The following process may prevent applying the necessary changes:`n'
            . '`nName: ' Info.Name '`nLocation: ' Info.Path '`n`nClose it now??', 'Heads up!', 0x4, 0x30).result
            Return 0
        If 'Yes' != MsgBoxEx('[Double Check] Are you sure to close this process?`n`n' Info.Name '`nLocated at: [ ' Info.Path ' ]`n`nClose it now??', 'Heads up!', 0x4, 0x30).result
            Return 0
        Try ProcessClose(Info.Name), ProcessWaitClose(Info.Name, 5)
        Catch {
            MsgBoxEx('Unable to close this process, you may try to close it manually!', 'Failed!', , 0x10)
            Return 0
        }
    }
    Return 1
}