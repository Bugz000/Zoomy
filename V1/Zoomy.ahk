#NoEnv
#SingleInstance, Force
#notrayicon
SetWinDelay, 10

CaptureX		:= -70
CaptureY		:= -30
CaptureWidth	:= 150
CaptureHeight	:= 100

RectangleWidth	:= 500
RectangleHeight	:= 200
OffsetX			:= 0
OffsetY			:= 50

CoordMode, Mouse
CoordMode, Pixel
ToolTip, @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`r@`r@`r@`r@`r@`r@`r@`r@`r
WinGet, hWnd, ID, ahk_class tooltips_class32
WinSet, ExStyle, +0x00000020, ahk_id %hWnd%
hDC_SC := DllCall("GetDC", "Uint", 0)
hDC_TT := DllCall("GetDC", "Uint", hWnd)
WinMove, ahk_id %hWnd%,, A_ScreenWidth, 1, RectangleWidth, RectangleHeight

!Z::
	Loop
		{
			if !GetKeyState("LAlt", "P") OR !GetKeyState("Z", "P")
				break
			MouseGetPos, xmouse, ymouse
			DllCall("StretchBlt", "Uint", hDC_TT, "int", 0, "int", 0, "int", RectangleWidth, "int", RectangleHeight, "Uint", hDC_SC, "int", CaptureX + xMouse, "int", CaptureY + yMouse, "int", CaptureWidth, "int", CaptureHeight, "Uint", 0x00CC0020)
			WinMove, ahk_id %hWnd%,, xmouse + OffsetX, ymouse + OffsetY, RectangleWidth, RectangleHeight
			WinSet, AlwaysOnTop, On, ahk_id %hWnd%
		}
	WinMove, ahk_id %hWnd%,, A_ScreenWidth, 1, RectangleWidth, RectangleHeight
	WinSet, AlwaysOnTop, OFF, ahk_id %hWnd%
return
