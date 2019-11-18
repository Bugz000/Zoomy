#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
VarSetCapacity(CurrentCursorStruct, A_PtrSize + 16)
loop
	{
		sleep 100
		;NumPut(VarSetCapacity(cursorInfo, A_PtrSize + 16), cursorInfo, "uint")
		  NumPut(A_PtrSize+16, CurrentCursorStruct, "uInt") ;for some reason cbSize is set to 0 after each call
		  DllCall("GetCursorInfo", "ptr", &CurrentCursorStruct)
		  cbSize := NumGet(CurrentCursorStruct, 0, "Uint")
		  flags := NumGet(CurrentCursorStruct, 4, "Uint")
		  hCursor := NumGet(CurrentCursorStruct, 8, "ptr")
		  xpos := NumGet(CurrentCursorStruct, 12, "Uint")
		  ypos := NumGet(CurrentCursorStruct, 16, "Uint")
		wat := DllCall("GetCursorInfo", "ptr", &cursorInfo)
		traytip, wat,  cbSize: %cbSize%`nflags: %flags%`nhCursor: %hCursor%`nxpos: %xpos%`nypos: %ypos%
		msgbox % DllCall("copyicon", "uInt", hCursor)
	}
	
QueryMouseCursor(byRef numP=0)
{
	;Crash&Burn
	NumPut(VarSetCapacity(CurrentCursorStruct, A_PtrSize + 16), CurrentCursorStruct, "uInt")
	DllCall("GetCursorInfo", "ptr", &CurrentCursorStruct)
	return (numP:=NumGet(CurrentCursorStruct,  8))
}


;	static APPSTARTING := 32650,HAND := 32649 ,ARROW := 32512,CROSS := 32515 ,IBEAM := 32513 ,NO := 32648 ,SIZE := 32640 ,SIZEALL := 32646 ,SIZENESW := 32643 ,SIZENS := 32645 ,SIZENWSE := 32642 ,SIZEWE := 32644 ,UPARROW := 32516 ,WAIT := 32514 
	
	