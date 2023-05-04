Const GFX=Chr$(16)

Print GFX "?"
Input Gw, Gh

Print GFX "C" 0, 0, Gw, Gh

X1=Gw\2-50
Y1=Gh\2-50
X2=Gw\2+50
Y2=Gh\2+50

Print GFX "ink" 255, 255, 0, 5
Print GFX "arc" X1+5, Y1+5, X2-5, Y2-5, 0, 0

Print GFX "ink" 255, 0, 0, 2
Print GFX "arc" Gw\2-30, Gh\2-20, Gw\2-10, Gh\2-10, 0, 0
Print GFX "arc" Gw\2+10, Gh\2-20, Gw\2+30, Gh\2-10, 0, 0
Print GFX "fill" Gw\2-20, Gh\2-15
Print GFX "fill" Gw\2+20, Gh\2-15


Print GFX "ink" 0, 255, 0, 5
Print GFX "moveto" Gw\2, Gh\2-5
Print GFX "drawto" Gw\2+5, Gh\2+8
Print GFX "drawto" Gw\2, Gh\2+8

Print GFX "ink" 0, 0, 255, 5
Print GFX "arc" Gw\2-25, Gh\2, Gw\2+25, Gh\2+30, 100, 260

dX=-1
dY=-1

Do
  Print GFX "S" X1, Y1, X2, Y2, dX, dY
  Print, X1, Y1, X2, Y2, dX, dY
  X1=X1+dX
  Y1=Y1+dY
  X2=X2+dX
  Y2=Y2+dY

  If X1=0 Then dX=-dX
  If Y1=0 Then dY=-dY
  If X2=Gw-1 Then dX=-dX
  If Y2=Gh-1 Then dY=-dY

  Pause 10
Loop