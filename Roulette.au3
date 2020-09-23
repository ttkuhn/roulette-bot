#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Roulette.ico
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         

 Script Function:
  v1.0
  Proof of concept.
  Not responsible for any damages or losses of any kind.

  v1.0.1
  Added test function + hotkeys.

  v1.1.0
  + Added 1366x768 resolution compatibility => getResolution() function.
  + Improved window-safety in click-functions by adding WinActivate(...).
    - reversed this (by commenting) because it noticably slows down the program!
  + Made some Global variables Local, because Global vars are evil:
    - Global $double  = 0   ; current number of raises
    - Global $turn    = 0   ; current number of turns
    - Global $clicks  = 1   ; number of clicks (see bet() function below)
  + Moved $win, $double assignments from main() to play() and passed ByRef.
  + Refactored $maxDouble to $MAXDOUBLE and $maxTurn to $MAXTURNS.
  + Added testSearch() function, specific image search for testing purposes.
  + Added togglePause() function and hotkey to pause the script at any time.
    - IT'S POSSIBLE TO MISS WIN-CHECK, SO DISABLED FOR NOW!

  v1.1.1
  + Removed Global $win = False ; False = default, True = win round (is declared Local)

#ce ----------------------------------------------------------------------------

#include <ImageSearch.au3>

Global $color     = False ; False = RED, True = BLACK
Global $MAXDOUBLE = 8     ; max number of raises
Global $MAXTURNS  = 2     ; max turns on same color
Global $lowRes    = False
Global $highRes   = False

Global $xR = 0
Global $yR = 0
Global $xB = 0
Global $yB = 0

Global $paused

; Press Escape on keyboard to end the script at any time.
; Press Space on keyboard to pause the script at any time.
HotKeySet("{Esc}", "exitScript")
;HotKeySet("{Space}", "togglePause")
; Hotkeys for testing
HotKeySet("t", "test")
HotKeySet("s", "testSearch")

; Start script
main()

; Endless loop
; Only active in correct window
; Reset nr. of raises before playing (because of a win or max nr. of raises was reached)
; Reset win to false
Func main()
  getResolution()
  Local $turn = 0
  While 1
    play($turn)
  WEnd
EndFunc

Func getResolution()
  Local $iDesktopWidth = @DesktopWidth, $iDesktopHeight = @DesktopHeight
  If $iDesktopWidth = 1366 And $iDesktopHeight = 768 Then
    $lowRes = True
  ElseIf $iDesktopWidth = 1920 And $iDesktopHeight = 1080 Then
    $highRes = True
  Else
    MsgBox(48, "ATTENTION", "Incompatible resolution. Currently supported resolutions: 1366x768, 1920x1080. Program will now exit.", 10)
    exitScript()
  EndIf
EndFunc

; Play and raise each turn until win = True or max nr. of raises is reached
Func play(ByRef $turn)
  Local $win = False
  Local $double = 0
  While Not $win And $double <> $MAXDOUBLE
    If $turn == $MAXTURNS Then
      If $color Then
        $color = False
        $turn = 0
      Else
        $color = True
        $turn = 0
      EndIf
    EndIf
    bet($double, $turn)
    checkForImage($win)
    $double += 1
  WEnd
EndFunc

; Clear table before each bet
; Bet amount -> nr. of mouse clicks -> depends on nr. of raises
; Switch betting color every 2 turns
Func bet($double, ByRef $turn)
  WinWaitActive("Roulette - Google Chrome","")
  Local $clicks = 2 ^ $double
  clearBet()
  If $color Then
    betBlack($clicks)
  Else
    betRed($clicks)
  EndIf
  quickSpin()
  $turn += 1
EndFunc

; NEXT FOUR FUNCTIONS:
; Game button locations (x,y)
; HAVE TO BE MODIFIED ACCORDING TO SCREEN SIZE AND RESOLUTION
; Tools > AU3Recorder or Alt + F6
; FIRST TWO FUNCTIONS:
; $c := number of clicks passed by bet()
Func betBlack($clicks)
  If $lowRes Then
    ;WinActivate("Roulette")
    MouseClick("left",560,520,$clicks)
  ElseIf $highRes Then
    WinActivate("Roulette")
    MouseClick("left",880,731,$clicks)
  EndIf
EndFunc

Func betRed($clicks)
  If $lowRes Then
    ;WinActivate("Roulette")
    MouseClick("left",500,485,$clicks)
  ElseIf $highRes Then
    WinActivate("Roulette")
    MouseClick("left",782,677,$clicks)
  EndIf
EndFunc

Func quickSpin()
  If $lowRes Then
    ;WinActivate("Roulette")
    MouseClick("left",470,650,1)
  ElseIf $highRes Then
    WinActivate("Roulette")
    MouseClick("left",728,936,1)
  EndIf
EndFunc

Func clearBet()
  If $lowRes Then
    ;WinActivate("Roulette")
    MouseClick("left",630,650,1)
  ElseIf $highRes Then
    WinActivate("Roulette")
    MouseClick("left",981,935,1)
  EndIf
EndFunc

; The ball rolls for approx. 1 sec. (sleep for 1.5 to be safe)
; Search page for win indication (find picture on screen)
; Displays message if won -> auto closes after 1 sec.
; Returns focus to game screen
Func checkForImage(ByRef $win)
  Sleep(1500)
  WinActivate("Roulette")
  If $lowRes Then
    Local $searchR = _ImageSearch('You_won_RED_768.png', 0, $xR, $yR, 10)
    Local $searchB = _ImageSearch('You_won_BLACK_768.png', 0, $xB, $yB, 10)
  ElseIf $highRes Then
    Local $searchR = _ImageSearch('You_won_RED.png', 0, $xR, $yR, 10)
    Local $searchB = _ImageSearch('You_won_BLACK.png', 0, $xB, $yB, 10)
  EndIf
  If $searchR = 1 Or $searchB = 1 Then
    $win = True
    MsgBox(0, "WINNER", "You won!", 1)
    WinActivate("Roulette")
  EndIf
EndFunc

#cs ----------------------------------------------------------------------------
#ce ----------------------------------------------------------------------------

Func togglePause()
    $paused = NOT $paused
    While $paused
        sleep(100)
        ToolTip('Script is PAUSED',0,0)
    WEnd
    ToolTip("")
EndFunc

Func test()
  MsgBox(64, "Test Mode", "Press s to perform image search at any time.", 1)
  While 1
    Sleep(200)
  WEnd
EndFunc

Func testSearch()
    Local $searchRlow = _ImageSearch('You_won_RED_768.png', 0, $xR, $yR, 10)
    Local $searchBlow = _ImageSearch('You_won_BLACK_768.png', 0, $xB, $yB, 10)
    Local $searchRhigh = _ImageSearch('You_won_RED.png', 0, $xR, $yR, 10)
    Local $searchBhigh = _ImageSearch('You_won_BLACK.png', 0, $xB, $yB, 10)
  If $searchRlow = 1 Or $searchBlow = 1 Or $searchBhigh = 1 Or $searchBhigh = 1 Then
    $win = True
    MsgBox(0, "WINNER", "You won!", 1)
  Else
    MsgBox(48, "404", "NO IMAGE FOUND", 1)
  EndIf
EndFunc

Func exitScript()
  Exit
EndFunc