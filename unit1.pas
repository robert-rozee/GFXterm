unit Unit1;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF WINDOWS}
  Windows,                             // important that Windows goes before Classes
{$ELSE}
  BaseUnix, TermIO,
{$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, Clipbrd, Math, LCLType, LCLIntf, Unit2, Unit3, Unit4, Unit5;

// Math is needed for min/max
// LCLType is needed for virtual key definitions
// BaseUnix is needed for file I/O under linux
// TermIO is needed for serial I/O under linux
// LCLIntf is needed for GetKeyState - used to determine capslock setting

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// remember to add -dUseCThreads to:                                          //
//                                                                            //
// Project -> Project Options -> Custom Options                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// before compiling, you need to have installed libasound2.dev with:          //
//                                                                            //
// sudo apt-get install libasound2-dev                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

type

  { TForm1 }

  TForm1 = class(TForm)
    MenuItem5B: TMenuItem;
    MenuItem1A: TMenuItem;
    MenuItem1B: TMenuItem;
    MenuItem2A: TMenuItem;
    MenuItem2B: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4A: TMenuItem;
      MenuItem4A1: TMenuItem;
      MenuItem4A2: TMenuItem;
    MenuItem4B: TMenuItem;

    MenuDivider1: TMenuItem;
    MenuItem5A: TMenuItem;
    MenuItem6: TMenuItem;
      MenuItem6A: TMenuItem;
      MenuItem6B: TMenuItem;
      MenuItem6C: TMenuItem;
      MenuItem6D: TMenuItem;
      MenuItem6E: TMenuItem;
      MenuItem6F: TMenuItem;
      MenuItem6G: TMenuItem;
      MenuItem6H: TMenuItem;
    MenuItem7: TMenuItem;
      MenuItem7A: TMenuItem;
      MenuItem7B: TMenuItem;
      MenuItem7C: TMenuItem;
    MenuItem8: TMenuItem;

    MenuDivider2: TMenuItem;
    MenuItem9: TMenuItem;
      MenuItem9A: TMenuItem;
      MenuItem9B: TMenuItem;
      MenuItem9C: TMenuItem;
      MenuItem9D: TMenuItem;
    MenuItem10: TMenuItem;
      MenuItem10A: TMenuItem;
      MenuItem10B: TMenuItem;
      MenuItem10C: TMenuItem;
    MenuItem11: TMenuItem;

    MenuDivider3: TMenuItem;
    MenuItem12: TMenuItem;

    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;

    Shape1: TShape;
    Panel1: TPanel;
      VTcursor: TLabel;
      Image1: TImage;
      Image2: TImage;
      Image3: TImage;
      Memo1: TMemo;
      Panel2: TPanel;
        Label9: TLabel;

    Timer1: TTimer;
    Timer3: TTimer;
    Timer4: TTimer;

    PopupMenu1: TPopupMenu;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog2: TSaveDialog;
    ApplicationProperties: TApplicationProperties;

    procedure ApplicationPropertiesActivate(Sender: TObject);
    procedure ApplicationPropertiesDeactivate(Sender: TObject);
    procedure ApplicationPropertiesIdle(Sender: TObject; var {%H-}Done: Boolean);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure Panel1MouseMove(Sender: TObject; {%H-}Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; {%H-}MousePos: TPoint; var Handled: Boolean);

    procedure PopupMenu1Popup(Sender: TObject);
    procedure MenuItem1AClick(Sender: TObject);
    procedure MenuItem1BClick(Sender: TObject);
    procedure MenuItem2AClick(Sender: TObject);
    procedure MenuItem2BClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4A1and2Click(Sender: TObject);
    procedure MenuItem4BClick(Sender: TObject);

    procedure MenuItem5ABClick(Sender: TObject);
    procedure MenuItem6MultiClick(Sender: TObject);
    procedure MenuItem7MultiClick(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);

    procedure MenuItem9MultiClick(Sender: TObject);
    procedure MenuItem10MultiClick(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);
//  procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


{$IFDEF WINDOWS}
const USBChangeFlag:boolean=false;
var PrevWndProc:WNDPROC;

  // from: https://wiki.lazarus.freepascal.org/Win32/64_Interface#Processing_non-user_messages_in_your_window
function WndCallback(Ahwnd:HWND; uMsg:UINT; wParam:WParam; lParam:LParam):LRESULT; stdcall;
begin
  if uMsg=WM_DEVICECHANGE then USBChangeFlag:=true;
  result:=CallWindowProc(PrevWndProc, Ahwnd, uMsg, WParam, LParam)
end;
{$ENDIF}


const {%H-}DN={$I %DATEDAY%};
      {%H-}MN={$I %DATEMONTH%};
      {%H-}YN={$I %DATEYEAR%};

{$IF DN<10}
  const DS=chr(ord('0')+DN);                                           // no leasding zero
{$ELSE}
  const DS=chr(ord('0')+(DN div 10))+chr(ord('0')+(DN mod 10));        // 2-digit day number
{$ENDIF}

{$IF MN=1}  const {%H-}MS1='JAN';  {%H-}MS2='jan';  {%H-}MS3='january';   {$ENDIF}
{$IF MN=2}  const {%H-}MS1='FEB';  {%H-}MS2='feb';  {%H-}MS3='february';  {$ENDIF}
{$IF MN=3}  const {%H-}MS1='MAR';  {%H-}MS2='mar';  {%H-}MS3='march';     {$ENDIF}
{$IF MN=4}  const {%H-}MS1='APR';  {%H-}MS2='apr';  {%H-}MS3='april';     {$ENDIF}
{$IF MN=5}  const {%H-}MS1='MAY';  {%H-}MS2='may';  {%H-}MS3='may';       {$ENDIF}
{$IF MN=6}  const {%H-}MS1='JUNE'; {%H-}MS2='june'; {%H-}MS3='june';      {$ENDIF}
{$IF MN=7}  const {%H-}MS1='JULY'; {%H-}MS2='july'; {%H-}MS3='july';      {$ENDIF}
{$IF MN=8}  const {%H-}MS1='AUG';  {%H-}MS2='aug';  {%H-}MS3='august';    {$ENDIF}
{$IF MN=9}  const {%H-}MS1='SEPT'; {%H-}MS2='sept'; {%H-}MS3='september'; {$ENDIF}
{$IF MN=10} const {%H-}MS1='OCT';  {%H-}MS2='oct';  {%H-}MS3='october';   {$ENDIF}
{$IF MN=11} const {%H-}MS1='NOV';  {%H-}MS2='nov';  {%H-}MS3='november';  {$ENDIF}
{$IF MN=12} const {%H-}MS1='DEC';  {%H-}MS2='dec';  {%H-}MS3='december';  {$ENDIF}

const YS=chr(ord('0')+ (YN div 1000)        )+
         chr(ord('0')+((YN div  100) mod 10))+
         chr(ord('0')+((YN div   10) mod 10))+
         chr(ord('0')+ (YN           mod 10));


const SoftwareKey='\Software\NZ made\GFXterm';
{$IFDEF WINDOWS}
      BuildName='Graphical VT Terminal (win32)';
{$ELSE}
      BuildName='Graphical VT Terminal (LINUX)';
{$ENDIF}
      BuildDate='build: '+DS+'-'+MS2+'-'+YS+'';


type str255=string[255];

const defROWS=24;
      defCOLS=80;
      minROWS=16;
      minCOLS=40;
      maxROWS=60;
      maxCOLS=160;

const ROWS:integer=defROWS;              // 24 or 36 or 43
      COLS:integer=defCOLS;              // win32 limit: 1036 pixels max if 1024 pixel wide physical screen



// can create 'rounded' corners to CRT area using the larger values below, but
// Win10 draws a single-pixel box around the window and makes it look awful :-(
      OVER=4 {12};     // overscan (in pixels)
//    WPEN=4 {25};     // width of the overscan 'pen' - odd numbers seem to work better here

        pL='      ';   // left packing spaces for ShowMessage calls
        pR='      ';   // right packing spaces for ShowMessage calls

const CommName:string='';                // currently connected comm port, set to '' on disconnect
      CommRate:integer=0;                // currently used baud rate, set to 0 on disconnect
      CommPara:string[5]='8-N-1';        // default of 8 data bits, no parity, 1 stop bit
      LastName:string='';                // last successfully connected comm port name
      LastRate:integer=0;                // last successfully used baud rate
      LastPara:string[5]='8-N-1';

var ConfigName:string;
       LogFile:text;

var cellW, cellH:integer;                // with and height of character cell
             SCR:TCanvas;                // used as a shortcut to text screen
             GFX:TCanvas;                // used as a shortcut to graphics screen

const cellWo:integer=0;                  // cell width offset                          \
      cellHo:integer=0;                  // cell height offset                          |
      cellXo:integer=0;                  // X offsets of character within cell          |
      cellYo:integer=0;                  // Y offsets of character within cell          |--- loaded/saved on startup, only
      autoXC:boolean=false;              // automatic horizontal centre                 |    adjusted after call to Form4
      autoYC:boolean=false;              // automatic vertical centre                   |
      slash0:boolean=false;              // substitute UNICODE /0 for normal 0         /

const FGdefault:integer=7;               // default text FG colour
      BGdefault:integer=0;               // default text BG colour
       FGcolour:integer=7;               // text foreground colour
       BGcolour:integer=0;               // text background colour
       InvertBW:boolean=false;           // flag to indicate black and white have both been inverted

       TxtStyle:TFontStyles=[];          // text style (we only use fsUnderline and fsBold)
        DimText:boolean=false;           // low intensity flag
        InvText:boolean=false;           // inverse video flag
         DimOpt:integer=0;               // enabled / bright 1 / bright 2
      CursorVis:boolean=true;            // hide/show text cursor
      VTinsMode:boolean=false;           // VT insert / replacement mode

           Xpos:integer=1;               // initial cursor column
           Ypos:integer=1;               // initial cursor row
          XYnew:boolean=false;           // flag indicating cursor has been moved
        Tmargin:integer=1;               // VT100 scroll area top margin
        Bmargin:integer=defROWS;         // VT100 scroll area bottom margin

          lastK:char=#00;                // last ascii key pressed. #255==\n
          lastC:char=#00;                // last ascii character printed

         MouseX:integer=-1;              // last mouse X position
         MouseY:integer=-1;              // last mouse Y position

         CRwait:integer=0;               // the number of <CR> characters being waited on (used when pasting)
         CRflag:boolean=false;           // flag to indicate a CR encountered in slow paste mode

            TS1:int64=0;                 // timestamp of last serial/network port data read (Rx)
            TS2:int64=0;                 // timestamp of last serial/network port data write (Tx)
            TS3:int64=0;                 // timestamp of last VT command decoded (Rx)
            TS4:int64=0;                 // timestamp of start of connection

            TS5:int64=0;                 // timestamp of start of paste operation
            TS6:int64=0;                 // timestamp of end of paste operation (or current time if paste in progress)
            TS7:int64=0;                 // timestamp of last CR sent in slow paste mode

            TS8:int64=0;                 // timestamp of last serial I/O thread activity
            TS9:int64=0;                 // timestamp of last keyboard activity (key-down or key-up event)
            TS10:int64=0;                // timestamp of last call to ApplicationPropertiesIdle (calls stop if LCL is swamped)

         RxBusy:boolean=false;
         TxBusy:boolean=false;
         CkBusy:boolean=false;

            ErrorCode:integer=0;                               // <>0: number indicating the cause of the last internal error
            ErrorPort:string='';                               // name of serial port opened when error occurred
            ErrorData:array [1..4] of integer=(0,0,0,0);       // data passed to error message display routine (in Timer4)
                 LCFn:integer=0;                               // last communications function called (always reset to zero upon return)

            RxBuffer:record                                    // serial input (ring) buffer
                       data:array [0..$3FFFF] of char;         // 256k
                       head:integer;
                       tail:integer
                     end=(data:''; head:0; tail:0);

            TxBuffer:record                                    // serial output (ring) buffer
                       data:array [0..$03FFF] of char;         // 16k
                       head:integer;
                       tail:integer
                     end=(data:''; head:0; tail:0);

            PasteBuffer:record
                          data:string;                         // paste buffer (characters to paste)
                          count:integer;                       // length of buffer
                          index:integer                        // index into buffer
                        end=(data:''; count:0; index:0);


const
{$IFDEF WINDOWS}
      BreakCounter:integer=-1;           // win32: used to time sending a break
{$ENDIF}
         CONNECTED:integer=0;            // 0 = offline, 1 = USB check,
                                         // 2 = serial,  4 = network
         LOGTOFILE:boolean=false;        // true if logging text to a file
         SKIPPRINT:boolean=false;        // buffer overflow, move cursor but no text output
         DEBUGMODE:integer=0;            // select what diagnostics to send to console
         MouseMode:integer=0;            // mouse mode and reporting protocol, 0=disabled

         flagFOCUS:boolean=false;        // set true by application activate, false by deactivate
         flagPOPUP:boolean=false;        // user to set true before a popup locks focus, clear after it returns,
                                         // for cases when application deactivate/activate fails (such as InputQuery)
         LABELTEST:boolean=false;

         ScrollLCK:boolean=false;        // signal scroll lock -> suspend screen output
         ScrollTOS:boolean=false;        // signal to scroll screen/cursor to Top Of Screen

         XMcounter:integer=0;            // <>0: F11 or F12 has been pressed, now check for XMODEM SEND/RECEIVE string
            XMload:boolean=false;        // 'XMODEM RECEIVE'+#13#10 string detected
            XMsave:boolean=false;        // 'XMODEM SEND'+#13#10 string detected
            XMinit:boolean=false;        // signal to initiate XModem transfer
            CCflag:boolean=false;        // signal from keyboard handler that ctrl-C has been pressed (used to interrupt)

var TextStore:array [1..maxROWS] of array [1..maxCOLS] of char;

const CPC:array [0..15] of TColor=(clBlack, clNavy, clGreen, clTeal,
                                   clMaroon, clPurple, clOlive, clSilver,
                                   clGray, clBlue, clLime, clAqua,
                                   clRed, clFuchsia, clYellow, clWhite);
{   (dim)           (bright)
0 = Black 	8 = Gray
1 = Blue 	9 = Light Blue
2 = Green 	A = Light Green
3 = Aqua 	B = Light Aqua     (Cyan)
4 = Red 	C = Light Red
5 = Purple 	D = Light Purple   (Magenta)
6 = Yellow 	E = Light Yellow
7 = White 	F = Bright White
}

const CVT:array [0..15] of TColor=(clBlack, clMaroon, clGreen, clOlive,
                                   clNavy, clPurple, clTeal, clSilver,
                                   clGray, clRed, clLime, clYellow,
                                   clBlue, clFuchsia, clAqua, clWhite);

{       (0-7 = dim, 8-15 = bright)
30	Black
31	Red
32	Green
33	Yellow
34	Blue                  TColor($FF8080) = bright blue, as per teraterm
35	Magenta   (Purple)
36	Cyan      (Aqua)
37	White

note: mmbasic should stop using bright-black (gray) for plain
text in the editor, and instead use dim-white (silver)
}

var  PAL:array [0..15] of TColor;              // holds colour palette, normally copied from CVT






(*
function GetTickCount64:int64;
const multiplier=24*60*60*1000;
begin
  Result:=trunc(Now*multiplier)
end;
*)



// returns how much time has elapsed since GetTickCount64 was assigned to a counter
// (placed up here as is used within serial.inc)
function timesince(counter:int64):int64;
begin
  result:=GetTickCount64-counter
end;



// place data into the serial output buffer, ready to be transmitted. on entry
// may wait up to 200ms for space in the output buffer to become free. returns
// false if unable to write because of blocking
// (placed up here as is used within engine.inc)
function QueueSerialWrite(Buffer:str255):boolean;
var mark:int64;
    flag:boolean;
     I,J:integer;
begin
  mark:=GetTickCount64;
  repeat
    I:=TxBuffer.head-TxBuffer.tail;
    if I<0 then I:=I+sizeof(TxBuffer.data);                            // calculate free space in TxBuffer
    flag:=(I<(length(Buffer)+16));                                     // require # characters + 16 free                        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    if not flag then sleep(20)                                         // if not enough space, wait...                          // should probably be Application.ProcessMessages
//  if not flag then Application.ProcessMessages                                                                                // <----------------- like this
  until flag or (timesince(mark)>200);                                 // loop until either enough space or timeout             // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  result:=flag;                                                        // returns false if no space in TxBuffer

  if flag then
  begin
    I:=TxBuffer.Head;
    for J:=1 to length(Buffer) do                                      // if enough space, load data into TxBuffer
    begin
      TxBuffer.data[I]:=Buffer[J];
      I:=(I+1) mod sizeof(TxBuffer.data)
    end;
    TxBuffer.head:=I
  end
end;



function ReadSerialQueue(var ch:char; timeout:int64):boolean;          // read (any) single character , with timeout
var TimeFlag:boolean;
        mark:int64;
begin
  ch:=#00;                                                             // returns character set to #00 if nothing to read
  mark:=GetTickCount64;
  if (timeout<>0) and (RxBuffer.head=RxBuffer.tail) then
  repeat                                                               // may NOT pass through -> TimeFlag MAY be undefined
    Application.ProcessMessages;
    TimeFlag:=(timesince(mark)>timeout)
  until (RxBuffer.head<>RxBuffer.tail) or TimeFlag;
//if timesince(mark)>=10 then write(timesince(mark), #9);

  if (RxBuffer.head=RxBuffer.tail) then result:=false else
  begin
    ch:=RxBuffer.data[RxBuffer.tail];
    RxBuffer.tail:=(RxBuffer.tail+1) mod sizeof(RxBuffer.data);
    result:=true
  end
end;



function WaitSerialQueue(ch:char; timeout:int64):boolean;              // wait for a specific character, with timeout
var CharFlag, TimeFlag:boolean;
                  mark:int64;
begin
  mark:=GetTickCount64;
  CharFlag:=false;
  repeat
    repeat
      Application.ProcessMessages;
      TimeFlag:=(timesince(mark)>timeout)
    until (RxBuffer.head<>RxBuffer.tail) or TimeFlag;                  // always passes through once -> TimeFlag is defined
//  if timesince(mark)>=200 then write(timesince(mark), #9);

    if not TimeFlag then
    begin
      CharFlag:=(RxBuffer.data[RxBuffer.tail]=ch);
      RxBuffer.tail:=(RxBuffer.tail+1) mod sizeof(RxBuffer.data)
    end
  until CharFlag or TimeFlag;
  result:=CharFlag
end;






{$I beeper.inc}
{$I video.inc}

{$IFDEF WINDOWS}
  {$I server1.inc}             // windows console server - place before commW32 and engine
  {$I commW32.inc}             // windows serial communications
{$ELSE}
  {$I serial.inc}              // linux serial communications
{$ENDIF}

{$I engine.inc}                // VT and GFX engines






// read configuration file, only called once (at startup)
function ReadConfigurationFile:boolean;
var T:text;
    S:string;
    I, J:integer;
begin
  result:=false;

  if FileExists(ConfigName) then
  try
//  writeln('opening config file');
    AssignFile(T, ConfigName);
    Reset(T);

    ReadLn(T, S);
//  writeln('version = ',S);
    if S='v6A' then
    begin
//    writeln('version matches');
      ReadLn(T, S);
      LastName:=trim(S);
      ReadLn(T, LastRate);
      ReadLn(T, S);
      LastPara:=trim(S);

      ReadLn(T, S);                      // font name
      S:=trim(S);
      Form1.VTcursor.Font.Name:=S;
      ReadLn(T, I);                      // size
      ReadLn(T, J);                      // height
      if I>J then Form1.VTcursor.Font.Size:=I
             else Form1.VTcursor.Font.Height:=J;

      ReadLn(T, I);
      COLS:=I;
      ReadLn(T, I);
      ROWS:=I;

      ReadLn(T, I);                      // cell width offset
      cellWo:=I;
      ReadLn(T, I);                      // cell height offset
      cellHo:=I;
      ReadLn(T, I);                      // X offsets of character within cell
      cellXo:=I;
      ReadLn(T, I);                      // Y offsets of character within cell
      cellYo:=I;
      ReadLn(T, I);                      // automatic horizontal centre
      autoXC:=odd(I and 1);
      ReadLn(T, I);                      // automatic vertical centre
      autoYC:=odd(I and 1);
      ReadLn(T, I);                      // slashed 0
      slash0:=odd(I and 1);

      ReadLn(T, I);
      Case I of 1:Form1.MenuItem6A.Checked:=true;
                2:Form1.MenuItem6B.Checked:=true;
                3:Form1.MenuItem6C.Checked:=true;
                4:Form1.MenuItem6D.Checked:=true;
                5:Form1.MenuItem6E.Checked:=true;
                6:Form1.MenuItem6F.Checked:=true;
                7:Form1.MenuItem6G.Checked:=true;
                8:Form1.MenuItem6H.Checked:=true
             else I:=7
      end;  { of case }
      if I=8 then InvertBW:=true;
      FGdefault:=min(I, 7);
      FGcolour:=FGdefault;

      ReadLn(T, I);
      case I of 0:Form1.MenuItem7A.Checked:=true;
                1:Form1.MenuItem7B.Checked:=true;
                2:Form1.MenuItem7C.Checked:=true
             else I:=0
      end;  { of case }
      DimOpt:=I;

      ReadLn(T, I);
      BELLvolume:=min(max(0, I), 100);

      for I:=0 to 15 do                                                // retrieve palette
      begin
        readln(T, S);
        S:=trim(S);
        PAL[I]:=StrToInt(S)
      end;

      if InvertBW then begin                                           // invert black and white
                         PAL[0]:=$00FFFFFF-PAL[0];                     // black -> white
                         PAL[15]:=$00FFFFFF-PAL[15]                    // white -> black
                       end;
//    writeln('parameters read ok');
      result:=true
    end;

//  writeln('closing config file')
    CloseFile(T)
  except
//  writeln('exception');
    try CloseFile(T) except end
  end
end;



// write configuration file, called at shutdown - may also be called at other times
procedure WriteConfigurationFile;
var T:text;
    I:integer;
begin
  if not ForceDirectories(ExtractFileDir(ConfigName)) then ShowMessage(#13+pL+'Failed to create config directory:'+pR+#13
                                                                          +pL+ExtractFileDir(ConfigName)+pR+#13) else
  try
    AssignFile(T, ConfigName);
    ReWrite(T);

    WriteLn(T, 'v6A');
    WriteLn(T, LastName);
    WriteLn(T, LastRate);
    WriteLn(T, LastPara);
    WriteLn(T, Form1.VTcursor.Font.Name);
    WriteLn(T, Form1.VTcursor.Font.Size);
    WriteLn(T, Form1.VTcursor.Font.Height);

    WriteLn(T, COLS);
    WriteLn(T, ROWS);

    WriteLn(T, cellWo);                  // cell width offset
    WriteLn(T, cellHo);                  // cell height offset
    WriteLn(T, cellXo);                  // X offsets of character within cell
    WriteLn(T, cellYo);                  // Y offsets of character within cell
    WriteLn(T, ord(autoXC));             // automatic horizontal centre
    WriteLn(T, ord(autoYC));             // automatic vertical centre
    WriteLn(T, ord(slash0));             // slashed zero

    if InvertBW then WriteLn(T, 8)
                else WriteLn(T, FGdefault);
    WriteLn(T, DimOpt);
    WriteLn(T, BELLvolume);

    if InvertBW then WriteLn(T,'0x'+Format('%.6x',[$00FFFFFF-PAL[0]]))
                else WriteLn(T,'0x'+Format('%.6x',[PAL[0]]));
    for I:=1 to 14 do WriteLn(T,'0x'+Format('%.6x',[PAL[I]]));
    if InvertBW then WriteLn(T,'0x'+Format('%.6x',[$00FFFFFF-PAL[15]]))
                else WriteLn(T,'0x'+Format('%.6x',[PAL[15]]));
    CloseFile(T)
  except
    try CloseFile(T) except end;
    ShowMessage(#13+pL+'Failed to write to config file:'+pR+#13
                   +pL+ConfigName+pR+#13)
  end
end;



// reset terminal. levels are:
// 0: full reset, but leaves serial port open
// 1: clear text and graphics layers, turn off graphics, home cursor
procedure ResetTerminal(level:integer);
var mark:int64;
begin
  if LOGTOFILE and (level=0) then                                      // close log file if open
  begin
    LOGTOFILE:=false;
    try Flush(LogFile) except end;
    try CloseFile(LogFile) except end
  end;

  if level=0 then                                                      // serial port, Rx, Tx, paste buffers
  begin
    SerialToIdle:=true;                                                // halt serial I/O thread

    SerialTicker:=3;
    mark:=GetTickCount64;
    repeat
      Application.ProcessMessages
    until (SerialTicker=0) or (timesince(mark)>300);                   // wait for thread to become idle

    RxBuffer.tail:=RxBuffer.head;                                      // clear Rx ring buffer
    TxBuffer.head:=TxBuffer.tail;                                      // clear Tx ring buffer

    SerialToIdle:=false;                                               // resume serial I/O thread

    PasteBuffer.index:=0;
    PasteBuffer.count:=0;
    PasteBuffer.data:=''                                               // empty paste buffer
  end;

  if level=0 then                                                      // reset VT settings
  begin
    DimText:=false;                                                    // reset text attributes
    InvText:=false;
    TxtStyle:=[];

    FGcolour:=FGdefault;                                               // reset text colours
    BGcolour:=BGdefault;

    GFXink(255, 0 ,0 ,1);                                              // default GFX pen: red, 1-pixel wide

    MouseMode:=0;                                                      // turn off mouse reporting
    CursorVis:=true;                                                   // unhide cursor
    VTinsMode:=false;                                                  // select replacement mode

    Tmargin:=1;                                                        // reset VT scroll margins
    Bmargin:=ROWS
  end;

  clear(1, 1, COLS, ROWS);                                             // clear text layer
  GFXclear(0, 0, Gw, Gh);                                              // clear graphics layer
  Form1.Image2.Hide;                                                   // hide graphics layer
  gotoxy(1,1)                                                          // home cursor
end;



// from milliseconds input, return days, hours, minutes, seconds in a formatted string
function DHMStime(ms:int64):string;
var D,H,M,S:int64;
begin
  D:=ms div (24*60*60*1000);
  dec(ms, D*24*60*60*1000);
  H:=ms div (60*60*1000);
  dec(ms, H*60*60*1000);
  M:=ms div (60*1000);
  dec(ms, M*60*1000);
  S:=ms div 1000;
  dec(ms, S*1000);
  if D=1  then result:=Format('%d day, %.2dh %.2dm %.2ds',[D, H, M, S]) else
  if D<>0 then result:=Format('%d days, %.2dh %.2dm %.2ds',[D, H, M, S]) else
  if H<>0 then result:=Format('%dh %.2dm %.2ds',[H, M, S]) else
  if M<>0 then result:=Format('%dm %.2ds', [M, S]) else
  if S=1  then result:=            '1 second' else
  if S<>0 then result:=IntToStr(S)+' seconds' else
               result:=IntToStr(ms)+' ms'
end;



// clean up a multi-line string:
// 1. clear top bit of all characters
// 2. translate CR-LF pairs into single CR's (will do nothing if LF delimited lines)
// 3. translate all remaining LF's into CR's (lines will now be CR delimited)
// 4. keep only control characters: TAB, CR, (optional) ctrl-Z
// 5. strip trailing spaces from lines
// 6. strip trailing spaces at end of file
// 7. remove any final trailing blank lines
// 8. ensure ends in either CR or ctrl-Z
// 9. (optional) pad with NULs to multiple of 128 bytes
//
// was originally common code for both types of paste (from clipboard and from text file);
// pulled out and put in to a standalone function, now also used by XModem receive routine
procedure CleanUpString(var S:string; KeepZ, Pad128:boolean);
var I:integer;
begin
  for I:=1 to length(S) do                                             // 1. clear bit-7 of all characters
        S[I]:=char(byte(S[I]) and $7F);

  I:=pos(#13#10, S);
  while I<>0 do
  begin                                                                // 2. translate all CR-LF pairs into single CR
    delete(S, I+1, 1);
    I:=pos(#13#10, S)
  end;

  for I:=1 to length(S) do                                             // 3. translate any remaining LFs into CRs
      if S[I]=#10 then S[I]:=#13;

  for I:=length(S) downto 1 do                                         // 4. remove superfluous control characters
      if KeepZ then begin                                                                  // (if KeepZ)
                      if not (S[I] in [#09, #13, #26, #32..#255]) then delete(S, I, 1);    // just keep TAB, CR and crtl-Z
                    end
               else begin                                                                  // (if NOT KeepZ)
                     if not (S[I] in [#09, #13, #32..#255]) then delete(S, I, 1);          // just keep TAB and CR
                    end;

  I:=pos(#32#13, S);
  while I<>0 do
  begin                                                                // 5. remove all trailing spaces at ends of lines
    delete(S, I, 1);
    I:=pos(#32#13, S)
  end;

  while (length(S)<>0) and (S[length(S)]=#32) do delete(S, length(S), 1);      // 6. remove any final trailing spaces at end
  while (length(S)<>0) and (S[length(S)]=#13) do delete(S, length(S), 1);      // 7. remove any final trailing blank lines
  if (length(S)<>0) and not (S[length(S)] in [#13, #26]) then S:=S+#13;        // 8. ensure ends in either CR or ctrl-Z
  if Pad128 then while (length(S) mod 128)<>0 do S:=S+#00                      // 9. (if pad128) pad to a multiple of 128 bytes
end;



// returns TRUE if passed a string that contains NO control characters
function IsSimpleString(S:string):boolean;
var ch:char;
     I:integer;
begin
  result:=false;
  for I:=1 to length(S) do                                             // clear bit-7 of all characters
        S[I]:=char(byte(S[I]) and $7F);

  for ch:=#1 to #31 do if pos(ch, S)<>0 then exit;                     // ignore any #0, else if any control characters found bail out
  result:=true
end;



procedure WaitFor_VK_RETURN_IsUp;
begin
//writeln(GetKeyState(VK_RETURN));
//if GetKeyState(VK_RETURN)<0 then write('KEYBD ')
//                            else write('mouse ');

  repeat Application.ProcessMessages until GetKeyState(VK_RETURN)>=0;
end;



(*
// obtain dimensions of working area of a maximized form
function GetMaximizedDimensions(var X,Y:integer):boolean;
var TestForm:TForm;
      APoint:TPoint;
           I:integer;
begin
  TestForm:=TForm.Create(nil);                                         // create test form objact
  TestForm.SetBounds(0,0,128,64);                                      // 128 pixels wide, 64 pixels high
  TestForm.AlphaBlend:=true;                                           // allow alpha blending
  TestForm.AlphaBlendValue:=0;                                         // make completely transparent
  TestForm.WindowState:=wsMaximized;                                   // maximize
  TestForm.ShowInTaskBar:=stNever;                                     // ensure form ion does NOT flash up on taskbar
  TestForm.Show;                                                       // show (invisible) form

  I:=20;                                                               // max 20 loops at 50ms each = 1000ms
  repeat
    Application.ProcessMessages;
    sleep(50);
    X:=TestForm.Width;                                                 // grab width
    Y:=TestForm.Height;                                                // grab height
//  writeln(X, ' x ', Y);
    dec(I)
  until (I=0) or ((X<>128) and (Y<>64));                               // keep looping until size has maximized, or timeout
  result:=(I<>0);                                                      // fail if we timed out

  FreeAndNil(TestForm);                                                // dispose of test form

  APoint.X:=Form1.Left;
  APoint.Y:=Form1.Top;
  I:=-Form1.ScreenToClient(APoint).X;                                  // find left border width, change sign as this returns a -ve number
  dec(X, 2*I);                                                         // remove width of left and right borders (assumes they are equal)
  dec(Y, I)                                                            // ##### assume bottom border is same width as side borders ####### <<<<<<<<<< this may be WRONG <<<<<<<<<<
end;                                                                   // ################################################################ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*)





////////////////////////////////////////////////////////////////////////////////
// Timer event handlers (x3)
//
// Timer1: 15mS nominal tick rate (may over-run up to 30ms or so)
//         flash cursor: 500mS on, 500mS off
//         update status bar and cursor location
//         [handle break signalling to 1455 firmware - windows only]
//         process Rx ring buffer to screen (max 30mS total runtime)
// Timer3: 300ms, paste ticker, interval changes to 15ms while pasting
//         also used for XMODEM transfers, via block of 'hijack' code
// Timer4: 300ms, USB connection check, also error message popup handler
//
// note: Timer1 may stomp all over the other timers if
//       it needs to process large quantities of data
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.Timer1Timer(Sender: TObject);
const startup:boolean=true;                                            // flag indicates starting up, cleared after window has faded in
      holdoff:integer=-90;                                             // holdoff time (90ms) before starting window fade-in
       cmdstr:string[31]='';                                           // command string, used to detect an XModem transfer request
        flag1:integer=0;                                               // 0,1,2,3 ring counter, incremented every 250ms
        flag2:integer=0;                                               // value of flag1 saved from last time round
        flag4:integer=-1;                                              // vlaue of CONNECTED from last time round
         tock:boolean=false;
//       mark:int64=0;                                                 // time at (near) start of ISR. used to calculate lost ISRs
//        UDC:integer=0;                                               // up/down counter, used for defining threshold for skipping
var mark, I64:int64;
     BusyFlag:boolean;
         LEDs:{$IFDEF WINDOWS}dword{$ELSE}cardinal{$ENDIF};
         I, J:integer;
         S, T:string;
           ch:char;
begin
{
// ******** handle LCL swamping, which will result in both (a) missed timer interrupts, and, (b) the LCL inserting 'catchup' interrupts
//I64:=mark;
  if timesince(mark)<5  then exit;                                     // skip any 'catchup' interrupts that the LCL throws at us
  if timesince(mark)<20 then UDC:=max(0, UDC-1)                        // we are within a few ms of the set time interval (15ms)
                        else UDC:=UDC+3;                               // we are substantially over  "   "   "      "     ( "  )
  mark:=GetTickCount64;
  if UDC>20 then
  begin                                                                // have exceeded limit for over-runs
//  writeln(timesince(I64), #09, 'SKIPPING');
    UDC:=10;                                                           // 10 --> once kicked in, skips every 5th or so time through
    exit                                                               // ... this is sufficient to allow dialogs to still function
  end; // else writeln(timesince(I64));
}

// the next 2 lines replace the above block of code. instead of measuring to see if Timer1 is running late (ie, not every 15ms or so),
// we just use a timestamp set on every call to application idle. if there are no idle calls for more that 100ms, we know that we need
// to start skipping until an idle call happens. this seems to work very well, and is much simpler than the above.
// WARNING: idle calls seem to STOP if a dialog pops up a question. ie, TSaveDialog asks if you want to overwrite an existing file.
// to get around this (bug?) we make sure we only skip every 2nd time through using a tick-tock boolean flag.

  tock:=not tock;
  if (timesince(TS10)>100) and tock then exit;
  mark:=GetTickCount64;

  // ******** run-at-startup-only, handles window fade-in **********************
  if startup then                                                      // startup with AlphaBlend=true, slow fade in after holdoff
  begin
    if holdoff<0 then inc(holdoff, Timer1.Interval)
                 else AlphaBlendValue:=min(AlphaBlendValue+17, 255);
    if AlphaBlendValue=255 then
    begin
      AlphaBlend:=false;                                               // at 100% visibility turn off AlphaBlend
      startup:=false                                                   // set end of startup flag, never end up here again
    end
  end;

// ******** get status of serial I/O thread ************************************
  BusyFlag:=(timesince(TS8)>300);                                      // 300ms since last activity from serial thread

// ******** set CURSOR COLOUR (red/green) based on shift state *****************
  if (GetKeyState(VK_SHIFT)<0) xor
     (GetKeyState(VK_CAPITAL)=0) then begin
                                        if VTcursor.Color<>clRed then
                                        begin
                                          VTcursor.Color:=clRed;
                                          VTcursor.Font.Color:=VTcursor.Color
                                        end
                                      end
                                 else begin
                                        if VTcursor.Color<>clLime then
                                        begin
                                          VTcursor.Color:=clLime;
                                          VTcursor.Font.Color:=VTcursor.Color
                                        end
                                      end;

// ******** FLASH CURSOR: 500ms on, 500ms off **********************************
// ******** also: change mouse cursor to hourglass if BusyFlag is set **********
// ********       flash 'ONLINE' indicator green/yellow if paused **************
  flag1:=((GetTickCount64 div 250) mod 4);
  if (flag1<>flag2) or XYnew then                                      // enter every 250ms, or if cursor has moved
  begin
    VTcursor.Visible:=((flag1<2) or XYnew)                             // first 500mS of 1000ms interval OR cursor has moved
        and CursorVis                                                  // AND is not turned off
        and (PasteBuffer.index=0);                                     // disable cursor while pasting
    XYnew:=false;                                                      // clear cursor movement flag
{$IFDEF LINUX}
    if flag1<>flag2 then tcFlush(StdInputHandle, TCIFLUSH);            // LINUX: every 250ms flush the console's keyboard buffer
{$ENDIF}
    flag2:=flag1;                                                      // save current value of flag1, so we can compare it next time round
    if BusyFlag or XMload or XMsave then Panel1.Cursor:=crHourGlass
                                    else Panel1.Cursor:=crDefault;
    if ScrollLCK then if odd(flag1) then Label5.Color:=clLime
                                    else Label5.Color:=clYellow
                 else Label5.Color:=clLime                             // or clYellow if network connection open
  end;
(*
// ******** update cursor position *********************************************                              (we should probably look at moving this down to near the end)
  I:=cellH*(min(max(1, Ypos), ROWS)-1);                                                                       ////////////////////////////////////////////////////////////
  if VTcursor.Top<>I then VTcursor.Top:=I;
  I:=cellW* (min(max(1, Xpos), COLS)-1);
  if VTcursor.Left<>I then VTcursor.Left:=I;
*)
// ******** UPDATE WINDOW CAPTION and TASKBAR TEXT *****************************
  if CONNECTED<>flag4 then                                             // only update if connection status has changed
  begin
    case CONNECTED of 0:begin                                          // now disconnected
                          Form1.Caption:=BuildName+'   '+BuildDate;
                          Application.Title:='offline'
                        end;
                      2:begin                                          // now connected (serial)
                          Form1.Caption:=CommName+':'+IntToStr(CommRate)+'   '+
                                         BuildName+'   '+BuildDate;
                          Application.Title:=CommName+':'+IntToStr(CommRate)
//                        Label5.Color:=clLime
                        end;
                      4:begin                                          // now connected (network)                      // #################### MISSING ####################
                          (*
                          Form1.Caption:=ClientSocket1.Host+':'+
                                      IntToStr(ClientSocket1.Port)+
                                      '   '+BuildName+
                                      '   '+BuildDate);
                          Application.Title:=ClientSocket1.Host+':'+
                                             IntToStr(ClientSocket1.Port);
                          Label5.Color:=clYellow
                          *)
                        end
    end;  { of case }
    flag4:=CONNECTED                                                   // save value of CONNECTED so we can compare it next time round
  end;

// ******** UPDATE STATUS BAR: Label1 - Rx char, row, col, Tx key **************
  S:=Format('%.2x row=%.2d col=%.3d key=%.2x',                         // expanded col=000 to allow for more than 99 columns
            [ord(lastC), Ypos, Xpos, 99, ord(lastK)]);                 // or could use min(Xpos, 99) to limit col= to 00..99
  if RightStr(S,2)='FF' then S:=LeftStr(S, length(S)-2)+'\n';          // replace 'key=FF' with 'key=\n' (cr+lf)
  if Label1.Caption<>S then Label1.Caption:=S;

// ******** Label2 - Rx timer **************************************************
  if BusyFlag then I64:=timesince(TS8)                                 // time since last serial I/O thread loop
              else I64:=timesince(TS1);                                // time since last character received
  if I64<60000   then begin
                        S:=Format('%.5d', [I64]);
                        S:=copy(S,1,2)+'.'+S[3]+'s'
                      end else
  if I64<3600000 then begin
                        S:=Format('%.2d%.5d', [I64 div 60000, I64 mod 60000]);
                        S:=copy(S,1,2)+':'+copy(S,3,2)
                      end else
                      S:=' >1h ';
(*
  S:=Format('%.10d', [I64]);
  if I64<1000  then S:=copy(S,8,2)+'0ms' else
  if I64<60999 then S:=copy(S,6,2)+'.'+S[8]+'s' else
                    S:='>1min';
*)
  if Label2.Caption<>S then Label2.Caption:=S;
  if BusyFlag then if RxBusy then begin if Label2.Color<>clYellow then Label2.Color:=clYellow end
                             else begin if Label2.Color<>clLime then Label2.Color:=clLime end
              else if Label2.Color<>clNone then Label2.Color:=clNone;

// ******** Label3 - Tx timer **************************************************
  if BusyFlag then I64:=timesince(TS8)                                 // time since last serial I/O thread loop
              else I64:=timesince(TS2);                                // time since last character transmitted
  if I64<60000   then begin
                        S:=Format('%.5d', [I64]);
                        S:=copy(S,1,2)+'.'+S[3]+'s'
                      end else
  if I64<3600000 then begin
                        S:=Format('%.2d%.5d', [I64 div 60000, I64 mod 60000]);
                        S:=copy(S,1,2)+':'+copy(S,3,2)
                      end else
                      S:=' >1h ';
(*
  S:=Format('%.10d', [I64]);
  if I64<1000  then S:=copy(S,8,2)+'0ms' else
  if I64<60999 then S:=copy(S,6,2)+'.'+S[8]+'s' else
                    S:='>1min';
*)
  if Label3.Caption<>S then Label3.Caption:=S;
  if BusyFlag then if TxBusy then begin if Label3.Color<>clYellow then Label3.Color:=clYellow end
                             else begin if Label3.Color<>clLime then Label3.Color:=clLime end
              else if Label3.Color<>clNone then Label3.Color:=clNone;

// ******** Label4 - RxBuffer (ring buffer) usage ******************************
  I:=RxBuffer.head-RxBuffer.tail;
  if I<0 then I:=I+sizeof(RxBuffer.data);
  I:=min((I*100) div sizeof(RxBuffer.data), 99);

  if I>98 then SKIPPRINT:=true;
  if I<95 then SKIPPRINT:=false;

  S:=Format('%.2d%%', [I]);                                            // %age of (256k) Rx ring buffer used
  if Label4.Caption<>S then
  begin
    Label4.Caption:=S;
    if I<10 then Label4.Color:=clGray else
    if I<40 then Label4.Color:=clAqua else
    if I<70 then Label4.Color:=clYellow
            else Label4.Color:=clRed
  end;

// ******** Label7 - characters remaining in paste buffer **********************
  if PasteBuffer.index<>0 then S:=Format('[%.6d]', [min(max(0, PasteBuffer.count-PasteBuffer.index+1), 999999)])
                          else S:='000000';
  if Label7.Caption<>S then
  begin
    Label7.Caption:=S;
    if timesince(TS3)>500 then Label7.Color:=clLime
                          else Label7.Color:=clAqua
  end;

// ******** Label8 - serial status lights **************************************
  if CONNECTED<>2 then Label8.Caption:='## lamp test ##' else
  try
{$IFDEF WINDOWS}
    GetCommModemStatus(SerialHandle,@LEDs);

    if (LEDs and   $0001  )<>0 then S:=  'DTR '    // $001     (just happens to work)
                               else S:=  'dtr ';
    if (LEDs and   $0002  )<>0 then S:=S+'RTS '    // $002     (just happens to work)
                               else S:=S+'rts ';
    if (LEDs and MS_CTS_ON)<>0 then S:=S+'CTS '    // $010
                               else S:=S+'cts ';
    if (LEDs and MS_DSR_ON)<>0 then S:=S+'DSR'     // $020
                               else S:=S+'dsr';
{$ELSE}
    FpIOCtl(SerialHandle, TIOCMGET, @LEDs);
    if (LEDs and TIOCM_DTR)<>0 then S:=  'DTR '    // $002
                               else S:=  'dtr ';
    if (LEDs and TIOCM_RTS)<>0 then S:=S+'RTS '    // $004
                               else S:=S+'rts ';
    if (LEDs and TIOCM_CTS)<>0 then S:=S+'CTS '    // $020
                               else S:=S+'cts ';
    if (LEDs and TIOCM_DSR)<>0 then S:=S+'DSR'     // $100
                               else S:=S+'dsr';
{$ENDIF}
    if Label8.Caption<>S then Label8.Caption:=S
  except
    Label8.Caption:='--- --- --- ---'
  end;

// ******** visibility of Label2 to Label8 *************************************
  Label2.Visible:=(CONNECTED<>0) or BusyFlag or LABELTEST;             // hide Rx timer if not connected (unless displaying thread time)
  Label3.Visible:=(CONNECTED<>0) or BusyFlag or LABELTEST;             // hide Tx timer if not connected (unless displaying thread time)
  Label4.Visible:=(CONNECTED<>0) or LABELTEST;                         // hide buffer %age if not connected
  Label5.Visible:=(CONNECTED<>0) or LABELTEST;                         // hide 'online' indicator if not connected
  Label6.Visible:=LOGTOFILE or LABELTEST;                              // hide 'logging' indicator if not logging
  Label7.Visible:=(PasteBuffer.index<>0) or LABELTEST;                 // hide pasting counter if paste buffer is empty
  Label8.Visible:=(CONNECTED<>0) or LABELTEST;                         // hide serial status indicators if not connected

// ******** hide "BELL volume" panel after 2 seconds ***************************
  if Panel2.Tag<>0 then
  begin
    Panel2.Tag:=max(0, Panel2.Tag-Timer1.Interval);
    if Panel2.Tag=0 then begin
                           Panel2.Hide;
                           Panel2.Left:=0;
                           Panel2.Top:=0
                         end;
  end;

// ******** hide or show 'NO KEYBOARD' graphic as required *********************
  if flagFOCUS and not flagPOPUP then begin                            // accepting keyboard input
                                        If Image3.Visible then         // push to left and hide
                                        begin
                                          Image3.Hide;
                                          Image3.Left:=0
//                                        writeln('keyboard input ENABLED')
                                        end
                                      end
                                 else begin                            // keyboard input DISABLED
                                        if not Image3.Visible then     // push to right and show
                                        begin
                                          Image3.Left:=Image1.Width-Image3.Width;
                                          Image3.Show
//                                        writeln('keyboard input suspended')
                                        end
                                      end;

// ******** HANDLE BREAK (alt-B) SIGNALLING :SetCommBreak / ClearCommBreak *****                   // for Lazarus/LINUX, this is done with tcSendBreak(handle, 0)
{$IFDEF WINDOWS}
  if BreakCounter<>-1 then                                             // BreakCounter is active
  begin
    if (BreakCounter=0) and (CONNECTED=2) then
    try SetCommBreak(SerialHandle) except end;                         // set break
    Inc(BreakCounter, Timer1.Interval);

    if BreakCounter>200 then                                           // then after 200mS
    begin
      if CONNECTED=2 then
      try ClearCommBreak(SerialHandle) except end;                     // reset break
      BreakCounter:=-1                                                 // set BreakCounter to inactive value (-1)
    end
  end;
{$ENDIF}


// ******** stage 1 of XMODEM trigger code *************************************
  if XMcounter<>0 then begin
                         XMcounter:=max(0, XMcounter-Timer1.Interval); // F11 or F12 has been pressed, decrement counter towards 0
                         if XMcounter=0 then cmdstr:=''                // clear cmdstr when counter reaches zero - no match detected
                       end;                                            // (a 250ms window of opportunity has been allowed for)

// ******** process 'cursor to top of screen' keyboard command *****************
  if ScrollTOS then begin
                      if (Ypos>1) then
                      begin
                        areascroll(1, 1, COLS, ROWS, 1);
                        dec(Ypos);
                        XYnew:=true
                      end;
                      ScrollTOS:=(Ypos>1) and (timesince(TS9)<1000)    // gives up after 1000ms
                    end;

// ******** process characters to the screen, inc GFX and ESC sequences ********
  if not (ScrollLCK or XMload or XMsave) then                          // only proceed if ScrollLCK flag is not set, and no XModem transfer is active
  while (timesince(mark)<30) and (RxBuffer.head<>RxBuffer.tail) do     // drop out after 30ms maximum since start of Timer1 ISR
  begin                                                                // (only ever more than a few ms if the LCL is being swamped)
    ch:=RxBuffer.data[RxBuffer.tail];
    RxBuffer.tail:=(RxBuffer.tail+1) mod sizeof(RxBuffer.data);
(* #############################################################################
  alternatively, we could replace the above 4 lines with:

  while (timesince(mark)<30) and ReadSerialQueue(ch, 0) do
  begin
    ...
############################################################################# *)
    if ch=#05 then begin                                               // ENQ -> ACK, this NEVER gets processed through VT100 or GFX engines
                     if PasteBuffer.index=0 then                       // ignore ENQ during pasting
                     case CONNECTED of 2:QueueSerialWrite(#06);        // serial write ACK
                                       4:;  // WriteSocket(#06)                                                        // #################### MISSING ####################
                     end  { of case }
                   end
              else begin
                     S:=VT100engine(ch);                               // first process character into/throught the VT100 engine

                     for I:=1 to length(S) do                          // for everything that comes out the other end...
                     begin                                             // (may be nothing, one, or a string of characters)
                       T:=GFXengine(S[I]);                             // ... process through the GFX engine

                       for J:=1 to length(T) do emit(T[J])             // lastly print out what remains as normal text
                     end
                   end;

//         (stage 2 of XMODEM trigger code)
    if XMcounter<>0 then begin
                           if ch in [#10, #13, #32..#126] then
                           begin
                             if length(cmdstr)>30 then delete(cmdstr, 1, 1);
                             cmdstr:=cmdstr+upcase(ch)                 // holds last 30 characters received
                           end;

                           if pos('XMODEM RECEIVE'+#13#10, cmdstr)<>0 then XMload:=true;       // trigger for XMODEM load
                           if pos('XMODEM SEND'   +#13#10, cmdstr)<>0 then XMsave:=true;       // trigger for XMODEM save

                           XMinit:=XMload or XMsave;                   // signal to initiate an XModem (load or save) transfer
                           if XMinit then
                           begin
                             cmdstr:='';                               // be sure to clear string to prevent double-calls
                             break                                     // immediately drop out of loop
                           end                                         //                           |
                         end                                           //                           |
  end;                                                                 //   <-----------------------+

// ******** update cursor position (the very last thing we do here) ************
  I:=cellH*(min(max(1, Ypos), ROWS)-1);
  if VTcursor.Top<>I then VTcursor.Top:=I;
  I:=cellW* (min(max(1, Xpos), COLS)-1);
  if VTcursor.Left<>I then VTcursor.Left:=I

////////////////////////////////////////////////////////////////
//  the following line ensures that Panel1 always has focus   //
//  when being interacted, and hence that mouse wheel events  //
//  are not disrupted. exceptions are:                        //
//  1. when command window is being interacted with,          //
//  2. the select and copy window (Memo1) is displayed,       //
//  3. the application has not got focus (keyboard input)     //
////////////////////////////////////////////////////////////////
//if not Memo1.Visible then Panel1.SetFocus
{
  if ACTIVATED and not (Memo1.Visible or                               // not text buffer visible (for copying text)
                      Panel1.Focused)                                  // not panel1 is focused
                         then Panel1.SetFocus                          // push focus to panel1         // with Lazarus, this can cause the application to
}                                                                                                      // exhibit an undesirable 'stay on top' behaviour
end;



(*
// process data from ringbuffer to screen
procedure TForm1.Timer2Timer(Sender: TObject);                         // screen ticker                                 ////////////////
var I1, I2:integer;                                                    // 45ms = approx 1/20th sec.                    XXX now 15ms XXX
    S1, S2:str255;                                                     // falls through after 30ms                    ////////////////
      mark:int64;
        ch:char;
//const N:int64=0;
begin
//  writeln('':16, GetTickCount64-N);
//  N:=GetTickCount64;
  mark:=GetTickCount64;

  if SkipCount>0 then dec(SkipCount, Timer2.Interval) else             // brief pause while any dialogs are popped up
  begin                                                                // (this is largely to keep Puppy Linux happy)

//  if Application.ModalLevel>0 then SkipCount:=Timer2.Interval*10;    // skip 10/11 of the time when a modal window is visible - kludge to stop TFontDialog misbehaving

    if ScrollLCK then begin
                        if ((mark mod 500)<250) then begin if Label5.Color<>clLime   then Label5.Color:=clLime   end
                                                 else begin if Label5.Color<>clYellow then Label5.Color:=clYellow end;
                        exit;
                      end
                 else if Label5.Color<>clLime then Label5.Color:=clLime;

    if ScrollTOS then begin
                        if (Ypos>1) then
                        begin
                          scroll(1, 1, COLS, ROWS, 1);
                          dec(Ypos);
                          XYnew:=true
                        end;
                        ScrollTOS:=(Ypos>1);
                        exit
                      end;
                                                                                                                        ////////////////
    while (timesince(mark)<10) and (RxBuffer.head<>RxBuffer.tail) do   // drop out after 30ms maximum                  XXX now 10ms XXX
    begin                                                                                                             ////////////////

      ch:=RxBuffer.data[RxBuffer.tail];
      RxBuffer.tail:=(RxBuffer.tail+1) mod sizeof(RxBuffer.data);

      if ch=#05 then begin                                             // ENQ -> ACK, this NEVER gets processed through VT100 or GFX engines
                       if PasteBuffer.index=0 then                     // ignore ENQ during pasting
                       case CONNECTED of 2:QueueSerialWrite(#06);      // serial write ACK
                                         4:;  // WriteSocket(#06)                                                        // #################### MISSING ####################
                       end  { of case }
                     end
                else begin
                       S1:=VT100engine(ch);                            // first process character into/throught the VT100 engine

                       for I1:=1 to length(S1) do                      // for everything that comes out the other end...
                       begin                                           // (may be nothing, one, or a string of characters)
                         S2:=GFXengine(S1[I1]);                        // ... process through the GFX engine

                         for I2:=1 to length(S2) do emit(S2[I2])       // lastly print out what remains as normal text
                       end
                     end
    end
  end
end;  *)



// handle paste operations, and XModem file transfers
procedure TForm1.Timer3Timer(Sender: TObject);                         // paste ticker (variable)
var block, checksum:byte;
        timeout, OK:boolean;
                 SL:TStringList;
                 TF:text;
                 ch:char;
                  I:integer;
                  S:str255;
                  T:string;
               mark:int64;
             Tblock:integer;                                           // Xmodem BLOCK timeout = Tlong + (transmission time * 3)

const Tshort=300;                                                      // short XModem timeout
       Tlong=3000;                                                     // long XModem timeout
begin
////////////////////////////////////////////////////////////////////////////////
// we're going to hijack this event handler, as required, to perform XModem   //
// transfers. since pasting isn't required while XModem is in operation, we   //
// will just sit here in a 'tight loop' carrying out the transfer. all other  //
// timers should keep on running happily without any issues (BUT THEY DO NOT) //
// and so the rest of the interface should still appear to be functioning.    //
//                                                                            //
//         xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         //
//         xxxxxxxx FAILS: while running the LCL freezes up, xxxxxxxx         //
//         xxxxxxxx adding Application.ProcessMessages fixes xxxxxxxx         //
//         xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

  if XMinit then                                                       // common code (XMload and XMsave)
  begin
    Timer3.Enabled:=false;                                             // ensures we won't be interrupted
    XMinit:=false;                                                     // makes doubly sure of the above
    CCflag:=false;                                                     // ctrl-C hasn't been pressed
    Tblock:=Tlong + ((131 * 10  * 3) div CommRate);                    // 131 bytes per block, 10 bits per bytes(8n1), 200% (3x) overhead
                                                                       // = 16.1 seconds at 300 baud, 3.41s at 9600 baud, 3.10s at 38400 baud

////////////////////////////////////////////////////////////////////////////////
// XMODEM RECEIVE (load from file on host)                                    //
////////////////////////////////////////////////////////////////////////////////
    if XMload then
    begin
      RxBuffer.tail:=RxBuffer.head;                                    // drain serial Rx buffer
      QueueSerialWrite(#24);                                           // CAN (cancel transfer)
      timeout:=not WaitSerialQueue(#06, Tlong);                        // wait for ACK response

// LOAD TEXT FROM FILE /////////////////////////////////////////////////////////
      if not timeout and OpenDialog2.Execute then                      // get name of file to upload
      begin
        SL:=TStringlist.Create;
        try
          SL.LoadFromFile(OpenDialog2.Filename);                       // grab content into a string list
          T:=SL.Text                                                   // convert to a single string
        except
          T:='';
          ShowMessage(#13+pL+'Exception reading from file '+OpenDialog2.Filename+pR+#13)
        end;
        SL.Free;
        CleanUpString(T, false, true);                                 // clean up string, no trailing ctrl-Z, pad to 128 byte boundary
// END (LOAD TEXT FROM FILE) ///////////////////////////////////////////////////

// DO XMODEM TRANSFER //////////////////////////////////////////////////////////
        if length(T)<>0 then
        begin
          RxBuffer.tail:=RxBuffer.head;                                // drain serial Rx buffer
          QueueSerialWrite('XMODEM RECEIVE'+#13);                      // restart transfer
          timeout:=not WaitSerialQueue(#21, Tlong);                    // wait for initial NAK

          block:=0;
          while (length(T)<>0) and not (timeout or CCflag) do
          begin
            inc(block);                                                // first block is #1
{###}       sprint('  '+IntToStr(length(T))+' '+#13);                  // display progress (counts down)
            S:=#01+chr(block)+chr(255-block)+copy(T, 1, 128);          // build packet (3 byte header + 128 bytes of data)
            delete(T, 1, 128);

            checksum:=0;
            for I:=1 to length(S) do checksum:=checksum+ord(S[I]);
            S:=S+chr(checksum);                                        // add checksum to end -> 132 bytes total packet size

            QueueSerialWrite(S);                                       // send packet

            timeout:=not WaitSerialQueue(#06, Tblock)                  // wait for block to transmit, and ACK response
          end;                         // was Tlong

          if not timeout then                                          // timeout error  --> send no final response
          begin
{###}       sprint('  wait...'+#13);                                   // display closing message
            if CCflag then QueueSerialWrite(#24)                       // ctrl-C pressed --> send CAN
                      else QueueSerialWrite(#04)                       // completed ok   --> send EOT
          end
        end
// END (XMODEM TRANSFER) ///////////////////////////////////////////////////////

      end;
{###} if timeout then sprint(space(16)+#13+'** timeout error **');
      XMload:=false                                                    // unblock keyboard, etc.
    end;

////////////////////////////////////////////////////////////////////////////////
// XMODEM SEND (save to file on host)                                         //
////////////////////////////////////////////////////////////////////////////////
    if XMsave then
    begin
      T:='';
      OK:=false;
      RxBuffer.tail:=RxBuffer.head;                                    // drain serial Rx buffer
      QueueSerialWrite(#21);                                           // send NAK to kick off transfer

// DO XMODEM TRANSFER //////////////////////////////////////////////////////////
      repeat
        S:='';
        timeout:=not ReadSerialQueue(ch, Tlong);
        if timeout then break;

        case ch of #01:begin                                           // #01 = valid block *******
                         timeout:=not ReadSerialQueue(ch, Tshort);     // get block number - ignore
                         if timeout then break;                        // -> failed (not OK)

                         timeout:=not ReadSerialQueue(ch, Tshort);     // 255-block number - ignore
                         if timeout then break;                        // -> failed (not OK)

                         mark:=GetTickCount64;
                         repeat
                           timeout:=not ReadSerialQueue(ch, Tshort)    // 128 bytes of data
                                    or (timesince(mark)>Tblock);       // ADDED: timeout on whole block exceeding a maximum based on baud rate
                           S:=S+ch
                         until (length(S)=128) or timeout;
                         if timeout then break;                        // -> failed (not OK)

                         timeout:=not ReadSerialQueue(ch, Tshort);     // checksum - ignore
                         if timeout then break;                        // -> failed (not OK)

                         if CCflag then begin
                                          QueueSerialWrite(#24);       // ctrl-C pressed --> send CAN
{###}                                     sprint(space(16)+#13);
                                          break;                       // -> failed (not OK)
                                        end
                                   else begin
                                          QueueSerialWrite(#06);       // block completed ok --> send ACK
                                          T:=T+S;
{###}                                     sprint('  '+IntToStr(length(T))+#13)
                                        end
                       end;
                   #04:begin                                           // #04 = no more data ******
                         QueueSerialWrite(#06);                        // donwload completed ok --> send ACK
{###}                    sprint(space(16)+#13);
                         OK:=true
                       end
        end  { of case}
      until OK;
// END (XMODEM TRANSFER) ///////////////////////////////////////////////////////

// SAVE TEXT TO FILE ///////////////////////////////////////////////////////////
      if OK then
      begin
        while (length(T)<>0) and (T[length(T)]=#00) do SetLength(T, length(T)-1);      // remove trailing NULs
        if not (RightStr(T,2)=#13#10) then T:=T+#13#10;                                // ensure ends with <cr><lf>

        if SaveDialog2.Execute then try
                                      AssignFile(TF, SaveDialog2.FileName);
                                      ReWrite(TF);
                                      Write(TF, T);
                                      CloseFile(TF)
                                  except
                                    try CloseFile(TF) except end;
                                    ShowMessage(#13+pL+'Exception writing to file '+SaveDialog2.Filename+pR+#13)
                                  end
      end;
// END (SAVE TEXT TO FILE) /////////////////////////////////////////////////////

{###} if timeout then sprint(space(16)+#13+'** timeout error **'+#13#10);
      XMsave:=false                                                    // unblock keyboard, etc.
    end;

    Timer3.Enabled:=true;                                              // enable further Timer3 events
    exit
  end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

  if (PasteBuffer.index=0) and (Timer3.Interval<>300) then Timer3.Interval:=300;       // idle at 300ms

  if PasteBuffer.index=1 then begin                                    // ######## initialize the paste operation
                                Timer3.Interval:=15;                   // ramp up to 15ms intervals
                                TS5:=GetTickCount64;                   // timestamp start of paste operation
                                TS6:=TS5;                              // finish = start: 0 seconds elapsed
                                TS3:=TS5;                              // force slow paste initially
                                CRflag:=false;                         // probably not needed
                                CRwait:=0                              // probably not needed
                              end;

  if ((PasteBuffer.index<>0) and (CONNECTED=0)) or                     // kill paste operation if suddenly disconnected
     (PasteBuffer.index>PasteBuffer.count) then begin                  // OR we have finished pasting everything in buffer
                                                  PasteBuffer.index:=0;
                                                  PasteBuffer.count:=0;
                                                  PasteBuffer.data:=''
                                                end;

  if (PasteBuffer.index<>0) and (CONNECTED in [2,4]) then              // there is something to paste, and we are connected to something
  begin
    if timesince(TS3)>1000 then                                        // *** fast paste ***  (TS3 is VT command timestamp)
    begin                                                              // ==================
//    writeln('fast paste', #9, GetTickCount64);
      if timesince(TS1)>180 then CRwait:=0;                            // 180ms timeout on seeing a handshake, TS1 is serial Rx timestamp
                                                                       // ( send <CR>  ->  receive <LF> )
      if CRwait<1 then
      begin
        S:='';
        I:=PasteBuffer.index;
        repeat
          ch:=PasteBuffer.data[I];
          if ch=#13 then inc(CRwait);

          S:=S+ch;
          inc(I)
        until (I>PasteBuffer.count) or (ch<#32) or                     // grab a line up to and incl CR or LF
              (length(S)>=80) or                                       // split lines > 80 characters long
              ((CommRate>120000) and (length(S)>=40));                 // 40 char split at higher baud rates

        case CONNECTED of 2:if QueueSerialWrite(S) then PasteBuffer.index:=I;
                          4:; // if WriteSocket(S) then PasteBuffer.index:=I                                           // #################### MISSING ####################
        end;  { of case }
        TS6:=GetTickCount64
      end
    end

    else                                                               // *** slow paste ***
    begin                                                              // ==================
//    writeln('slow paste', #9, GetTickCount64);
//    writeln(ord(CRflag), #09, TS10, #09, TS1, #09, GetTickCount64, #9, '(', Xpos, ',', Ypos, ')');

      if not (CRflag and ((timesince(TS7)<300) or (timesince(TS1)<300))) then
      begin                                                            // 300ms of continuous silence req'd after we've sent a <CR>
        ch:=PasteBuffer.data[PasteBuffer.index];
        CRflag:=(ch=#13);                                              // flag to show a CR is about to been sent
        if CRflag then TS7:=GetTickCount64;                           // timestamp (just before) of CR being sent

//      if ch<#32 then writeln(ord(ch))
//                else writeln('"', ch, '"');

        case CONNECTED of 2:if QueueSerialWrite(ch) then inc(PasteBuffer.index);
                          4:; // if WriteSocket(ch) then inc(PasteBuffer.index)                                        // #################### MISSING ####################
        end;  { of case }
        TS6:=GetTickCount64
      end
    end
  end
//writeln('active control is: ',TButton(Screen.ActiveControl).Name)
end;



// check for unplugged USB cable, display various error messages
procedure TForm1.Timer4Timer(Sender: TObject);                         // was USB health check, now more used for displaying popup error messages
var temp, info:string;                                                 // 300mS
// const N:int64=0;
begin
//  writeln('':48, GetTickCount64-N);
//  N:=GetTickCount64;
(*
  X:=Image1.ScreenToClient(Mouse.CursorPos).x;                                         // this was originally handled by timer1, but was
  Y:=Image1.ScreenToClient(Mouse.CursorPos).y;                                         // ... causing problems when called too frequently.
  Label8.Visible:=(X>=0) and (Y>=0) and (X<Image1.Width) and (Y<Image1.Height);        // ... here seems to be a safer place to do this.
*)                                                                                     // (no longer used, as Label8 now displays DTR/DSR, RTS/CTS)
{$IFNDEF WINDOWS}
  if (CONNECTED=2) and not FileExists(CommName) then
  begin
    temp:=CommName;
    CloseCommPort;
    MessageDlg('GFXterm - Error', #13+pL+'Serial device symlink missing:'+pR+#13+
                                      pL+temp+pR+#13+
                                  #13+
                                      pL+'If you are using a USB to serial bridge,'+pR+#13+
                                      pL+'please check that the USB cable has not'+pR+#13+
                                      pL+'been unplugged.'+pR+#13, mtWarning, [mbOk],0)
  end;
{$ENDIF}

  if ErrorCode<>0 then
  begin
    if SaveDialog1.FileName='' then info:='(filename not specified)'                           // used by errors 12 (6) and 13 (7)
                               else info:=SaveDialog1.FileName;

////////////////////////////////////////////////////////////////////////////////
// 21 to 25 are LINUX specific serial communications errors                   //
// - 21, 22, 23 originate in SetupCommPort                                    //
// - 24 and 25 originate in serial thread                                     //
////////////////////////////////////////////////////////////////////////////////
    case ErrorCode of 21:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Failed to open serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13;

                      22:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Failed to flush serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13;

                      23:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Failed to configure serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13;

                      24:temp:=#13+pL+'Communications Error'+pR+#13+                           // (in serial thread)
                               #13+
                                   pL+'Error reading data from serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;
//                                 pL+'[ '+SysErrorMessage(ErrorData[1])+' ]'+pR+#13;

                      25:temp:=#13+pL+'Communications Error'+pR+#13+                           // (in serial thread)
                               #13+
                                   pL+'Error writing data to serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;
//                                 pL+'[ '+SysErrorMessage(ErrorData[1])+' ]'+pR+#13;

////////////////////////////////////////////////////////////////////////////////
// 31 to 36 are win32 specific serial communications errors                   //
// - all originate in serial thread                                           //
////////////////////////////////////////////////////////////////////////////////
                      31:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Error checking Rx queue of port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                              #13+
                                   pL+'Connection has been Closed'+pR+#13;

                      32:temp:=#13+pL+'Communications Exception'+pR+#13+
                               #13+
                                   pL+'Error checking Rx queue of port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;

                      33:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Error reading data from serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;

                      34:temp:=#13+pL+'Communications Exception'+pR+#13+
                               #13+
                                   pL+'Error reading data from serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;

                      35:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Error writing data to serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;

                      36:temp:=#13+pL+'Communications Exception'+pR+#13+
                               #13+
                                   pL+'Error writing data to serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'Connection has been Closed'+pR+#13;

                      37:temp:=#13+pL+'Communications Error'+pR+#13+
                               #13+
                                   pL+'Unable to locate serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'If you are using a USB to serial bridge,'+pR+#13+
                                   pL+'please check that the USB cable has not'+pR+#13+
                                   pL+'been unplugged.'+pR+#13;

                      38:temp:=#13+pL+'Communications Exception'+pR+#13+
                               #13+
                                   pL+'Unable to locate serial port:'+pR+#13+
                                   pL+ErrorPort+pR+#13+
                               #13+
                                   pL+'If you are using a USB to serial bridge,'+pR+#13+
                                   pL+'please check that the USB cable has not'+pR+#13+
                                   pL+'been unplugged.'+pR+#13;

////////////////////////////////////////////////////////////////////////////////
                      11:begin                                                                 // 11: unable to connect due to serial I/O thread being busy
                          case ErrorData[1] of 1:temp:='Close Device';                         // fpClose   (linux), CloseHandle (win32)
                                               2:temp:='Open Device';                          // fpOpen    (linux)
                                               3:temp:='IO Control';                           // fpIOCtl   (linux)
                                               4:temp:='Flush Tx Data';                        // tcFlush   (linux)
                                               5:temp:='Set Attributes';                       // tcSetAttr (linux)
                                               6:temp:='Read Data';                            // fpRead    (linux), ReadFile    (win32)
                                               7:temp:='Write Data';                           // fpWrite   (linux), WriteFile   (win32)
                                               8:temp:='Check Rx Queue';                       // ClearCommError (win32 only)
                                               9:temp:='Check USB Status';                     // CreateFile (win32 only)
                                            else temp:='other'
                          end;  { of case }                                                    // (in fact, only 1, 6, 7, 8, or 9 can end up here)

//                        if ErrorData[2]=ErrorData[3] then info:='' else                      // neither or both (both is impossible)
                          if ErrorData[2]=ord(true)    then info:='(Serial Receive) ' else     // RxBusy
                          if ErrorData[3]=ord(true)    then info:='(Serial Transmit) ' else    // TxBusy
                          if ErrorData[4]=ord(true)    then info:='(Device Change) ' else      // CkBusy
                                                            info:='';                          // neither

                          temp:=#13+pL+'Communications System '+info+'is Busy'+pR+#13+
                                #13+
                                    pL+'Waiting on function:  '+temp+pR+#13+
//                                  pL+'thread delay = '+IntToStr(timesince(TS7) div 1000)+'s'+pR+#13+#13+
                                    pL+'Please wait 30 seconds, then try again'+pR+#13
                        end;

////////////////////////////////////////////////////////////////////////////////
                      12:temp:=#13+pL+'Failed to Append to existing Log File:'+pR+#13+         // 12 (6) and 13 (7) are errors writing to a log file
                                   pL+info {SaveDialog1.FileName} +pR+#13;

                      13:temp:=#13+pL+'Could not create new Log File:'+pR+#13+
                                   pL+info {SaveDialog1.FileName} +pR+#13;

                      14:temp:=#13+pL+'Selected font size is too small'+pR+#13;                // 14 (8) and 15 (9) are errors relating to changing font

                      15:temp:=#13+pL+'Selected font size is too large'+pR+#13+
                               #13+
                                   pL+'need: '+ IntToStr(ErrorData[1])+' x '+IntToStr(ErrorData[2])+' pixels'+pR+#13+
                                   pL+'have: '+ IntToStr(ErrorData[3])+' x '+IntToStr(ErrorData[4])+' pixels'+pR+#13;

                      16:temp:=#13+pL+'Missing Decimal Digit(s) following  "/"  Character'+pR+#13+
                               #13+
                                   pL+'Enter  //  if a single  /  character is required,'+pR+#13+
                                   pL+'otherwise there must be at least ONE decimal'+pR+#13+
                                   pL+'digit after each  /  character.  Any digits beyond'+pR+#13+
                                   pL+'the 3rd are treated as plain text.'+pR+#13

                    else temp:=#13+pL+'An unknown error ('+IntToStr(ErrorCode)+') has occured'+pR+#13+
                                   pL+'data : '+IntToStr(ErrorData[1])+', '+IntToStr(ErrorData[2])+
                                           ', '+IntToStr(ErrorData[3])+', '+IntToStr(ErrorData[4])+pR+#13
    end;  { of case }

    ErrorCode:=0;
    ErrorPort:='';
    fillchar(ErrorData, sizeof(ErrorData), #00);
    MessageDlg('GFXterm - Error', temp, mtWarning, [mbOk],0)
  end
end;






////////////////////////////////////////////////////////////////////////////////
// Keyboard and Mouse Events
// =========================
////////////////////////////////////////////////////////////////////////////////

// *** handle normal ascii keys ***
procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Memo1.Visible then exit;                  // ignore keys if select/cut text buffer visible
//windows.beep(880,50);

  lastK:=Key;
  if Key=#03 then CCflag:=true;
  if PasteBuffer.index=0 then case CONNECTED of 0:begin
                                                    if not (Key in [#00..#06, #14..#31]) then emit(Key) else   // null (#00) can never lands here, it is instead
                                                    begin                                                      // handled in TForm1.FormKeyDown as a special case
                                                      emit('<');
                                                      emit(chr(ord('0')+(ord(Key) div 10)));
                                                      emit(chr(ord('0')+(ord(Key) mod 10)));
                                                      emit('>')
                                                    end;
                                                    TS1:=GetTickCount64;
                                                    TS2:=TS1
                                                  end;
                                                2:if not (XMload or XMsave) then QueueSerialWrite(Key);
                                                4:; // WriteSocket(Key)                                                // #################### MISSING ####################
                              end  { of case }
end;



// *** handle special keys that need to be auto-repeating ***
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var S:string;
    I:integer;
begin
  TS9:=GetTickCount64;
  if Memo1.Visible then exit;                                          // ignore keys if select/cut text buffer visible
//windows.beep(880,50);

  S:='';

  if not (ssAlt in Shift) then                                         // exclude alt- versions
  case Key of VK_UP:S:=#27+'[A';
            VK_DOWN:S:=#27+'[B';
           VK_RIGHT:S:=#27+'[C';
            VK_LEFT:S:=#27+'[D';

            VK_HOME:S:=#27+'[1~';
          VK_INSERT:S:=#27+'[2~';
//        VK_DELETE:S:=#27+'[3~';                                      // VT220 sequence for the delete key
             VK_END:S:=#27+'[4~';
           VK_PRIOR:S:=#27+'[5~';
            VK_NEXT:S:=#27+'[6~';

             VK_TAB:begin S:=#09; lastK:=#09 end;                      // map tab key to chr(9)
          VK_DELETE:begin S:=#127; lastK:=#127 end;                    // VT102 delete key -> chr(127)
             VK_F10:Key:=0;                                            // WINDOWS: supress f10 popping up right-click menu (seems to do no harm under Linux)
          VK_SCROLL:Key:=0;                                            // supress scroll-lock key, so it doesn't generating ctrl-T. scroll-lock state still toggles
          VK_ESCAPE:;  // if NetworkSearching then NetworkErrorFlag:=true
                       // kludge to escape from loop while connecting                                                  // #################### MISSING ####################
  end;  { of case }

  if (ssCtrl in Shift) and (Key=VK_RETURN) then begin S:=#10; lastK:=#10 end;      // ctrl-enter -> lf (windows seems to do this mapping internally)
  if (ssAlt in Shift) and (Key=VK_RETURN) then begin S:=#13#10; lastK:=#255 end;   // alt-enter -> cr+lf, 255 codes "\n"
  if (ssCtrl in Shift) and (Key=ord('0')) then begin S:=#00; lastK:=#00 end;       // ctrl-0 -> nul
  if (ssAlt in Shift) and (Key=ord('0')) then begin S:=#00; lastK:=#00 end;        // alt-0 -> nul (depreciated, but kept in for nostalgia)

  if length(S)<>0 then Key:=0;                                         // supress handled keys from being passed on to Form1.OnKeyPress handler

  if (ssCtrl in Shift) and (Key in [ord(' ')]) then Key:=0;            // WINDOWS: without, #32 is passed to Form1.OnKeyPress, we don't want this

  if (ssAlt in Shift) and (Key in [ord('A')..ord('Z'),                 // WINDOWS: supress 'boing' sound on releasing alt-A to -Z,
                                   ord('0')..ord('9'),                 //                                             alt-0 to -9,
                           VK_LCL_COMMA, VK_LCL_POINT,                 // (seems to do no harm under Linux)       alt-< and alt->,
                                   ord(' ')]) then Key:=0;             // (seems to do no harm under Linux)             alt-space
                                                                       // note: zeroing Key does not affect Form1.OnKeyUp handler being called
  if (PasteBuffer.index=0) and (length(S)>0) then
  case CONNECTED of 0:begin
                        if S[1]=#27 then S:=' esc'+'"'+S+'" ';
                        if S[1]=#00 then S:='<00>';                    // special case of ctrl-0 or alt-0
                        for I:=1 to length(S) do emit(S[I])
                      end;
                    2:if not (XMload or XMsave) then QueueSerialWrite(S);
                    4:; // WriteSocket(S)                                                                              // #################### MISSING ####################
  end  { of case }
end;



// *** handle non-repeating keys upon release ***
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var S, T:string;
    I, N:integer;
begin
  TS9:=GetTickCount64;
  if Memo1.Visible then                                                // usually ignore keys if select/cut text buffer visible
  begin
    if (Key=13) or (Key=27) then
    begin
      Memo1.Lines.Clear;
      Memo1.Enabled:=false;                                            // probably not needed
      Memo1.Visible:=false;

      Memo1.Width:=94;                                                 // shrink down to designtime size to avoid
      Memo1.Height:=90;                                                // any problems if font size is changed

      Form1.PopupMenu:=PopupMenu1                                      // re-enable our popup menu
//    Form1.SetFocus
    end;

    exit
  end;
//windows.beep(880,50);

// ssShift	The Shift key is held down.
// ssAlt	The Alt key is held down.
// ssCtrl	The Ctrl key is held down.

  S:='';                                                               // default action: do nothing

  if Key=VK_SCROLL then ScrollLCK:=not ScrollLCK;                      // pause screen scrolling (toggles, same as alt-8 below)

// *** shifted and unshifted function keys ***
  if not (ssAlt in Shift) and not (ssCtrl in Shift) then               // disallow alt and ctrl
  if ssShift in Shift
  then case Key of VK_F3:S:=#27+'[25~';                                // shifted function keys (maps to F13 onwards)
                   VK_F4:S:=#27+'[26~';
                   VK_F5:S:=#27+'[28~';
                   VK_F6:S:=#27+'[29~';
                   VK_F7:S:=#27+'[31~';
                   VK_F8:S:=#27+'[32~';
                   VK_F9:S:=#27+'[33~';
                  VK_F10:S:=#27+'[34~'
       end  { of case }
  else case Key of VK_F1:S:=#27+'[11~';                                // unshifted function keys
                   VK_F2:S:=#27+'[12~';
                   VK_F3:S:=#27+'[13~';
                   VK_F4:S:=#27+'[14~';
                   VK_F5:S:=#27+'[15~';
                   VK_F6:S:=#27+'[17~';
                   VK_F7:S:=#27+'[18~';
                   VK_F8:S:=#27+'[19~';
                   VK_F9:S:=#27+'[20~';
                  VK_F10:S:=#27+'[21~';
                  VK_F11:begin S:=#27+'[23~'; XMcounter:=250; end;
                  VK_F12:begin S:=#27+'[24~'; XMcounter:=250; end
       end;  { of case }

// *** alt keys (letters and symbols), these are all 'special' commands ***
  if (ssAlt in Shift) and not (ssCtrl in Shift) and not (ssShift in Shift) then
  begin
    case Key of ord('B'):{$IFDEF WINDOWS}
                         BreakCounter:=0;                              // try to reset micromite
                         {$ELSE}
                         if CONNECTED=2 then try tcSendBreak(SerialHandle, 0) except end;
                         {$ENDIF}
//              ord(' '):if CONNECTED=2 then CloseCommPort                                     // linux/XFCE hooks alt-space, so we have to use ctrl-space instead   :-(
//                                      else {if LastPort<>''} then MenuItem1AClick(nil);      //     (see alternative code approx 148 lines further down)
                ord('P'):MenuItem4A1and2Click(MenuItem4A1);
                ord('C'):begin
                           GFXclear(0, 0, Gw, Gh);                     // clear graphics layer
                           Image2.Hide                                 // hide graphics layer
                         end;
                ord('D'):clear(1, 1, COLS, ROWS);                      // clear text layer
                ord('Z'):if PasteBuffer.index<>0 then
                         begin                                         // cancel paste
                           PasteBuffer.index:=0;
                           PasteBuffer.count:=0;
                           PasteBuffer.data:=''
                         end;
                ord('A'):RxBuffer.tail:=RxBuffer.head;                 // clear Rx ring buffer
                ord('L'):if LOGTOFILE then begin                       // stop logging
                                             LOGTOFILE:=false;
                                             try Flush(LogFile) except end;
                                             try CloseFile(LogFile) except end
                                           end
                                      else if SaveDialog1.FileName<>'' then
                                           try                         // resume logging
                                             Append(LogFile);
                                             LOGTOFILE:=true
                                           except
                                             LOGTOFILE:=false;
                                             try Flush(LogFile) except end;
                                             try CloseFile(LogFile) except end;
                                             ErrorCode:=12
                                           end;
                ord('R'):ResetTerminal(0);                             // reset whole terminal system
                ord('U'):CursorVis:=not CursorVis;                     // toggle cursor visible/hidden

                ord('M'):PopupMenu1.Popup(Mouse.CursorPos.x, Mouse.CursorPos.Y);

            VK_LCL_COMMA:begin                                         // the ",<" key (volume down)
                           BELLvolume:=max(BELLvolume-5, 0);
                           Panel2.Left:=(Panel1.Width-Panel2.Width) div 2;
                           Panel2.Top:=(Panel1.Height-Panel2.Height) div 2;
                           Label9.Caption:='BELL volume:'+#13+
                                           StringOfChar('|',(BELLvolume div 5))+
                                           StringOfChar('-',20-(BELLvolume div 5));
                           Panel2.Show;
                           Panel2.Tag:=3000;                           // hide after 3 seconds
                           BELL:=1
                         end;
            VK_LCL_POINT:begin                                         // the ".>" key (volume up)
                           BELLvolume:=min(BELLvolume+5, 100);
                           Panel2.Left:=(Panel1.Width-Panel2.Width) div 2;
                           Panel2.Top:=(Panel1.Height-Panel2.Height) div 2;
                           Label9.Caption:='BELL volume:'+#13+
                                           StringOfChar('|',(BELLvolume div 5))+
                                           StringOfChar('-',20-(BELLvolume div 5));
                           Panel2.Show;
                           Panel2.Tag:=3000;                           // hide after 3 seconds
                           BELL:=1
                         end
    end  { of case }
  end;
                                                                                               // *************************************************
// *** alt keys (numbers ONLY), these are all 'special' commands ***                           // **  ALSO ALLOW CTRL-ALT, AS PUPPY LINUX HOOKS  **
  if (ssAlt in Shift) and {not (ssCtrl in Shift) and} not (ssShift in Shift) then              // **  PLAIN ALT-number FOR ITS OWN DESKTOP USE   **
  begin                                                                                        // *************************************************
    case Key of
{$IFDEF WINDOWS}
                ord('1'):if CONNECTED=2 then try EscapeCommFunction(SerialHandle, SETDTR) except end;          // set DTR
                ord('2'):if CONNECTED=2 then try EscapeCommFunction(SerialHandle, CLRDTR) except end;          // clear DTR
                ord('3'):if CONNECTED=2 then try EscapeCommFunction(SerialHandle, SETRTS) except end;          // set RTS
                ord('4'):if CONNECTED=2 then try EscapeCommFunction(SerialHandle, CLRRTS) except end;          // clesr RTS
{$ELSE}
                ord('1'):if CONNECTED=2 then try I:=TIOCM_DTR; FpIOCtl(SerialHandle, TIOCMBIS, @I) except end;         // set DTR
                ord('2'):if CONNECTED=2 then try I:=TIOCM_DTR; FpIOCtl(SerialHandle, TIOCMBIC, @I) except end;         // clear DTR
                ord('3'):if CONNECTED=2 then try I:=TIOCM_RTS; FpIOCtl(SerialHandle, TIOCMBIS, @I) except end;         // set RTS
                ord('4'):if CONNECTED=2 then try I:=TIOCM_RTS; FpIOCtl(SerialHandle, TIOCMBIC, @I) except end;         // clesr RTS
{$ENDIF}
         VK_UP, ord('6'):if not ScrollLCK then ScrollTOS:=true;                // ^ = scroll prompt to top of screen (also map to alt-UP)
                ord('7'):begin
                           flagPOPUP:=true;
                           if InputQuery('Control String Input',
                                         'Enter control codes in Decimal as  /d,  /dd,  or  /ddd.  //  translates to  /'+StringOfChar(#32, 16)+#13+
                                         ' ', S) then                                    // 16 spaces is a 'fix' for windows, as width snaps to prompt's length
                           begin
                             T:='';
                             while length(S)<>0 do
                             begin
                               if S[1]<>'/' then begin                                   // starts with anything other than '/'
                                                   T:=T+S[1];
                                                   delete(S, 1, 1)
                                                 end
                                            else if pos('//',S)=1 then begin             // starts with '//' (escape sequence for '/'
                                                                         T:=T+S[1];
                                                                         delete(S, 1, 2)
                                                                       end
                                                                  else begin             // starts with '/n[n[n]]' where n are digits in ['0'..'9']
                                                                         I:=0;
                                                                         while (length(S)>(I+1)) and (S[I+2] in ['0'..'9']) do inc(I);
                                                                         I:=min(I, 3);                              // ignore digits beyond the 3rd
                                                                         if I in [1..3] then begin
                                                                                               N:=StrToInt(copy(S, 2, I));
                                                                                               T:=T+chr(N);
                                                                                               delete(S, 1, I+1)
                                                                                             end
                                                                                        else begin
                                                                                                S:='';
                                                                                                T:='';
                                                                                                ErrorCode:=16
                                                                                              end
                                                                       end
                             end;
                             S:=T
                           end;
                           flagPOPUP:=false
                         end;
                ord('8'):ScrollLCK:=not ScrollLCK                      // pause screen scrolling (toggles)
    end  { of case }                                                   // don't try using alt-0 in here, as it is now used
  end;                                                                 // to generate null in the Form1.OnKeyDown handler

// ############################################################################
// the following key actions (except ctrl-space) are for testing purposes only,
// and there is NO guarantee that any given function will remain the same, or
// be present, between different releases of GFXterm.
// ############################################################################

// *** ctrl-n (numbers only) ***
  if (ssCtrl in Shift) and not (ssAlt in Shift) and not (ssShift in Shift) then
  begin
    case Key of ord(' '):if CONNECTED=2 then CloseCommPort             // ctrl-space   toggle connection - linux/XFCE hooks alt-space, so we have to use ctrl-space instead   :-(
                                        else MenuItem1AClick(nil);
                ord('1'):begin                                         // ctrl-1   toggle double buffering
                           Panel1.DoubleBuffered:=not Panel1.DoubleBuffered;
                           if Panel1.DoubleBuffered then ShowMessage(#13+pL+'Double Buffering is ON'+pR+#13)
                                                    else ShowMessage(#13+pL+'Double Buffering is OFF'+pR+#13)
                         end;
                ord('2'):begin                                         // ctrl-2   toggle lamp test
                           LABELTEST:=not LABELTEST;
                           if LABELTEST then ShowMessage(#13+pL+'lamp test is ON'+pR+#13)
                                        else ShowMessage(#13+pL+'lamp test is OFF'+pR+#13)
                         end;
// note - under linux ctrl-3 to ctrl-7 produce control codes 0x1B-0x1F respectively, making these unavailable as special functions
//                    ~~~~~~    ~~~~~~                       ~~~~~~~~~
(*              ord('4'):begin                                         // ctrl-4                                       // #################### MISSING ####################
                           if CONNECTED=4 then CONNECTED:=0;
//                           try ClientSocket1.Close except end; // force network disconnect
//                           ShowMessage(#13+pL+'Client Socket has been CLOSED'+pR+#13)
                         end;  *)
                ord('8'):begin                                         // ctrl-8   display font, event timing, and serial port information
                           I:=max(0, TS6-TS5);
                           with VTcursor.Font do if Height<Size then S:=IntToStr(abs(Size))+' points   ('+IntToStr(abs(Height))+' px)'
                                                                else S:=IntToStr(abs(Height))+' pixels   ('+IntToStr(abs(Size))+' pt)';

                           S:=#13+pL+VTcursor.Font.Name+pR+#13+
                                  pL+S+pR+#13+
                              #13;

                           S:=S+pL+'cell :  '+IntToStr(cellW)+' wide  x  '+IntToStr(cellH)+' high'+pR+#13;

                           if CONNECTED<>0 then
                               S:=S+#13+pL+'connected for '+DHMStime(timesince(TS4))+pR+#13+
                                        pL+'last RxD was '+DHMStime(timesince(TS1))+' ago'+pR+#13+
                                        pL+'last TxD was '+DHMStime(timesince(TS2))+' ago'+pR+#13+
                                    #13+
                                        pL+'last paste took '+IntToStr(I div 1000)+'.'
                                                             +IntToStr((I mod 1000) div 100)
                                                             +' seconds'+pR+#13;
{$IFDEF WINDOWS}
                           if Server2Active then S:=S+#13+pL+'Console Server is Running'+pR+#13+
                                                          pL+'id = '+MapName+pR+#13
                                            else S:=S+#13+pL+'No Console Server Found'+pR+#13;
{$ELSE}
                           if CONNECTED=2 then S:=S+#13+pL+'TTYname :  '+TTYname(SerialHandle)+pR+#13;
{$ENDIF}
                           S:=S+#13+pL+'compiled :'+pR+#13+
                                    pL+{$I %DATE%}+ '  at  '+{$I %TIME%}+pR+#13+
                                    pL+IntToStr(sizeof(PtrUInt)*8)+'-bit mode'+pR+#13;

                           ShowMessage(S);
                           S:=''
                         end;
                ord('9'):inc(BELL)
    end  { of case }                                                   // don't try using alt-0 in here, as it is now used
  end;                                                                 // to generate null in the Form1.OnKeyDown handler

  if (PasteBuffer.index=0) and (length(S)>0) then
  case CONNECTED of 0:begin
                        if S[1]=#27 then S:=' esc'+'"'+S+'" ';
                        for I:=1 to length(S) do emit(S[I])
                      end;
                    2:if not (XMload or XMsave) then QueueSerialWrite(S);
                    4:; // WriteSocket(S)                                                                              // #################### MISSING ####################
  end  { of case }
end;






////////////////////////////
// mouse movement events ///
////////////////////////////

// *** MOUSE MOVE ***
procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Sender=VTcursor then begin
                            MouseX:=min(Xpos, COLS);                   // fix: can be =81 if at end of line
                            MouseY:=Ypos
                          end else
   if sender=Panel1  then begin
                            MouseX:=(X div cellW)+1;                   //  was: trunc((X/cellW)+1);
                            MouseY:=(Y div cellH)+1;                   //  was: trunc((Y/cellH)+1)
                          end
                     else ShowMessage(#13+pL+'WARNING: unexpected mouse move event from '+TButton(Sender).Name+pR+#13)
//write(MouseX:8, MouseY:8);
//if sender=VTcursor then writeln('*':8)
//                   else writeln
end;



// *** MOUSE DOWN ***
procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var flags:byte;
        S:string;
begin
  if (CONNECTED in [2,4]) and (MouseMode>0) and (Button=mbLeft) and (PasteBuffer.index=0) then
  begin
    if sender=VTcursor then begin
                               MouseX:=min(Xpos, COLS);                // fix: can be =81 if at end of line
                               MouseY:=Ypos
                             end else
    if sender=Panel1    then begin
                               MouseX:=(X div cellW)+1;                //  was: trunc((X/cellW)+1);
                               MouseY:=(Y div cellH)+1;                //  was: trunc((Y/cellH)+1)
                             end
                        else ShowMessage(#13+pL+'WARNING: unexpected mouse down event from '+TButton(Sender).Name+pR+#13);

//  if sender=VTcursor then writeln('mouse down', '*':14)
//                     else writeln('mouse down');

//  ShowMessage(IntToStr(MouseX)+','+IntToStr(MouseY))
    if (MouseX>=1) and (MouseX<=COLS) and (MouseY>=1) and (MouseY<=ROWS) then
    begin
      flags:=0;
      if ssShift in Shift then inc(flags, 4);
      if ssAlt in Shift then inc(flags, 8);
      if ssCtrl in Shift then inc(flags, 16);

      case MouseMode of $0001:S:=#27+'[M '+chr(32+MouseX)+chr(32+MouseY);                  // X10
                        $0101:S:=#27+'[<0;'+IntToStr(MouseX)+';'+IntToStr(MouseY)+'M';     // X10/SGR
                        $1001:S:=#27+'[32;'+IntToStr(MouseX)+';'+IntToStr(MouseY)+'M';     // X10/URXVT

                        $0010:S:=#27+'[M'+chr(32+flags)+chr(32+MouseX)+chr(32+MouseY);                     // VT200
                        $0110:S:=#27+'[<'+IntToStr(flags)+';'+IntToStr(MouseX)+';'+IntToStr(MouseY)+'M';   // VT200/SGR
                        $1010:S:=#27+'['+IntToStr(32+flags)+';'+IntToStr(MouseX)+';'+IntToStr(MouseY)+'M'  // VT200/URXVT
                     else S:=''
      end ; { of case }

      if (PasteBuffer.index=0) and (length(S)>0) then
      case CONNECTED of 2:if not (XMload or XMsave) then QueueSerialWrite(S);
                        4:; // WriteSocket(S)                                                                          // #################### MISSING ####################
      end  { of case }
    end
  end
end;



/// *** MOUSE UP ***
procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var flags:byte;
        S:string;
begin
  if (CONNECTED in [2,4]) and (MouseMode>0) and (Button=mbLeft) and (PasteBuffer.index=0) then
  begin
    if sender=VTcursor then begin
                               MouseX:=min(Xpos, COLS);                // fix: can be =81 if at end of line
                               MouseY:=Ypos
                            end else
    if sender=Panel1   then begin
                              MouseX:=(X div cellW)+1;                 //  was: trunc((X/cellW)+1);
                              MouseY:=(Y div cellH)+1;                 //  was: trunc((Y/cellH)+1)
                            end
                       else ShowMessage(#13+pL+'WARNING: unexpected mouse up event from '+TButton(Sender).Name+pR+#13);

//  if sender=VTcursor then writeln('mouse up', '*':16)
//                     else writeln('mouse up');

//  ShowMessage(IntToStr(MouseX)+','+IntToStr(MouseY))
    if (MouseX>=1) and (MouseX<=COLS) and (MouseY>=1) and (MouseY<=ROWS) then
    begin
      flags:=0;
      if ssShift in Shift then inc(flags, 4);
      if ssAlt in Shift then inc(flags, 8);
      if ssCtrl in Shift then inc(flags, 16);

      case MouseMode of $0010:S:=#27+'[M'+chr(32+3+flags)+chr(32+MouseX)+chr(32+MouseY);                       // VT200
                        $0110:S:=#27+'[<'+IntToStr(flags)+';'+IntToStr(MouseX)+';'+IntToStr(MouseY)+'m';       // VT200/SGR
                        $1010:S:=#27+'['+IntToStr(32+3+flags)+';'+IntToStr(MouseX)+';'+IntToStr(MouseY)+'M'    // VT200/URXVT
                     else S:=''
      end ; { of case }

      if (PasteBuffer.index=0) and (length(S)>0) then
      case CONNECTED of 2:if not (XMload or XMsave) then QueueSerialWrite(S);
                        4:; // WriteSocket(S)                                                                          // #################### MISSING ####################
      end  { of case }
    end
  end
end;



// *** MOUSE WHEEL ***
procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var S:string;
begin
  if Memo1.Visible then exit;                                          // ignore mouse wheel if select/cut text buffer visible

  if ssShift in Shift then begin                                               // (shifted)
                             if WheelDelta>0 then S:=#27+'[D' else             // cursor left
                             if WheelDelta<0 then S:=#27+'[C' else S:=''       // cursor right
                           end
                      else begin                                               // (unshifted)
                             if WheelDelta>0 then S:=#27+'[A' else             // cursor up
                             if WheelDelta<0 then S:=#27+'[B' else S:=''       // cursor down
                           end;

  if (PasteBuffer.index=0) and (length(S)>0) then
  case CONNECTED of 2:if not (XMload or XMsave) then QueueSerialWrite(S);
                    4:; // WriteSocket(S)                                                                              // #################### MISSING ####################
  end; { of case }
//windows.beep(880,50);
  Handled:=true
end;






////////////////////////////////
// right-click menu controls ///
////////////////////////////////

// customise menu before it pops up
procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
  MenuItem1A.Visible:=(CONNECTED=0);
  MenuItem1B.Visible:=(CONNECTED<>0);
  MenuItem2A.Visible:=not LOGTOFILE;
  MenuItem2B.Visible:=LOGTOFILE;
  MenuItem4A.Visible:=(PasteBuffer.index=0);
  MenuItem4B.Visible:=(PasteBuffer.index<>0);
  MenuItem4A1.Enabled:=(CONNECTED<>0);
  MenuItem4A2.Enabled:=(CONNECTED<>0);

  case DEBUGMODE of 0:MenuItem10A.Checked:=true;
                    1:MenuItem10B.Checked:=true;
                    2:MenuItem10C.Checked:=true
  end  { of case}
end;



// popup menu item - connect
procedure TForm1.MenuItem1AClick(Sender: TObject);
var OK:boolean;
     I:integer;
     f:TForm3;
begin
  WaitFor_VK_RETURN_IsUp;                                              // pause until the RETURN key is released

//SetupCommPort('/dev/ttyACM0', 38400, 8, 0, 1);
  I:=LCFn;
  if (timesince(TS8)>300) then begin
                                 ErrorData[1]:=I;
                                 ErrorData[2]:=ord(RxBusy);
                                 ErrorData[3]:=ord(TxBusy);
                                 ErrorData[4]:=ord(CkBusy);
                                 ErrorCode:=11
                               end
                          else

  begin
    if (LastName='') or (LastRate=0) then begin
                                            PortName:='';
                                            PortRate:=0;
                                            PortPara:='8-N-1';
                                            LastName:='';
                                            LastRate:=0;
                                            LastPara:='8-N-1'
                                          end
                                     else begin
                                            PortName:=LastName;
                                            PortRate:=LastRate;
                                            PortPara:=LastPara
                                          end;

    if (Sender=nil) and (PortName<>'') then begin
                                              OK:=true;
                                              LastName:='';            // if we can't connect, this ensures the last connection details are
                                              LastRate:=0;             // erased, so that the next 'ctrl-space' calls up the connect dialog
                                              LastPara:='8-N-1'        //                     ^^^^
                                            end
                                       else begin
                                              OK:=false;
                                              f:=TForm3.Create(nil);
                                              try
                                                flagPOPUP:=true;
                                                OK:=(f.ShowModal=mrOK)
                                              finally
                                                flagPOPUP:=false;
                                                f.Release
                                              end
                                            end;

//  writeln(PortName, ' : ', PortRate, ' , ', PortPara);
    if OK then SetupCommPort(PortName, PortRate, ord(PortPara[1])-ord('0'), pos(PortPara[3],'NOE')-1, ord(PortPara[5])-ord('0'));
{$IFDEF WINDOWS}
    if CONNECTED=2 then try EscapeCommFunction(SerialHandle, SETDTR) except end
{$ELSE}
    if CONNECTED=2 then try I:=TIOCM_DTR; FpIOCtl(SerialHandle, TIOCMBIS, @I) except end
{$ENDIF}                                                               // NASTY NASTY HACK for RPi Nano to immediately assert DTR
  end
end;



// popup menu item - disconnect
procedure TForm1.MenuItem1BClick(Sender: TObject);
begin
  case Connected of 2:CloseCommPort;
                    4:;                                                                                                // #################### MISSING ####################
  end
end;



// popup menu item - log to file
procedure TForm1.MenuItem2AClick(Sender: TObject);                     // should only be able to enter here with LOGTOFILE set false
begin
  WaitFor_VK_RETURN_IsUp;                                              // pause until the RETURN key is released

  if SaveDialog1.Execute then
  try
//  writeln('rewriting log file');                                     // SaveDialog1 has returned, should have a valid filename
    AssignFile(LogFile, SaveDialog1.Filename);
    ReWrite(LogFile);
    LOGTOFILE:=true                                                    // if we arrive here we can set LOGTOFILE true
  except
//  writeln('exception rewriting');                                    // exception - error occurred while rewriting file
    LOGTOFILE:=false;                                                  // just in case!
    try Flush(LogFile) except end;
    try CloseFile(LogFile) except end;
    ErrorCode:=13
  end
//writeln('<', SaveDialog1.Filename, '>')                              // check filename looks right
end;



// popup menu item - stop logging
procedure TForm1.MenuItem2BClick(Sender: TObject);
begin
  LOGTOFILE:=false;
  try Flush(LogFile) except end;
  try CloseFile(LogFile) except end
end;



// popup menu item - show 'select and copy' edit box
procedure TForm1.MenuItem3Click(Sender: TObject);
var X, Y:integer;
       S:string;
//    TR:TRect;
begin
  WaitFor_VK_RETURN_IsUp;                                              // pause until the RETURN key is released

  Memo1.Width:=cellW*COLS;
  Memo1.Height:=cellH*ROWS;

  Memo1.Font:=VTcursor.Font;
  Memo1.Font.Style:=[];
  Memo1.Font.Color:=clBlack;                                           // black text on a
  Memo1.Color:=clSilver;                                               // silver background

  Memo1.Lines.Clear;                                                   // ensure memo is completely blank

  for Y:=1 to ROWS do                                                  // fill in memo text
  begin
    S:=StringOfChar(' ', COLS);                                        // blank line of 80 chars
    for X:=1 to COLS do
    begin
      S[X]:=TextStore[Y, X];                                           // copy text from buffer (TextStore)
      if S[X]<' ' then S[X]:=' '                                       // turn any control chars into whitespace
    end;                                                               // ... (although there should be none)
    S:=TrimRight(S);
    Memo1.Lines.Add(S)                                                 // transfer completed line into memo
  end;

  S:=Memo1.Text;

{$IFDEF WINDOWS}
  S:=copy(S, 1, length(S)-2);                                          // remove final CR-LF from memo      (WIN32)
{$ELSE}
  S:=copy(S, 1, length(S)-1);                                          // remove final linefeed from memo   (Linux)
{$ENDIF}

  Memo1.Text:=S;

//  TR:=Memo1.ClientRect;                                              // get rid of
//  SendMessage(Memo1.Handle, EM_SETRECT, 0, integer(@TR));            // those pesky
//  Memo1.Invalidate;                                                  // margins!!!
//  above lines are win32-specific, and possibly are not needed anyway for a borderless TMemo

  Form1.PopupMenu:=nil;                                                // disable our popup menu
                                                                       // (cut/copy menu takes over)
  Memo1.Enabled:=true;
  Memo1.Visible:=true
end;



// popup menu item - paste from clipboard or file
procedure TForm1.MenuItem4A1and2Click(Sender: TObject);
var SL:TStringList;
     S:string;
begin
  if Sender=MenuItem4A2 then WaitFor_VK_RETURN_IsUp;                   // pause until the RETURN key is released

  if PasteBuffer.index<>0 then exit;

// setup for paste from clipboard
  if Sender=MenuItem4A1 then if ClipBoard.HasFormat(CF_TEXT) then
                             try
                               S:=ClipBoard.AsText;
                             except
                               S:=''
//                             ShowMessage('ClipBoard exception')
                             end;

// setup for paste from text file
  if Sender=MenuItem4A2 then if OpenDialog1.Execute then
                             begin
                               SL:=TStringlist.Create;
                               try
                                 SL.LoadFromFile(OpenDialog1.Filename);
                                 S:=SL.Text
                               except
                                 S:=''
//                               ShowMessage('LoadFromFile exception')
                               end;
                               SL.Free
                             end;

// common code for both types of paste (from clipboard and from text file)

  if not IsSimpleString(S) then CleanUpString(S, true, false);         // clean up string, keep any trailing ctrl-Z, no padding

{
  for I:=1 to length(S) do                                             // clear bit-7 of all characters being pasted
        S[I]:=char(byte(S[I]) and $7F);

  I:=pos(#13#10, S);
  while I<>0 do
  begin                                                                // translate all CR-LF pairs into single CR
    delete(S, I+1, 1);
    I:=pos(#13#10, S)
  end;

  for I:=1 to length(S) do                                             // translate any remaining LFs into CRs
      if S[I]=#10 then S[I]:=#13;

  for I:=length(S) downto 1 do                                         // remove any other control characters (just keeping TAB, CR and crtl-Z)
      if not (S[I] in [#9, #13, #26, #32..#255]) then delete(S, I, 1);

  I:=pos(#32#13, S);
  while I<>0 do
  begin                                                                // remove all trailing spaces at ends of lines
    delete(S, I, 1);
    I:=pos(#32#13, S)
  end;

  while (length(S)<>0) and (S[length(S)]=#32) do delete(S, length(S), 1);
                                                                       // remove final trailing spaces at end of S
(*
  for I:=1 to length(S) do                                             // translate all CRs into LFs as
      if S[I]=#13 then S[I]:=#10;                                      // test for unix formatted files
*)
(*
  for I:=1 to length(S) do                                             // set bit-7 of all characters being pasted
      S[I]:=char(byte(S[I]) or $80);                                   // test for ignoring bit-7 set
*)
}
  if length(S)<>0 then
  begin
    PasteBuffer.data:=S;                                               // load data into string ready to be streamed
    PasteBuffer.count:=length(S);                                      // out of the comm port by a timer interrupt
    PasteBuffer.index:=1                                               // setting index to 1 kicks off paste...
  end
end;



// popup menu item - cancel pasting
procedure TForm1.MenuItem4BClick(Sender: TObject);
begin
  if PasteBuffer.index<>0 then
  begin
    PasteBuffer.index:=0;
    PasteBuffer.count:=0;
    PasteBuffer.data:=''
  end
end;



// popup menu item - select screen font and size (extremely messy, requires shutting down EVERYTHING while in operation)
procedure TForm1.MenuItem5ABClick(Sender: TObject);
var newW, newH,                                                        // width and height with new font
    maxW, maxH,                                                        // width and height when maximized
    fixW ,fixH,                                                        // fixed portion of form's width and height (window dressings)
       LBW,TBH:integer;                                                // left border width, top bar height
        APoint:TPoint;
            OK:boolean;
            f4:TForm4;
            f5:TForm5;
begin
  WaitFor_VK_RETURN_IsUp;                                              // pause until the RETURN key is released

  if Sender=MenuItem5A then f4:=TForm4.Create(nil) else
  if Sender=MenuItem5B then f5:=TForm5.Create(nil) else begin
                                                          ShowMessage('Invalid caller to MenuItem5Click');
                                                          exit
                                                        end;

  APoint.X:=Form1.Left;                                                // left edge of Form1's left border, this is OUTSIDE of Form1's working area
  APoint.Y:=Form1.Top;                                                 // top edge of Form1's title bar. again, this is OUTSIDE of Form1's working area

  LBW:=-Form1.ScreenToClient(APoint).X;                                // ScreenToClient converts to (negative) left border width, sign changed so LBW is positive
  TBH:=-Form1.ScreenToClient(APoint).Y;                                // ScreenToClient converts to (negative) title bar height, sign changed so TBH is positive

  fixW:=Form1.Width -Image1.Picture.Bitmap.Width + (LBW*2);            // fixed portion of form width, INC. L+R window borders + OVERSCAN
  fixH:=Form1.Height-Image1.Picture.Bitmap.Height + (TBH+LBW);         // fixed portion of form height, INC. T.bar + B window border + OVERSCAN + our statusbar

  maxW:=Form1.Monitor.WorkAreaRect.Width-fixW;                         // decrease width. ASSUMES Form1's right border is the same width as left border
  maxH:=Form1.Monitor.WorkAreaRect.Height-fixH;                        // decrease height. ASSUMES Form1's bottom border is the same width as left border
                                                                       // note: WorkAreaRect ***excludes*** the taskbar

  with FontInfo do
  begin                                                                // data to pass into Form4
    FamilyName:=VTcursor.Font.Name;
    CharHeight:=VTcursor.Font.Height;
    CharPoints:=VTcursor.Font.Size;

    Wo:=cellWo;                                                        // cell width offset                    \
    Ho:=cellHo;                                                        // cell height offset                    |
    Xo:=cellXo;                                                        // X offsets of character within cell    |
    Yo:=cellYo;                                                        // Y offsets of character within cell    |--- inputs to Form4
    HC:=autoXC;                                                        // automatic horizontal centre           |
    VC:=autoYC;                                                        // automatic vertical centre             |
    SZ:=slash0;                                                        // slashed zero                         /

    MW:=maxW div COLS;                                                 // maximum cell width,  maxW is the maximum width  for Image1, et al.
    MH:=maxH div ROWS                                                  // maximum cell height, maxH is the maximum height for Image1, et al.
  end;

  // data to pass into form 5
  AreaInfo.defCOLS:=defCOLS;                                           // default number of columns (initial run, RO)
  AreaInfo.defROWS:=defROWS;                                           // default number of rows (initial run, RO)
  AreaInfo.minCOLS:=minCOLS;                                           // lower column limit (pick a 'sensible' value, RO)
  AreaInfo.minROWS:=minROWS;                                           // lower row limit (pick a 'sensible' value, RO)
  AreaInfo.maxCOLS:=maxCOLS;                                           // upper column limit (dictated by TextStore dimensions, RO)
  AreaInfo.maxROWS:=maxROWS;                                           // upper row limit (dictated by TextStore dimensions, RO)
  AreaInfo.cellW:=cellW;                                               // current cell width (RO)
  AreaInfo.cellH:=cellH;                                               // current cell height (RO)
  AreaInfo.maxAW:=maxW;                                                // maximum text area width in pixels (RO)
  AreaInfo.maxAH:=maxH;                                                // maximum text area height in pixels (RO)
  AreaInfo.COLS:=COLS;                                                 // number of columns - RW, this is changed if new values will fit in text area
  AreaInfo.ROWS:=ROWS;                                                 // number of rows - RW, this is changed if new values will fit in text area

  try
    OK:=false;
    flagPOPUP:=true;
    if Sender=MenuItem5A then OK:=(f4.ShowModal=mrOK)
                         else OK:=(f5.ShowModal=mrOK)
  finally
    flagPOPUP:=false;
    if Sender=MenuItem5A then f4.Release
                         else f5.Release
  end;

  if OK then                                                           // Form4's (or Form5's) OK button was pressed, width and height less than maximums
  begin
    COLS:=AreaInfo.COLS;                                               // update value or COLS and ROWS - changed by Form5
    ROWS:=AreaInfo.ROWS;

    with FontInfo do                                                   // update various font information - changed by Form4
    begin                                                              // (incorporates any new values for COLS and ROWS)
      VTcursor.Font.Name:=FamilyName;
      if CharHeight<CharPoints then VTcursor.Font.Size:=CharPoints
                               else VTcursor.Font.Height:=CharHeight;

      cellWo:=Wo;                                                      // cell width offset                    \
      cellHo:=Ho;                                                      // cell height offset                    |
      cellXo:=Xo;                                                      // X offsets of character within cell    |
      cellYo:=Yo;                                                      // Y offsets of character within cell    |--- outputs from Form4
      autoXC:=HC;                                                      // automatic horizontal centre           |
      autoYC:=VC;                                                      // automatic vertical centre             |
      slash0:=SZ;                                                      // slashed zero                         /

//    if slash0 then CP437toUTF16['0']:=#$00d8                         // slashed zero, also #195#152          ALREADY DONE in Form4.UpdateFontSample
//              else CP437toUTF16['0']:='0';                           // default zero                         ALREADY DONE in Form4.UpdateFontSample

      if autoXC then with SCR.TextStyle do Alignment:=taCenter         // automatic horizontal centre (overrides XP)
                else with SCR.TextStyle do Alignment:=taLeftJustify;
      if autoYC then with SCR.TextStyle do Layout:=tlCenter            // automatic vertical centre (overrides YP)
                else with SCR.TextStyle do Layout:=tlTop;

      cellW:=VTcursor.Canvas.TextWidth('#') + cellWo;
      cellH:=VTcursor.Canvas.TextHeight('#') + cellHo;
      VTcursor.Width:=cellW;
      VTcursor.Height:=cellH;

      newW:=Form1.Width -Image1.Picture.Bitmap.Width +(cellW*COLS);    // new form target width, EXCLUDING L+R window borders
      newH:=Form1.Height-Image1.Picture.Bitmap.Height+(cellH*ROWS);    // new form target height, EXCLUDING title bar and bottom window border
    end;


    Timer1.Enabled:=false;                                             // pause all timers while changing font and image/window dimensions.
    Timer3.Enabled:=false;                                             // not doing so is just too complicated, with the risk of something
    Timer4.Enabled:=false;                                             // trying to draw on the screen mid-adjustment.


    Form1.Constraints.MinWidth:=0;                                     // ### ENABLE RESIZING
    Form1.Constraints.MaxWidth:=0;
    Form1.Constraints.MinHeight:=0;
    Form1.Constraints.MaxHeight:=0;
//  Application.ProcessMessages;                                       // seems we don't need this anymore

    Shape1.Width:=cellW*COLS     + (OVER*2);                           // creates a OVERSCAN border
    Shape1.Height:=cellH*ROWS    + (OVER*2);                           // around all sides of Panel1

    Image1.Picture.Bitmap.Width:=cellW*COLS;                           // set width
    Image1.Picture.Bitmap.Height:=cellH*ROWS;                          // set height
    Image1.Picture.Bitmap.Canvas.Font:=VTcursor.Font;                  // copy font details from cursor
    Image1.Picture.Bitmap.Canvas.Font.Style:=[];                       // no underline, etc.
    Image1.Width:=Image1.Picture.Bitmap.Width;                         // (just in case... needed if autosize is false)
    Image1.Height:=Image1.Picture.Bitmap.Height;                       // (just in case... needed if autosize is false)

    Image2.Picture.Bitmap.Width:=cellW*COLS;                           // set width
    Image2.Picture.Bitmap.Height:=cellH*ROWS;                          // set height
    Image2.Width:=Image2.Picture.Bitmap.Width;                         // (just in case... needed if autosize is false)
    Image2.Height:=Image2.Picture.Bitmap.Height;                       // (just in case... needed if autosize is false)

    Image3.Left:=(cellW*COLS)-Image3.Width;                            // is always visible when we get here

    Form1.Width:=newW;
    Form1.Height:=newH;
//  Form1.Left:=(Screen.Width - newW) div 2;
//  Form1.Top:=(Screen.Height - newH) div 2;

    Form1.Constraints.MinWidth:=newW;
    Form1.Constraints.MaxWidth:=newW;
    Form1.Constraints.MinHeight:=newH;
    Form1.Constraints.MaxHeight:=newH;                                 // ### DISABLE RESIZING

    Timer1.Enabled:=true;
    Timer3.Enabled:=true;
    Timer4.Enabled:=true;

    ResetTerminal(0)                                                   // was 1, but we need to reset the margins as well
  end
end;



// popup menu item - select default text colour
procedure TForm1.MenuItem6MultiClick(Sender: TObject);
var TC:integer;
begin
  if Sender=MenuItem6A then begin TC:=1; MenuItem6A.Checked:=true end else
  if Sender=MenuItem6B then begin TC:=2; MenuItem6B.Checked:=true end else
  if Sender=MenuItem6C then begin TC:=3; MenuItem6C.Checked:=true end else
  if Sender=MenuItem6D then begin TC:=4; MenuItem6D.Checked:=true end else
  if Sender=MenuItem6E then begin TC:=5; MenuItem6E.Checked:=true end else
  if Sender=MenuItem6F then begin TC:=6; MenuItem6F.Checked:=true end else
  if Sender=MenuItem6G then begin TC:=7; MenuItem6G.Checked:=true end else
  if Sender=MenuItem6H then begin TC:=8; MenuItem6H.Checked:=true end
                       else       TC:=-1;
  if TC<>-1 then
  begin
    if InvertBW then begin                                             // undo previous invert
                       PAL[0]:=$00FFFFFF-PAL[0];
                       PAL[15]:=$00FFFFFF-PAL[15];
                       Shape1.Pen.Color:=PAL[0];
                       Shape1.Brush.Color:=PAL[0];
                       InvertBW:=false
                     end;

    FGdefault:=min(TC, 7);
    FGcolour:=FGdefault;
    if TC=8 then begin                                                 // invert black and white
                   PAL[0]:=$00FFFFFF-PAL[0];                           // black -> white
                   PAL[15]:=$00FFFFFF-PAL[15];                         // white -> black
                   Shape1.Pen.Color:=PAL[0];
                   Shape1.Brush.Color:=PAL[0];
                   InvertBW:=true
                 end
  end
end;



// popup menu item - select how dim attribute is handled (8 vs 16 colour mode)
procedure TForm1.MenuItem7MultiClick(Sender: TObject);
var TD:integer;
begin
  if Sender=MenuItem7A then begin TD:=0; MenuItem7A.Checked:=true end else     // dim attribute enabled
  if Sender=MenuItem7B then begin TD:=1; MenuItem7B.Checked:=true end else     // force bright 1
  if Sender=MenuItem7C then begin TD:=2; MenuItem7C.Checked:=true end          // force bright 2
                       else       TD:=-1;
  if TD<>-1 then Dimopt:=TD
end;



// popup menu item - call up palette editor contained in Unit2
procedure TForm1.MenuItem8Click(Sender: TObject);
var f:TForm2;
    I:integer;
begin
  WaitFor_VK_RETURN_IsUp;                                              // pause until the RETURN key is released

  for I:=0 to 15 do begin
                      PaletteRO[I]:=CVT[I];                            // load 'read only' default palette
                      PaletteRW[I]:=PAL[I]                             // load working palette
                    end;
  if InvertBW then begin                                               // undo inversion of BLACK and WHITE
                     PaletteRW[0]:=$00FFFFFF-PaletteRW[0];
                     PaletteRW[15]:=$00FFFFFF-PaletteRW[15]
                   end;

  f:=TForm2.Create(nil);
  try
    flagPOPUP:=true;
    if f.ShowModal=mrOK then
    begin
      if InvertBW then begin                                           // redo inversion of BLACK and WHITE
                         PaletteRW[0]:=$00FFFFFF-PaletteRW[0];
                         PaletteRW[15]:=$00FFFFFF-PaletteRW[15]
                       end;
      for I:=0 to 15 do PAL[I]:=PaletteRW[I];                          // retrieve working palette
      Shape1.Pen.Color:=PAL[0];
      Shape1.Brush.Color:=PAL[0]
    end
  finally
    flagPOPUP:=false;
    f.Release
  end
end;



// popup menu item - clear graphics layer / text layer / Rx ring buffer
procedure TForm1.MenuItem9MultiClick(Sender: TObject);
begin
  if Sender=MenuItem9A then begin
                          GFXclear(0, 0, Gw, Gh);                      // clear graphics layer
                          Image2.Hide                                  // hide graphics layer
                        end else
  if Sender=MenuItem9B then clear(1, 1, COLS, ROWS) else               // clear text layer
  if Sender=MenuItem9C then RxBuffer.tail:=RxBuffer.head else          // clear Rx ring buffer
  if Sender=MenuItem9D then ResetTerminal(0)
end;



// popup menu item - diagnostics information
procedure TForm1.MenuItem10MultiClick(Sender: TObject);
{$IFDEF WINDOWS} const initial:boolean=true; var I:integer;{$ENDIF}
var DM:integer;
begin
  if Sender=MenuItem10A then begin DM:=0; MenuItem10A.Checked:=true end else
  if Sender=MenuItem10B then begin DM:=1; MenuItem10B.Checked:=true end else
  if Sender=MenuItem10C then begin DM:=2; MenuItem10C.Checked:=true end
                        else       DM:=-1;
  if DM<>-1 then
  begin
{$IFDEF WINDOWS}
    if DM<>0 then
    begin
      if initial then                                                  // set up shared memory
      begin
        Randomize;                                                     // create unique name:
        for I:=1 to 8 do MapName:=MapName+IntToHex(Random(256), 2);    // 16 digits (8 pairs) of random hex digits

        MapFile:=CreateFileMapping(
                   INVALID_HANDLE_VALUE,                               // use paging file
                   nil,                                                // default security
                   PAGE_READWRITE,                                     // read/write access
                   0,                                                  // maximum object size (high-order DWORD)
                   sizeof(MapPtr^),                                    // maximum object size (low-order DWORD)
                   PChar(MapName));                                    // name for mapping object
        if MapFile=0 then begin ShowMessage('Client Failure at: OpenFileMapping'); exit end;                           // should never happen

        MapPtr:=MapViewOfFile(MapFile,                                 // handle to map object
                  FILE_MAP_ALL_ACCESS,                                 // read/write permission
                  0,
                  0,
                  sizeof(MapPtr^));
        if MapPtr=nil then begin ShowMessage('Client Failure at: MapViewOfFile'); exit end;                            // should never happen

        MapPtr^.head:=0;                                               // zero here so we are absolutely sure these are valid before being used
        MapPtr^.tail:=0;                                               //                     ^^^^^^^^^^                      ^^^^^^

        TRunServerThread.Create(false);                                // start run-server thread
        initial:=false
      end;

      if not Server2Active then LaunchServer2:=true                    // set trigger for launch of server (shared memory is set up by this point)
    end;
{$ENDIF}
    DEBUGMODE:=DM
  end
end;



// popup menu item - exit application
procedure TForm1.MenuItem11Click(Sender: TObject);
begin
  WaitFor_VK_RETURN_IsUp;
  Form1.Close
end;






procedure TForm1.FormCreate(Sender: TObject);
var I:integer;
    S:string;
    T:textfile;
begin
  Form1.Caption:='GFXterm64';                                          // updated later on by Timer1
  Application.Title:='GFXterm64';                                      // updated later on by Timer1
  Application.ShowButtonGlyphs:=sbgNever;                              // ensure glyphs not shown on buttons (InputQuery is one offender)

{$IFDEF WINDOWS}
  Form1.VTcursor.Font.Name:='Terminal';                                // Default under Linux is Monospace
  Form1.VTcursor.Font.Size:=9;                                         // Default under Linux is 12pt
{$ENDIF}

  ConfigName:=GetAppConfigFile(false);                                 // uses Application.Title
//ShowMessage('config file: '+ConfigName);

// attempt to read configuration file. if this fails, set up default palette
  if not ReadConfigurationFile then for I:=0 to 15 do PAL[I]:=CVT[I];

//Application.HintHidePause:=5000;

////////////////////////////////////////////////////////////////////////////////
// the below functionality (loadable .PAL file) is rendered redundant by the
// inclusion of an internal palette editor and the saving and loading of the
// palette to/from the main configuration file at startup and exit.
////////////////////////////////////////////////////////////////////////////////
  S:=ChangeFileExt(ExpandFileName(paramstr(0)),'.pal');
  if FileExists(S) then
  try
    AssignFile(T, S);
    Reset(T);
//  ReWrite(T);                                                        // use to create sample pallette file

    for I:=0 to 15 do
    begin
//    writeln(T,'0x'+Format('%.6x',[PAL[I]]));                         // write to sample file
      ReadLn(T,S);
      if S='' then ReadLn(T,S);
      if pos(' ', S)<>0 then S:=copy(S, 1, pos(' ', S)-1);
      if pos(#08, S)<>0 then S:=copy(S, 1, pos(#08, S)-1);
      PAL[I]:=StrToInt(S)
    end;

    if InvertBW then begin                                             // invert black and white
                       PAL[0]:=$00FFFFFF-PAL[0];                       // black -> white
                       PAL[15]:=$00FFFFFF-PAL[15]                      // white -> black
                     end;

    CloseFile(T)
  except
    for I:=0 to 15 do PAL[I]:=CVT[I];
    try CloseFile(T) except end;
    ShowMessage(#13+pL+'Error reading .PAL file, using default VT palette'+pR+#13)
  end;
////////////////////////////////////////////////////////////////////////////////

  cellW:=VTcursor.Canvas.TextWidth('#') + cellWo;                      // cell width, with any offset applied
  cellH:=VTcursor.Canvas.TextHeight('#') + cellHo;                     // cell height, with any offset applied
  VTcursor.Width:=cellW;
  VTcursor.Height:=cellH;

  if slash0 then CP437toUTF16['0']:=#$00d8;                            // slashed zero, also #195#152 in UTF8

  with Image1.Picture.Bitmap.Canvas do
  begin
    if autoXC then with TextStyle do Alignment:=taCenter               // automatic horizontal centre (overrides XP)
              else with TextStyle do Alignment:=taLeftJustify;
    if autoYC then with TextStyle do Layout:=tlCenter                  // automatic vertical centre (overrides YP)
              else with TextStyle do Layout:=tlTop
  end;

//Form1.AutoSize:=true;                                                // dimensions of Form1 are LOCKED further down
  Panel1.AutoSize:=true;

//Form1.AutoScroll:=false;                                             // set in form view
//Form1.KeyPreview:=true;                                              // set in form view
//Form1.DoubleBuffered:=true;                                          // leave unset in form view, below line replaces this
  Panel1.DoubleBuffered:=true;                                         // only double-buffer Panel1 instead of whole form

////////////////////////////////////////////////////////////////////////////////
// start of code to rearrange and resize components for display
////////////////////////////////////////////////////////////////////////////////

  Bevel1.Left:=0;                                                      // used to define top of window and minimum allowed width
  Bevel1.Top:=0;
  Bevel1.Width:=640 + (OVER*2);                                        // (80 characters x 8 pixels) + OVERSCAN, 2 pixels (left margin) + 2 pixels (right margin)
  Bevel1.Height:=Label1.Canvas.TextHeight('#')+4;                      // height of text + 4 pixels - 2 above, 2 below, looks better with the extras

  for I:=0 to ComponentCount-1 do if Components[I] is TLabel then
      if (length(Components[I].Name)=6) and
         (LeftStr(Components[I].Name,5)='Label') and
         (Components[I].Name[6] in ['1'..'8']) then
  begin
{$IFDEF WINDOWS}
    TLabel(Components[I]).Font.Name:='Courier New';                                // ensure is a monospaced font under windows
{$ENDIF}
    TLabel(Components[I]).Left:=TLabel(Components[I]).Left + OVER;                 // shuffle the 8 top-bar labels OVERSCAN pixels to the right
    TLabel(Components[I]).Top:=TLabel(Components[I]).Top + 2;                      // shuffle the 8 top-bar labels 2 pixels down, so is an even gap above and below
    TLabel(Components[I]).Height:=TLabel(Components[I]).Canvas.TextHeight('#')     // this line is to get around Lazarus calculating the wrong height
  end;
{$IFDEF WINDOWS}
  Label9.Font.Name:='Courier New';                                                 // Label9 is the volume control slider
{$ENDIF}

  Shape1.Left:=0;
  Shape1.Top:=Label1.Height+4;                                         // height of text + 2 pixels above + 2 pixels below
  Shape1.Width:=cellW*COLS     + (OVER*2);                             // OVERSCAN on each side
  Shape1.Height:=cellH*ROWS    + (OVER*2);                             // OVERSCAN above and below
  Shape1.Pen.Color:=PAL[0];
  Shape1.Brush.Color:=PAL[0];

//Shape1.Pen.Width:=25;  {was WPEN}                                    // width of pen used to draw oversan -> should have WPEN >= OVER
//Shape1.Pen.JoinStyle:={pjsMiter} pjsRound;                           // rounded corners, or squared corners
// the above would give us nice rounded corners, except Win10 messes this up with a 1-pixel black border around the window

  Panel1.Left:=Shape1.Left     + OVER;                                 // OVERSCAN +2 -> centre in border (Shape1)
  Panel1.Top:=Shape1.Top       + OVER;

// create text area
  Image1.Left:=0;                                                      // horizontal position of screen grid
  Image1.Top:=0;                                                       // vertical position of screen grid
(*
  Image1.Picture.Bitmap:=TBitmap.Create;                               // create a bitmap object for text - ****** LAZARUS SEEMS TO DO THIS AUTOMATICALLY ******
*)
  Image1.Picture.Bitmap.Width:=cellW*COLS;                             // set width
  Image1.Picture.Bitmap.Height:=cellH*ROWS;                            // set height
//Image1.Picture.Bitmap.Canvas.TextFlags:=ETO_OPAQUE;                  // opaque writing of text, improves speed       *** NOT SUPPORTED BY LAZARUS ***
  Image1.Picture.Bitmap.Canvas.Font:=VTcursor.Font;                    // copy font details from cursor object
//Image1.Picture.Bitmap.Canvas.Font.Style:=[];                         // no underline, etc.                            \
//Image1.Picture.Bitmap.Canvas.Font.Color:=clWhite;                    // WHITE text by default                          |-- these are all now set in the
//Image1.Picture.Bitmap.Canvas.Brush.Color:=clBlack;                   // default brush: clBlack (for clearing screen)  /             text write routines
  Image1.Width:=Image1.Picture.Bitmap.Width;                           // (just in case... needed if autosize is false)
  Image1.Height:=Image1.Picture.Bitmap.Height;                         // (just in case... needed if autosize is false)

// create graphics area
  Image2.Left:=0;                                                      // graphics plane overlays text plane
  Image2.Top:=0;
(*
  Image2.Picture.Bitmap:=TBitmap.Create;                               // create a bitmap object for graphics - ****** LAZARUS SEEMS TO DO THIS AUTOMATICALLY ******
*)
  Image2.Picture.Bitmap.Width:=cellW*COLS;                             // set width
  Image2.Picture.Bitmap.Height:=cellH*ROWS;                            // set height
//Image2.Picture.Bitmap.Canvas.Brush.Color:=clBlack;                   // default brush: clBlack (for clearing screen)  \
//Image2.Picture.Bitmap.Canvas.Pen.Color:=clRed;                       // default pen: clRed (for drawing lines)         |-- these are set in GFXink and
//Image2.Picture.Bitmap.Canvas.Pen.Width:=1;                                                        //                  /         GFXclear, called below
  Image2.Width:=Image2.Picture.Bitmap.Width;                           // (just in case... needed if autosize is false)
  Image2.Height:=Image2.Picture.Bitmap.Height;                         // (just in case... needed if autosize is false)

// make graphics area transparent
  Image2.Transparent:=true;                                            // allow transparency (or can be set in form view)
//Image2.Picture.Bitmap.Transparent:=true;                             //         (doesn't seem to be needed with Lazarus/linux)
  Image2.Picture.Bitmap.TransparentColor:=clBlack;                     // transparent colour is black
  Image2.Picture.Bitmap.TransparentMode:=tmFixed;                      // use above setting for TC

// position 'no keyboard input' icon to top left, hidden
  Image3.Left:=0;
  Image3.Top:=0;
  Image3.Width:=Image3.Picture.Bitmap.Width;
  Image3.Height:=Image3.Picture.Bitmap.Height;
//Image3.Autosize:=true;                                               // didn't work reliably, so set size manually with above 2 lines
  Image3.Transparent:=true;
//Image3.Picture.Bitmap.Transparent:=true;                             //         (doesn't seem to be needed with Lazarus/linux)
  Image3.Picture.Bitmap.TransparentColor:=clBlack;                     // transparent colour is black
  Image3.Picture.Bitmap.TransparentMode:=tmFixed;                      // use above setting for TC
  Image3.Hide;                                                         // keep HIDDEN until required (flagFOCUS and not flagPOPUP -> hidden, checked in Timer1 handler)

// position cursor at top left of text area
  VTcursor.Top:=0;                                                     // initial cursor: row 1
  VTcursor.Left:=0;                                                    // initial cursor: column 1
  VTcursor.Font.Color:=clRed;                                          // cursor colour (FG)
  VTcursor.Color:=clRed;                                               // cursor colour (BG)

// configure text copy object
  Memo1.Left:=0;
  Memo1.Top:=0;
(*                                                                     // the following are handled
  Memo1.Width:=cellW*COLS;                                             // within right-click menu's
  Memo1.Height:=cellH*ROWS;                                            // Item3 ("select/copy text")

  Memo1.Font:=VTcursor.Font;
  Memo1.Font.Style:=[];
  Memo1.Font.Color:=clBlack;                                           // black text on
  Memo1.Color:=clSilver;                                               // a silver background

  Memo1.Hint:=' Select the text you want to copy using the mouse, '+#13+       // this text has been moved to form designer
              ' then press control-C to copy it to the clipboard. '+#13+
              ' When finished, press ENTER to exit this view. ';
*)
  Label5.Color:=clLime;                                                // green 'running' annunciator by default
  Label6.Color:=clYellow;                                              // yellow 'logging' annunciator by default
  Label7.Color:=clAqua;                                                // light blue paste annunciator by default

  Label9.Font.Size:=16;
  Panel2.Left:=0;
  Panel2.Top:=0;
//Panel2.Visible:=false;                                               // need to do this in first run of form activate

  OpenDialog1.InitialDir:=ExtractFilePath(ExpandFileName(paramstr(0)));
  SaveDialog1.InitialDir:=ExtractFilePath(ExpandFileName(paramstr(0)));
  OpenDialog2.InitialDir:=ExtractFilePath(ExpandFileName(paramstr(0)));
  SaveDialog2.InitialDir:=ExtractFilePath(ExpandFileName(paramstr(0)));

// align graphics and text layers along the Z-axis
  Memo1.Enabled:=false;                                                // *** probably not needed
  Memo1.Visible:=false;
//Memo1.SendToBack;                                                    // *** probably does nothing, upsets GDK/GTK if placed here

  Image1.Enabled:=false;                                               // ignore mouse and keyboard events
  Image2.Enabled:=false;                                               // ignore mouse and keyboard events
  Image3.Enabled:=false;                                               // ignore mouse and keyboard events

  Image1.BringToFront;                                                 // text layer ends in background
  Image2.BringToFront;                                                 // graphics layer overlays text
  Image3.BringToFront;                                                 // 'NO KEYBOARD' graphic in front, but not visible

  VTcursor.BringToFront;                                               // cursor always on top of text and graphics

// create shortcuts - for EXCLUSIVE use by graphics routines within video.inc
  SCR:=Image1.Picture.Bitmap.Canvas;                                   // shorthand for canvas object (text screen)
  GFX:=Image2.Picture.Bitmap.Canvas;                                   // shorthand for canvas object (graphics screen)

// moved back here as a test to see if locking these down early stops startup flicker when not using AlphaBlend to fade in at startup ################
  Form1.Width:=Shape1.Width;
  Form1.Height:=Shape1.Height+Shape1.Top;
  Form1.Constraints.MinWidth:=Shape1.Width;                            // these next four lines
  Form1.Constraints.MaxWidth:=Shape1.Width;                            // lock the form dimensions
  Form1.Constraints.MinHeight:=Shape1.Height+Shape1.Top;               // so the user can not
  Form1.Constraints.MaxHeight:=Shape1.Height+Shape1.Top;               // change them.

  Form1.Left:=(Form1.Monitor.WorkAreaRect.Width-Form1.Width) div 2;    // approximate centre of screen, ignores title bar height
  Form1.Top:=(Form1.Monitor.WorkAreaRect.Height-Form1.Height) div 2;   // and side border widths, but is the best we can do.

// *****************************************************************************
// in theory form layout is now complete, and form1 is positioned (more-or-less)
// in the middle of the monitor's active area. form still isn't visible, it will
// only be visible when we get to the first call to Form1's activate handler
// *****************************************************************************

  clear(1, 1, COLS, ROWS);                                             // clear text layer
  GFXink(255, 0 ,0 ,1);                                                // default GFX pen: red, 1-pixel wide
  GFXclear(0, 0, Gw, Gh);                                              // clear graphics layer, background set to black
  Image2.Hide;                                                         // graphics layer is turned off initially
  gotoxy(1,1);                                                         // home cursor

  AlphaBlendValue:=0;                                                  // start up invisible, Timer1 handler
  AlphaBlend:=true;                                                    // fades in over approximately 225ms (comment out for testing)

{$IFDEF WINDOWS}                                                       // win32: hook to detect USB plug/unplug
  PrevWndProc:=Windows.WNDPROC(SetWindowLongPtr(Self.Handle,GWL_WNDPROC,PtrUInt(@WndCallback)));
{$ENDIF}

  TSerialThread.Create(false);                                         // start serial I/O thread
  TCheckThread.Create(false)                                           // start bell thread
end;



procedure TForm1.FormDestroy(Sender: TObject);
var mark:int64;
begin
  LOGTOFILE:=false;                                            // stop any further logging
  CONNECTED:=0;                                                // stop any further serial I/O
  DEBUGMODE:=0;                                                // stop any further diagnostics output

  WriteConfigurationFile;                                      // #### write configuration file ####
  try Flush(LogFile) except end;
  try CloseFile(LogFile) except end;
  CloseCommPort;

  AlphaBlend:=true;
  repeat                                                       // approx 330ms fadeout
    mark:=GetTickCount64;
    AlphaBlendValue:=max(0, AlphaBlendValue-12);               // (255/12)*15ms = 330ms
    repeat
      Application.ProcessMessages                              // keep GUI ticking over so we can see the fadeout
    until timesince(mark)>15
  until AlphaBlendValue=0;
  sleep(100)
end;



procedure TForm1.ApplicationPropertiesActivate(Sender: TObject);
const startup:boolean=true;
// var Cw, Ch:integer;
begin
  if startup then                                              // startup things that can/should not be performed until the main form is 'live'
  begin
    startup:=false;

    Panel2.Visible:=false;                                     // can't hide until here otherwise dimensions/location will be wrong when first revealed
    Memo1.SendToBack;                                          // LINUX: generates an error if this is in form1.create, probably does nothing anyway


(*
    Cw:=Gw div COLS;
    Ch:=Gh div ROWS;

    SCR.Pen.Color:=$7F7F7F;
    SCR.Pen.Width:=5;

    sprint(#10#10#10#09+'Right-Click on mouse or press Alt-M on keyboard to activate'+#13#10+
                    #09+'command menu, then select CONNECT to open a serial port, or'+#13#10+
                    #09+'go to HELP/ABOUT to create a help file (PDF) on the Desktop' +#13#10#10#10#10);

    SCR.MoveTo((Cw div 2)+(Cw*6) , (Ch div 2)+(Ch*2));
    SCR.LineTo((Cw div 2)+(Cw*68), (Ch div 2)+(Ch*2));
    SCR.LineTo((Cw div 2)+(Cw*68), (Ch div 2)+(Ch*6));
    SCR.LineTo((Cw div 2)+(Cw*6) , (Ch div 2)+(Ch*6));
    SCR.LineTo((Cw div 2)+(Cw*6) , (Ch div 2)+(Ch*2));
*)
//  if InvertBW then SCR.Font.Color:=clBlack
//              else SCR.Font.Color:=clWhite;

//  sprint('----- Right-Click on mouse or press Alt-M on keyboard to view command menu -----'+#13#10#10);

    SCR.Font.Color:=PAL[FGcolour];
    SCR.Brush.Color:=PAL[BGColour];
    SCR.Font.Italic:=true;
    SCR.TextOut(0,VTcursor.Height,'  press Alt-M to view command menu...');
    gotoxy(1,4);


// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//  if LastName<>'' then MenuItem1AClick(nil);                 // (experimental - automatic connect)

// before calling MenuItem1AClick(nil) we should first check that the port LastName actually exists
// so that we don't get an error message immediately popping up if the port is no longer there...

// under Win32 this would be something like:
// if FileExists('\\.\'+LastName)
// under Linux this would be something like:
// if FileExists(LastName)

// notwithstanding the above checks, the experimental single line of code does actually seem to work!

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TS1:=GetTickCount64;                                       // initialize all timestamps to the startup time
    TS2:=TS1;
    TS3:=TS2;
    TS4:=TS3;
    TS5:=TS4;
    TS6:=TS5;
    TS7:=TS6;
    TS8:=TS7;
    TS9:=TS8;
    TS10:=TS9;
    Timer1.Enabled:=true;
    Timer3.Enabled:=true;
    Timer4.Enabled:=true
  end;

  flagFOCUS:=true
end;



procedure TForm1.ApplicationPropertiesDeactivate(Sender: TObject);
begin
  flagFOCUS:=false
end;



procedure TForm1.ApplicationPropertiesIdle(Sender: TObject; var Done: Boolean);
begin
  TS10:=GetTickCount64
end;



(*
procedure TForm1.FormResize(Sender: TObject);
begin
  writeln('form resized at: ', GetTickCount64);
end;

procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
  write('form state changed to :');
  if Form1.WindowState=wsFullScreen then writeln('wsFullScreen') else
  if Form1.WindowState=wsMaximized  then writeln('wsMaximized')  else
  if Form1.WindowState=wsMinimized  then writeln('wsMinimized')  else
  if Form1.WindowState=wsNormal     then writeln('wsNormal')
                                    else writeln('- unknown -')
end;

procedure TForm1.ApplicationProperties1Restore(Sender: TObject);
begin
  writeln('application restored')
end;
*)




begin
{$IFNDEF UseCThreads}
  ShowMessage('To compile and run correctly, the following:'+#09#13#13+
              '-dUseCThreads'+#13#13+
              'needs to be added under:'+#13#13+
              'Project ->'+#13+
              #09+'Project Options ->'+#13+
              #09#09+'Compiler Options ->'+#13+
              #09#09#09+'Custom Options');
  halt;
{$ENDIF}
end.

