#Include C:\Users\Spoon\Desktop\Classes\gdip.ahk


;---------Done---------
;input protection //
;thin display lines  //
;crosshair reference? //
;make display follow cursor //
;tidbits scrolly change value thingy  http://www.ahkscript.org/boards/viewtopic.php?f=6&t=219 //
;lock capture at edges of screen /// (mega fix'd :D)
;Another hotkey to show preview (with title bar for dragging) //

;---------Buggy but working---------


;---------Todo---------
;Relative/absolute coord toggle for output ?? (forgot what this means // see below line)
;configurable coords for persistent box
;Configurable hotkeys
;stop the settings lines resetting to middle when you adjust values

#NoEnv
#SingleInstance, Force
SetWinDelay 10
IniRead, Started, ZoomySettings.ini, Vars, Started, 0

ProgramName         := "Zoomy"
Version             := "V5"

if !(Started)
    {
        msgbox Zoomy %Version%`r`nThis is a one-time message and won't bug you in the future`r`n`r`nWARNING`r`nThis script is designed for 32bit Unicode AHK only.`r`n`r`nCredits:`r`n     tidbit: Mouse and wheel + general help`r`n     Bigvent: Debugging/general help`r`n     Afterlemon: Debugging/general help`r`n     Nameless_exe: Debugging/general help`r`n     Linear Spoon: Fixing complex issue with region moving
        IniWrite, 1, ZoomySettings.ini, Vars, Started
    }

_G_CaptureX         := -70
_G_CaptureY         := -30
_G_CaptureWidth     := 150
_G_CaptureHeight    := 100

_G_Magnification    := 2.33333

_G_RectangleWidth       := 349
_G_RectangleHeight  := 233
_G_OffsetX          := 20
_G_OffsetY          := 70

Vars = G_CaptureX,G_CaptureY,G_CaptureWidth,G_CaptureHeight,G_Magnification,G_OffsetX,G_OffsetY,G_RectangleWidth,G_RectangleHeight

loop, parse, vars, `,
    IniRead, %A_Loopfield%, ZoomySettings.ini, Vars, %A_Loopfield%, % _%A_Loopfield% ;Try to read vars, if it fails, the Default param resolves to appropriate "Default" var (_varname)

loop, parse, vars, `,
    IniWrite, % %A_Loopfield%, ZoomySettings.ini, Vars, %A_Loopfield%

Traytip, %ProgramName% %version%, %ProgramName% started. `r`nHold Alt Z or press Win Z to start!`r`n`r`Many thanks to:`r`n-tidbit`r`n-Bigvent`r`n-Afterlemon`r`n-Linear Spoon, 10
Menu, tray, NoStandard
Menu, tray, add, Settings, MenuHandler
Menu, tray, add
Menu, tray, add, Reload, MenuHandler
Menu, tray, add, Exit, MenuHandler

CoordMode, Mouse
CoordMode, Pixel

Gui, add, text
Gui, +Toolwindow
Gui, show, , Zoomy

WinGet, hWnd, ID, Zoomy
WinSet, ExStyle, +0x00000020, ahk_id %hWnd%
WinSet, Style, -0xC00000, ahk_id %hWnd%

hDC_SC := DllCall("GetDC", "Uint", 0)
hDC_TT := DllCall("GetDC", "Uint", hWnd)
WinMove, ahk_id %hWnd%,, A_ScreenWidth, 1, G_RectangleWidth, G_RectangleHeight

OnMessage(WM_MOUSEWHEEL:=0x20A, "wheel")
OnMessage(WM_MOUSEMOVE:=0x200, "drag")


hDC_MEM := CreateCompatibleDC(hDC_TT)
hBM := CreateCompatibleBitmap(hDC_TT, G_CaptureWidth, G_CaptureHeight)
old_hBM := SelectObject(hDC_MEM, hBM)

!Z::
    if (PersistentShow)
        Return
    WinShow, ahk_id %hWnd%
    WinSet, Style, -0xC00000, ahk_id %hWnd%
    While (GetKeyState("LAlt", "P")&&GetKeyState("Z", "P")){
            MouseGetPos, xmouse, ymouse
            ;Copy capture region into memory bitmap
            BitBlt(hDC_MEM, 0, 0, G_CaptureWidth, G_CaptureHeight, hDC_SC, x_source := (XMouse+G_CaptureWidth+G_CaptureX>=A_ScreenWidth?A_ScreenWidth-G_CaptureWidth:(XMouse+G_CaptureX<=0?0:XMouse+G_CaptureX)), y_source := (YMouse+G_CaptureHeight+G_CaptureY>=A_ScreenHeight?A_ScreenHeight-G_CaptureHeight:(YMouse+G_CaptureY<=0?0:YMouse+G_CaptureY)))

            VarSetCapacity(cursorInfo, sz := 16+A_PtrSize)
            Numput(sz, cursorInfo, 0, "uint") ;cbSize
            DllCall("GetCursorInfo", "ptr", &cursorInfo)  ;This gets us HCURSOR and tells us if the cursor is hidden or not
            if (NumGet(cursorInfo, 4, "uint") = 1) ;if cursor is showing
            {
              ;We dont have to worry about resizing the mouse - stretchblt will do that
              VarSetCapacity(iconInfo, 8+3*A_PtrSize)
              DllCall("GetIconInfo", "ptr", NumGet(cursorInfo, 8, "ptr"), "ptr", &iconInfo)  ;This gets us the "hotspot" of the cursor, which is needed to draw it in the correct offset
              xcursor := Floor((XMouse-x_source-Numget(iconInfo, 4, "uint")))
              ycursor := Floor((YMouse-y_source-Numget(iconInfo, 8, "uint")))
              DllCall("DrawIconEx", "ptr", hDC_MEM, "int", xcursor, "int", ycursor, "ptr", NumGet(cursorInfo, 8, "ptr"), "int", 0, "int", 0, "uint", 0, "ptr", 0, "uint", 11)
            }
            
            ;Stretch memory bitmap onto window
            StretchBlt(hDC_TT, 0, 0, G_RectangleWidth, G_RectangleHeight, hDC_MEM, 0, 0, G_CaptureWidth, G_CaptureHeight)

            ;Bound blue box to the screen
            x_dest := XMouse+G_RectangleWidth+G_OffsetX >= A_ScreenWidth ? A_ScreenWidth - G_RectangleWidth : (XMouse+G_OffsetX<0?0:XMouse+G_OffsetX)
            y_dest := YMouse+G_RectangleHeight+G_OffsetY >= A_ScreenHeight ? A_ScreenHeight - G_RectangleHeight : (YMouse + G_OffsetY < 0 ? 0 : YMouse + G_OffsetY)
        
            ;If it overlaps the red box...
            if Intersects(x_dest, y_dest, G_RectangleWidth, G_RectangleHeight, x_source, y_source, G_CaptureWidth, G_CaptureHeight)
            {
                ;Calculate the distance to get the blue box off the red box (while remaining on the screen)
                left_shift := (x_source - G_RectangleWidth < 0 ? 999999 : x_source - G_RectangleWidth) - x_dest
                right_shift := (x_source + G_CaptureWidth + G_RectangleWidth > A_ScreenWidth ? 999999 : x_source + G_CaptureWidth) - x_dest
                x_shift := abs(left_shift) < abs(right_shift) ? left_shift : right_shift
                up_shift := (y_source - G_RectangleHeight < 0 ? 999999 : y_source - G_RectangleHeight) - y_dest
                down_shift := (y_source + G_CaptureHeight + G_RectangleHeight > A_ScreenHeight ? 999999 : y_source + G_CaptureHeight) - y_dest
                y_shift := abs(up_shift) < abs(down_shift) ? up_shift : down_shift
                
                ;Alternate, faster algorithm that might also be suitable
            ;   x_shift := (x_dest > A_ScreenWidth//2 ? x_source - G_RectangleWidth : x_source + G_CaptureWidth) - x_dest
            ;   y_shift := (y_dest > A_ScreenHeight//2 ? y_source - G_RectangleHeight : y_source + G_CaptureHeight) - y_dest
            
              ;Figure out the shortest direction possible and go that way
                if (abs(x_shift) > abs(y_shift))
                    x_dest += x_shift
                else
                    y_dest += y_shift
            }
            

            
            WinMove, ahk_id %hWnd%,, x_dest, y_dest, G_RectangleWidth, G_RectangleHeight
            WinSet, AlwaysOnTop, On, ahk_id %hWnd%
        }
    WinMove, ahk_id %hWnd%,, A_ScreenWidth, 1, G_RectangleWidth, G_RectangleHeight
    WinSet, AlwaysOnTop, OFF, ahk_id %hWnd%
    WinSet, Style, +0xC00000, ahk_id %hWnd%
    WinHide, ahk_id %hWnd%
return

;I made this a function because I suspect you may want to ensure that the boxes don't overlap when confirming settings...
Intersects(x1, y1, w1, h1, x2, y2, w2, h2)
{
    return !(x1+w1 < x2 || x1 > x2+w2 || y1+h1 < y2 || y1 > y2+h2)
}

#Z::
    PersistentShow = 1
    WinSet, Style, +0xC00000, ahk_id %hWnd%
    WinShow, ahk_id %hWnd%
    WinMove, ahk_id %hWnd%,, A_Screenwidth / 2, A_ScreenHeight / 2, G_RectangleWidth, G_RectangleHeight
    While (PersistentShow)
        {
            MouseGetPos, xmouse, ymouse
            ;Copy capture region into memory bitmap
            BitBlt(hDC_MEM, 0, 0, G_CaptureWidth, G_CaptureHeight, hDC_SC, x_source := (XMouse+G_CaptureWidth+G_CaptureX>=A_ScreenWidth?A_ScreenWidth-G_CaptureWidth:(XMouse+G_CaptureX<=0?0:XMouse+G_CaptureX)), y_source := (YMouse+G_CaptureHeight+G_CaptureY>=A_ScreenHeight?A_ScreenHeight-G_CaptureHeight:(YMouse+G_CaptureY<=0?0:YMouse+G_CaptureY)))

            VarSetCapacity(cursorInfo, sz := 16+A_PtrSize)
            Numput(sz, cursorInfo, 0, "uint") ;cbSize
            DllCall("GetCursorInfo", "ptr", &cursorInfo)  ;This gets us HCURSOR and tells us if the cursor is hidden or not
            if (NumGet(cursorInfo, 4, "uint") = 1) ;if cursor is showing
            {
              ;We dont have to worry about resizing the mouse - stretchblt will do that
              VarSetCapacity(iconInfo, 8+3*A_PtrSize)
              DllCall("GetIconInfo", "ptr", NumGet(cursorInfo, 8, "ptr"), "ptr", &iconInfo)  ;This gets us the "hotspot" of the cursor, which is needed to draw it in the correct offset
              xcursor := Floor((XMouse-x_source-Numget(iconInfo, 4, "uint")))
              ycursor := Floor((YMouse-y_source-Numget(iconInfo, 8, "uint")))
              DllCall("DrawIconEx", "ptr", hDC_MEM, "int", xcursor, "int", ycursor, "ptr", NumGet(cursorInfo, 8, "ptr"), "int", 0, "int", 0, "uint", 0, "ptr", 0, "uint", 11)
            }
            
            ;Stretch memory bitmap onto window
            StretchBlt(hDC_TT, 0, 0, G_RectangleWidth, G_RectangleHeight, hDC_MEM, 0, 0, G_CaptureWidth, G_CaptureHeight)
            
            
            
           ; MouseGetPos, xmouse, ymouse
           ; DllCall("StretchBlt", "Uint", hDC_TT, "int", 0, "int", 0, "int", G_RectangleWidth, "int", G_RectangleHeight, "Uint", hDC_SC, "int", (XMouse+G_CaptureWidth+G_CaptureX>=A_ScreenWidth?A_ScreenWidth-G_CaptureWidth:(XMouse+G_CaptureX<=0?0:XMouse+G_CaptureX)), "int", (YMouse+G_CaptureHeight+G_CaptureY>=A_ScreenHeight?A_ScreenHeight-G_CaptureHeight:(YMouse+G_CaptureY<=0?0:YMouse+G_CaptureY)), "int", G_CaptureWidth, "int", G_CaptureHeight, "Uint", 0x00CC0020)
            WinSet, AlwaysOnTop, On, ahk_id %hWnd%
        }
    WinSet, AlwaysOnTop, OFF, ahk_id %hWnd%
    WinMove, ahk_id %hWnd%,, A_ScreenWidth, 1, G_RectangleWidth, G_RectangleHeight
    WinHide, ahk_id %hWnd%
return

MenuHandler:
    if (A_ThisMenuItem = "Exit")
        exitapp
    if (A_ThisMenuItem = "Reload")
        Reload
    if (A_ThisMenuItem = "Settings")
        Goto Settings
return

Settings:
    Hotkey, lAlt, MoveGFX
    Gui 2: +E0x80000 +LastFound
    Gui 2: Show, x0 y0 h%A_Screenheight% w%A_ScreenWidth%, SettingsView
    If !pToken := Gdip_Startup()
        {
            MsgBox, 48, gdiplus error!, Gdiplus failed to start.
            exitapp
        }
    hwnd1 := WinExist()
    hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_FillRectangle(G, Gdip_BrushCreateSolid("0x" "C0" "000000"), 0, 0, A_Screenwidth, A_Screenheight)
    
    CursorX := A_ScreenWidth / 2
    CursorY := A_ScreenHeight / 2
    
    Gui 3: font, cCFF0000
    Gui 3: Add, Text, x12 y2 w150 h30 BackgroundTrans, ________________________
    Gui 3: font, cDefault
    Gui 3: Add, GroupBox, x2 y3 w160 h128 , Capture
    Gui 3: Add, Text, x12 y23 w50 h30 , X offset
    Gui 3: Add, Edit, x92 y23 w60 h30 r1 gEditHandler vG_CaptureX, %G_CaptureX%
    Gui 3: Add, Text, x12 y45 w60 h20 , Y offset
    Gui 3: Add, Edit, x92 y45 w60 h30 r1 gEditHandler vG_CaptureY, %G_CaptureY%
    Gui 3: Add, Text, x12 y75 w20 h20 , W
    Gui 3: Add, Edit, x92 y75 w60 h30 r1 gEditHandler vG_CaptureWidth, %G_CaptureWidth%
    Gui 3: Add, Text, x12 y97 w20 h20 , H
    Gui 3: Add, Edit, x92 y97 w60 h30 r1 gEditHandler vG_CaptureHeight, %G_CaptureHeight%

    Gui 3: Add, text, x10 y138 w65 h30 , Magnification
    Gui 3: Add, Edit, x75 y135 w75 h30 r1 gEditHandler vG_Magnification, %G_Magnification%
    Gui 3: Add, Text, x155 y135 w20 h20 , x
    
    Gui 3: font, c0000FF
    Gui 3: Add, Text, x12 y158 w150 h30 BackgroundTrans, ________________________
    Gui 3: font, cDefault
    
    Gui 3: Add, GroupBox, x2 y160 w160 h128 , Display
    Gui 3: Add, Text, x12 y183 w50 h30 , X offset
    Gui 3: Add, Edit, x92 y183 w60 h30 r1 gEditHandler vG_OffsetX, %G_OffsetX%
    Gui 3: Add, Text, x12 y206 w60 h20 , Y offset
    Gui 3: Add, Edit, x92 y206 w60 h30 r1 gEditHandler vG_OffsetY, %G_OffsetY%
    Gui 3: Add, Text, x12 y236 w20 h20 , W
    Gui 3: Add, Edit, x92 y236 w60 h30 r1 gEditHandler vG_RectangleWidth +readonly, %G_RectangleWidth%
    Gui 3: Add, Text, x12 y259 w20 h20 , H
    Gui 3: Add, Edit, x92 y259 w60 h30 r1 gEditHandler vG_RectangleHeight +readonly, %G_RectangleHeight%

    Gui 3: Add, Button, x12 y290 w140 h30 gApply, Apply
    Gui 3: +toolwindow
    Gui 3: +AlwaysOnTop
    tidbitsFuriouslyViolentExposureToSquid := A_screenwidth - 250
    Gui 3: Show, x%tidbitsFuriouslyViolentExposureToSquid% yCenter w165, Settings
    gosub EditHandler
return

EditHandler:    
    gui 3: submit, nohide
    CaptureRatio := G_CaptureWidth / G_CaptureHeight
    G_RectangleHeight := G_CaptureHeight * G_Magnification
    G_RectangleWidth := G_RectangleHeight * CaptureRatio

    loop, parse, vars, `,
        if (A_GuiControl != A_Loopfield)
        {
                GuiControl, -g, %A_Loopfield%
                GuiControl,, %A_Loopfield%, % %A_Loopfield%
                GuiControl, +gEditHandler, %A_Loopfield%
        }
    
    gui 3: submit, nohide
    
    DrawGFX(A_ScreenWidth/2,A_ScreenHeight/2)
return
    
Apply:
    gui 3: submit, nohide
    loop, parse, vars, `,
    {
        T := %A_Loopfield%
        If T Is not Number
            {
                msgbox Error: Var %A_Loopfield% wrong type.`r`nPlease insert numbers only.
                return
            }
    }
    gui 3: submit, hide
    gui 2: submit, hide
    gui 3: Destroy
    gui 2: Destroy
    loop, parse, vars, `,
        IniWrite, % %A_Loopfield%, ZoomySettings.ini, Vars, %A_Loopfield%
    Hotkey, lAlt, off, off
    ;Resizes memory bitmap to match capture region
    hBM := CreateCompatibleBitmap(hDC_MEM, G_CaptureWidth, G_CaptureHeight)
    DeleteObject(SelectObject(hDC_MEM, hBM)) ;Return value of SelectObject is the previous object
return

GuiClose:
PersistentShow = 0
return

2GuiClose:
3GuiClose:
    ExitApp
return

MoveGFX:
While (GetKeyState("lAlt", "P"))
    {
        MouseGetPos, xmouse, ymouse
        DrawGFX(xMouse,yMouse)
    }
return

DrawGFX(CursorX, CursorY)
{
    Global
    Gdip_GraphicsClear(G, "0x" "C0" "000000")
    
    Gdip_DrawLine(G, Gdip_CreatePen("0x" "FF" "00FF00", 2), CursorX - 10, CursorY, CursorX + 10, CursorY)
    Gdip_DrawLine(G, Gdip_CreatePen("0x" "FF" "00FF00", 2), CursorX, CursorY - 10, CursorX, CursorY + 10)
    ;Gdip_DrawEllipse(G, Gdip_CreatePen("0x" "FF" "00FF00", 3), CursorX, CursorY, 5, 5)
    Gdip_DrawRoundedRectangle(G, Gdip_CreatePen("0x" "FF" "0000FF", 3), CursorX + G_OffsetX, CursorY + G_OffsetY, G_RectangleWidth, G_RectangleHeight, 5)
    Gdip_DrawRoundedRectangle(G, Gdip_CreatePen("0x" "FF" "FF0000", 3), CursorX + G_CaptureX, CursorY + G_CaptureY, G_CaptureWidth, G_CaptureHeight, 5)
        _W  := 500
        _H  := 120
        _X  := 10
        _Y  := A_screenheight - _H - 100
        Options := "x" _X " y" _Y " Centre c8fffffff r4 s20 Underline Italic" ;c3fffffff
        Gdip_FontFamilyCreate("Arial")
        Gdip_FillRoundedRectangle(G, Gdip_BrushCreateSolid(0xaa000000), _X, _Y, _W, _H, 20)
        Gdip_TextToGraphics(G, "Try selecting an edit field and scroll or click/drag`r`nYou may use ctrl to adjust the first decimal place (3.1)`r`nor shift to adjust the second (3.14) decimal`r`n`r`nHold left Alt to drag the preview around", options, "Arial", _W, _H)
    UpdateLayeredWindow(hwnd1, hdc, 0, 0, A_screenwidth, A_screenheight)
}
/*
Name: Wheel &  Drag
Version 1.0 (Thu October 10, 2013)
Created: Thu October 10, 2013
Author: tidbit
Credit: AfterLemon - detecting a bug some people may or may not get.

Description:
   * Allows you to change numeric values in edit controls by
   dragging the mouse and/or scrolling the mouse wheel.
   * Two modes for Dragging exist, up/down and left/right.
   * Please see the comments of the functions aswell as the
   demo code for more information.
   
*/

; /*
; -----------------
; --- DEMO CODE ---
; -----------------
; the only thing you need to do is add either (or both) of these 2 lines
; at the top of your script:
; OnMessage(WM_MOUSEWHEEL:=0x20A, "wheel")
; OnMessage(WM_MOUSEMOVE:=0x200, "drag")
/*
drag
   Allows you to click&hold then drag the mouse while an edit control is active
   to adjust numeric values.

   wParam - DO NOT TOUCH
   lParam - Not used, but DO NOT TOUCH

   You may use ctrl to adjust the first decimal place (3.1)
   or shift to adjust the second (3.14) decimal.

example: there is none. Just place ... OnMessage(WM_MOUSEMOVE:=0x200, "drag") ... in your code.
*/
drag(wParam, lParam)
{
   static yp,lastControl,change
   sensitivity:=7 ; In pixels, about how far should the mouse move before adjusting the value?
   amt:=1         ; How much to increase the value
   mode:=1        ; 1 = up/down, 2=left/right
   
   ; some safety checks
   if (!GetKeyState("Lbutton", "P"))      
      return
   GuiControlGet, controlType, Focus
   if (!instr(controlType, "Edit"))
      return
   GuiControlGet, value,, %A_GuiControl%
   if value is not number
      return

   if (mode=1)
      MouseGetPos,, y
   else if (mode=2)
   {
      MouseGetPos, y
      y*=-1 ; need to swap it so dragging to the right adds, not subtracts.
   }
   else
      return
     
   if (lastControl!=A_GuiControl) ; set the position to the current mouse position
      yp:=y
   change:=abs(y-yp)              ; check to see if the value is ready to be changed, has it met the sensitivity?
   
   mult:=((wParam=5) ? 0.01 : (wParam=9) ? 0.1 : 1)
   value+=((y<yp && change>=sensitivity) ? amt*mult : (y>yp && change>=sensitivity) ? -amt*mult : 0)

   GuiControl,, %A_GuiControl%, % RegExReplace(value, "(\.[1-9]+)0+$", "$1")
   
   if (change>=sensitivity)
      yp:=y
   lastControl:=A_GuiControl
}

/*
wheel
   Use MouseWheel Up and MouseWheel Down to adjust to adjust neumeric values.

   wParam - DO NOT TOUCH
   lParam - Not used, but DO NOT TOUCH

   You may use ctrl to adjust the first decimal place (3.1)
   or shift to adjust the second (3.14) decimal.

example: there is none. Just place ... OnMessage(WM_MOUSEWHEEL:=0x20A, "wheel") ... in your code.
*/
wheel(wParam, lParam)
{
   amt:=1 ; How much to increase the value
   GuiControlGet, controlType, Focus
   if (!instr(controlType, "Edit"))
      return
     
   GuiControlGet, value,, %A_GuiControl%
   if value is not number
      return
   
   mult:=((wParam & 0xffff=4) ? 0.01 : (wParam & 0xffff=8) ? 0.1 : 1)
   value+=((StrLen(wParam)>7) ? -amt*mult : amt*mult)
   GuiControl,, %A_GuiControl%, % RegExReplace(value, "(\.[1-9]+)0+$", "$1")
}