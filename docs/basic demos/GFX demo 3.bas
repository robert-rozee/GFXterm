For I=32 To 255
  If (I Mod 32)=0 Then Print Chr$(13) Chr$(10),
  If I=127 Then Print " "; Else Print Chr$(I);
Next I
Print
Print
Print
Pause 1000


Const GFX=Chr$(16)
Const ENQ=Chr$(5)
Const ACK=Chr$(6)

Print GFX "?"
Input Gw, Gh

Print GFX "clear" 0, 0, Gw, Gh
Print GFX "ink" 255, 255, 0, 7

angle=0
Y0=Int(Gh/2)
T0%=Timer

phase=1
R=&hFF
G=0
B=0

Do
  angle=(angle+2) Mod 360
  value=Sin(angle*Pi/180)
  Y1=Int(Gh/2-value*Gh/3)

  If phase=1 Then
    If G<255 Then G=G+3 Else phase=2
  ElseIf phase=2 Then
    If R>0   Then R=R-3 Else phase=3
  ElseIf phase=3 Then
    If B<255 Then B=B+3 Else phase=4
  ElseIf phase=4 Then
    If G>0   Then G=G-3 Else phase=5
  ElseIf phase=5 Then
    If R<255 Then R=R+3 Else phase=6
  Else
    If B>0   Then B=B-3 Else phase=1
  EndIf

  R=Min(Max(0, R), 255)
  G=Min(Max(0, G), 255)
  B=Min(Max(0, B), 255)

  Print GFX "ink" R, G , B, 7
  CV%=(((Int(R) << 8) Or Int(G)) << 8) Or Int(B)       ' ok
' CV%=(((Int(R) << 8) + Int(G)) << 8) + Int(B)         ' ok
' CV%=(((Int(R)*256)+Int(G))*256)+Int(B)               ' ok
' CV%=(((R*256)+G)*256)+B                              ' fails

  Print GFX "scroll" 0, 0, Gw-1, Gh-1, -1, 0

  Print GFX "line" Gw-10, Y0, Gw-9, Y1
  Y0=Y1

  T1%=Timer
  Print , angle, Y1, Str$(value, -3, 3),, T1%-T0% "ms",, Hex$(CV%, 6)
  T0%=T1%

  Do :Loop Until (Inkey$=ACK) Or (Timer-T1%>500)
  Print ENQ;

' Do
' Loop Until (Timer Mod 200)>180
Loop
