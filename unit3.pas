unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus,
{$IFDEF WINDOWS}
  Registry,
{$ELSE}
  BaseUnix, TermIO,
{$ENDIF}
  LCLType, LCLIntf, ExtCtrls;

type

  { TForm3 }

  TForm3 = class(TForm)
    MenuItem1: TMenuItem;
      MenuItem1A: TMenuItem;
      MenuItem1B: TMenuItem;
      MenuItem1C: TMenuItem;
      MenuItem1D: TMenuItem;
    MenuItem2: TMenuItem;
      MenuItem2A: TMenuItem;
      MenuItem2B: TMenuItem;
      MenuItem2C: TMenuItem;
    MenuItem3: TMenuItem;
      MenuItem3A: TMenuItem;
      MenuItem3B: TMenuItem;
      MenuItem4: TMenuItem;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    CheckBox1: TCheckBox;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    procedure ComboBox1DropDown(Sender: TObject);
    procedure ComboBoxANYKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure Label3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItemClick(Sender: TObject);
  private

  public

  end;

var
//  Form3: TForm3;                       // not needed here - form is created by caller
    PortName:string;
    PortRate:integer;
    PortPara:string[5];

implementation

{$R *.lfm}

{ TForm3 }

const NPFstring='  - no ports found -  ';


{$IFDEF WINDOWS}

procedure PopulatePortList(var PortList:TStringList);
var Reg:TRegistry;
      I:integer;
begin
  Reg:=TRegistry.Create;
  PortList.Clear;
  with Reg do
  try
    RootKey:=HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly('hardware\devicemap\serialcomm') then
    begin
      GetValueNames(PortList);
      for I:=0 to PortList.Count-1 do
        PortList.Strings[I]:=ReadString(PortList.Strings[I]);
      if PortList.Count=0 then PortList.Add(NPFstring)
    end;
  finally
    CloseKey
  end;
  Reg.Free;
  PortList.Sort
end;


function PortExists(PortName:string):boolean;
var PortList:TStringList;
         Reg:TRegistry;
           I:integer;
begin
  Reg:=TRegistry.Create;
  PortList:=TStringList.Create;
  with Reg do
  try
    RootKey:=HKEY_LOCAL_MACHINE;
    if OpenKeyReadOnly('hardware\devicemap\serialcomm') then
    begin
      GetValueNames(PortList);
      for I:=0 to PortList.Count-1 do
        PortList.Strings[I]:=ReadString(PortList.Strings[I]);
//    if PortList.Count=0 then PortList.Add(NPFstring)
    end;
  finally
    CloseKey
  end;
  result:=(PortList.IndexOf(PortName)<>-1);
  Reg.Free;
  PortList.Free
end;

{$ELSE}

type
   TSerialStruct = packed record
          typ: cint;
          line: cint;
          port: cuint;
          irq:  cint;
          flags: cint;
          xmit_fifo_size: cint;
          custom_divisor: cint;
          baud_base: cint;
          close_delay: cushort;
          io_type: cchar;
          reserved_char:  pcchar;
          hub6: cint;
          closing_wait: cushort; // time to wait before closing
          closing_wait2: cushort; // no longer used...
          iomem_base: pcchar;
          iomem_reg_shift: cushort;
          port_high: clong; // cookie passed into ioremap
   end;


// method based on information obtained from the following two sites:
// https://www.lazarusforum.de/viewtopic.php?p=72837
// https://stackoverflow.com/questions/2530096
function CheckDevice(DeviceName:string):boolean;               // checks to see if the device named is a live
var DriverName:string;                                         // ... serial port. this is done by checking
            FD:longint;                                        // ... entries in /sys/class/tty, including the
            SS:TSerialStruct;                                  // ... presence of a link to a device driver.
            ST:stat;
begin
  Result:=false;
  ST.st_mode:=0;

  if (DeviceName<>'.') and (DeviceName<>'..') then
  if FileExists('/sys/class/tty/'+DeviceName+'/device/driver') or
     DirectoryExists('/sys/class/tty/'+DeviceName+'/device/driver') then
  if fpLstat('/sys/class/tty/'+DeviceName+'/device', ST)=0 then
  if fpS_ISLNK(ST.st_mode) then
  begin
    DriverName:=ExtractFileName(fpReadLink('/sys/class/tty/'+DeviceName+'/device/driver'));
//  writeln(DeviceName,'  :  ',DriverName);

    if DriverName<>'serial8250' then Result:=true
                                else begin
//                                     writeln('    checking serial8250 device');
                                       FD:={%H-}fpOpen('/dev/'+DeviceName, O_RDWR or O_NONBLOCK or O_NOCTTY);
                                       if FD>0 then
                                       try
                                         if fpIOCtl(FD, TIOCGSERIAL, @SS)<>-1 then
                                         if SS.typ<>0 then Result:=true;
                                         fpclose(FD)
                                       except end
                                     end
  end
end;


procedure PopulatePortList(var PortList:TStringList);
var S1,S2:string;
    I,J,K:integer;
     done:boolean;
       SR:TSearchRec;
begin
  PortList.Clear;

  if FindFirst('/sys/class/tty/*', faDirectory , SR) = 0 then                  // initially we scan /sys/class/tty for potential serial ports
  repeat                                                                       //                   ~~~~~~~~~~~~~~
//  writeln(SR.Name);
    if CheckDevice(SR.Name) then PortList.Add('/dev/'+SR.Name)                 // check that each port found is live, add to PortList if it is
  until FindNext(SR) <> 0;
  FindClose(SR);

  if PortList.Count=0 then PortList.Add(NPFstring) else                        // ALWAYS have at least ONE item in list, even if a 'not found' message
  repeat                                                                       // excessively complicated sort routine, tries to ensure that the
    done:=true;                                                                // 'fixed' serial ports appear last, and that port numbers are
    for I:=0 to PortList.Count-2 do                                            // ordered correctly: 0,1,2...,8,9,10,11, etc.
    begin
      S1:=PortList[I];
      J:=1+length(S1);

      S2:=PortList[I+1];
      K:=1+length(S2);

      if (J-K)<0 then begin                                                    // pack S1 with zeros to left of numeric part
                        while (J>1) and (S1[J-1] in ['0'..'9']) do dec(J);
                        while length(S1)<length(S2) do insert('0', S1, J)
                      end else
      if (K-J)<0 then begin                                                    // pack S2 with zeros to left of numeric part
                        while (K>1) and (S2[K-1] in ['0'..'9']) do dec(K);
                        while length(S2)<length(S1) do insert('0', S2, K)
                      end;

      J:=pos('ttyS',S1);                                                       // <>0 if is a 'fixed' serial port
      K:=pos('ttyS',S2);                                                       // <>0 if is a 'fixed' serial port

//    if ((J=0) and (K<>0)) or                                                 // bubble ttyS* ports to top of the list
//       ((J=K) and (S1>S2)) then                                              // within respective groups sort alphabetically
      if ((J<>0) and (K=0)) or                                                 // push ttyS* ports to bottom of the list
         ((J=K) and (S1>S2)) then                                              // within respective groups sort alphabetically
      begin
        PortList.Exchange(I, I+1);
        done:=false                                                            // flag set if at least one swap during this pass
      end
    end
  until done
end;

{$ENDIF}


procedure TForm3.Button1Click(Sender: TObject);
var f:TCustomForm;
begin
  f:=GetParentForm(Self);
  if f<>nil then f.ModalResult:=mrCancel
end;


procedure TForm3.Button2Click(Sender: TObject);
var f:TCustomForm;
    I:int64;
begin
  f:=GetParentForm(Self);
  if f<>nil then
  begin
    if ComboBox1.Text=NPFstring then f.ModalResult:=mrCancel else
    begin
      PortName:=Trim(ComboBox1.Text);
      try PortRate:=StrToInt(Trim(ComboBox2.Text)) except PortRate:=38400 end;

      if GetKeyState(VK_CONTROL)<0 then                                        // control key is pressed, do special connect for pico
      begin
        Button1.Enabled:=false;
        Button2.Enabled:=false;
        I:=GetTickCount64+9999;                                                // 10 seconds to unplug and replug
        Label3.Font.Color:=clMaroon;
{$IFDEF WINDOWS}
        while PortExists(PortName)     and ((I-GetTickCount64)>0) do
{$ELSE}
        while FileExists(PortName)     and ((I-GetTickCount64)>0) do
{$ENDIF}
                                                                    begin
                                                                       Label3.Caption:=RightStr(IntToStr(50000+I-GetTickCount64),4)+'ms';
                                                                       Application.ProcessMessages
                                                                     end;
        Label3.Font.Color:=clGreen;
{$IFDEF WINDOWS}
        while not PortExists(PortName) and ((I-GetTickCount64)>0) do
{$ELSE}
        while not FileExists(PortName) and ((I-GetTickCount64)>0) do
{$ENDIF}
                                                                     begin
                                                                       Label3.Caption:=RightStr(IntToStr(50000+I-GetTickCount64),4)+'ms';
                                                                       Application.ProcessMessages
                                                                     end;
        sleep(100)
      end;

      f.ModalResult:=mrOk
    end
  end
end;


procedure TForm3.ComboBox1DropDown(Sender: TObject);
var SL:TStringList;
    S0:string;
     I:integer;
begin
  S0:=ComboBox1.Text;
  SL:=TStringList.Create;
  PopulatePortList(SL);
  ComboBox1.Items:=SL;
  ComboBox1.ItemIndex:=0;
  SL.Free;
  with ComboBox1 do for I:=0 to Items.Count-1 do if Items[I]=S0 then ItemIndex:=I
end;


procedure TForm3.FormCreate(Sender: TObject);
var SL:TStringList;
  I, N:integer;
begin
  MenuItem1A.Visible:=false;                   // 5 bits - not so useful
  MenuItem1B.Visible:=false;                   // 6 bits - also unuseful
  SL:=TStringList.Create;
  PopulatePortList(SL);
  ComboBox1.Items:=SL;
  ComboBox1.ItemIndex:=0;
  SL.Free;

  {$if declared(B50)}      ComboBox2.Items.Add('50');      {$endif}
  {$if declared(B75)}      ComboBox2.Items.Add('75');      {$endif}
  {$if declared(B110)}     ComboBox2.Items.Add('110');     {$endif}
  {$if declared(B134)}     ComboBox2.Items.Add('134');     {$endif}
  {$if declared(B150)}     ComboBox2.Items.Add('150');     {$endif}
  {$if declared(B200)}     ComboBox2.Items.Add('200');     {$endif}
  {$if declared(B300)}     ComboBox2.Items.Add('300');     {$endif}
  {$if declared(B600)}     ComboBox2.Items.Add('600');     {$endif}
  {$if declared(B1200)}    ComboBox2.Items.Add('1200');    {$endif}
  {$if declared(B1800)}    ComboBox2.Items.Add('1800');    {$endif}
  {$if declared(B2400)}    ComboBox2.Items.Add('2400');    {$endif}
  {$if declared(B4800)}    ComboBox2.Items.Add('4800');    {$endif}
  {$if declared(B9600)}    ComboBox2.Items.Add('9600');    {$endif}
  {$if declared(B19200)}   ComboBox2.Items.Add('19200');   {$endif}
  {$if declared(B38400)}   ComboBox2.Items.Add('38400');   {$endif}
  {$if declared(B57600)}   ComboBox2.Items.Add('57600');   {$endif}
  {$if declared(B115200)}  ComboBox2.Items.Add('115200');  {$endif}
  {$if declared(B230400)}  ComboBox2.Items.Add('230400');  {$endif}    // top rate for BSD
  {$if declared(B460800)}  ComboBox2.Items.Add('460800');  {$endif}    // top rate for SPARC and ARM
  // the baud rates below this line are all untested!
  {$if declared(B500000)}  ComboBox2.Items.Add('500000');  {$endif}
  {$if declared(B576000)}  ComboBox2.Items.Add('576000');  {$endif}    // = 115200 x 5
  {$if declared(B921600)}  ComboBox2.Items.Add('921600');  {$endif}    // = 115200 x 8    ok:works with CP2102
  {$if declared(B1000000)} ComboBox2.Items.Add('1000000'); {$endif}
  {$if declared(B1152000)} ComboBox2.Items.Add('1152000'); {$endif}    // = 115200 x 10
  {$if declared(B1500000)} ComboBox2.Items.Add('1500000'); {$endif}
  {$if declared(B2000000)} ComboBox2.Items.Add('2000000'); {$endif}
  {$if declared(B2500000)} ComboBox2.Items.Add('2500000'); {$endif}
  {$if declared(B3000000)} ComboBox2.Items.Add('3000000'); {$endif}
  {$if declared(B3500000)} ComboBox2.Items.Add('3500000'); {$endif}
  {$if declared(B4000000)} ComboBox2.Items.Add('4000000'); {$endif}

{$IFDEF WINDOWS}
  ComboBox2.Items.Add('300');
  ComboBox2.Items.Add('600');
  ComboBox2.Items.Add('1200');
  ComboBox2.Items.Add('1800');
  ComboBox2.Items.Add('2400');
  ComboBox2.Items.Add('4800');
  ComboBox2.Items.Add('9600');
  ComboBox2.Items.Add('19200');
  ComboBox2.Items.Add('38400');
  ComboBox2.Items.Add('57600');
  ComboBox2.Items.Add('115200');
  ComboBox2.Items.Add('230400');               // top rate for BSD
  ComboBox2.Items.Add('460800');               // top rate for SPARC and ARM
  ComboBox2.Items.Add('576000');               // = 115200 x 5
  ComboBox2.Items.Add('921600');               // = 115200 x 8    ok:works with CP2102
  ComboBox2.Items.Add('1152000');              // = 115200 x 10
{$ENDIF}

//writeln(PortName, ' : ', PortRate, ' , ', PortPara);

  with ComboBox1 do
  begin
    N:=-1;
    for I:=0 to Items.Count-1 do if Items[I]=PortName then N:=I;
    if N=-1 then PortPara:='8-N-1'
            else ItemIndex:=N
  end;

  with ComboBox2 do
  begin
    N:=-1;
    for I:=0 to Items.Count-1 do if Items[I]=IntToStr(PortRate) then N:=I;
    if N=-1 then for I:=0 to Items.Count-1 do
                 begin
                   if Items[I]='38400' then ItemIndex:=I
                 end
            else ItemIndex:=N
  end;

  Label3.Caption:=PortPara
end;


procedure TForm3.MenuItemClick(Sender: TObject);
begin
  if Sender=MenuItem1A then PortPara[1]:='5' else
  if Sender=MenuItem1B then PortPara[1]:='6' else
  if Sender=MenuItem1C then PortPara[1]:='7' else
  if Sender=MenuItem1D then PortPara[1]:='8' else

  if Sender=MenuItem2A then PortPara[3]:='N' else
  if Sender=MenuItem2B then PortPara[3]:='O' else
  if Sender=MenuItem2C then PortPara[3]:='E' else

  if Sender=MenuItem3A then PortPara[5]:='1' else
  if Sender=MenuItem3B then PortPara[5]:='2' else

  if Sender=MenuItem4 then PortPara:='8-N-1';

  Label3.Caption:=PortPara
end;


procedure TForm3.ComboBoxANYKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//Label3.Caption:=IntToHex(Key,4);
  if (Sender=ComboBox1) and CheckBox1.Checked then exit;
  if Key=VK_RETURN then Button2.Click
                   else if (Key<>VK_UP) and (KEY<>VK_DOWN) and (KEY<>VK_TAB) then Key:=0
end;


procedure TForm3.Label3Click(Sender: TObject);
begin
//with Label3.Font do if Color=clNone then Color:=clDefault
//                                    else Color:=clNone
end;



end.

