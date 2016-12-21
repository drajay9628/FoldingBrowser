; Edit this installer script with HM NIS Edit.
; Requires that NSIS (Nullsoft Scriptable Install System) compiler be installed.

;---- Helper defines / constants ----
!define PRODUCT_VERSION "0.1.3.3"  ;Match the displayed version in the program title. Example: 1.2.3
!define PRODUCT_4_VALUE_VERSION "0.1.3.3"  ;Match the executable version: Right-click the program executable file | Properties | Version. Example: 1.2.3.4
!define PRODUCT_YEAR "2016"
!define PRODUCT_NAME "CureCoin"
!define PRODUCT_EXE_NAME "curecoin-qt"  ;Executable name without extension
!define PRODUCT_PUBLISHER "CureCoin"
!define PRODUCT_WEB_SITE "https://github.com/Hou5e/FoldingBrowser/releases"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_EXE_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_EXE_NAME "Uninstall_${PRODUCT_EXE_NAME}"  ;Executable name without extension

SetCompressor lzma  ;Set compression method


!define MULTIUSER_EXECUTIONLEVEL admin  ;Set the execution level for 'MultiUser.nsh'
!include MultiUser.nsh  ;Used for testing execution level. Does the installee have admin rights?

!include FileFunc.nsh  ;File Functions Header, for RefreshShellIcons
!insertmacro un.RefreshShellIcons

;---- Modern UI section ----
!include MUI2.nsh

;MUI Settings
!define MUI_ABORTWARNING
!define MUI_WELCOMEFINISHPAGE_BITMAP "Resources\CURE - Side-164x314.bmp"
!define MUI_ICON "Resources\CureCoinLogo-16_32_48.ico"
!define MUI_UNICON "Resources\Uninstaller-16_32_48.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "Resources\CURE - Header-150x57.bmp"
!define MUI_COMPONENTSPAGE_SMALLDESC   ;properties for the Components page. Without this, the description field is larger.

;Welcome page
!insertmacro MUI_PAGE_WELCOME

;License page
!insertmacro MUI_PAGE_LICENSE "CureCoin\license.txt"

;Directory page
!insertmacro MUI_PAGE_DIRECTORY

;Instfiles page
!insertmacro MUI_PAGE_INSTFILES

;Finish page
;Enable for debugging to see where files get installed.
;!define MUI_FINISHPAGE_NOAUTOCLOSE  
;!define MUI_FINISHPAGE_RUN "$INSTDIR\${PRODUCT_EXE_NAME}.exe"
;!define MUI_FINISHPAGE_RUN_NOTCHECKED
;!insertmacro MUI_PAGE_FINISH

;Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

;Language files
!insertmacro MUI_LANGUAGE "English"
;---- MUI section end ----

;---- Installer Info ----
Name "${PRODUCT_NAME} v${PRODUCT_VERSION}"
OutFile "CureInst\Install ${PRODUCT_NAME} v${PRODUCT_VERSION}.exe"
BrandingText "${PRODUCT_PUBLISHER}"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"  ;Default installation folder (Set to: $INSTDIR during MUI_PAGE_DIRECTORY)
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
SetDatablockOptimize on
ShowInstDetails show
AutoCloseWindow true
ShowUnInstDetails show
SetDateSave on
CRCCheck on
XPStyle on
SilentInstall normal  ;Silent install or uninstall: run from the command line with /S or /SD (case-sensitive) option. See NSIS help for more details.

;---- Installer output file version information ----
  VIProductVersion "${PRODUCT_4_VALUE_VERSION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME} v${PRODUCT_VERSION}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "${PRODUCT_NAME} v${PRODUCT_VERSION} Installer"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${PRODUCT_PUBLISHER}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright � ${PRODUCT_YEAR} ${PRODUCT_PUBLISHER}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${PRODUCT_NAME} v${PRODUCT_VERSION} Installer"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION}"

;---- Installer sections, selectable on configuration page if shown ----
Section "!Main Program Installation" SEC01
  SetOverwrite on
  SectionIn RO  ;RO = Read only, which forces this section to be required
  SetShellVarContext all  ;Try to use the 'All Users' folder for shortcuts (WinXP only), otherwise default to the user's folder

  ;If the CureCoin Wallet is running, then close it
  Call CloseCureCoin

  ;Program files to put in the installtion directory
  SetOutPath "$INSTDIR"  ;Destination
  File "CureCoin\license.txt"
  File "CureCoin\curecoin-qt.exe"
  File "CureCoin\libgcc_s_dw2-1.dll"
  File "CureCoin\libstdc++-6.dll"
  File "CureCoin\mingwm10.dll"
  File "CureCoin\QtCore4.dll"
  File "CureCoin\QtGui4.dll"
  File "CureCoin\Curecoin- cygnusxi - Source files on GitHub.url"

  SetShellVarContext current   ;for 'Current': $AppData = C:\Users\%username%\AppData\Roaming, otherwise for 'all': $AppData = C:\ProgramData
  SetOutPath "$APPDATA\curecoin"
  File "CureCoin\curecoin.conf.example"

  ;Create program shortcuts
  SetShellVarContext all  ;Uninstall shortcuts from the 'All Users' folder (WinXP only), otherwise uninstall shortcuts from the user's folder
  SetOutPath "$INSTDIR"  ;Destination. Required to make the EXE shortcut 'start in' path correct
  CreateShortCut "$DESKTOP\CureCoin.lnk" "$INSTDIR\curecoin-qt.exe"
  CreateShortCut "$SMPROGRAMS\CureCoin.lnk" "$INSTDIR\curecoin-qt.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\${PRODUCT_UNINST_EXE_NAME}.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\${PRODUCT_UNINST_EXE_NAME}.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\curecoin-qt.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


; ---- Installer functions ----
Function .onInit
  ;On install startup, ensure Admin user privilege level
  !insertmacro MULTIUSER_INIT
FunctionEnd

Function .oninstsuccess
  SetShellVarContext current
  ;Auto-run the main EXE, once installed, with the command line options to load settings for the RPC login and port
  Exec "$INSTDIR\${PRODUCT_EXE_NAME}.exe -conf=$APPDATA\curecoin\curecoin.conf.example"
FunctionEnd

Function CloseCureCoin
  Push $R1
RetryLoop:
  ;See if program is running
  FindWindow $R1 "" "curecoin-qt"
  ;MessageBox MB_OK "Found: $R1"    ;Enable for debugging
  IntCmp $R1 0 ExitWhenNotFound

  ;Ask to Close program
  MessageBox MB_RETRYCANCEL "Please close the running CureCoin Wallet software,$\r$\nand press 'Retry' (takes about 20 seconds).$\r$\n$\r$\nNote: CureCoin maybe running in the system tray in the lower righthand corner of your screen." /SD IDCANCEL IDCANCEL ExitWhenNotFound

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 5000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 5000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 5000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 3000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 3000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 3000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 ExitWhenNotFound
  Sleep 3000

  Goto RetryLoop
ExitWhenNotFound:
  Pop $R1
FunctionEnd


;---- Uninstaller ----
Section Uninstall
  SetShellVarContext all  ;Uninstall shortcuts from the 'All Users' folder (WinXP only), otherwise uninstall shortcuts from the user's folder

  ;If the CureCoin Wallet is running, then close it
  Call un.CloseCureCoin

  ;Delete the program shortcuts
  Delete "$SMPROGRAMS\CureCoin.lnk"
  Delete "$DESKTOP\CureCoin.lnk"

  ;Delete the main installation folder, if possible
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\curecoin-qt.exe"
  Delete "$INSTDIR\libgcc_s_dw2-1.dll"
  Delete "$INSTDIR\libstdc++-6.dll"
  Delete "$INSTDIR\mingwm10.dll"
  Delete "$INSTDIR\QtCore4.dll"
  Delete "$INSTDIR\QtGui4.dll"
  Delete "$INSTDIR\CureCoin\Curecoin- cygnusxi - Source files on GitHub.url"
  Delete "$INSTDIR\*"
  RMDir "$INSTDIR"

  SetOutPath $APPDATA     ;Try changing to a different path to avoid being in the working folder
  ;Delete the main folder if possible
  RMDir /r "$INSTDIR"

  ;Delete the main folder, if possible
  Delete "$INSTDIR\*"
  RMDir "$INSTDIR"

  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  ${un.RefreshShellIcons}   ;Make sure the desktop is refreshed to cleanup any deleted desktop icons
  SetAutoClose true
SectionEnd


;---- Uninstaller functions ----
Function un.onInit
  !insertmacro MULTIUSER_UNINIT  ;On uninstall startup, ensure Admin user privilege level

  MessageBox MB_ICONQUESTION|MB_YESNO "Are you sure you want to remove $(^Name)?$\r$\n(User settings will be left in your user profile)" /SD IDYES IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer." /SD IDOK
FunctionEnd

Function un.CloseCureCoin
  Push $R1
unRetryLoop:
  ;See if program is running
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound

  ;Ask to Close program
  MessageBox MB_RETRYCANCEL "Please close the running CureCoin Wallet software,$\r$\nand press 'Retry' (takes about 20 seconds).$\r$\n$\r$\nNote: CureCoin maybe running in the system tray in the lower righthand corner of your screen." /SD IDCANCEL IDCANCEL unExitWhenNotFound

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 5000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 5000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 5000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 3000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 3000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 3000

  ;Try exiting loop
  FindWindow $R1 "" "curecoin-qt"
  IntCmp $R1 0 unExitWhenNotFound
  Sleep 3000

  Goto unRetryLoop
unExitWhenNotFound:
  Pop $R1
FunctionEnd