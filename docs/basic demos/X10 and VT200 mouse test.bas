Const ESC=Chr$(27)

Print
Print
Print "select mouse reporting mode"
Print "  1) X10"
Print "  2) VT200"
Print "?";
Do: M$=Inkey$: Loop Until M$="1" Or M$="2"
Print Chr$(13) M$

Print
Print "select response protocol"
Print "  1) normal"
Print "  2) URXVT"
Print "  3) SGR"
Print "?";
Do: P$=Inkey$: Loop Until P$="1" Or P$="2" Or P$="3"
Print Chr$(13) P$

Print
Print "press ctrl-Z to exit"
Print

'
' NOTES:
' =====
' X10 only reports mouse down events, and does not encode shift, control, alt
' VT200 reports mouse down and up events, plus modifier keys that are pressed
' 
' "normal" encoding always returns 6 characters: ESC [ M Cb Cx Cy
' URXVT encodes as ESC [ num ; num ; num M
' SGR encodes as ESC [ < num ; num ; num M/m   (M = mouse down, m = mouse up)
'
' general VT200 is more useful, as it lets you make use of modifier keys
' "normal" is a fixed length string, but limited to 223 x 223 screen size
' SGR is slightly more complicated to decode, but screen size is not limited
' URXVT is not favoured as it is no improvement over SGR
'

If M$="1" Then Print ESC "[?9h";         ' enable X10 mouse reporting
If M$="2" Then Print ESC "[?1000h";      ' enable VT200 mouse reporting
If P$="2" Then Print ESC "[?1015h";      ' select URXVT encoding (if available)
If P$="3" Then Print ESC "[?1006h";      ' select SGR encoding (if available)

Do
  Do: A$=Inkey$: Loop Until A$<>""
  If A$=Chr$(27) Then Print
  If Asc(A$)<32 Then Print "<" Str$(Asc(A$)) ">"; Else Print A$;
Loop Until A$=Chr$(26)

Print ESC "[?1006l";                     ' disable SGR encoding
Print ESC "[?1015l";                     ' disable URXVT encoding
Print ESC "[?1000l";                     ' disable VT200 mouse reporting
Print ESC "[?9l";                        ' disable X10 mouse reporting
Print 