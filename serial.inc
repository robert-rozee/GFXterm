////////////////////////////////////////////////////////////////////////////////
// Linux serial port access
////////////////////////////////////////////////////////////////////////////////


var SerialHandle:longint;

const SerialTicker:byte=0;                                             // decremented (down to 0) by serial I/O thread each time round the loop
      SerialToIdle:boolean=false;                                      // signal serial I/O thread to go in to idle (inactive) mode


// log to console, with timestamp and control characters translated
procedure LogPacket(S:string);
const limit=72;
var H24, M60, S60, ms:word;
              I, N, C:integer;
begin
  DecodeTime(Time, H24, M60, S60, ms);
//WriteLn(#27+'[1;33m', Format('%.2dh %.2dm %.2ds %.3dms   %d bytes',[H24, M60, S60, MS, length(S)]), #27+'[0m');
  WriteLn(#27+'[1;33m', Format('%.2d:%.2d:%.2d.%.3dms   %d bytes',[H24, M60, S60, MS, length(S)]), #27+'[0m');

  N:=0;                                        // characters written so far on current screen line
  C:=44;                                       // background for non-ascii characters: alternates between 44 (blue) and 46 (cyan)

  for I:=1 to length(S) do
  begin
    if (S[I]<#32) or (S[I]>#126) then case S[I] of #07:begin                   // bell
                                                         inc(N, 5);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=5 end;
                                                         Write(#27+'[',C,'m',  '<BEL>');
                                                         C:=C xor 2
                                                       end;
                                                   #08:begin                   // backspace
                                                         inc(N, 4);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=4 end;
                                                         Write(#27+'[',C,'m',  '<BS>');
                                                         C:=C xor 2
                                                       end;
                                                   #09:begin                   // tab
                                                         inc(N, 5);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=5 end;
                                                         Write(#27+'[',C,'m',  '<TAB>');
                                                         C:=C xor 2
                                                       end;
                                                   #10:begin                   // linefeed
                                                         inc(N, 4);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=4 end;
                                                         Write(#27+'[',C,'m',  '<LF>');
                                                         C:=C xor 2
                                                       end;
                                                   #13:begin                   // carriage return
                                                         inc(N, 4);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=4 end;
                                                         Write(#27+'[',C,'m',  '<CR>');
                                                         C:=C xor 2
                                                       end;
                                                   #27:begin                   // escape
                                                         inc(N, 5);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=5 end;
                                                         Write(#27+'[',C,'m',  '<ESC>');
                                                         C:=C xor 2
                                                       end;
                                                  #127:begin                   // delete
                                                         inc(N, 5);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=5 end;
                                                         Write(#27+'[',C,'m',  '<DEL>');
                                                         C:=C xor 2
                                                       end
                                                else   begin
                                                         inc(N, 6);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=6 end;
                                                         Write(#27+'[',C,'m',  '<0x', IntToHex(ord(S[I]), 2), '>');
                                                         C:=C xor 2
                                                      end
                                      end  { of case }
                                 else                  begin                   // printable ascii character
                                                         inc(N, 1);
                                                         if N>limit then begin WriteLn(#27+'[0m'); N:=1 end;
                                                         Write(#27+'[0m',   S[I])
                                                       end
  end;
  WriteLn(#27+'[0m');
  WriteLn
end;



function CheckCommRate(BaudRate:integer):boolean;
var C:cardinal;
begin
  case BaudRate of
  {$if declared(B50)}           50:C:=B50;      {$endif}
  {$if declared(B75)}           75:C:=B75;      {$endif}
  {$if declared(B110)}         110:C:=B110;     {$endif}
  {$if declared(B134)}         134:C:=B134;     {$endif}
  {$if declared(B150)}         150:C:=B150;     {$endif}
  {$if declared(B200)}         200:C:=B200;     {$endif}
  {$if declared(B300)}         300:C:=B300;     {$endif}
  {$if declared(B600)}         600:C:=B600;     {$endif}
  {$if declared(B1200)}       1200:C:=B1200;    {$endif}
  {$if declared(B1800)}       1800:C:=B1800;    {$endif}
  {$if declared(B2400)}       2400:C:=B2400;    {$endif}
  {$if declared(B4800)}       4800:C:=B4800;    {$endif}
  {$if declared(B9600)}       9600:C:=B9600;    {$endif}
  {$if declared(B19200)}     19200:C:=B19200;   {$endif}
  {$if declared(B38400)}     38400:C:=B38400;   {$endif}
  {$if declared(B57600)}     57600:C:=B57600;   {$endif}
  {$if declared(B115200)}   115200:C:=B115200;  {$endif}
  {$if declared(B230400)}   230400:C:=B230400;  {$endif}       // top rate for BSD
  {$if declared(B460800)}   460800:C:=B460800;  {$endif}       // top rate for SPARC and ARM
// the baud rates below this line are all untested!
  {$if declared(B500000)}   500000:C:=B500000;  {$endif}
  {$if declared(B576000)}   576000:C:=B576000;  {$endif}       // = 115200 x 5
  {$if declared(B921600)}   921600:C:=B921600;  {$endif}       // = 115200 x 8    ok:works with CP2102
  {$if declared(B1000000)} 1000000:C:=B1000000; {$endif}
  {$if declared(B1152000)} 1152000:C:=B1152000; {$endif}       // = 115200 x 10
  {$if declared(B1500000)} 1500000:C:=B1500000; {$endif}
  {$if declared(B2000000)} 2000000:C:=B2000000; {$endif}
  {$if declared(B2500000)} 2500000:C:=B2500000; {$endif}
  {$if declared(B3000000)} 3000000:C:=B3000000; {$endif}
  {$if declared(B3500000)} 3500000:C:=B3500000; {$endif}
  {$if declared(B4000000)} 4000000:C:=B4000000; {$endif}
              else                 C:=0
  end;  { of case }

  Result:=(C<>0)
end;



procedure CloseCommPort;
var mark:int64;
begin
  CONNECTED:=0;

  SerialTicker:=3;
  mark:=GetTickCount64;
  repeat until (SerialTicker=0) or (timesince(mark)>300);

//try tcFlush(SerialHandle, TCIOFLUSH) except end;                     // discard ALL pending reads and writes
//try tcDrain(SerialHandle) except end;                                // wait for any pending writes to complete

  LCFn:=1;
  try fpClose(SerialHandle) except end;
  LCFn:=0;

//writeln(GetTickCount64-mark, ' ms');

  CommName:='';
  CommRate:=0
end;



procedure SetupCommPort(CommPortName:string; BaudRate, BitCount, Parity, StopBits:integer);
var tios:termios;                                  //  5,6,7,8   0,1,2     1,2
       I:integer;                                  //            0=none
begin                                              //            1=odd
  I:=CONNECTED;                                    //            2=even
  CONNECTED:=0;
  if I=2 then CloseCommPort;

  LCFn:=2;
  try SerialHandle:={%H-}fpOpen(CommPortName, O_RDWR or O_NOCTTY or O_NonBlock) except SerialHandle:=-1 end;
  LCFn:=0;                                                  // **********                             non-blocking so that Pi Pico can't block on writes if DTR not set
  if SerialHandle<0 then
  begin
    CloseCommPort;
//  ShowMessage(#13+pL+'Failed to open '+CommPortName+pR+#13);
    ErrorPort:=CommPortName;
    ErrorCode:=21;
    exit
  end;

  LCFn:=3;
  try fpIOCtl(SerialHandle, TIOCEXCL, nil) except end;                 // try to set exclusive access mode for serial port, am best-guessing this is the correct method
  LCFn:=0;

  FillChar(tios, SizeOf(tios), #00);

  case BaudRate of
  {$if declared(B50)}           50:tios.c_cflag:=B50;      {$endif}
  {$if declared(B75)}           75:tios.c_cflag:=B75;      {$endif}
  {$if declared(B110)}         110:tios.c_cflag:=B110;     {$endif}
  {$if declared(B134)}         134:tios.c_cflag:=B134;     {$endif}
  {$if declared(B150)}         150:tios.c_cflag:=B150;     {$endif}
  {$if declared(B200)}         200:tios.c_cflag:=B200;     {$endif}
  {$if declared(B300)}         300:tios.c_cflag:=B300;     {$endif}
  {$if declared(B600)}         600:tios.c_cflag:=B600;     {$endif}
  {$if declared(B1200)}       1200:tios.c_cflag:=B1200;    {$endif}
  {$if declared(B1800)}       1800:tios.c_cflag:=B1800;    {$endif}
  {$if declared(B2400)}       2400:tios.c_cflag:=B2400;    {$endif}
  {$if declared(B4800)}       4800:tios.c_cflag:=B4800;    {$endif}
  {$if declared(B9600)}       9600:tios.c_cflag:=B9600;    {$endif}
  {$if declared(B19200)}     19200:tios.c_cflag:=B19200;   {$endif}
  {$if declared(B38400)}     38400:tios.c_cflag:=B38400;   {$endif}
  {$if declared(B57600)}     57600:tios.c_cflag:=B57600;   {$endif}
  {$if declared(B115200)}   115200:tios.c_cflag:=B115200;  {$endif}
  {$if declared(B230400)}   230400:tios.c_cflag:=B230400;  {$endif}    // top rate for BSD
  {$if declared(B460800)}   460800:tios.c_cflag:=B460800;  {$endif}    // top rate for SPARC and ARM
// the baud rates below this line are all untested!
  {$if declared(B500000)}   500000:tios.c_cflag:=B500000;  {$endif}
  {$if declared(B576000)}   576000:tios.c_cflag:=B576000;  {$endif}    // = 115200 x 5
  {$if declared(B921600)}   921600:tios.c_cflag:=B921600;  {$endif}    // = 115200 x 8    ok:works with CP2102
  {$if declared(B1000000)} 1000000:tios.c_cflag:=B1000000; {$endif}
  {$if declared(B1152000)} 1152000:tios.c_cflag:=B1152000; {$endif}    // = 115200 x 10
  {$if declared(B1500000)} 1500000:tios.c_cflag:=B1500000; {$endif}
  {$if declared(B2000000)} 2000000:tios.c_cflag:=B2000000; {$endif}
  {$if declared(B2500000)} 2500000:tios.c_cflag:=B2500000; {$endif}
  {$if declared(B3000000)} 3000000:tios.c_cflag:=B3000000; {$endif}
  {$if declared(B3500000)} 3500000:tios.c_cflag:=B3500000; {$endif}
  {$if declared(B4000000)} 4000000:tios.c_cflag:=B4000000; {$endif}
              else begin
                     BaudRate:=38400;
                     tios.c_cflag:=B38400
                   end
  end;  { of case }

{$ifndef SOLARIS}
  tios.c_ispeed:=tios.c_cflag;
  tios.c_ospeed:=tios.c_cflag;
{$endif}

  tios.c_cflag:=tios.c_cflag or CREAD or CLOCAL;

  case BitCount of 5:tios.c_cflag:=tios.c_cflag or CS5;
                   6:tios.c_cflag:=tios.c_cflag or CS6;
                   7:tios.c_cflag:=tios.c_cflag or CS7;
                   8:tios.c_cflag:=tios.c_cflag or CS8
                else tios.c_cflag:=tios.c_cflag or CS8
  end;  { of case }

  case Parity of 0:;
                 1:tios.c_cflag:=tios.c_cflag or PARENB or PARODD;
                 2:tios.c_cflag:=tios.c_cflag or PARENB
  end;  { of case }

  case StopBits of 1:;
                   2:tios.c_cflag:=tios.c_cflag or CSTOPB
  end;  { of case }

//tios.c_cflag := tios.c_cflag or CRTSCTS;                             // enable RTS/CTS flow control

  try
    LCFn:=4;                                                           ////////////////////////////////////////////////////////
    tcFlush(SerialHandle, TCIOFLUSH);                                  // this is the ONLY flush in the original serial code //
    LCFn:=0                                                            ////////////////////////////////////////////////////////
  except
    LCFn:=0;
    CloseCommPort;
//  ShowMessage(#13+pL+'Failed to flush '+CommPortName+pR+#13);
    ErrorPort:=CommPortName;
    ErrorCode:=22;
    exit
  end;

  try
    LCFn:=5;
    tcSetAttr(SerialHandle, TCSANOW, tios);
    LCFn:=0
  except
    LCFn:=0;
    CloseCommPort;
//  ShowMessage(#13+pL+'Failed to configure '+CommPortName+pR+#13);
    ErrorPort:=CommPortName;
    ErrorCode:=23;
    exit
  end;

  TS1:=GetTickCount64;
  TS2:=TS1;
  TS3:=TS2;
  TS4:=TS3;

  CommName:=CommPortName;
  CommRate:=BaudRate;
  CommPara:=IntToStr(BitCount)+'-'+copy('NOE', 1+Parity, 1)+'-'+IntToStr(StopBits);
  LastName:=CommPortName;
  LastRate:=BaudRate;
  LastPara:=IntToStr(BitCount)+'-'+copy('NOE', 1+Parity, 1)+'-'+IntToStr(StopBits);
//writeln(BitCount, #09, Parity, #09, StopBits, #09, '<', CommPara, '>');
  CONNECTED:=2;
  ScrollLCK:=false                                                     // ensure that scroll lock is OFF when we are first connected
end;



(*
function ReadComm(var Buffer:str255):boolean;
const lock:boolean=false;                                              // locks are probably not needed, a hangover from win32 version
var I:integer;
begin
//if lock then writeln('lock violation in ReadComm');
  if lock or (CONNECTED<>2) then result:=false else
  begin
    lock:=true;

    LCFn:=6;
    try I:=fpRead(SerialHandle, @Buffer[1], 250) except I:=-1 end;     // adding @ supresses a compiler note, seems to still work ok
    LCFn:=0;

    result:=(I>0);
    if I<0 then begin
                  ErrorData[1]:=fpGetErrno;
                  ErrorPort:=CommName;
                  ErrorCode:=24;
                  CloseCommPort
                end else
    if I>0 then begin
                  Buffer[0]:=char(I);
                  TS1:=GetTickCount64;
                  if DEBUGMODE=1 then LogEXTS(Buffer)
                end;
    lock:=false
  end
end;
*)



(*
function WriteComm(Buffer:str255):boolean;
const lock:boolean=false;                                              // locks are probably not needed, a hangover from win32 version
var I:integer;
begin
//if lock then writeln('lock violation in WriteComm');
  if lock or (CONNECTED<>2) then result:=false else
  begin
    lock:=true;

    LCFn:=7;
    try I:=fpWrite(SerialHandle, @Buffer[1], length(Buffer)) except I:=-1 end;
    LCFn:=0;                                                           // adding @ supresses a compiler note, seems to still work ok

    result:=(I>0);
    if I<0 then begin
                  ErrorData[1]:=fpGetErrno;
                  ErrorPort:=CommName;
                  ErrorCode:=25;
                  CloseCommPort
                end else
    if I>0 then begin
                  TS2:=GetTickCount64
                end;
    lock:=false
  end
end;
*)



type TSerialThread = class(TThread)
     private
     protected
       procedure Execute; override;
     end;

// serial I/O thread, used to (1) read data from then (2) write data to the serial port
procedure TSerialThread.Execute;
const WriteTimeOut=10;                                                 // 10ms maximum time spent writing
       ReadTimeOut=10;                                                 // 10ms maximum time spent reading
var T0, T1, T2:int64;
       I, J, K:integer;
        Buffer:str255;
            ch:char;
begin
  while true do
  begin
    while SerialToIdle do
    begin
      sleep(20);
      if SerialTicker>0 then dec(SerialTicker)
    end;

    TS8:=GetTickCount64;
    T0:=TS8;
    T1:=T0;                                                            // set T0 and T1 to current time
    T2:=T1+ReadTimeOut;                                                // set up timeout 10ms in future

// ******** read data from serial port and place into RxBuffer *****************
    if (CONNECTED=2) then
    repeat
      RxBusy:=true;
//    SetLength(Buffer, 250);                                          // not needed for short strings as space is already allocated

      LCFn:=6;
      try I:=fpRead(SerialHandle, @Buffer[1], 250) except I:=-1 end;   // adding @ supresses a compiler note, seems to still work ok
      LCFn:=0;

      if I>0 then begin                                                // data has been read in from serial port
                    TS1:=GetTickCount64;
                    SetLength(Buffer, I);
                    if DEBUGMODE=1 then LogPacket(Buffer);

                    for J:=1 to length(Buffer) do
                    begin
                      ch:=Buffer[J];
                      if (ch=#10) and (CRwait<>0) then dec(CRwait);    // <LF> handshake, used while pasting
                      K:=(RxBuffer.head+1) mod sizeof(RxBuffer.data);

                      if K<>RxBuffer.tail then
                      begin
                        RxBuffer.data[RxBuffer.head]:=ch;              // insert character into ring buffer
                        RxBuffer.head:=K                               // increment head index
                      end
                    end
                  end else
      if I<0 then begin                                                // ERROR - disconnect and advise main program
                    CONNECTED:=0;
                    ErrorData[1]:=fpGetErrno;
                    ErrorPort:=CommName;
                    ErrorCode:=24;
                    CommName:='';
                    CommRate:=0;

                    LCFn:=1;
                    try fpClose(SerialHandle) except end;
                    LCFn:=0
                  end;

      T1:=GetTickCount64;                                              // after we have done stuff, update  T1 to current time
      RxBusy:=false
    until (CONNECTED<>2) or (I<=0) or (T1>T2);                         // keep reading until disconnected, nothing to read, or 10ms timeout


    T2:=T1+WriteTimeOut;                                               // set up timeout 10ms in future


// ******** write data contained in TxBuffer to serial port ********************
    while (CONNECTED=2) and (TxBuffer.head<>TxBuffer.tail) and (T1<T2) do
    begin                                                              // write while connected, and more to write, and within 10ms timeout
      TxBusy:=true;
//    SetLength(Buffer, 250);                                          // not needed for short strings as space is already allocated

      I:=0;
      K:=TxBuffer.tail;
      while (I<250) and (TxBuffer.head<>K) do
      begin
        inc(I);
        Buffer[I]:=TxBuffer.data[K];
        K:=(K+1) mod sizeof(TxBuffer.data)
      end;
      SetLength(Buffer, I);

      LCFn:=7;
      try I:=fpWrite(SerialHandle, @Buffer[1], length(Buffer)) except I:=-1 end;
      LCFn:=0;                                                         // adding @ supresses a compiler note, seems to still work ok

      if I>0 then begin                                                // successful write to serial port
                    TS2:=GetTickCount64;
                    TxBuffer.tail:=(TxBuffer.tail+I) mod sizeof(TxBuffer.data)
                  end else
      if I<0 then begin                                                // ERROR - disconnect and advise main program
                    CONNECTED:=0;
                    ErrorData[1]:=fpGetErrno;
                    ErrorPort:=CommName;
                    ErrorCode:=25;
                    CommName:='';
                    CommRate:=0;

                    LCFn:=1;
                    try fpClose(SerialHandle) except end;
                    LCFn:=0
                  end;

      T1:=GetTickCount64;                                              // after we have done stuff, update  T1 to current time
      TxBusy:=false
    end;

    I:=T1-T0;                                                          // always comes out 1ms or less, so hardly worth counting!
    if CONNECTED=2 then sleep(max(10, 20-I))
                   else sleep(20);
    if SerialTicker>0 then dec(SerialTicker)
  end
end;




