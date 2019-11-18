;When anything is edited - it calls EditHandler
;The result of this is that the UI gets refreshed but so does cursor position
;any way round the cursor position reset?
#singleinstance force
ProgramName := "Zoomy"
Version := "V2"

CaptureX		:= -70
CaptureY		:= -30
CaptureWidth	:= 150
CaptureHeight	:= 100

RectangleWidth	:= 800
RectangleHeight	:= 200
OffsetX			:= 0
OffsetY			:= 50

MagCapture		:= 1
MagDisplay		:= 0
DisplayAspect	:= 1
CaptureAspect	:= 0
MagCheck		:= 1

Gui 3: font, cCFF0000
Gui 3: Add, Text, x12 y2 w150 h30 BackgroundTrans, ________________________
Gui 3: font, cDefault
Gui 3: Add, GroupBox, x2 y3 w160 h128 , Capture
Gui 3: Add, Text, x12 y23 w50 h30 , X offset
Gui 3: Add, Edit, x92 y23 w60 h30 r1 gEditHandler vG_CaptureX, %CaptureX%
Gui 3: Add, Text, x12 y45 w60 h20 , Y offset
Gui 3: Add, Edit, x92 y45 w60 h30 r1 gEditHandler vG_CaptureY, %CaptureY%
Gui 3: Add, Text, x12 y75 w20 h20 , W
Gui 3: Add, Edit, x92 y75 w60 h30 r1 gEditHandler vG_CaptureWidth, %CaptureWidth%
Gui 3: Add, Text, x12 y97 w20 h20 , H
Gui 3: Add, Edit, x92 y97 w60 h30 r1 gEditHandler vG_CaptureHeight, %CaptureHeight%


Gui 3: Add, Radio, x17 y88 w78 h10 Checked%CaptureAspect% gEditHandler vCaptureAspect, Lock Aspect
Gui 3: Add, Radio, x17 y299 w78 h10 Checked%DisplayAspect% gEditHandler vDisplayAspect, Lock Aspect

Gui 3: Add, Checkbox, x10 y158 w85 h30 Checked%MagCheck% gEditHandler vMagCheck, Magnification
Gui 3: Add, Edit, x95 y165 w30 h30 r1 gEditHandler vG_Magnification,
Gui 3: Add, Text, x130 y165 w20 h20 , x

Gui 3: Add, Radio, x50 y135 w100 h30 Checked%MagCapture% gEditHandler vMagCapture, Lock Capture
Gui 3: Add, Radio, x50 y180 w100 h30 Checked%MagDisplay% gEditHandler vMagDisplay, Lock Display

Gui 3: font, c0000FF
Gui 3: Add, Text, x12 y208 w150 h30 BackgroundTrans, ________________________
Gui 3: font, cDefault
Gui 3: Add, GroupBox, x2 y210 w160 h128 , Display
Gui 3: Add, Text, x12 y233 w50 h30 , X offset
Gui 3: Add, Edit, x92 y233 w60 h30 r1 gEditHandler vG_OffsetX, %OffsetX%
Gui 3: Add, Text, x12 y256 w60 h20 , Y offset
Gui 3: Add, Edit, x92 y256 w60 h30 r1 gEditHandler vG_OffsetY, %OffsetY%
Gui 3: Add, Text, x12 y286 w20 h20 , W
Gui 3: Add, Edit, x92 y286 w60 h30 r1 gEditHandler vG_RectangleWidth, %RectangleWidth%
Gui 3: Add, Text, x12 y309 w20 h20 , H
Gui 3: Add, Edit, x92 y309 w60 h30 r1 gEditHandler vG_RectangleHeight, %RectangleHeight%

Gui 3: Add, Button, x12 y340 w65 h30 gUpdate +default, Update
Gui 3: Add, Button, x90 y340 w65 h30 gSave, Save
Gui 3: Add, Button, x12 y370 w143 h30 gClose, Close
Gui 3: +toolwindow
Gui 3: +AlwaysOnTop
tidbitsFuriouslyViolentExposureToSquid := A_screenwidth - 250
Gui 3: Show, x%tidbitsFuriouslyViolentExposureToSquid% yCenter, Settings

EditHandler:
	;Work out ratios
	
	;CaptureRatio
	
	;G_CaptureX
	;G_CaptureY
	;G_CaptureWidth
	;G_CaptureHeight
	
	;MagCapture
	;MagCheck	;G_Magnification
	;MagDisplay
	
	;DisplayRatio
	
	;G_OffsetX
	;G_OffsetY
	;G_RectangleWidth
	;G_RectangleHeight
	
	;do fancy math based on radios
	gui, submit, nohide
	if (A_GuiControl = CaptureRatio) OR (A_GuiControl = DisplayRatio) 
		{
			CaptureRatio := G_CaptureWidth / G_CaptureHeight
			DisplayRatio := G_RectangleWidth / G_RectangleHeight
		}
	if (CaptureAspect = 1)
		{
			if (A_GuiControl = G_CaptureWidth)
				G_CaptureHeight := G_CaptureWidth * G_CaptureRatio
			if (A_GuiControl = G_CaptureHeight)
				G_CaptureWidth := G_CaptureHeight * G_CaptureRatio
		}
	if (DisplayAspect = 1)
		{
		}
	if (MagCheck = 1)
		{
			GuiControl, Enable, MagCapture
			GuiControl, Enable, MagDisplay
			GuiControl, Enable, G_Magnification
			if (MagCapture = 1)
				{
					GuiControl, Enable, G_CaptureX
					GuiControl, Enable, G_CaptureY
					GuiControl, Enable, G_CaptureWidth
					GuiControl, Enable, G_CaptureHeight	
					GuiControl, Enable, G_OffsetX
					GuiControl, Enable, G_OffsetY
					GuiControl, Disable, G_RectangleWidth
					GuiControl, Disable, G_RectangleHeight
				}
			if (MagDisplay = 1)
				{
					GuiControl, Enable, G_CaptureX
					GuiControl, Enable, G_CaptureY
					GuiControl, Disable, G_CaptureWidth
					GuiControl, Disable, G_CaptureHeight	
					GuiControl, Enable, G_OffsetX
					GuiControl, Enable, G_OffsetY
					GuiControl, Enable, G_RectangleWidth
					GuiControl, Enable, G_RectangleHeight
				}
		}
	else
		{
			GuiControl, Enable, G_CaptureX
			GuiControl, Enable, G_CaptureY
			GuiControl, Enable, G_CaptureWidth
			GuiControl, Enable, G_CaptureHeight
			GuiControl, Disable, MagCapture
			GuiControl, Disable, MagDisplay
			GuiControl, Disable, G_Magnification
			GuiControl, Enable, G_OffsetX
			GuiControl, Enable, G_OffsetY
			GuiControl, Enable, G_RectangleWidth
			GuiControl, Enable, G_RectangleHeight
		}
		
	GuiControl,, G_CaptureX, %G_CaptureX%
	GuiControl,, G_CaptureY, %G_CaptureY%
	GuiControl,, G_CaptureWidth, %G_CaptureWidth%
	GuiControl,, G_CaptureHeight, %G_CaptureHeight%
	GuiControl,, MagCapture, %MagCapture%
	GuiControl,, MagCheck, %MagCheck%
	GuiControl,, MagDisplay, %MagDisplay%
	GuiControl,, G_OffsetX, %G_OffsetX%
	GuiControl,, G_OffsetY, %G_OffsetY%
	GuiControl,, G_RectangleWidth, %G_RectangleWidth%
	GuiControl,, G_RectangleHeight, %G_RectangleHeight%
	
	gui 3: submit, nohide
return

Update:
Close:
SavE:
exitapp






















/*
Gui 3: Add, GroupBox, x2 y3 w200 h128 , Capture
Gui 3: Add, Text, x12 y23 w50 h30 , X offset
Gui 3: Add, Edit, x92 y23 w100 h30 r1,
Gui 3: Add, Text, x12 y45 w60 h20 , Y offset
Gui 3: Add, Edit, x92 y45 w100 h30 r1,
Gui 3: Add, Text, x12 y75 w20 h20 , W
Gui 3: Add, Edit, x92 y75 w100 h30 r1,
Gui 3: Add, Radio, x17 y88 w78 h10 , Lock Aspect
Gui 3: Add, Text, x12 y97 w20 h20 , H
Gui 3: Add, Edit, x92 y97 w100 h30 r1,

Gui 3: Add, Radio, x112 y135 w100 h30 , Lock Capture

Gui 3: Add, Text, x12 y165 w80 h80 , Status
Gui 3: Add, Text, x72 y165 w100 h30 , Magnification
Gui 3: Add, Edit, x142 y165 w50 h30 r1,
Gui 3: Add, Text, x192 y165 w20 h20 , x

Gui 3: Add, Radio, x112 y180 w100 h30 , Lock Display

Gui 3: Add, GroupBox, x2 y210 w200 h128 , Display
Gui 3: Add, Text, x12 y233 w50 h30 , X offset
Gui 3: Add, Edit, x92 y233 w100 h30 r1,
Gui 3: Add, Text, x12 y256 w60 h20 , Y offset
Gui 3: Add, Edit, x92 y256 w100 h30 r1,
Gui 3: Add, Text, x12 y286 w20 h20 , W
Gui 3: Add, Edit, x92 y286 w100 h30 r1,
Gui 3: Add, Radio, x17 y299 w78 h10 , Lock Aspect
Gui 3: Add, Text, x12 y309 w20 h20 , H
Gui 3: Add, Edit, x92 y309 w100 h30 r1,

Gui 3: Add, Button, x12 y340 w90 h30 , Update
Gui 3: Add, Button, x112 y340 w90 h30 , Save
Gui 3: Add, Button, x12 y370 w190 h30 , Close
Gui 3: +toolwindow
Gui 3: Show,, Settings
Return

GuiClose:
ExitApp
