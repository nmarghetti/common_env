;Windows + ! -> to keep the current windows always on top (press again to deactivate)
#!:: Winset,AlwaysOnTop,,A

RetrieveMonitorsInfo() {
  SysGet, MonitorCount, MonitorCount
  screens := {}
  Loop, %MonitorCount% {
      SysGet, MonitorName, MonitorName, %A_Index%
      ; SysGet, Monitor, Monitor, %A_Index%
      ; Better use MonitorWorkAreaBottom to handle taskbar
      SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
      screens[A_Index] := { left: MonitorWorkAreaLeft, top: MonitorWorkAreaTop, right: MonitorWorkAreaRight, bottom: MonitorWorkAreaBottom, width: MonitorWorkAreaRight - MonitorWorkAreaLeft, height: MonitorWorkAreaBottom - MonitorWorkAreaTop }
  }
  sameScreen := []
  For index, screen in screens {
    ;MsgBox % "Monitor " index ": (" screen.left ":" screen.top ")`t" screen.width "x" screen.height
    For other_index, other_screen in screens {
      if (other_index < index){
        if (screen.width == other_screen.width && screen.height == other_screen.height) {
          ;MsgBox % "Same screen: " other_index " " index
          sameScreen.Push(other_index, index)
        }
      }
    }
  }
  multiScreen := {}
  if (sameScreen.length() > 1) {
    Loop % sameScreen.Length() {
      if (A_Index == 1) {
        x := screens[sameScreen[A_Index]].left
        y := screens[sameScreen[A_Index]].top
        width := screens[sameScreen[A_Index]].width * sameScreen.Length()
        height := screens[sameScreen[A_Index]].height
      } else {
        if (screens[sameScreen[A_Index]].left < x) {
          x := screens[sameScreen[A_Index]].left
        }
        if (screens[sameScreen[A_Index]].top < y) {
          y := screens[sameScreen[A_Index]].top
        }
      }
    }
    multiScreen := { left: x, top: y, width: width, height: height }
    ;MsgBox % "X: " x ", Y:" y ", width:" width ", height: " height
  }
  return { screens: screens, sameScreen: sameScreen, multiScreen: multiScreen }
}

;Shift + Windows + Up -> maximize a window across all displays (https://stackoverflow.com/a/9830200/470749)
+#Up::
  info := RetrieveMonitorsInfo()
  if (info.sameScreen.length() > 1) {
    WinGetActiveTitle, Title
    WinRestore, %Title%
    WinMove, %Title%,, info.multiScreen.left, info.multiScreen.top, info.multiScreen.width, info.multiScreen.height
    ;MsgBox % "X: " info.multiScreen.left ", Y:" info.multiScreen.top ", width:" info.multiScreen.width ", height: " info.multiScreen.height
  }
return

;Shift + Windows + Down -> put back a window back on one display only
+#Down::
  info := RetrieveMonitorsInfo()
  if (info.sameScreen.length() > 1) {
    WinGetActiveTitle, Title
    WinRestore, %Title%
    screen := info.screens[info.sameScreen[1]]
    WinMove, %Title%,, screen.left, screen.top, screen.width, screen.height
  }
return

;Shift + Windows + i -> gives information about your monitors
+#i::
  SysGet, MonitorCount, MonitorCount
  SysGet, MonitorPrimary, MonitorPrimary
  SysGet, Left, 76
  SysGet, Top, 77
  SysGet, Width, 78
  SysGet, Height, 79
  MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%`nVirtual screen:`n`tLeft:`t%Left%`n`tTop:`t%Top%`n`tWidth:`t%Width%`n`tHeight:`t%Height%
  Loop, %MonitorCount%
  {
      SysGet, MonitorName, MonitorName, %A_Index%
      SysGet, Monitor, Monitor, %A_Index%
      SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
      MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
  }
return
