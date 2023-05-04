////////////////////////////////////////////////////////////////////////////////
// the following is a VT100 command processing engine. it takes characters one
// at a time via the parameter 'ch'. normally these are simply passed out
// unaltered as a one character long return string to then be passed onto
// emit(ch).
//
// however, when a VT100 command sequence is detected characters are accumulated
// in the internal string 'VTline'. once matched to a valid VT100 command, the
// command is enacted. while if the string accumulated is detected as invalid,
// the whole string is returned.
////////////////////////////////////////////////////////////////////////////////

function VT100engine(ch:char):str255;
const VTflag:boolean=false;         // internally held flag
      VTline:str255='';             // internally held string
       Xsave:integer=-1;            //  )
       Ysave:integer=-1;            //  )
      FGsave:integer=-1;            //  ) saved values for
      BGsave:integer=-1;            //  ) cursor location
      TSsave:TFontStyles=[];        //  ) and attributes
      DTsave:boolean=false;         //  )
      ITsave:boolean=false;         //  )
var n, v, h, I, J:integer;
             S, T:str255;

  function PC(S:str255):integer;       // returns count of semicolon delimited parameters
  var I, dc, sc:integer;               // or -1 if any invalid characters are found
  begin
    if length(S)=0 then PC:=0 else     // empty string -> no parameters
    begin
      dc:=0;                           // number of digits
      sc:=0;                           // number of semicolon delimiters
      for I:=1 to length(S) do
      begin
        if S[I] in ['0'..'9'] then inc(dc);
        if S[I]=';' then inc(sc);
      end;
      if (dc+sc)<>length(S) then PC:=-1        // invalid characters found
                            else PC:=sc+1      // number of parameters in S
    end
  end;      // ( 1;2 = 2 parameters, 1;;2 = 3 parameters, ;;; = 4 parameters

  function Pn(S:str255; n:integer):integer;    // returns parameter n as an integer
  var I:integer;
  begin
    while (n>1) and (length(S)<>0) do
    begin
      if pos(';', S)=1 then dec(n);
      delete(S, 1, 1)
    end;
    if (length(S)=0) or (S[1]=';') then Pn:=0 else
    begin
      I:=pos(';', S);
      if I<>0 then S:=copy(S, 1, I-1);
      if length(S)=0 then Pn:=0
                     else try
                            Pn:=StrToInt(S)
                          except
                            Pn:=0              // should never arrive here
                          end
    end
  end;

  function OK(S:str255; var n:integer):boolean;        // returns true if a valid number
  begin                                                // (with number placed in n)
    OK:=true;
    n:=0;
    try
      if length(S)<>0 then n:=StrToInt(S)
    except
      OK:=false
    end
  end;

  procedure fail;              // failed to decode string
  begin
    if DEBUGMODE=2 then
    begin
    {$IFDEF WINDOWS}
      WriteMapBuffer(chr($80 + 15+64));                                // set WHITE text on a RED background
      WriteMapBuffer('FAIL: <ESC>'+copy(VTline,2,length(VTline)-1));
      WriteMapBuffer(chr($80 + 15) + #13#10)
    {$ELSE}
      WriteLn(#27+'[41m', 'FAIL: <ESC>', copy(VTline,2,length(VTline)-1), #27+'[0m')
    {$ENDIF}
    end;

    result:=VTline;            // return complete string
    VTline:='';
    VTflag:=false              // drop out of VT100 mode
  end;

  procedure pass;              // sucessfully processed string
  begin
    if DEBUGMODE=2 then
    begin
    {$IFDEF WINDOWS}
      WriteMapBuffer(chr($80 + 15));                                   // set WHITE text on a BLACK background
      WriteMapBuffer('PASS: <ESC>'+copy(VTline,2,length(VTline)-1) + #13#10)
    {$ELSE}
      WriteLn('PASS: <ESC>', copy(VTline,2,length(VTline)-1))
    {$ENDIF}
    end;

    VTline:='';
    VTflag:=false;             // drop out of VT100 mode
    TS3:=GetTickCount64
  end;

// main function VT100engine begins ********************************************
begin
  n:=0;                                        // supresses a compiler warning later on
  if ch=#27 then VTflag:=true;
  if not VTflag then result:=ch else
  begin
    result:='';
    VTline:=VTline{%H-}+ch;
    if length(VTline)=1 then exit;

    if length(VTline)>250 then fail            // way too long an escape sequence!
    else
    if pos(#27+'[', VTline)=1 then             // try to process a complete <esc>[ string
    begin
      if length(VTline)=2 then exit;           // still building command string
      if ch in ['0'..'9',';','?'] then exit;   // still building command string

      S:=copy(VTline, 3, length(VTline)-3);    // extract parameter segment

      case ch of 'A':begin                     // move cursor up n lines
                       if not OK(S, n) then fail else
                       begin
//                       ShowMessage('UP '+IntToStr(n));
                         if n=0 then n:=1;
                         if Ypos<Tmargin then gotoxy(-1, Ypos-n)
                                         else gotoxy(-1, max(Ypos-n, Tmargin));
                         pass
                       end
                     end;

                 'B':begin                     // move cursor down n lines
                       if not OK(S, n) then fail else
                       begin
//                       ShowMessage('DOWN '+IntToStr(n));
                         if n=0 then n:=1;
                         if Ypos>Bmargin then gotoxy(-1, Ypos+n)
                                         else gotoxy(-1, min(Ypos+n, Bmargin));
                         pass
                       end
                     end;

                 'C':begin                     // move cursor right n columns
                       if not OK(S, n) then fail else
                       begin
//                       ShowMessage('RIGHT '+IntToStr(n));
                         if n=0 then n:=1;
                         gotoxy(Xpos+n, -1);
                         pass
                       end
                     end;

                 'D':begin                     // move cursor left n columns
                       if not OK(S, n) then fail else
                       begin
//                       ShowMessage('LEFT '+IntToStr(n));
                         if n=0 then n:=1;
                         gotoxy(Xpos-n, -1);
                         pass
                       end
                     end;

             'H','f':begin                     // position cursor (ignores Tmargin and Bmargin)
                       n:=PC(S);
//                     ShowMessage('position cursor |'+S+'|'+VTline+'| '+IntToStr(n));
                       case n of 0:begin
                                     gotoxy(1, 1);
//                                   ShowMessage('top left');
                                     pass
                                   end;
                                 1:begin
                                     v:=Pn(S,1);
                                     if v=0 then v:=1;
                                     gotoxy(1, v);
                                     pass
                                   end;
                                 2:begin
                                     v:=Pn(S,1);
                                     h:=Pn(S,2);
                                     if v=0 then v:=1;
                                     if h=0 then h:=1;
                                     gotoxy(h, v);
//                                   ShowMessage('row = '+IntToStr(v)+'  col = '+IntToStr(h));
                                     pass
                                   end
                              else fail
                       end  { of case }
                     end;

                 'J':if not OK(S, n) then fail else    // clear screen above/below cursor
                     case n of 0:begin                 // clear cursor to end of screen
                                   clear(Xpos, Ypos, COLS, Ypos);
                                   if Ypos<ROWS then clear(1, Ypos+1, COLS, ROWS);
                                   pass
                                 end;
                               1:begin                 // clear start of screen to cursor
                                   if Ypos>1 then clear(1, 1, COLS, Ypos-1);
                                   clear(1, Ypos, Xpos, Ypos);
                                   pass
                                 end;
                               2:begin                 // clear whole screen
                                   clear(1, 1, COLS, ROWS);
//                                 gotoxy(1, 1);       // ANSI std *may* specify home cursor
                                   pass                // VT100 manual says cursor DOES NOT MOVE
                                 end
                            else fail
                     end;  { of case }

                 'K':if not OK(S, n) then fail else    // clear line to left/right of cursor
                     case n of 0:begin                 // clear cursor to EOL
                                   clear(Xpos, Ypos, COLS, Ypos);
                                   pass
                                 end;
                               1:begin                 // clear SOL to cursor
                                   clear(1, Ypos, Xpos, Ypos);
                                   pass
                                 end;
                               2:begin                 // clear whole line
                                   clear(1, Ypos, COLS, Ypos);
                                   pass
                                 end
                                else fail
                     end;  { of case }

// ######## VT102 edit commands (start)

                 'P':if not OK(S, n) then fail else    // delete character under cursor
                     begin
                       if n=0 then n:=1;
                       for I:=1 to n do linescroll(Xpos, COLS, Ypos, -1);
                       pass
                     end;

                 'M':if not OK(S, n) then fail else    // delete line and scroll screen up
                     if Ypos in [Tmargin..Bmargin] then
                     begin
                       if n=0 then n:=1;
                       for I:=1 to n do areascroll(1, Ypos, COLS, Bmargin, +1);
                       pass
                     end;

                 'L':if not OK(S, n) then fail else    // insert line and scroll screen down
                     if Ypos in [Tmargin..Bmargin] then
                     begin
                       if n=0 then n:=1;
                       for I:=1 to n do areascroll(1, Ypos, COLS, Bmargin, -1);
                       pass
                     end;

                 'X':if not OK(S, n) then fail else    // erase from cursor position to the right (VT200 mode only)
                     begin
                       if n=0 then n:=1;
                       clear(Xpos, YPos, Xpos+n-1, Ypos);
                       pass
                     end;

                 '@':if not OK(S, n) then fail else    // insert n blanks under cursor (VT200 mode only)
                     begin
                       if n=0 then n:=1;
                       for I:=1 to n do linescroll(Xpos, COLS, Ypos, +1);
                       pass
                     end;

// ######## VT102 edit commands (end)

                 'm':begin                             // set up character colours and attributes
                       if length(S)=0 then S:='0';
                       n:=PC(S);
//                     ShowMessage(IntToStr(n)+'  |'+S+'|');
                       if n=-1 then fail else
                       begin
                         for I:=1 to n do
                         begin
                           J:= Pn(S,I);
                           case J of 0:begin
//                                       ShowMessage('reset colours and attributes');
                                         DimText:=false;
                                         InvText:=false;
                                         TxtStyle:=[];
                                         FGcolour:=FGdefault;
                                         BGcolour:=BGdefault
                                       end;
                                     1:TxtStyle:= TxtStyle+[fsBold];       // bold
                                     2:DimText:=true;                      // dim FGcolour
                                     4:TxtStyle:=TxtStyle+[fsUnderline];   // underline
                                     5:begin end;                          // (not supported)
                                     7:InvText:=true;                      // reverse video
                                30..37:FGcolour:=J-30;
                                    39:FGcolour:=FGdefault;
                                40..47:BGcolour:=J-40;
                                    49:BGcolour:=BGdefault
                           end  { of case }
                         end;
                         pass
                       end
                     end;

                 'n':if not OK(S, n) then fail else
                     if n<>6 then fail else
                     begin                             // return cursor row and column
//                     ShowMessage('cursor position requested');
                       T:=#27+'['+IntToStr(Ypos)+';'+IntToStr(Xpos)+'R';
                       if PasteBuffer.index=0 then case CONNECTED of 2:QueueSerialWrite(T);
                                                                     4:;  // WriteSocket(T)                            // #################### MISSING ####################
                                                   end;  { of case }
                       pass
                     end;

                 'r':begin                             // set up scrolling region
                       n:=PC(S);
//                     ShowMessage('set scroll window |'+S+'|'+VTline+'| '+IntToStr(n));
                       case n of 0:begin
                                     Tmargin:=1;
                                     Bmargin:=ROWS;
                                     gotoxy(1, 1);     // VT100 manual specifies home cursor
                                     pass
                                   end;
                                 2:begin
                                     I:=max(Pn(S,1), 1);
                                     J:=min(Pn(S,2), ROWS);
                                     if (I<J)then begin
                                                    Tmargin:=I;
                                                    Bmargin:=J
                                                  end;
                                     gotoxy(1, 1);     // VT100 manual specifies home cursor
                                     pass
                                   end
                              else fail
                       end  { of case }
                     end;

                 'h':begin                                         // enable feature
                       if S='4'     then VTinsMode:=true else      // select insert mode
                       if S='?9'    then MouseMode:=MouseMode and $FF00 or $0001 else  // X10 flag
                       if S='?1000' then MouseMode:=MouseMode and $FF00 or $0010 else  // VT200 flag
                       if S='?1006' then MouseMode:=MouseMode and $00FF or $0100 else  // SGR flag
                       if S='?1015' then MouseMode:=MouseMode and $00FF or $1000 else  // URXVT flag
                       if S='?25'   then CursorVis:=true else fail;    // show text cursor
                       if VTflag then pass
                     end;

                 'l':begin                                         // disable feature
                       if S='4'     then VTinsMode:=false else     // select replacement mode
                       if S='?9'    then MouseMode:=MouseMode and $FFF0 else   // X10 flag
                       if S='?1000' then MouseMode:=MouseMode and $FF0F else   // VT200 flag
                       if S='?1006' then MouseMode:=MouseMode and $F0FF else   // SGR flag
                       if S='?1015' then MouseMode:=MouseMode and $0FFF else   // URXVT flag
                       if S='?25'   then CursorVis:=false else fail;   // hide text cursor
                       if VTflag then pass
                     end
              else   fail
      end  { of case}
    end
    else

    if pos(#27, VTline)=1 then                 // process a complete <esc> string
    begin
      if length(VTline)=1 then exit;           // still building command string
      if ch='[' then exit;                     // still building command string

//    S:=copy(VTline, 2, length(VTline)-2);    // extract parameter segment

      case ch of '7':begin                     // save cursor position and attributes
                       Xsave:=Xpos;
                       Ysave:=Ypos;
                       FGsave:=FGcolour;
                       BGsave:=BGcolour;
                       TSsave:=TxtStyle;
                       DTsave:=DimText;
                       ITsave:=InvText;
                       pass
                     end;

                 '8':begin                     // restore cursor position and attributes
                       if (Xsave>0) and (Ysave>0) then
                       begin
                         gotoxy(Xsave,Ysave);
                         FGcolour:=FGsave;
                         BGcolour:=BGsave;
                         TxtStyle:=TSsave;
                         DimText:=DTsave;
                         InvText:=ITsave;
                         Xsave:=-1;
                         Ysave:=-1
                       end;
                       pass
                     end;

                 'E':begin                     // same as ESC D (below) followed by CR
                       if Ypos<Bmargin then gotoxy(1,Ypos+1)
                                       else begin
                                              areascroll(1, Tmargin, COLS, Bmargin, +1);
                                              gotoxy(1,-1)
                                            end;
                       pass
                     end;

                 'D':begin                     // scroll region up if cursor is at bottom of window
                       if Ypos<Bmargin then gotoxy(-1,Ypos+1)
                                       else areascroll(1, Tmargin, COLS, Bmargin, +1);
                       pass
                     end;

                 'M':begin                     // scroll region down if cursor is at top of window
                       if Ypos>Tmargin then gotoxy(-1,Ypos-1)
                                       else areascroll(1, Tmargin, COLS, Bmargin, -1);
                       pass
                     end
              else   fail
      end  { of case }
    end else fail
  end
end;


////////////////////////////////////////////////////////////////////////////////
// the following is a GFX command processing engine. it takes characters one
// at a time via the parameter 'ch'. normally these are simply passed out
// unaltered as a one character long return string to then be passed onto
// emit(ch).
//
// however, when a GFX command sequence is detected characters are accumulated
// in the internal string 'GFXline'. once matched to a valid GFX command, the
// command is enacted. while if the string accumulated is detected as invalid,
// the whole string is returned.
////////////////////////////////////////////////////////////////////////////////

function GFXengine(inputCH:char):str255;
const GFXflag:boolean=false;        // internally held flag
      GFXline:str255='';            // internally held string
       skipLF:boolean=false;        // set true if GFXline holds <#16><some_string><CR> -> we should skip any following <LF>
var params:array[1..16] of integer;
    CMD, S, T, PSn:str255;
           I, J, n:integer;

  procedure fail;                                                      // failed to decode string
  var S:string;
  begin
    if DEBUGMODE=2 then                                                // at the very lease, must start with <DLE>
    begin
      if RightStr(GFXline, 1)=#13 then S:=copy(GFXline,2,length(GFXline)-2)    // ends in <CR>, chop off the <CR>
                                  else S:=copy(GFXline,2,length(GFXline)-1);   // ends in something else
    {$IFDEF WINDOWS}
      WriteMapBuffer(chr($80 + 15+64));                                // set WHITE text on a RED background
      WriteMapBuffer('FAIL: <DLE>'+S);
      WriteMapBuffer(chr($80 + 15) + #13#10)
    {$ELSE}
      WriteLn(#27+'[41m', 'FAIL: <DLE>', S, #27+'[0m')
    {$ENDIF}
    end;

    result:=GFXline;                                                   // return entire accumulated string
    GFXline:='';                                                       // clear accumulated string
    GFXflag:=false;                                                    // drop out of GFX mode
    if inputCH=#13 then skipLF:=true                                   // signal to discard trailing <LF> (if there is one) on next iteration
  end;

// main function GFXengine begins **********************************************
begin
  if skipLF then                                                       // have just processed a GFX line that ended in <CR>, now check for trailing <LF>
  begin
    skipLF:=false;                                                     // clear flag
    if inputCH=#10 then begin
                          result:='';                                  // <LF> -> return nothing and exit (back to caller)
                          exit
                        end                                            // <CR> followed by NOT <LF>, carry on and process character
  end;

  if inputCH=#16 then GFXflag:=true;                                   // ** enter GFX mode **

  if not GFXflag then result:=inputCH else                             // not in GFX mode -> just return the character passed in
  begin
    result:='';                                                        // ** GATHER and process GFX line **
    GFXline:=GFXline+inputCH;

    if length(GFXline)>250 then begin                                  // error: way too long a GFX sequence!
                                  fail;
                                  exit
                                end;

    if (GFXline[1]=#16) and (GFXline[length(GFXline)]=#13) then        // ** <DLE> ... <CR> -> valid 'head' and 'tail' for a GFX line
    begin                                                              // process a complete <dle> string
//  format is:  <DLE> Command [,|<TAB>|<SPC>]  Param1 [,|<TAB><SPC>]  Param2... <CR><LF>    (<LF> is optional, discarded on next time through)

      S:=GFXline;

// the below FOR and WHILE loops perform the following:
// - convert every control character, space, comma and semicolon into a TAB (this includes the <DLE> 'head' and <CR> 'tail')
// - convert all groups of consecutive TABs into a single TAB
// - remove any leading TABs from beginning
// - remove any trailing TABs from the end
      for I:=1 to length(S) do if S[I] in [#00..#32,',',';'] then S[I]:=#09;

      I:=pos(#09#09, S);
      while I<>0 do                                                    // convert pairs of TABs into single TABs
      begin
        delete(S, I, 1);
        I:=pos(#09#09, S)
      end;

      while (length(S)<>0) and (S[1]=#09) do
          delete(S, 1, 1);                                             // remove leading TABs
      while (length(S)<>0) and (S[length(S)]=#09) do
          delete(S, length(S), 1);                                     // remove trailing TABs

      if length(S)=0 then fail;
      if not GFXflag then exit;
//    writeln('[',S,']');

// next the command is peeled off the start of the string, and converted to upper case
      I:=pos(#09, S);
      J:=pos('-', S);
      if J<>0 then I:=min(I, J);                                       // new version, allows a '+' or '-',
      J:=pos('+', S);                                                  // from the 1st numeric parameter,
      if J<>0 then I:=min(I, J);                                       // to delimit the command

      if I<>0 then begin
                     CMD:=UpperCase(copy(S, 1, I-1));
                     if S[I]<>#09 then dec(I);                         // leave '+' or '-' intact (see above comment)
                     delete(S, 1, I)
                   end
              else begin
                     CMD:=S;
                     S:=''
                   end;

// now we (1) abbreviate/shorten the command to a single letter, and,
//        (2) decide how many parameters we are expecting to see
      if length(CMD)<>1 then                                           // check for commands containing 2 or more letters
      if CMD='CLEAR'  then CMD:='C' else
      if CMD='INK'    then CMD:='I' else
      if CMD='LINE'   then CMD:='L' else
      if CMD='PLOT'   then CMD:='P' else
      if CMD='ARC'    then CMD:='A' else
      if CMD='FILL'   then CMD:='F' else
      if CMD='MOVETO' then CMD:='M' else
      if CMD='DRAWTO' then CMD:='D' else
      if CMD='SCROLL' then CMD:='S'
                      else fail;                                       // failed to identify a long command
      if not GFXflag then exit;                                        // failed -> exit

//    n:=0;                                                            // suppress compiler warning (seems to no longer be needed)
      case CMD[1] of 'P', 'F', 'M', 'D':n:=2;
                          'C', 'I', 'L':n:=4;
                               'A', 'S':n:=6;
                                    '?':n:=0
                  else                  fail                           // failed to identify a short command
      end;  { of case }
      if not GFXflag then exit;                                        // failed -> exit
//    writeln(CMD, '<', S, '>');

      if (n=0) and (S<>'') then begin                                  // 0 parameters expected, but non-empty string of parameters
                                  fail;
                                  exit                                 // failed -> exit
                                end;

// the next thing to do is to separate out the parameters
      for I:=1 to n do
      begin
        J:=pos(#09, S);
        if J<>0 then begin                                             // parameter seperator, <TAB>, is present
                       if I=n then begin                               // found too many parameters
                                     fail;
                                     exit                              // failed -> exit
                                   end;

                       PSn:=copy(S, 1, J-1);
                       delete(S, 1, J)
                     end
                else begin                                             // no <TAB> found, so last parameter in line
                       PSn:=S;
                       S:=''
                     end;

        try
//        writeln(length(S):4,' <',S,'>    ',I,' <',PSn,'>');
          params[I]:=trunc(StrToFloat(PSn))
        except                                                         // invalid parameter, not an identifiable number
          fail;                                                        // (includes an empty string)
          exit                                                         // failed -> exit
        end
      end;

      case CMD[1] of 'C':GFXclear(params[1], params[2], params[3], params[4]);
                     'I':GFXink(params[1], params[2], params[3], params[4]);
                     'L':GFXlineAB(params[1], params[2], params[3], params[4]);
                     'P':GFXplot(params[1], params[2]);
                     'A':GFXarc(params[1], params[2], params[3], params[4], params[5], params[6]);
                     'F':GFXfill(params[1], params[2]);
                     'M':GFXmoveto(params[1], params[2]);
                     'D':GFXdrawto(params[1], params[2]);
                     'S':GFXscroll(params[1], params[2], params[3], params[4], params[5], params[6]);
                     '?':begin
                           T:=IntToStr(Gw)+', '+IntToStr(Gh)+#13;
                           if PasteBuffer.index=0 then case CONNECTED of 2:QueueSerialWrite(T);
                                                                         4:;  // WriteSocket(T)                        // #################### MISSING ####################
                                                       end  { of case }
                         end
                  else   fail                                          // should never end up here!
      end;  { of case }

// if we have arrived here with GFXflag set, then the line has been succesfully processed without any errors

      if GFXflag then
      begin
        if not Form1.Image2.Visible then Form1.Image2.Show;            // turn on graphics layer if not already visible
        Form1.Image2.Picture.Bitmap.TransparentColor:=clWhite;         // <--- horrible kludge to keep Lazarus happy, <<<<<<<<<<
        Form1.Image2.Picture.Bitmap.TransparentColor:=clBlack;         // <--- otherwise the image is not transparent <<<<<<<<<<
//      Form1.Image2.Picture.Bitmap.TransparentMode:=tmAuto;
//      Form1.Image2.Picture.Bitmap.TransparentMode:=tmFixed;          // (these two lines, together, also seem to produce the same result)

        if DEBUGMODE=2 then
        begin
        {$IFDEF WINDOWS}
          WriteMapBuffer(chr($80 + 15));                               // set WHITE text on a BLACK background
          WriteMapBuffer('PASS: <DLE>'+copy(GFXline,2,length(GFXline)-2) + #13#10)
        {$ELSE}
          WriteLn('PASS: <DLE>', copy(GFXline,2,length(GFXline)-2))
        {$ENDIF}
        end;

        GFXline:='';
        GFXflag:=false;                                                // drop out of GFX mode
        skipLF:=true                                                   // signal to discard trailing linefeed if one shows up next time through
      end;
    end  { end of processing a valid GFX command string }
  end
end;



(*
//
// attempt to remove control characters from output stream in DEBUGMODE 2, may get back to later                       // #################### MISSING ####################
//

S:='';
for I:=2 to length(GFXline)-2 do
if GFXline[I]<#32 then case GFXline[I] of #07:S:=S+('<BEL>');        // bell
                                          #08:S:=S+('<BS>');         // backspace
                                          #09:S:=S+#9;               // tab -> pass straight through
                                          #10:S:=S+('<LF>');         // linefeed
                                          #13:S:=S+('<CR>');         // carriage return
                                          #27:S:=S+('<ESC>')         // escape
                                       else   S:=S+('<'+IntToHex(ord(S[I]), 2)+'>')
                       end  { of case }
                  else S:=S+GFXline[I];
*)
