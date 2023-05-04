unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, LCLType, Math, LConvEncoding, Types;

type

  { TForm4 }

  TForm4 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;

    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;

    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;

    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelT: TLabel;
    LabelS: TLabel;

    Panel1: TPanel;
      Image1: TImage;

    LabelW: TLabel;
    LabelH: TLabel;
    LabelX: TLabel;
    LabelY: TLabel;

    SpinEditS: TSpinEdit;
    SpinEditW: TSpinEdit;
    SpinEditH: TSpinEdit;
    SpinEditX: TSpinEdit;
    SpinEditY: TSpinEdit;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;

    ListBox1: TListBox;
    Timer1: TTimer;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);

    procedure Image1Click(Sender: TObject);
    procedure SpinEditChanged(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure Timer1Timer(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure UpdateFontSample({%H-}CallerName:string);
  public

  end;

var
//  Form4: TForm4;                       // not needed here - form is created by caller
    FontInfo:record
               FamilyName:string[255];
               CharHeight:integer;       // EITHER height in pixels
               CharPoints:integer;       // OR size in points
                   Wo, Ho,               // +/- cell width and height
                   Xo, Yo:integer;       // offsets within cell
                   HC, VC:boolean;       // automatic H/V centre
//                 U1, U2,               // custom underline: normal
//                 U3, U4:integer;       // custom underline: bold
//                  UseCU:boolean;       // use custom values
                       SZ:boolean;       // slashed zero
                   MW, MH:integer;       // maximum cell width and height
             end;  { of record }


const CP437toUTF16:array [char] of widechar=(
#$00  , #$01  , #$02  , #$03  , #$04  , #$05  , #$06  , #$07  , #$08  , #$09  , #$0A  , #$0B  , #$0C  , #$0D  , #$0E  , #$0F  ,    // control characters
#$10  , #$11  , #$12  , #$13  , #$14  , #$15  , #$16  , #$17  , #$18  , #$19  , #$1A  , #$1B  , #$1C  , #$1D  , #$1E  , #$1F  ,
 ' '  , '!'   , '"'   , '#'   , '$'   , '%'   , '&'   , #$27  , '('   , ')'   , '*'   , '+'   , ','   , '-'   , '.'   , '/'   ,    // punctuation
 '0'  , '1'   , '2'   , '3'   , '4'   , '5'   , '6'   , '7'   , '8'   , '9'   , ':'   , ';'   , '<'   , '='   , '>'   , '?'   ,    // numbers and punctuation
 '@'  , 'A'   , 'B'   , 'C'   , 'D'   , 'E'   , 'F'   , 'G'   , 'H'   , 'I'   , 'J'   , 'K'   , 'L'   , 'M'   , 'N'   , 'O'   ,    // uppercase letters (A-O)
 'P'  , 'Q'   , 'R'   , 'S'   , 'T'   , 'U'   , 'V'   , 'W'   , 'X'   , 'Y'   , 'Z'   , '['   , '\'   , ']'   , '^'   , '_'   ,    //                   (P-Z)
 '`'  , 'a'   , 'b'   , 'c'   , 'd'   , 'e'   , 'f'   , 'g'   , 'h'   , 'i'   , 'j'   , 'k'   , 'l'   , 'm'   , 'n'   , 'o'   ,    // lowercase letters (a-o)
 'p'  , 'q'   , 'r'   , 's'   , 't'   , 'u'   , 'v'   , 'w'   , 'x'   , 'y'   , 'z'   , '{'   , '|'   , '}'   , '~'   , #$2302,    //                   (p-z)
#$00c7, #$00fc, #$00e9, #$00e2, #$00e4, #$00e0, #$00e5, #$00e7, #$00ea, #$00eb, #$00e8, #$00ef, #$00ee, #$00ec, #$00c4, #$00c5,
#$00c9, #$00e6, #$00c6, #$00f4, #$00f6, #$00f2, #$00fb, #$00f9, #$00ff, #$00d6, #$00dc, #$00a2, #$00a3, #$00a5, #$20a7, #$0192,
#$00e1, #$00ed, #$00f3, #$00fa, #$00f1, #$00d1, #$00aa, #$00ba, #$00bf, #$2310, #$00ac, #$00bd, #$00bc, #$00a1, #$00ab, #$00bb,
#$2591, #$2592, #$2593, #$2502, #$2524, #$2561, #$2562, #$2556, #$2555, #$2563, #$2551, #$2557, #$255d, #$255c, #$255b, #$2510,
#$2514, #$2534, #$252c, #$251c, #$2500, #$253c, #$255e, #$255f, #$255a, #$2554, #$2569, #$2566, #$2560, #$2550, #$256c, #$2567,
#$2568, #$2564, #$2565, #$2559, #$2558, #$2552, #$2553, #$256b, #$256a, #$2518, #$250c, #$2588, #$2584, #$258c, #$2590, #$2580,
#$03b1, #$00df, #$0393, #$03c0, #$03a3, #$03c3, #$00b5, #$03c4, #$03a6, #$0398, #$03a9, #$03b4, #$221e, #$03c6, #$03b5, #$2229,
#$2261, #$00b1, #$2265, #$2264, #$2320, #$2321, #$00f7, #$2248, #$00b0, #$2219, #$00b7, #$221a, #$207f, #$00b2, #$25aa, #$00a0);
                                                                                                             // #@25a0
//  {$I CP437.inc}             // no improvement over the above array

implementation

{$R *.lfm}

{ TForm4 }

const Magnification=5;

var Magnify:boolean;
      ULine:boolean;                                                   // underline flag
      CLine:boolean;                                                   // use custom u.line values flag
      BText:boolean;                                                   // bold text flag
      errCW:boolean;
      errCH:boolean;
      errTN:boolean;


procedure TForm4.UpdateFontSample(CallerName:string);
var cellW, cellH, Xo, Yo, X, Y:integer;
                         ARect:TRect;
                            ch:char;
//                           W:word;
begin
  if (ListBox1.ItemIndex=-1) then exit;                                // no fonts available -> do nothing
//writeln(GetTickCount64, #9, 'UPDATE from: ', CallerName);

  Panel1.Visible:=true;                                                // initially hidden
  Label2.Color:=clNone;                                                // once a selection is made, remove highlighting
  SpinEditS.Color:=clYellow;                                           // highlight font size SpinEdit
  Label3.Visible:=true;
  Label4.Visible:=true;

  Magnify:=false;

  with Image1.Picture.Bitmap.Canvas do                                 // set up font details (Name, Size/Height, Colour, Style (Underline, Bold),
  begin                                                                // updating EVERYTHING from Form4's ListBox, SpinEdit, CHeckBox controls
    Font.Name:=ListBox1.Items[ListBox1.ItemIndex];                     // **NAME**

    if pos('x', Button5.Caption)<>0 then Font.Height:=SpinEditS.Value  // **HEIGHT**
                                    else Font.Size:=SpinEditS.Value;   // **SIZE**

    Font.Style:=[];                                                    // **STYLE** (clear all, in particulat underline and bold)
    Font.Color:=clBlack;                                               // **COLOR** of text -> Black
//  Pen.Color:=clBlack;                                                // only needed if drawing underline using Line()
//  Pen.Width:=1;                                                      //  "     "    "     "        "       "     "

    cellW:=max(1, TextWidth('#')+SpinEditW.Value);                     // can now calculate **CELL DIMENSIONS**, once this is done
    cellH:=max(1, TextHeight('#')+SpinEditH.Value);                    // we can proceed to apply styles (which may change width/height)

    if ULine and not CLine then Font.Style:=Font.Style+[fsUnderline];  // **UNDERLINE**
    if BText then Font.Style:=Font.Style+[fsBold];                     // **BOLD**

    if CheckBox2.Checked then with TextStyle do Alignment:=taCenter    // set automatic horizontal centre
                          else with TextStyle do Alignment:=taLeftJustify;
    if CheckBox3.Checked then with TextStyle do Layout:=tlCenter       // set automatic vertical centre
                          else with TextStyle do Layout:=tlTop
  end;

  if CheckBox1.Checked then CP437toUTF16['0']:=#$00d8                  // slashed zero, also #195#152 (in UTF8)
                       else CP437toUTF16['0']:='0';                    // default zero

  with FontInfo do
  begin
    errCW:=(cellW>MW);
    errCH:=(cellH>MH);
    errTN:=(cellW<8);

    if errCW or errTN then Label3.Color:=clRed                         // !!cell is too narrow or too wide!!
                      else Label3.Color:=clNone;
    if errCH then Label4.Color:=clRed                                  // !!cell is too high!!
             else Label4.Color:=clNone;
  end;

  with Image1.Picture.Bitmap do                                        // set image size, 32 characters x 7 lines (excludes #00..#31)
  begin
    Width:=(cellW*32)+33;                                              // 32 characters/line + 33 verticals
    Height:=(cellH*7)+8                                                // 7 rows + 8 horizontals
  end;                                                                 // Image1.AutoSize=True, so it follows the bitmap's size

  with Image1.Picture.Bitmap.Canvas do
  begin
    Brush.Color:=clRed;                                                // solid RED background -> forms grid lines once populated
    FillRect(0, 0, Image1.Picture.Bitmap.Width, Image1.Picture.Bitmap.Height);

    for Y:=0 to 6 do
    for X:=0 to 31 do                                                  // 7 lines of 32 characters each, #32..#255
    begin
      ch:=chr(32+(Y*32)+X);
      Xo:=1+(X*cellW)+X;
      Yo:=1+(Y*cellH)+Y;
      ARect:=Rect(Xo, Yo, Xo+cellW, Yo+cellH);                         // cell bounding box

      if odd(Y) xor odd (X) then Brush.Color:=clYellow                 // 'checkerboard' background
                            else Brush.Color:=clAqua;
//    Brush.Color:=clWhite;                                            // alternate: white background

      FillRect(ARect);                                                 // fill cell with background colour
      inc(Xo, SpinEditX.Value);
      inc(Yo, SpinEditY.Value);                                        // apply X and Y offsets to character position within cell

// **** solution for Linux and "Courier New", "Lucida Console" under Win32
      TextRect(ARect, Xo, Yo, UTF8Encode(CP437toUTF16[ch]));         // print character within cell (clipped)

// **** fixes all but #$80 to #$9F under Win32
{     W:=ord(ch);
      TextRect(ARect, Xo, Yo, UTF8Encode(wchar(W)));                   // print character within cell (clipped)
}
// **** fully (?? did ONCE ??) fixes Terminal font under Win32
{     Font.CharSet:=ANSI_CHARSET;
      W:=ord(ch);
      if (ch<#$80) or (ch>#$9F) then TextRect(ARect, Xo, Yo, UTF8Encode(wchar(W)))
                                else TextRect(ARect, Xo, Yo, UTF8Encode(CP437_to_UTF16[ch]));
}
      if ULine and CLine then                                          // display underline using custom underline values
      begin
        if BText then begin
                        ARect.Top:=ARect.Bottom - min(cellH, SpinEdit3.Value);
                        ARect.Bottom:=ARect.Bottom - min(cellH, SpinEdit4.Value-1)
                      end
                 else begin
                        ARect.Top:=ARect.Bottom - min(cellH, SpinEdit1.Value);
                        ARect.Bottom:=ARect.Bottom - min(cellH, SpinEdit2.Value-1)
                      end;
        Brush.Color:=clBlack;
        FillRect(ARect)                                                // draw custom underline (as a rectangle)
      end
    end;

    if Font.Height<Font.Size then Label1.Caption:='  '+Font.Name+'  '+IntToStr(Abs(Font.Size))+'pt  ('+IntToStr(Abs(Font.Height))+' px)'
                             else Label1.Caption:='  '+Font.Name+'  '+IntToStr(Abs(Font.Height))+'px  ('+IntToStr(Abs(Font.Size))+' pt)';
    Label1.Font.Style:=[fsBold];
//  with Label1 do Width:=Canvas.TextWidth(Caption);
//  with Label1 do Height:=Canvas.TextHeight(Caption);                 // bug fix

    Label2.Caption:='  width = '+IntToStr(cellW)+'    x    height = '+IntToStr(cellH)+'  ';
//  with Label2 do Width:=Canvas.TextWidth(Caption);
//  with Label2 do Height:=Canvas.TextHeight(Caption)                  // bug fix
  end;

  Panel1.AutoSize:=true;                                               // allow Panel1 to snap to size of Image1,
  Panel1.AutoSize:=false;                                              // ... then lock to this size

  Self.AutoSize:=true;                                                 // allow Form4 to snap to content size,
  Self.AutoSize:=false;                                                // ... then lock to this size
//Self.Color:=clBlue;                                                  // check if Self is referencing Form4

  SpinEditS.Enabled:=true;                                             // ensure all controls are enabled
  SpinEditW.Enabled:=true;
  SpinEditH.Enabled:=true;
  SpinEditX.Enabled:=true;
  SpinEditY.Enabled:=true;
  SpinEdit1.Enabled:=true;
  SpinEdit2.Enabled:=true;
  SpinEdit3.Enabled:=true;
  SpinEdit4.Enabled:=true;
  Button3.Enabled:=true;
  Button4.Enabled:=true;
  Button5.Enabled:=true;
  CheckBox1.Enabled:=true;
  CheckBox2.Enabled:=true;
  CheckBox3.Enabled:=true;
  CheckBox4.Enabled:=true
end;


// buttons ---------------------------------------------------------------------

procedure TForm4.Button1Click(Sender: TObject);                        // CANCEL button pressed
var f:TCustomForm;
begin
  f:=GetParentForm(Self);
  if f<>nil then f.ModalResult:=mrCancel
end;


procedure TForm4.Button2Click(Sender: TObject);                        // OK button pressed
var f:TCustomForm;
begin
  if ListBox1.ItemIndex=-1 then ShowMessage(#13+'      No Font has been Selected      '+#13) else
  if errCW or errCH then ShowMessage(#13+'      Cell Size is too Large for Monitor      '+#13) else
  if errTN then ShowMessage(#13+'      Minimum Cell Width is 8 pixels      '+#13);

  if (ListBox1.ItemIndex=-1) or errCW or errCH or errTN then exit;     // prevent exiting if error condition
                                                                       // (user can still press CANCEL)
  f:=GetParentForm(Self);
  if f<>nil then with FontInfo do
  begin
    with Image1.Picture.Bitmap.Canvas do
    begin
      FamilyName:=Font.Name;
      CharHeight:=Font.Height;
      CharPoints:=Font.Size
    end;

    Wo:=SpinEditW.Value;
    Ho:=SpinEditH.Value;
    Xo:=SpinEditX.Value;
    Yo:=SpinEditY.Value;
    HC:=CheckBox2.Checked;
    VC:=CheckBox3.Checked;
//  U1:=SpinEdit1.Value;
//  U2:=SpinEdit2.Value;
//  U3:=SpinEdit3.Value;
//  U4:=SpinEdit4.Value;
//  UseCU:=CheckBox4.Checked;
    SZ:=CheckBox1.Checked;

    f.ModalResult:=mrOK
  end
end;


procedure TForm4.Button3Click(Sender: TObject);                        // U.LINE (test) button pressed
begin
  ULine:=not ULine;
  if ULine then Button3.Font.Style:=[fsBold]                           // BOLD label = selected
           else Button3.Font.Style:=[];

  SpinEdit1.Enabled:=CLine and ULine and not BText;
  SpinEdit2.Enabled:=CLine and ULine and not BText;
  SpinEdit3.Enabled:=CLine and ULine and BText;
  SpinEdit4.Enabled:=CLine and ULine and BText;
  UpdateFontSample(TButton(Sender).Name)
end;


procedure TForm4.Button4Click(Sender: TObject);                        // BOLD (test) button pressed
begin
  BText:=not BText;
  if BText then Button4.Font.Style:=[fsBold]                           // BOLD label = selected
           else Button4.Font.Style:=[];

  SpinEdit1.Enabled:=CLine and ULine and not BText;
  SpinEdit2.Enabled:=CLine and ULine and not BText;
  SpinEdit3.Enabled:=CLine and ULine and BText;
  SpinEdit4.Enabled:=CLine and ULine and BText;
  UpdateFontSample(TButton(Sender).Name)
end;


procedure TForm4.Button5Click(Sender: TObject);
var I, J:integer;
begin
  with Image1.Picture.Bitmap.Canvas do                                 // make use of font data previously set up in Image1, if we
  begin                                                                // land here Image1 has already been drawn and is visible.
    I:=-Font.Size;
    J:=-Font.Height;
      if I>J then begin
                    Font.Size:=I;
                    Button5.Caption:='points';
                    SpinEditS.Value:=I
                  end
             else begin
                    Font.Height:=J;
                    Button5.Caption:='pixels';
                    SpinEditS.Value:=J
                  end
  end;
  if abs(I)=abs(J) then UpdateFontSample(TButton(Sender).Name)         // required in case size happens to equal height, 1pt/1px is an example
end;



// checkboxes ------------------------------------------------------------------

procedure TForm4.CheckBox1Change(Sender: TObject);                     // slashed zero substitution on/off
begin
  UpdateFontSample(TCheckBox(Sender).Name)
end;


procedure TForm4.CheckBox2Change(Sender: TObject);                     // horizontal centring on/off
begin
  SpinEditX.Enabled:=not CheckBox2.Checked;                            // X offset SpinBox disabled if AUTO
  UpdateFontSample(TCheckBox(Sender).Name)
end;


procedure TForm4.CheckBox3Change(Sender: TObject);                     // vertical centring on/off
begin
  SpinEditY.Enabled:=not CheckBox3.Checked;                            // Y offset SpinBox disabled if AUTO
  UpdateFontSample(TCheckBox(Sender).Name)
end;


procedure TForm4.CheckBox4Change(Sender: TObject);                     // custom undeline values ON/OFF
begin
  Cline:=CheckBox4.Checked;

  SpinEdit1.Enabled:=CLine and ULine and not BText;
  SpinEdit2.Enabled:=CLine and ULine and not BText;
  SpinEdit3.Enabled:=CLine and ULine and BText;
  SpinEdit4.Enabled:=CLine and ULine and BText;
  UpdateFontSample(TCheckBox(Sender).Name)
end;


procedure TForm4.CheckBox5Change(Sender: TObject);
var I:integer;
begin
  CheckBox5.Visible:=false;
  for I:=0 to Screen.Fonts.Count-1 do
  begin
    if ListBox1.Items.IndexOf(Screen.Fonts.Strings[I])=-1 then         // not already loaded
    begin
      ListBox1.Items.Add(Screen.Fonts.Strings[I]);
      if ListBox1.Items.Count=1 then Label1.Caption:='  '+IntToStr(ListBox1.Items.Count)+' font'
                                else Label1.Caption:='  '+IntToStr(ListBox1.Items.Count)+' fonts';
//    with Label1 do Width:=Canvas.TextWidth(Caption);
//    with Label1 do Height:=Canvas.TextHeight(Caption);               // bug fix
      Application.ProcessMessages
    end
  end;
  UpdateFontSample(TCheckBox(Sender).Name)
end;


// spinedits -------------------------------------------------------------------

procedure TForm4.SpinEditChanged(Sender: TObject);                     // ANY SpinEdit control has changed
begin
    UpdateFontSample(TSpinEdit(Sender).Name)
end;


// listbox ---------------------------------------------------------------------

procedure TForm4.ListBox1SelectionChange(Sender: TObject; User: boolean);
begin
  UpdateFontSample(TListBox(Sender).Name)                              // selected font has changed (drops through if not)
end;


// image (of sample font) ------------------------------------------------------

procedure TForm4.Image1Click(Sender: TObject);                         // click on image toggles magnify ON/OFF
var ARect:TRect;
      TBM:TBitMap;
begin
  Magnify:=not Magnify;

  if not Magnify then UpdateFontSample(TImage(Sender).Name) else       // redraw to original size
  begin
    ARect:=Image1.BoundsRect;
    TBM:=TBitMap.Create;
    TBM.Width:=ARect.Width;
    TBM.Height:=ARect.Height;
    TBM.Canvas.CopyRect(ARect, Image1.Picture.Bitmap.Canvas, ARect);

    with Image1 do with Picture.Bitmap do
    begin
      Width:=Width*Magnification;
      Height:=Height*Magnification;
      Canvas.StretchDraw(BoundsRect, TBM)                              // magnify image
    end;

    TBM.Free
  end
end;


procedure TForm4.Timer1Timer(Sender: TObject);                         // handle scrolling around magnified image
var APoint:Tpoint;
begin
  if Magnify then
  begin
    APoint:=Point(Mouse.CursorPos.X, Mouse.CursorPos.Y);               // get mouse SCREEN coordinates
    APoint:=Panel1.ScreenToClient(APoint);                             // remap coordinates so relative to Panel1

    with APoint do
    begin
      X:=-X * (Magnification-1);                                       // convert to X and Y offsets for the TLH corner of Image1
      Y:=-Y * (Magnification-1);

      Image1.Left:=min(max(Panel1.Width-Image1.Width, X), 0);          // move Image1 within Panel1 so that it appears to
      Image1.Top:=min(max(Panel1.Height-Image1.Height, Y), 0)          // track the mouse pointer like a magnifying glass

    end
  end
end;


// initialization code --------------------------------------------------------

var Initialize:boolean;                                                // set true each time form is used

procedure TForm4.FormCreate(Sender: TObject);
var I:integer;
begin
  for I:=0 to ComponentCount-1 do                                      // fix for label height bug in Lazarus 2.0.12
  if Components[I].ClassNameIs('TLabel') then
  with TLabel(Components[I]) do Constraints.MinHeight:=Canvas.TextHeight('#');

  SpinEditS.Enabled:=false;                                          // disable all controls until font selected
  SpinEditW.Enabled:=false;
  SpinEditH.Enabled:=false;
  SpinEditX.Enabled:=false;
  SpinEditY.Enabled:=false;
  SpinEdit1.Enabled:=false;
  SpinEdit2.Enabled:=false;
  SpinEdit3.Enabled:=false;
  SpinEdit4.Enabled:=false;
  Button3.Enabled:=false;
  Button4.Enabled:=false;
  Button5.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  CheckBox3.Enabled:=false;
  CheckBox4.Enabled:=false;
  CheckBox5.Enabled:=false;

  Magnify:=false;                                                    // initialize variables
  ULine:=false;
  CLine:=false;
  BText:=false;
  errCW:=false;
  errCH:=false;
  errTN:=false;
  Initialize:=true                                                   // enable FormActivate 1st startup code
end;


procedure TForm4.FormActivate(Sender: TObject);
var W:array [33..126] of integer;
var I, J:integer;
      OK:boolean;
       L:TLabel;
begin
  if Initialize then                                                   // first call here after form creation
  begin
    Initialize:=false;
    Screen.Cursor:=crHourGlass;

    ListBox1.Items.Clear;
    L:=TLabel.Create(self);
    L.Parent:=self;
    L.Visible:=false;
    with FontInfo do if (FamilyName<>'') and ((CharHeight*CharPoints)<>0) then
    begin                                                              // we have some existing font information passed in
      SpinEditS.Value:=max(CharHeight, CharPoints);                    // set "size :" SpinEdit to a sane value
      if CharHeight<CharPoints then Button5.Caption:='points'          // set Button5.Caption correctly
                               else Button5.Caption:='pixels';
    end;
    Application.ProcessMessages;

//  from: https://forum.lazarus.freepascal.org/index.php/topic,20193.msg116202.html#msg116202
    for I:=0 to Screen.Fonts.Count-1 do
    begin
      L.Font.Name:=Screen.Fonts.Strings[I];

      with L.Canvas do OK:=(TextWidth('WMWMWM')=TextWidth('iiiiii'));  // first check if widths match: 'W'='M'='i'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// consider skipping the extended check, just rely on 'WMWMWM' vs 'iiiiii'. otherwise takes too long to complete ////
      if OK then                                                       // perform check for rest of #33..#126        //
      begin                                                                                                          //
        for J:=low(W) to high(W) do with L.Canvas do W[J]:=TextWidth(chr(J));                                        //
        for J:=low(W) to high(W) do if W[J]<>W[35] then OK:=false      // compare each one to '#' (ascii 35)         //
      end;                                                                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      if OK or (upcase(FontInfo.FamilyName)=upcase(L.Font.Name)) then  // passes monospace test, or is currently used font
      begin                                                            //                        ^^^^^^^^^^^^^^^^^^^^^^^^^
        ListBox1.Items.Add(L.Font.Name);
        if ListBox1.Items.Count=1 then Label1.Caption:='  '+IntToStr(ListBox1.Items.Count)+' font'
                                  else Label1.Caption:='  '+IntToStr(ListBox1.Items.Count)+' fonts';
//      with Label1 do Width:=Canvas.TextWidth(Caption);
//      with Label1 do Height:=Canvas.TextHeight(Caption);             // bug fix
        Application.ProcessMessages                                    // update ListBox1 and Label1 on screen
      end
    end;

    with FontInfo do
    begin
      I:=ListBox1.Items.IndexOf(FamilyName);

      if I=-1 then Label2.Color:=clYellow else                         // no font selected -> highlight instructions
      begin                                                            // load up (incoming) data about selected font
        SpinEditS.Value:=max(CharHeight, CharPoints);
        if CharHeight<CharPoints then Button5.Caption:='points'
                                 else Button5.Caption:='pixels';
        SpinEditW.Value:=Wo;
        SpinEditH.Value:=Ho;
        SpinEditX.Value:=Xo;
        SpinEditY.Value:=Yo;
        CheckBox2.Checked:=HC;
        CheckBox3.Checked:=VC;
//      SpinEdit1.Value:=U1;
//      SpinEdit2.Value:=U2;
//      SpinEdit3.Value:=U3;
//      SpinEdit4.Value:=U4;
//      CheckBox4.Checked:=UseCU;
        CheckBox1.Checked:=SZ;
        ListBox1.ItemIndex:=I                                            // this will trigger a ListBox1SelectionChange and draw Image1
      end;

      Label3.Caption:='  (8 - '+IntToStr(MW)+')  ';                      // ensure Label 3 has the correct data filled in
//    with Label3 do Width:=Canvas.TextWidth(Caption);
//    with Label3 do Height:=Canvas.TextHeight(Caption);                 // bug fix
      Label4.Caption:='  (max '+IntToStr(MH)+')  ';                      // ensure Label 4 has the correct data filled in
//    with Label4 do Width:=Canvas.TextWidth(Caption);
//    with Label4 do Height:=Canvas.TextHeight(Caption)                  // bug fix
    end;

    L.free;
    Screen.Cursor:=crDefault;
    CheckBox5.Enabled:=true
  end
end;



end.

