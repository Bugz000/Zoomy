#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
G_CaptureX := 1
G_CaptureY := 2
G_CaptureWidth := 3
G_CaptureHeight := 4
G_Magnification := 5
G_OffsetX := 6
G_OffsetY := 7
G_RectangleWidth := 8
G_RectangleHeight := 9

VariableNames = G_CaptureX,G_CaptureY,G_CaptureWidth,G_CaptureHeight,G_Magnification,G_OffsetX,G_OffsetY,G_RectangleWidth,G_RectangleHeight
inisave(VariableNames, "Settings.ini")
msgbox Settings Saved
G_CaptureX := 0
G_CaptureY := 0
G_CaptureWidth := 0
G_CaptureHeight := 0
G_Magnification := 0
G_OffsetX := 0
G_OffsetY := 0
G_RectangleWidth := 0
G_RectangleHeight := 0
iniLoad(Variablenames, "Settings.ini", 1)
msgbox The variables were all set to Zero before loading`r`nSettings Loaded`r`ntop line is Loaded vars`r`n Bottom line is backed up vars (previous state)`r`n %G_CaptureX% %G_CaptureY% %G_CaptureWidth% %G_CaptureHeight% %G_Magnification% %G_OffsetX% %G_OffsetY% %G_RectangleWidth% %G_RectangleHeight%`r`n %_G_CaptureX% %_G_CaptureY% %_G_CaptureWidth% %_G_CaptureHeight% %_G_Magnification% %_G_OffsetX% %_G_OffsetY% %_G_RectangleWidth% %_G_RectangleHeight%

;the function will automatically back up all vars to be loaded
;the Defaults param will cause any Errors in loading to revert to backup-
;(previous state before loading)
;if defaults is not defined, the script will use ERROR as error text
;the function will check for errors also
iniLoad(sVars, File, Defaults = 0)
{
	global
	loop, parse, sVars, `,
		_%A_Loopfield% := %A_Loopfield% 
	loop, parse, sVars, `,
		if Defaults
			IniRead, %A_Loopfield%, %File%, sVars, %A_Loopfield%, % _%A_Loopfield% 
		else
			IniRead, %A_Loopfield%, %File%, sVars, %A_Loopfield%
	loop, parse, sVars, `,	
		if (%A_Loopfield% = "Error")
			msgbox Error reading ini file`r`n Var %A_Loopfield%
}

iniSave(sVars, File)
{
	loop, parse, sVars, `,
		IniWrite, % %A_Loopfield%, %File%, sVars, %A_Loopfield%
}