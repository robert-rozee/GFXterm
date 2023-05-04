Print ca(0)
clrscr

' ---------------- page 1 ----------------

Print at(20,1) ca(0,40,37) "VT/ANSI colour test"
Print at(1,3) ca(0) "normal",,"dim",,"reverse",,"reverse+dim"
Print at(1,13) ca(0) "normal",,"dim",,"reverse",,"reverse+dim"

Print ca(0)
FGchart(1,4)

Print ca(0,2)
FGchart(17,4)

Print ca(0,7)
FGchart(33,4)

Print ca(0,2,7)
FGchart(49,4)


Print ca(0)
BGchart(1,14)

Print ca(0,2)
BGchart(17,14)

Print ca(0,7)
BGchart(33,14)

Print ca(0,2,7)
BGchart(49,14)

Print ca(0) at(1,23);
Do :Loop While Inkey$<>""
Do :Loop Until Inkey$<>""
clrscr



' ---------------- page 2 ----------------

Print at(1,1) ca(0) "Default text on Default background"
Print
Print ca(0,30,40) "30 40 - Black text on Black background  " ca(0)
Print ca(0,31,40) "31 40 - Red text on Black backgrond     " ca(0)
Print ca(0,32,40) "31 40 - Green text on Black background  " ca(0)
Print ca(0,34,40) "34 40 - Blue text on Black background   " ca(0)
Print ca(0,37,40) "37 40 - White text on Black background  " ca(0)
Print ca(0,39,40) "39 40 - Default text on Black background" ca(0)
Print ca(0)

Print ca(0,30,42) "30 42 - Black text on Green background  " ca(0)
Print ca(0,31,42) "31 42 - Red text on Green backgrond     " ca(0)
Print ca(0,32,42) "31 42 - Green text on Green background  " ca(0)
Print ca(0,34,42) "34 42 - Blue text on Green background   " ca(0)
Print ca(0,37,42) "37 42 - White text on Green background  " ca(0)
Print ca(0,39,42) "39 42 - Default text on Green background" ca(0)
Print ca(0)

Print ca(0,30,47) "30 47 - Black text on White background  " ca(0)
Print ca(0,31,47) "31 47 - Red text on White backgrond     " ca(0)
Print ca(0,32,47) "31 47 - Green text on White background  " ca(0)
Print ca(0,34,47) "34 47 - Blue text on White background   " ca(0)
Print ca(0,37,47) "37 47 - White text on White background  " ca(0)
Print ca(0,39,47) "39 47 - Default text on White background" ca(0)

Print ca(0);
Do :Loop While Inkey$<>""
Do :Loop Until Inkey$<>""
clrscr



' ---------------- page 3 ----------------

Print ca(0) at(1,3) "normal intensity text:"
For C=40 To 47
For B=30 To 37
  Print at((B-23)*4, C-37) ca(0, B, C) "abcd"
Next B: Next C

Print ca(0) at(1, 14) "dim intensity text:"
For C=40 To 47
For B=30 To 37
  Print at((B-23)*4, C-26) ca(0, 2, B, C) "abcd"
Next B: Next C

Print ca(0) at(1,23);
Do :Loop While Inkey$<>""
Do :Loop Until Inkey$<>""
clrscr



' ---------------- page 4 ----------------

Print ca(0) at(1,3) "normal+inverted text:"
For C=40 To 47
For B=30 To 37
  Print at((B-23)*4, C-37) ca(0, 7, B, C) "abcd"
Next B: Next C

Print ca(0) at(1, 14) "dim+inverted text:"
For C=40 To 47
For B=30 To 37
  Print at((B-23)*4, C-26) ca(0, 2, 7, B, C) "abcd"
Next B: Next C

Print ca(0) at(1,23);
Do : Loop While Inkey$<>""
Do : Loop Until Inkey$<>""
clrscr



' ---------------- page 5 ----------------

Print at(11,3) ca(0) "Character Set (0x20 to 0xFF)"
For Y=1 To 7
For X=0 To 31
  I=(Y*32)+X
  Print at(X+9, Y+5) Chr$(I);
Next X: Next Y

Print at(1,15) ca(0) " normal  ",
Print ca(1) "bold text" ca(0), ca(2) " dimmed  " ca(0),
Print ca(4) "underline" ca(0), ca(7) "inverted" ca(0)

Print at(1,16) ca(0) " normal  ",
Print ca(1) "bold text" ca(0), ca(2) " dimmed  " ca(0),
Print ca(4) "underline" ca(0), ca(7) "inverted" ca(0)

Print at(1,17) ca(0) " normal  ",
Print ca(1) "bold text" ca(0), ca(2) " dimmed  " ca(0),
Print ca(4) "underline" ca(0), ca(7) "inverted" ca(0)

Print at(1,20) "Press any key to finish";
Do :Loop While Inkey$<>""
Do :Loop Until Inkey$<>""

Pause (100)
Do : Loop While Inkey$<>""
Print
Print
End



' ------------ subroutines ------------

Sub FGchart(x,y)
Print at(x,y+0) ca(30) "30 - Black  "
Print at(x,y+1) ca(31) "31 - Red    "
Print at(x,y+2) ca(32) "32 - Green  "
Print at(x,y+3) ca(33) "33 - Yellow "
Print at(x,y+4) ca(34) "34 - Blue   "
Print at(x,y+5) ca(35) "35 - Magenta"
Print at(x,y+6) ca(36) "36 - Cyan   "
Print at(x,y+7) ca(37) "37 - White  "
End Sub


Sub BGchart(x,y)
Print at(x,y+0) ca(40) "40 - Black  "
Print at(x,y+1) ca(41) "41 - Red    "
Print at(x,y+2) ca(42) "42 - Green  "
Print at(x,y+3) ca(43) "43 - Yellow "
Print at(x,y+4) ca(44) "44 - Blue   "
Print at(x,y+5) ca(45) "45 - Magenta"
Print at(x,y+6) ca(46) "46 - Cyan   "
Print at(x,y+7) ca(47) "47 - White  "
End Sub


Function at(x,y) As string
  at=Chr$(27)+"["+Str$(y)+";"+Str$(x)+"H"
End Function


Function ca(A, B, C, D, E) As string
  Local temp$
  temp$=Chr$(27)+"["+Str$(A)
  If B<>0 Then temp$=temp$+";"+Str$(B)
  If C<>0 Then temp$=temp$+";"+Str$(C)
  If D<>0 Then temp$=temp$+";"+Str$(D)
  If E<>0 Then temp$=temp$+";"+Str$(E)
  ca=temp$+"m"
End Function


Sub clrscr
  Print Chr$(27)+"[2J";
End Sub
