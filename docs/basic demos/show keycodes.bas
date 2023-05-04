Do
  I=Timer
  Do
    a$=Inkey$
  Loop Until a$<>""

  If Timer-I>100 Then Print

  key=Asc(a$)

  If key=13 Then
    Print "<cr>";
  ElseIf key=10 Then
    Print "<lf>";
  ElseIf key=27 Then
    Print "<esc>";
  ElseIf (key<32) Or (key>126) Then
    Print "<0x" Hex$(key,2) ">";
  Else
    Print a$;
  EndIf
Loop

