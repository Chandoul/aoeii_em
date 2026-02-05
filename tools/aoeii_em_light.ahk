#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\Libs\Base.ahk

aoeiiapp := Base()
aoeiiapp.__Startup()

aoeiiGui := GuiEx(, aoeiiapp.name)
aoeiiGui.initiate()