#singleinstance, force
+Lbutton::
While GetKeyState("Lbutton","p") && GetKeyState("lShift","p")
	{
		send {LButton down}
		Delay = 0
		SetTimer, Delay, 2900
		While GetKeyState("Lbutton","p") && GetKeyState("lShift","p") && Delay = 0
			continue
		send {LButton UP}

		send {RButton down}
		Delay := 0
		SetTimer, Delay, 2300
		while GetKeyState("Lbutton","p") && GetKeyState("lShift","p") && Delay = 0
			Continue
		send {RButton Up}
	}
	
Delay:
Delay := 1
SetTimer, Delay, Off
return