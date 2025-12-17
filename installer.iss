; 脚本生成于 2024-12-17
; 专为 Flutter Windows 项目 "Flex Com" 设计
; === 自动读取版本号部分 START ===

; 定义一个辅助函数来读取文件
#define FileHandle
#define FileLine
#define PubspecPath "pubspec.yaml"

; 尝试打开 pubspec.yaml
#if FileExists(PubspecPath)
  #sub ProcessFileLine
    #if Pos("version:", FileLine) == 1
      ; 找到 version: 开头的行，提取版本号
      ; Flutter 格式通常是 "version: 1.0.0+1"
      ; 我们只需要 "1.0.0" 部分，忽略构建号
      #define public MyAppVersion Copy(FileLine, 10, Pos("+", FileLine) - 10)
    #endif
  #endsub

  #for {FileHandle = FileOpen(PubspecPath); FileHandle && !FileEof(FileHandle); FileLine = FileRead(FileHandle)} \
    ProcessFileLine
  #if FileHandle
    #expr FileClose(FileHandle)
  #endif
#else
  ; 如果没找到文件，给个默认值
  #define public MyAppVersion "1.0.0" 
#endif

; 如果读取失败（比如格式不对），兜底防止报错
#if MyAppVersion == ""
  #define MyAppVersion "1.0.0"
#endif

; === 自动读取版本号部分 END ===

#define MyAppName "Flex Com"
#define MyAppPublisher "YourName"
#define MyAppURL "https://github.com/silevilence/flex_com"
#define MyAppExeName "flex_com.exe" 
; 注意：上面的 MyAppExeName 必须与 pubspec.yaml 中的 name 字段一致（编译后的文件名）

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{46496B07-D86F-4048-9DBE-DB360138A955}
AppName={#MyAppName}
; 直接使用上面提取出来的 MyAppVersion
AppVersion={#MyAppVersion}
OutputBaseFilename=FlexCom_Setup_v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; 使得安装包更美观的配置
LicenseFile=LICENSE
; 图标路径，假设你把上次生成的图标放到了这个位置
SetupIconFile=windows\runner\resources\app_icon.ico
; 生成的安装包输出位置
OutputDir=dist
; 压缩算法配置，使安装包尽可能小
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Flutter Windows 仅支持 64位
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimp"; MessagesFile: "ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 核心：将 Flutter 编译输出目录 (build\windows\x64\runner\Release) 下的所有文件打包
; Flags: ignoreversion (忽略版本检查), recursesubdirs (递归子目录), createallsubdirs (保持目录结构)
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 注意: 确保上面路径正确。如果你的 Flutter 版本较老，可能是 build\windows\runner\Release

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent