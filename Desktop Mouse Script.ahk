InstallKeybdHook
InstallMouseHook
#include Lib\TapHoldManager.ahk


#MaxThreadsBuffer 													;Necessary to capture all scrollwheel inputs properly
A_MaxHotkeysPerInterval := 200    									;Should prevent the popup when scrolling a lot, increase when necessary

GroupAdd "Excluded", "ahk_exe League of Legends.exe"
GroupAdd "Excluded", "ahk_exe FSD-Win64-Shipping.exe"
GroupAdd "Excluded", "ahk_exe Gunfire Reborn.exe"
GroupAdd "Excluded", "ahk_exe BPMGame-Win64-Shipping.exe"
GroupAdd "Excluded", "ahk_exe Deathloop.exe"
GroupAdd "Excluded", "ahk_exe helldivers2.exe"

thm := TapHoldManager(100,200,,"$*","ahk_group Excluded")


thm.Add("XButton2", XB2Func)
thm.Add("XButton1", XB1Func)
thm.ADD("RButton", RButtonFunc)


global customCombinator := 0
global customFired := true

XB1Func(isHold, taps, state){
	global
	if (state == 2) {													;XB1 Down
		if(customCombinator == 0){
			customFired := false
			customCombinator := 1
		} else if (customCombinator == 3){								;RButton + XB1 DOWN => Ctrl + z
			Send "^z"
			ComboBreaker(0)
		} else {
			customCombinator := customCombinator . "1"
		}
	} else if (state == -1 OR state == 0) { 							;XB1 up Tap or Hold
		if(customCombinator == 1){										;XB1 by itself => F11 (fullscreen)
			FireControl()
			Send "{f11}"
			Terminator()
		} else if (customCombinator == 3){								;RButton + XB1 DOWN => Ctrl + z so XB1 up is blocked 
			Exit										
		} else {
			Terminator()
		}
	} else if (state == 1) {											;Hold activated

	}

	FireControl(){														;ends execution and resets customCombinator if a custom combination was used
		if(customFired){
			customCombinator := 0
			Exit
		}
	}

	Terminator(){														;ends execution and resets customCombinator. For terminating chords that involve only a single key (i.e. RButton doubleclick, tripleclick, single+longpress, etc)
		customCombinator := 0
		Exit
	}


	;ComboBreaker ends execution, sets customFired to true, and removes this buttons additions to customCombinator. pClicks is the ammount of clicks of this button before triggering an action
	;Example: Doubleclicking and holding XB1 sets customCombinator to '11'. Tapping RButton once sets it to '113' and fires the '113' tap function. 
	;After the tap function, ComboBreaker(1) is called and the last digit of customCombinator is removed, resetting it to '11', which lets you fire more inputs on the '11' layer
	;until letting go of XB1 and resetting customCombinator due to the customFired flag.
	
	ComboBreaker(pClicks){												
		customFired :=true												
		if(pClicks>0){
			customCombinator :=	SubStr(customCombinator, 1 , "-" pClicks)	
		}																
		Exit															
	}
	
}

XB2Func(isHold, taps, state){
	global
	if (state == 2) {													;XB2 Down
		if(customCombinator == 0){
			customFired := false
			customCombinator := 2
		} else if (customCombinator == 3){								;RButton + XB2 DOWN => Backspace
			Send "{Blind}{BackSpace}"
			ComboBreaker(0)
		} else {
			customCombinator := customCombinator . "2"
		}
	} else if (state == -1 OR state == 0) { 							;XB2 up Tap or Hold
		if(customCombinator == 2){										;XB2 by itself => #Meta
			FireControl()
			Send "{LWin}"
			Terminator()
		}	else if (customCombinator == 22) {							;XB2 doubleclick => #Tab
			FireControl()
			Send "#{Tab}"
			Terminator()
		} else if (customCombinator == 23){								;XButton2 + RButton => Paste (in case XButton2 is release before triggering the RButton tab)
			FireControl()
			Send "^v"
			Terminator()
		} else if (customCombinator == 3){								;RButton + XB2 DOWN => Backspace so XB up is blocked 
			Exit										
		} else {
			Terminator()
		}
	} else if (state == 1) {											;Hold activated

	}

	FireControl(){														;ends execution and resets customCombinator if a custom combination was used
		if(customFired){
			Send "{Alt up}"
			customCombinator := 0
			Exit
		}
	}

	Terminator(){														;ends execution and resets customCombinator. For terminating chords that involve only a single key (i.e. RButton doubleclick, tripleclick, single+longpress, etc)
		customCombinator := 0
		Exit
	}


	;ComboBreaker ends execution, sets customFired to true, and removes this buttons additions to customCombinator. pClicks is the ammount of clicks of this button before triggering an action
	;Example: Doubleclicking and holding XB1 sets customCombinator to '11'. Tapping RButton once sets it to '113' and fires the '113' tap function. 
	;After the tap function, ComboBreaker(1) is called and the last digit of customCombinator is removed, resetting it to '11', which lets you fire more inputs on the '11' layer
	;until letting go of XB1 and resetting customCombinator due to the customFired flag.
	
	ComboBreaker(pClicks){												
		customFired :=true												
		if(pClicks>0){
			customCombinator :=	SubStr(customCombinator, 1 , "-" pClicks)	
		}																
		Exit															
	}
}

RButtonFunc(isHold, taps, state){
	global
	if (state == 2) {													;RbuttonDown
		if(customCombinator == 0){
			customFired := false
			customCombinator := 3
		} else {
			customCombinator := customCombinator . "3"
		}
	} else if (state == -1 OR state == 0) { 							;RButton up Tap or Hold
		if(customCombinator == 3){										;RButton by itself sends blind+RButton or resets customCombinator if a customCombination was used while RButton was held down
			FireControl()
			Send "{Blind}{RButton}"
			Terminator()
		} else if(customCombinator == 23){								;XButton2 + RButton => Paste
			FireControl()
			Send "^v"
			ComboBreaker(1)
		} else if (customCombinator == 223){
			FireControl()
			ToolTip("Clipboard: " . A_Clipboard)
		  SetTimer(RemoveTooltip, -1000) 
		  ComboBreaker(1)
		} else if (customCombinator == 13){								;XButton1 + RButton => Reopen last closed tab
			Send "+^t"
		} else {
			Terminator()
		}
	} else if (state == 1) {											;Hold activated

	}

	FireControl(){														;ends execution and resets customCombinator if a custom combination was used
		if(customFired){
			customCombinator := 0
			Exit
		}
	}

	Terminator(){														;ends execution and resets customCombinator. For terminating chords that involve only a single key (i.e. RButton doubleclick, tripleclick, single+longpress, etc)
		customCombinator := 0
		Exit
	}



	;ComboBreaker ends execution, sets customFired to true, and removes this buttons additions to customCombinator. pClicks is the ammount of clicks of this button before triggering an action
	;Example: Doubleclicking and holding XB1 sets customCombinator to '11'. Tapping RButton once sets it to '113' and fires the '113' tap function. 
	;After the tap function, ComboBreaker(1) is called and the last digit of customCombinator is removed, resetting it to '11', which lets you fire more inputs on the '11' layer
	;until letting go of XB1 and resetting customCombinator due to the customFired flag.
	
	ComboBreaker(pClicks){												
		customFired :=true												
		if(pClicks>0){
			customCombinator :=	SubStr(customCombinator, 1 , "-" pClicks)	
		}																
		Exit															
	}
}



RemoveTooltip(){
  ToolTip
}

	




#SuspendExempt  ; Exempt the following hotkey from Suspend.

Suspension(){
	if(A_IsSuspended){
		reload
	}else {
		Suspend 
	} 
}  


F20::{			;I bound f20 to my DPI switch button. This lets me quickly toggle/reload the script
	global
	switch customCombinator
	{
		case 0:	Suspension()                   		;Default behavior
		case 1: Send "{f11}"                        ;Back + DPI Button. Full screen
		case 2: Send "#{Tab}"                      ;Forward + DPI Button switches tabs
		case 3: MsgBox "RButton+F20"              ;RButton + DPI Button message
		default: Send "{f20}"
	}
	if(customCombinator > 0){
		customFired := true
	}
}

#d:: Suspension

#SuspendExempt False 




;customCombinator replaces Autohotkeys build in Custom Combinations and removes most of their limitations while maintaining speedy execution. 
;This one variable can handle multi button combinations (keys > 2), multi click combinations (multiclick of the modifier before activating the combo), and makes it easy to handle modified custom combinations (i.e. ctrl + cc)
;0000
;^^^^
;|||Amount of XButton1 presses
;||Amount of XButton2 presses
;|Amount of LButton presses
;I might add more modifiers once I get a mouse with extra buttons unless I need more than 18 different custom modifiers I'm golden (max int is 9223372036854775807)   





#HotIf !(WinActive("ahk_group Excluded")) ;Excluded programs


$*WheelDown::{
	global
	if (customCombinator == 0) {   		; Default behavior
		Send "{Blind}{WheelDown}" 
	} else if (customCombinator == 2) {  ; Holding down the forward button and scrolling switches between windows. Very handy
		Send "{Alt down}{Tab}" 
	} else if (customCombinator == 22) {  ; Double click forward + wheel switches between desktops
		Send "^#{right}" 
	} else if (customCombinator == 23) {  ; forward + RButton + wheel changes volume
		Send "{Volume_Down}" 
	} else if (customCombinator == 1) {  ; Back + Scrolling switches between tabs
		Send "^{Tab}" 
	} else if (customCombinator == 3) {  ; RightClick + Scrolling goes left and right
		Send "{Blind}{Right}" 
	} else if (customCombinator == 33) {  ; RightClick + Scrolling sends up and down
		Send "{Blind}{Down}" 
	} else {
		ToolTip("Invalid Combination")
		SetTimer(RemoveTooltip, -1000) 
	}

	if(customCombinator > 0){
		customFired := true
	}
}

$*WheelUp::{
	global
	if (customCombinator == 0) {   		; Default behavior
		Send "{Blind}{WheelUp}" 
	} else if (customCombinator == 2) {  ; Holding down the forward button and scrolling switches between windows. Very handy
		Send "{Alt down}+{Tab}"
	} else if (customCombinator == 22) {  ; Double click forward + wheel switches between desktops
		Send "^#{left}" 
	} else if (customCombinator == 23) {  ; forward + RButton + wheel changes volume
		Send "{Volume_Up}" 
	} else if (customCombinator == 1) {  ; Back + Scrolling switches between tabs
		Send "^+{Tab}" 
	} else if (customCombinator == 3) {  ; RightClick + Scrolling goes left and right
		Send "{Blind}{Left}" 
	} else if (customCombinator == 33) {  ; RightClick + Scrolling sends up and down
		Send "{Blind}{Up}" 
	} else {
		ToolTip("Invalid Combination")
		SetTimer(RemoveTooltip, -1000) 
	}

	if(customCombinator > 0){
		customFired := true
	}
}


#HotIf !(WinActive("ahk_group Excluded")  or WinActive("ahk_class MultitaskingViewFrame")) ;excluding MultitaskingViewFrame enables clicking on windows after opening the altTab screen with the hotkeys above



$*LButton::{
	global
	if (customCombinator == 0) {   		; Default behavior
		Send "{Blind}{LButton Down}" 
	} else if (customCombinator == 1) {  ;Back + LeftClick closes Tabs
		Send "^w"
	} else if (customCombinator == 2) {  ; ;Forward + LeftClick copies
		Send "^c" 
	} else if (customCombinator == 3) {  ; RButton + LButton => Send "{Enter}" 
		Send "{Enter}" 
	} else if (customCombinator == 22) {  ; Double XButton2 + LButton 
		ToolTip("Double XButton1 + LButton")
		SetTimer(RemoveTooltip, -1000) 
	} else {
		ToolTip("Invalid Combination")
		SetTimer(RemoveTooltip, -1000) 
	}

	if(customCombinator > 0){
		customFired := true
	}
}

$*LButton Up::{
	global
	if (GetKeyState("LButton")){
		Send "{Blind}{LButton Up}"
	}
}

$*MButton::{
	global
	switch customCombinator
	{
		case 0: Send "{Blind}{MButton Down}"                     ;Default behavior
		case 1: Send "{f5}"                           ;Back + MiddleMouseButton refreshes pages
		case 2: Send "!{Escape}"                        ;Forward + MiddleMouseButton minimizes current window
		case 3: MsgBox "MButton+RButton"            ;MiddleMouseButton + RightClick message
		default: Send "{MButton}"
	}
	if(customCombinator > 0){
		customFired := true
	}
}

$*MButton Up::{
	global
	if(GetKeyState("MButton")){
		Send "{Blind}{MButton Up}"
	}
}




 

/* Deprecated for now TODO
RButton & XButton1:: Send "^z"

Rbutton & XButton2:: Send "{BackSpace}"

XButton2 & Xbutton1:: Send "#{Tab}" ; Forward + Back (Some mice seem to handle this weirdly)

XButton1 & XButton2:: MsgBox "XButton1+XButton2" ;Back + Forward

*/



#HotIf







/*
n::{
	if(KeyWait("n","T0.2")){
			if(KeyWait("n", "D T0.2"))
			{
				KeyWait("n")
				MsgBox "double"
			}	else {
				MsgBox "short"
			}
		} else {
			KeyWait("n")
			MsgBox "n longpress"
		}
}

a::{
	if(KeyWait("a","T0.2")){
			MsgBox "a shortpress"
		} else {
			KeyWait("a")
			MsgBox "a longpress"
		}
}
*/

^!v:: {
    
    ; Loop through each character in the clipboard content
    Loop Parse,  A_Clipboard
    {
        ; Send the current character as a keystroke
        Send A_LoopField
        
        ; Wait for 20 milliseconds before sending the next keystroke
        Sleep 20
    }
}
^!c::{
	ToolTip(A_Clipboard)
	SetTimer(RemoveTooltip, -1000) 
}