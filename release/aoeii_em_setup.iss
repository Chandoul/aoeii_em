#define APP_NAME "Age of Empires II Easy Manager"
#define INSTALL_DIR "{commonpf}\Age of Empires II Easy Manager v2"
#define AHK "AutoHotkey"
#define AHK_FAILED "AutoHotkey is missing, it has to be installed first!."
#define SETUP_ICON "resources\aoeii_em-icon-2.png"
#define SHORTCUT_ICON "resources\aoeii_em-icon-2.ico"
#define SETUP_IMG "resources\aoeii_em-side.png"
#define SETUP_AHK_NAME "AutoHotkey_2.0.26_setup.exe"
#define SETUP_AHK "resources\" + SETUP_AHK_NAME
#define INTERPRETER_AHK "resources\AutoHotkey32_2.0.26.exe"
#define SETUP_NAME "aoeii_em"
//#define APP_VERSION "1.0"

[Setup]
AppId=6C8A2B8E-EE1C-4FA8-8BB9-149BA20347BA
AppName={#APP_NAME}
AppVersion={#APP_VERSION}
AppVerName={#APP_NAME} v{#APP_VERSION}
AppPublisher=Smile
AppPublisherURL=chandoul.github.io
AppSupportURL=chandoul.github.io
AppUpdatesURL=chandoul.github.io
VersionInfoVersion={#APP_VERSION}
AppCopyright=MIT License, 2025
DefaultDirName={#INSTALL_DIR}
WizardSmallImageFile={#SETUP_ICON}
DisableWelcomePage=no
OutputDir=..\release
WizardImageFile={#SETUP_IMG}
OutputBaseFilename={#SETUP_NAME}_setup_latest
UninstallDisplayIcon={app}\resources\aoeii_em-icon-2.ico

[Dirs]
Name: "{app}\packages"

[Files]
Source: {#SETUP_AHK}; DestDir: "{app}\resources"; Flags: ignoreversion dontcopy
Source: {#SHORTCUT_ICON}; DestDir: "{app}\resources"; Flags: ignoreversion
Source: "..\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs
Source: "..\externals\*"; DestDir: "{app}\externals"; Flags: ignoreversion recursesubdirs
Source: "..\libs\*"; DestDir: "{app}\libs"; Flags: ignoreversion recursesubdirs
Source: "..\screenshots\*"; DestDir: "{app}\screenshots"; Flags: ignoreversion recursesubdirs
// autohotkey
Source: "..\tools\ahk\ahk.ahk"; DestDir: "{app}\tools\ahk"; Flags: ignoreversion
Source: "..\tools\ahk\default.json"; DestDir: "{app}\tools\ahk"; Flags: ignoreversion
// data mods
Source: "..\tools\dm\datamods.ahk"; DestDir: "{app}\tools\dm"; Flags: ignoreversion
// Fixs
Source: "..\tools\fix\fix.ahk"; DestDir: "{app}\tools\fix"; Flags: ignoreversion 
Source: "..\tools\fix\features.txt"; DestDir: "{app}\tools\fix"; Flags: ignoreversion 
// game
Source: "..\tools\game\game.ahk"; DestDir: "{app}\tools\game"; Flags: ignoreversion
Source: "..\tools\game\uninstallgame.ahk"; DestDir: "{app}\tools\game"; Flags: ignoreversion
// language
Source: "..\tools\lng\language.ahk"; DestDir: "{app}\tools\lng"; Flags: ignoreversion 
// recording
Source: "..\tools\rec\closephp.ahk"; DestDir: "{app}\tools\rec"; Flags: ignoreversion 
Source: "..\tools\rec\recanalyst.ahk"; DestDir: "{app}\tools\rec"; Flags: ignoreversion 
// version
Source: "..\tools\version\version.ahk"; DestDir: "{app}\tools\version"; Flags: ignoreversion
// visual mods
Source: "..\tools\vm\visualmods.ahk"; DestDir: "{app}\tools\vm"; Flags: ignoreversion
// hide all ip
Source: "..\tools\hai\hideallip.ahk"; DestDir: "{app}\tools\hai"; Flags: ignoreversion
// main
Source: "..\tools\aoeii_em.ahk"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "..\tools\gamefiles.json"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "..\workDirectory"; DestDir: "{app}"; Flags: ignoreversion
// other files
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{commondesktop}\Age of Empires II Easy Manager"; Filename: "{app}\tools\aoeii_em.ahk"; \
WorkingDir: "{app}\tools"; \
IconFilename: "{app}\resources\aoeii_em-icon-2.ico";

Name: "{group}\Age of Empires II Easy Manager"; Filename: "{app}\tools\aoeii_em.ahk"; WorkingDir: "{app}"
Name: "{group}\Uninstall Age of Empires II Easy Manager"; Filename: "{uninstallexe}"

[Run]
Filename: "{commondesktop}\Age of Empires II Easy Manager"; \
Description: "Run Age of Empires II Easy Manager v{#APP_VERSION}"; \
Flags: postinstall shellexec

[Languages]
Name: "English"; MessagesFile: "compiler:Default.isl"
Name: "Arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "Armenian"; MessagesFile: "compiler:Languages\Armenian.isl"
Name: "French"; MessagesFile: "compiler:Languages\French.isl"
Name: "Turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "BrazilianPortuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "Bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"
Name: "Catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "Corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "Czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "Danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "Dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "Finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "German"; MessagesFile: "compiler:Languages\German.isl"
Name: "Hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "Hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "Italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "Japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "Korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "Norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "Polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "Portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "Russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "Slovak"; MessagesFile: "compiler:Languages\Slovak.isl"
Name: "Spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "Swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
Name: "Tamil"; MessagesFile: "compiler:Languages\Tamil.isl"
Name: "Ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[code]
function GetTickCount(): Cardinal; external 'GetTickCount@kernel32.dll';
function GetTickCount64(): Int64; external 'GetTickCount64@kernel32.dll stdcall';

function WaitForWindow(const WindowTitle: string; TimeoutMS: Integer): Boolean;
var
    StartTick: DWORD;
begin
    Result := False;
    StartTick := GetTickCount();

    while GetTickCount - StartTick < DWORD(TimeoutMS) do
    begin
        if FindWindowByWindowName(WindowTitle) <> 0 then
        begin
            Result := True;
            Exit;
        end;
        Sleep(200);
    end;
end;

procedure InitializeWizard();
begin
    WizardForm.MainPanel.Color := $71A6CB;
    WizardForm.Color := $97DAF4;
end;

function IsAppInstalled(): Boolean;
var InstallPath: string;
    NodeHKLM, NodeHKCU: integer;
begin
    NodeHKLM := HKLM;
    NodeHKCU := HKCU;
    if IsWin64 then 
    begin
        NodeHKLM := HKLM64;
        NodeHKCU := HKCU64;
    end; 
    Result := RegQueryStringValue(NodeHKLM,'Software\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey', 'InstallLocation', InstallPath) 
           or RegQueryStringValue(NodeHKLM, 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey', 'InstallLocation', InstallPath)
           or RegQueryStringValue(NodeHKCU,'Software\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey', 'InstallLocation', InstallPath) 
           or RegQueryStringValue(NodeHKCU, 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey', 'InstallLocation', InstallPath);
end;

function InitializeSetup(): Boolean;
var ResultCode: integer;
begin
    if not IsAppInstalled() then
    begin
        if IDNO = MsgBox('AutoHotkey is required to run this application!, Do you like to install it now?', mbError, MB_YESNO) 
            then Result := False
        else
        begin
            ExtractTemporaryFile(ExpandConstant('{#SETUP_AHK_NAME}'));
            ExecAsOriginalUser(ExpandConstant('{tmp}\{#SETUP_AHK_NAME}'), '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
            if not WaitForWindow('AutoHotkey Dash', 10000) and not IsAppInstalled()
            then begin
                if IDYES = MsgBox('Unabled to find AutoHotkey on your system!, do you wish to continue anyway?', mbError, MB_YESNO)
                then Result := True
                else Result := False;
            end
            else Result := True;
        end;
    end 
    else Result := True;
end;

// AutoHotkey Dash
// ahk_class AutoHotkeyGUI
// ahk_exe AutoHotkeyUX.exe