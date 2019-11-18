#singleinstance, force

loop
{
	MouseGetPos, mouseX , mouseY
	activeMonitorInfo( X , Y ,  Width , Height   )
	tooltip,  %X%   %Y%   %Width%   %Height% || %mouseX% %mouseY%
	Sleep 50
}


activeMonitorInfo( ByRef X, ByRef Y, ByRef Width,  ByRef  Height  )
{ ; retrieves the size of the monitor, the mouse is on
	
	CoordMode, Mouse, Screen
	MouseGetPos, mouseX , mouseY
	SysGet, monCount, MonitorCount
	Loop %monCount%
    { 	SysGet, curMon, Monitor, %a_index%
        if ( mouseX >= curMonLeft and mouseX <= curMonRight and mouseY >= curMonTop and mouseY <= curMonBottom )
            {
				X      := curMonLeft
				y      := curMonTop
				Height := curMonBottom - curMonTop
				Width  := curMonRight  - curMonLeft
			}
    }
}
esc::exitapp