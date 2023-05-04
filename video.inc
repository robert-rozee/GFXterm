////////////////////////////////////////////////////////////////////////////////
// the following routines are the text plane primatives. this plane sits
// behind the graphics plane. the following commands are provided:
// putch (x, y, character)              - puts a single character at (x,y)
// gotoxy (x, y)                        - moves cursor to (x,y)
// clear (x1, y1, x2, y2)               - clears a rectangular area
// scroll (x1, y1, x2, y2, direction)   - direction = -1 (down) or +1 (up)
// linescroll (x1, x2, y1, direction)   - direction = -1 (left) or +1 (right)
// emit (ch)                            - print (ch) at cursor, update cursor
// sprint (S)                           - print a string of characters
//
// note: emit scrolls within Tmargin and Bmargin,
// as well as respecting the setting of VTinsMode
////////////////////////////////////////////////////////////////////////////////

(*
const CP437toUTF16:array [#127..#255] of widechar=(                                                                     #$2302,
#$00c7, #$00fc, #$00e9, #$00e2, #$00e4, #$00e0, #$00e5, #$00e7, #$00ea, #$00eb, #$00e8, #$00ef, #$00ee, #$00ec, #$00c4, #$00c5,
#$00c9, #$00e6, #$00c6, #$00f4, #$00f6, #$00f2, #$00fb, #$00f9, #$00ff, #$00d6, #$00dc, #$00a2, #$00a3, #$00a5, #$20a7, #$0192,
#$00e1, #$00ed, #$00f3, #$00fa, #$00f1, #$00d1, #$00aa, #$00ba, #$00bf, #$2310, #$00ac, #$00bd, #$00bc, #$00a1, #$00ab, #$00bb,
#$2591, #$2592, #$2593, #$2502, #$2524, #$2561, #$2562, #$2556, #$2555, #$2563, #$2551, #$2557, #$255d, #$255c, #$255b, #$2510,
#$2514, #$2534, #$252c, #$251c, #$2500, #$253c, #$255e, #$255f, #$255a, #$2554, #$2569, #$2566, #$2560, #$2550, #$256c, #$2567,
#$2568, #$2564, #$2565, #$2559, #$2558, #$2552, #$2553, #$256b, #$256a, #$2518, #$250c, #$2588, #$2584, #$258c, #$2590, #$2580,
#$03b1, #$00df, #$0393, #$03c0, #$03a3, #$03c3, #$00b5, #$03c4, #$03a6, #$0398, #$03a9, #$03b4, #$221e, #$03c6, #$03b5, #$2229,
#$2261, #$00b1, #$2265, #$2264, #$2320, #$2321, #$00f7, #$2248, #$00b0, #$2219, #$00b7, #$221a, #$207f, #$00b2, #$25aa, #$00a0);
                                                                                                             // #@25a0       *)

procedure putch(X, Y:integer; ch:char);
var FGmask, BGmask:byte;
            XP, YP:integer;
             ARect:TRect;
begin
  case DimOpt of 0:begin                                               // apply dim attribute
                     if DimText then FGmask:=$0
                                else FGmask:=$8;
                     BGmask:=$0
                   end;
                 1:begin
                     FGmask:=$8;
                     BGmask:=$0
                   end
              else begin
                     FGmask:=$8;
                     if BGcolour=0 then BGmask:=$0
                                   else BGmask:=$8
                   end
  end;  { of case }

  if InvText then begin                                                // apply inverse attribute
                    SCR.Font.Color:=PAL[BGcolour or BGmask];
                    SCR.Brush.Color:=PAL[FGColour or FGmask]
                  end
             else begin
                    SCR.Font.Color:=PAL[FGcolour or FGmask];
                    SCR.Brush.Color:=PAL[BGColour or BGmask]
                  end;

  SCR.Font.Style:=TxtStyle;                                            // apply underline and bold attributes
(*
  SCR.Font.Quality:=fqDraft;                                           // doesn't seem to have any effect with: Linux + Lazarus 2.0.12 + FPC 3.2.0

  type TFontQuality = (
    fqDefault,                 // Default font quality; used when appearance is not important
    fqDraft,                   // Prefer other font features (size, style) against output quality
    fqProof,                   // Prefer output quality against other font features (size, style)
    fqNonAntialiased,          // Disable font anti-aliasing
    fqAntialiased,             // Use font anti-aliasing
    fqCleartype,               // Use Clear Type Natural font anti-aliasing when available
    fqCleartypeNatural
  );
*)

////////////////////////////////////////////////////////////////////////////////
// "improved" version using TextRect() instead of TextOut()
////////////////////////////////////////////////////////////////////////////////
  if not SKIPPRINT then
  begin
    XP:=cellW*(X-1);                                                   // doesn't matter if off screen area, as will just clip
    YP:=cellH*(Y-1);
    ARect:=Rect(XP, YP, XP+cellW, YP+cellH);

    SCR.FillRect(ARect);                                               // fill cell with background colour

    inc(XP, cellXo);                                                   // apply any X offset within cell (overflow will be clipped)
    inc(YP, cellYo);                                                   // apply any Y offset within cell (overflow will be clipped)


// the below is now just done when font parameters are changed - in Form1.Create (after loading conig file) and in Form1.MenuItem5Click
(*
    if autoXC then with SCR.TextStyle do Alignment:=taCenter           // automatic horizontal centre (overrides XP)
              else with SCR.TextStyle do Alignment:=taLeftJustify;
    if autoYC then with SCR.TextStyle do Layout:=tlCenter              // automatic vertical centre (overrides YP)
              else with SCR.TextStyle do Layout:=tlTop;
*)

// the below 3 lines are replaced by the single-line version (following) using the extended copy of CP437toUTF16 from Unit4/Form4
(*
    if ch<#127 then SCR.TextRect(ARect, XP, YP, ch)                    // #00..#126 passed through unaltered
               else SCR.TextRect(ARect, XP, YP,                        // #127..#255 need conversion to unicode
                        UTF8Encode(CP437toUTF16[ch]))                  // translate CP437 -> UTF16 -> UTF8
*)
    SCR.TextRect(ARect, XP, YP, UTF8Encode(CP437toUTF16[ch]))          // translate CP437 -> UTF16 -> UTF8
  end;

                                                                                             ///////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////// REMOVE BELOW LINES WHEN READY //
                                                                                             ///////////////////////////////////
(*
  if ch<#127 then SCR.TextOut(cellW*(X-1), cellH*(Y-1), ch)            // #00..#126 passed through unaltered
             else SCR.TextOut(cellW*(X-1), cellH*(Y-1),                // #127..#255 need conversion to unicode
                                UTF8Encode(CP437toUTF16[ch]));         // translate CP437 -> UTF16 -> UTF8
*)

(*
  if not SKIPPRINT then                                                                      // ######## win32 code, not unicode-aware ##############################
  if CSR.AutoSize then SCR.TextOut(cellW{CSR.Width}*(X-1), cellH{CSR.Height}*(Y-1), ch);     // "Terminal", monospaced so can guarantee every chr fills the rectangle
                  else begin                                                                 // manual font override, handle possibility of font not being monospaced
                         SCR.FillRect(Rect(cellW{CSR.Width}*(X-1), cellH{CSR.Height}*(Y-1),  // #####################################################################
                                           cellW{CSR.Width}*(X),   cellH{CSR.Height}*(Y)));
                         SCR.TextOut(cellW{CSR.Width}*(X-1)
                                   +(cellW{CSR.Width}-SCR.TextWidth(ch)) div 2,
                                     cellH{CSR.Height}*(Y-1), ch)
                       end;
*)
                                                                                             ///////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////// REMOVE ABOVE LINES WHEN READY //
                                                                                             ///////////////////////////////////

  if (X in [1..COLS]) and (Y in [1..ROWS]) then
  begin
    if ch in [#32..#126] then TextStore[Y, X]:=ch                      // store character in screen text grid
                         else TextStore[Y, X]:='?'                     // control and high characters -> store '?'
  end
end;


procedure gotoxy(X, Y:integer);        // -1 indicate no change
begin
  if X<>-1 then Xpos:=min(max(1, X), COLS);                            // Xpos = 1 .. ROWS
  if Y<>-1 then Ypos:=min(max(1, Y), ROWS);                            // Ypos = 1 .. COLS
  XYnew:=true                                                          // flag cursor position as moved
end;


procedure clear(X1, Y1, X2, Y2:integer);
var X, Y:integer;
begin
  if X2<X1 then begin X:=X1; X1:=X2; X2:=X end;
  if Y2<Y1 then begin Y:=Y1; Y1:=Y2; Y2:=Y end;
  X1:=min(max(1, X1), COLS);                                           // limit range to valid screen
  X2:=min(max(1, X2), COLS);
  Y1:=min(max(1, Y1), ROWS);
  Y2:=min(max(1, Y2), ROWS);

  SCR.Brush.Color:=PAL[BGColour];

//SCR.FillRect(Rect(cellW*(X1-1), cellH*(Y1-1),
//                  cellW*(X2),   cellH*(Y2)  ));                      // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  SCR.FillRect(cellW*(X1-1), cellH*(Y1-1),                             // @@@@@@@@@@@@@@@@@@@@@ Rect() type casting seems to not be needed by Lazarus @@@@@@@@@@@@@@@@@@@@@
               cellW*(X2),   cellH*(Y2)  );                            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  for Y:=Y1 to Y2 do FillChar(TextStore[Y, X1], X2-X1+1, ' ')
end;


procedure areascroll(X1, Y1, X2, Y2, direction:integer);       // direction: +1 = scroll up, -1 = scroll down
var R1, R2:TRect;
      X, Y:integer;
begin
  if X2<X1 then begin X:=X1; X1:=X2; X2:=X end;
  if Y2<Y1 then begin Y:=Y1; Y1:=Y2; Y2:=Y end;
  X1:=min(max(1, X1), COLS);                                           // limit range to valid screen
  X2:=min(max(1, X2), COLS);
  Y1:=min(max(1, Y1), ROWS);
  Y2:=min(max(1, Y2), ROWS);

  R1:=Rect(cellW*(X1-1), cellH*(Y1-1),                                 // upper rectangle
           cellW*(X2  ), cellH*(Y2-1));
  R2:=Rect(cellW*(X1-1), cellH*(Y1  ),                                 // lower rectangle
           cellW*(X2  ), cellH*(Y2  ));

  SCR.Brush.Color:=PAL[BGColour];

  case direction of +1:begin                                           // scroll screen upwards by 1 line
                         SCR.CopyRect(R1, SCR, R2);                    // destination=R1, canvas, source=R2
                         R2.Top:=R1.Bottom;
                         SCR.FillRect(R2);
                         for Y:=Y1 to Y2-1 do move(TextStore[Y+1, X1], TextStore[Y, X1], X2-X1+1);
                                                //      source,          destination,     count
                         FillChar(TextStore[Y2, X1], X2-X1+1, ' ')     // blank bottom line
                       end;
                    -1:begin;                          // scroll screen downwards by 1 line
                         SCR.CopyRect(R2, SCR, R1);    // destination=R2, canvas, source=R1
                         R1.Bottom:=R2.Top;
                         SCR.FillRect(R1);
                         for Y:=Y2 downto Y1+1 do move(TextStore[Y-1, X1], TextStore[Y, X1], X2-X1+1);
                                                    //      source,          destination,     count
                         FillChar(TextStore[Y1, X1], X2-X1+1, ' ')     // blank top line
                       end
                 else  ShowMessage(#13+pL+'invalid area scroll value (+1,-1 required)'+pR+#13)
  end  { of case }
end;


procedure linescroll(X1, X2, Y1, direction:integer);   // -1 = scroll left, +1 = scroll right
var R1, R2:TRect;
         X:integer;
begin
  if X2<X1 then begin X:=X1; X1:=X2; X2:=X end;
  X1:=min(max(1, X1), COLS);                                           // limit range to valid screen
  X2:=min(max(1, X2), COLS);
  Y1:=min(max(1, Y1), ROWS);

  R1:=Rect(cellW*(X1-1), cellH*(Y1-1),                                 // left rectangle
           cellW*(X2-1), cellH*(Y1  ));
  R2:=Rect(cellW*(X1  ), cellH*(Y1-1),                                 // right rectangle
           cellW*(X2  ), cellH*(Y1  ));

  SCR.Brush.Color:=PAL[BGColour];

  case direction of -1:begin                                           // scroll line left
                         SCR.CopyRect(R1, SCR, R2);                    // destination=R1, canvas, source=R2
                         R2.Left:=R1.Right;
                         SCR.FillRect(R2);

                         for X:=X1 to X2-1 do TextStore[Y1,X]:=TextStore[Y1,X+1];
                         TextStore[Y1,X2]:=' '                         // blank RHS character
                       end;

                    +1:begin;                                          // scroll line right
                         SCR.CopyRect(R2, SCR, R1);                    // destination=R2, canvas, source=R1
                         R1.Right:=R2.Left;
                         SCR.FillRect(R1);

                         for X:=X2 downto X1+1 do TextStore[Y1,X]:=TextStore[Y1,X-1];
                         TextStore[Y1,X1]:=' '                         // blank LHS character
                       end
                 else  ShowMessage(#13+pL+'invalid line scroll value (+1,-1 required)'+pR+#13)
  end  { of case }
end;


procedure emit(ch:char);
var lastX, lastY:integer;
       printable:boolean;
begin
  lastC:=ch;
  lastX:=Xpos;
  lastY:=Ypos;
  printable:=false;                                                    // will be set true ONLY for characters ok to be logged to text file

  if ch<#32 then case ch of #07:if BELL<16 then inc(BELL);             // max 16 queued, beeper.inc may impose a lesser limit
                            #08:if Xpos<>1 then dec(Xpos);             // backspace, non-destructive, is NOT considered printable
                            #09:begin                                  // TAB
                                  if Xpos>COLS then
                                  begin
                                    Xpos:=1;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                    inc(Ypos);                                                                                                   //
                                    if Ypos=Bmargin+1 then                         // we need to scroll area between Tmargin and Bmargin         //
                                    begin                                                                                                        //
                                      areascroll(1, Tmargin, COLS, Bmargin, +1);   // scroll area between Tmargin and Bmargin                    //
                                      Ypos:=Bmargin                                // place cursor at bottom of scroll region                    //
                                    end;                                                                                                         //
                                    if Ypos>ROWS then Ypos:=ROWS                   // cursor started out below scroll region -> NO scroll here   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                  end;
                                  repeat                               // perform tab - ALWAYS moves cursor by AT LEAST one space
                                    putch(Xpos, Ypos, ' ');
                                    inc(Xpos)                          // note: Xpos may end up off the right of the screen, this is handled elsewhere
                                  until (Xpos-1) mod 8=0;
                                  printable:=true                      // TAB is a printable character <<<<<<<<<<<<<<<<
                                end;
                    #10,#11,#12:begin                                  // linefeed, vertical tab, or formfeed
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                  inc(Ypos);                                                                                                     //
                                  if Ypos=Bmargin+1 then                           // we need to scroll the area between Tmargin and Bmargin     //
                                  begin                                                                                                          //
                                    areascroll(1, Tmargin, COLS, Bmargin, +1);     // scroll area between Tmargin and Bmargin                    //
                                    Ypos:=Bmargin                                  // place cursor at bottom of scroll region                    //
                                  end;                                                                                                           //
                                  if Ypos>ROWS then Ypos:=ROWS;                    // cursor started out below scroll region -> NO scroll here   //                                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                  if ch=#10 then printable:=true       // LF is a printable character <<<<<<<<<<<<<<<<<
                                end;
                            #13:begin                                  // carriage return
                                  Xpos:=1;
                                  printable:=true                      // CR is a printable character <<<<<<<<<<<<<<<<<
                                end;
                            #17:;                                      // DC 1
                            #18:;                                      // DC 2
                            #19:;                                      // DC 3
                            #20:;                                      // DC 4
                            #27:;                                      // escape
                 end  { of case }
            else begin
                   if Xpos>COLS then
                   begin
//                   windows.beep(880,100);                            // line overrun
                     Xpos:=1;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                     inc(Ypos);                                                                                                                  //
                     if Ypos=Bmargin+1 then                                        // we need to scroll the area between Tmargin and Bmargin     //
                     begin                                                                                                                       //
                       areascroll(1, Tmargin, COLS, Bmargin, +1);                  // scroll area between Tmargin and Bmargin                    //
                       Ypos:=Bmargin                                               // place cursor at bottom of scroll region                    //
                     end;                                                                                                                        //
                     if Ypos>ROWS then Ypos:=ROWS                                  // cursor started out below scroll region -> NO scroll here   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                   end;

                   if VTinsMode and (Xpos<COLS) then linescroll(Xpos, COLS, Ypos, +1);
                   putch(Xpos, Ypos, ch);
                   inc(Xpos);                                          // note: Xpos may end up off the right of the screen, this is handled elsewhere
                   if ch<#127 then printable:=true                     // #32 to #126 are printable characters <<<<<<<<
                 end;

  if (Xpos<>lastX) or (Ypos<>lastY) then XYnew:=true;                  // flag cursor position as having moved

  if LOGTOFILE and printable then                                      // only log if character is one of: TAB, LF, CR, #32..#126
  try
    Write(LogFile, ch);                                                // write to log file
    if ch=#13 then Flush(LogFile)                                      // flush logfile at end of each line
  except
    LOGTOFILE:=false;
    try Flush(LogFile) except end;
    try CloseFile(LogFile) except end
  end
end;


procedure sprint(S:String);                                            // used by XMODEM routines to put a progress message on screen
var I:integer;
begin
  for I:=1 to length(S) do emit(S[I])
end;


////////////////////////////////////////////////////////////////////////////////
// the following routines are the graphic plane primatives. this plane sits
// in front of the text plane. the following commands are provided:
// Gw                              - returns width of graphic area
// Gh                              - returns height of graphic area
// GFXclear ((x1, y1, x2, y2)      - erase a rectular area
// GFXlineAB (x1, y1, x2, y2)      - draw a line from (x1,y1) to (x2,y2)
// GFXarc (x1, y1, x2, y2, A1, A2) - draw arc within a rectangle, from
//                                   A1 to A2 degrees; 0 = 12 o'clock
// GFXplot (x, y)                  - plot a single pixel
// GFXink (R, G, B, width)         - set ink colour and pen width
// GFXfill (x, y)                  - fill an area we have just enclosed
// GFXmoveto (x, y)                - set starting location
// GFXdrawto (x, y)                - draw from previous location to (x,y)
// GFXscroll(x1, y1, x2, y2,
//           deltaX, deltaY)       - scroll a graphics area
////////////////////////////////////////////////////////////////////////////////

function Gw:integer;
begin
  result:=cellW*COLS                                                   // = Form1.Image2.Picture.Bitmap.Width
end;


function Gh:integer;
begin
  result:=cellH*ROWS                                                   // = Form1.Image2.Picture.Bitmap.Height
end;


procedure GFXclear(X1, Y1, X2, Y2:integer);
begin
  if X1<X2 then inc(X2)                                                // +1 as fillrect normally excludes RHS edge
           else inc(X1);
  if Y1<Y2 then inc(Y2)                                                // +1 as fillrect normally excludes bottom edge
           else inc(Y1);
  GFX.Brush.Color:=clBlack;

//GFX.FillRect(Rect(X1, Y1, X2, Y2))                                   // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  GFX.FillRect(X1, Y1, X2, Y2)                                         // @@@@@@@@@@@@@@@@@@@@@ Rect() type casting seems to not be needed by Lazarus @@@@@@@@@@@@@@@@@@@@@
end;                                                                   // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


procedure GFXlineAB(X1, Y1, X2, Y2:integer);
begin
  GFX.MoveTo(X1, Y1);
  GFX.LineTo(X2, Y2)                                                   // draw line, excluding the last point
//GFX.LineTo(X2, Y2)                                                   // fill in last point not needed as GFX.Pen.EndCap=pecRound by default
end;


procedure GFXarc(X1, Y1, X2, Y2:integer; A1, A2:single);
var X0, Y0, X3, Y3, X4, Y4:integer;
begin
  A1:=(A1*pi/180.0)-(pi/2.0);                                          // convert A1 to radians, shift origin ccw 1/4 turn
  A2:=(A2*pi/180.0)-(pi/2.0);                                          // convert A2 to radians, shift origin ccw 1/4 turn

  X0:=(X1 + X2) div 2;                                                 // locate centre of elipse: X0
  Y0:=(Y1 + Y2) div 2;                                                 // locate centre of elipse: Y0

  X3:=X0 + trunc(1000.0*Cos(A2));
  Y3:=Y0 + trunc(1000.0*Sin(A2));
  X4:=X0 + trunc(1000.0*Cos(A1));
  Y4:=Y0 + trunc(1000.0*Sin(A1));

  GFX.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4)
end;


procedure GFXplot(X, Y:integer);
begin
  GFX.Pixels[X, Y]:=GFX.Pen.Color
end;


procedure GFXink(R, G, B, width:integer);
begin
  R:=min(max(0, R), 255);
  G:=min(max(0, G), 255);
  B:=min(max(0, B), 255);
  GFX.Pen.Color:=(B*$10000) + (G*$100) + R;
  GFX.Pen.Width:=width
end;


procedure GFXfill(X, Y:integer);
begin
  GFX.Brush.Color:=GFX.Pen.Color;                                      // select pen colour as fill
  GFX.FloodFill(X, Y, GFX.Pen.Color, fsBorder);                        // fill everything enclosed by pen colour
  GFX.Brush.Color:=clBlack                                             // go back to a black brush
(*
  GFX.Brush.Color:=clBlack;                                            // select black fill colour
  GFX.FloodFill(X, Y, GFX.Pen.Color, fsBorder);                        // fill area bounded by pen colour
  GFX.Brush.Color:=GFX.Pen.Color;                                      // select pen colour as fill
  GFX.FloodFill(X, Y, clBlack, fsSurface);                             // fill everything we previously set to black
  GFX.Brush.Color:=clBlack                                             // go back to a black brush
*)
end;


procedure GFXmoveto(X, Y:integer);
begin
  GFX.MoveTo(X, Y)                                                     // set starting point of a multi-line
end;


procedure GFXdrawto(X, Y:integer);
begin
  GFX.LineTo(X, Y)                                                     // draw line to (x,y)
end;                                                                   // fill in last point not needed as GFX.Pen.EndCap=pecRound by default

(*
procedure GFXscroll_OLD(X1, Y1, X2, Y2, deltaX, deltaY:integer);
var R1, R2, Fh, Fv:TRect;
begin
  if (deltaX=0) and (deltaY=0) then exit;                              // nothing to do!

// R1 is the source rectangle, R2 is the destingation rectangle
  if deltaX<0 then begin                                               // moving *** left ***
                     R1.Left:=X1-deltaX;                               // - source left side
                     R1.Right:=X2;                                     // - source right side
                     R2.Left:=X1;                                      // - destination left side
                     R2.Right:=X2+deltaX;                              // - destination right side

                     Fv.Left:=R2.Right+1;
                     Fv.Right:=X2+1                                    // +1 as fillrect skips right side
                   end
              else begin                                               // moving *** right ***
                     R1.Left:=X1;                                      // - source left side
                     R1.Right:=X2-deltaX;                              // - source right side
                     R2.Left:=X1+deltaX;                               // - destination left side
                     R2.Right:=X2;                                     // - destination right side

                     Fv.Left:=X1;
                     Fv.Right:=R2.Left                                 // fillrect skips right side
                   end;
  Fv.Top:=Y1;
  Fv.Bottom:=Y2+1;                                                     // +1 as fillrect skips bottom edge

  if deltaY<0 then begin                                               // moving *** up ***
                     R1.Top:=Y1-deltaY;                                // - source top side
                     R1.Bottom:=Y2;                                    // - source bottom side
                     R2.Top:=Y1;                                       // - destination top side
                     R2.Bottom:=Y2+deltaY;                             // - destination bottom side

                     Fh.Top:=R2.Bottom+1;
                     Fh.Bottom:=Y2+1                                   // +1 as fillrect skips bottom edge
                   end
              else begin                                               // moving *** down  ***
                     R1.Top:=Y1;                                       // - source top side
                     R1.Bottom:=Y2-deltaY;                             // - source bottom side
                     R2.Top:=Y1+deltaY;                                // - destination top side
                     R2.Bottom:=Y2;                                    // - destination bottom side

                     Fh.Top:=Y1;
                     Fh.Bottom:=R2.Top                                 // fillrect skips bottom edge
                   end;
  Fh.Left:=X1;
  Fh.Right:=Y2+1;                                                      // +1 as fillrect skips right side

  GFX.CopyRect(R2, GFX, R1);                                           // destination=R2, canvas, source=R1

  GFX.Brush.Color:=clBlack;
  if deltaX<>0 then GFX.FillRect(Fv);
  if deltaY<>0 then GFX.FillRect(Fh)
end;
*)

////////////////////////////////////////////////////////////////////////////////
// assumes CopyRect and FillRect both skip right column and bottom row        //
////////////////////////////////////////////////////////////////////////////////

procedure GFXscroll(X1, Y1, X2, Y2, deltaX, deltaY:integer);
var R1, R2, Fh, Fv:TRect;
begin
  if (deltaX=0) and (deltaY=0) then exit;                              // nothing to do!

  if X1<X2 then inc(X2)                                                // +1 as copy/fillrect normally excludes RHS edge
           else inc(X1);
  if Y1<Y2 then inc(Y2)                                                // +1 as copy/fillrect normally excludes bottom edge
           else inc(Y1);

// R1 is the source rectangle, R2 is the destingation rectangle
  if deltaX<0 then begin                                               // moving *** left ***
                     R1.Left:=X1-deltaX;                               // - source left side
                     R1.Right:=X2;                                     // - source right side
                     R2.Left:=X1;                                      // - destination left side
                     R2.Right:=X2+deltaX;                              // - destination right side

                     Fv.Left:=R2.Right;
                     Fv.Right:=X2                                      // set up vertical strip to clear
                   end
              else begin                                               // moving *** right ***
                     R1.Left:=X1;                                      // - source left side
                     R1.Right:=X2-deltaX;                              // - source right side
                     R2.Left:=X1+deltaX;                               // - destination left side
                     R2.Right:=X2;                                     // - destination right side

                     Fv.Left:=X1;
                     Fv.Right:=R2.Left                                 // set up vertical strip to clear
                   end;
  Fv.Top:=Y1;
  Fv.Bottom:=Y2;                                                       // set up vertical strip to clear

  if deltaY<0 then begin                                               // moving *** up ***
                     R1.Top:=Y1-deltaY;                                // - source top side
                     R1.Bottom:=Y2;                                    // - source bottom side
                     R2.Top:=Y1;                                       // - destination top side
                     R2.Bottom:=Y2+deltaY;                             // - destination bottom side

                     Fh.Top:=R2.Bottom;                                // set up horizontal strip to clear
                     Fh.Bottom:=Y2
                   end
              else begin                                               // moving *** down  ***
                     R1.Top:=Y1;                                       // - source top side
                     R1.Bottom:=Y2-deltaY;                             // - source bottom side
                     R2.Top:=Y1+deltaY;                                // - destination top side
                     R2.Bottom:=Y2;                                    // - destination bottom side

                     Fh.Top:=Y1;                                       // set up horizontal strip to clear
                     Fh.Bottom:=R2.Top
                   end;
  Fh.Left:=X1;
  Fh.Right:=Y2;                                                        // set up horizontal strip to clear

  GFX.CopyRect(R2, GFX, R1);                                           // destination=R2, canvas, source=R1

  GFX.Brush.Color:=clBlack;
  if deltaX<>0 then GFX.FillRect(Fv);                                  // if needsbe blank vertical strip
  if deltaY<>0 then GFX.FillRect(Fh)                                   // if needsbe blank horizontal strip
end;


