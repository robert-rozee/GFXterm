////////////////////////////////////////////////////////////////////////////////
// Win32 serial port access
////////////////////////////////////////////////////////////////////////////////


var SerialHandle:THandle;

const SerialTicker:byte=0;                                             // decremented (down to 0) by serial I/O thread each time round the loop
      SerialToIdle:boolean=false;                                      // signal serial I/O thread to go in to idle (inactive) mode


// log to console, with timestamp and control characters translated
procedure LogEXTS(S:string);
const limit=72;
var H24, M60, S60, ms:word;
              I, N, C:integer;
begin
(* text foreground and background colours for SetConsoleTextAttribute():
        FOREGROUND_BLUE = 1;
        FOREGROUND_GREEN = 2;
        FOREGROUND_RED = 4;
        FOREGROUND_INTENSITY = 8;
        BACKGROUND_BLUE = 16;
        BACKGROUND_GREEN = 32;
        BACKGROUND_RED = 64;
        BACKGROUND_INTENSITY = 128;                                    // DO NOT USE - characters $80..$FF are mapped to colour changes
*)
  DecodeTime(Time, H24, M60, S60, ms);
//WriteLn(Format('%.2dh %.2dm %.2ds %.3dms   %d bytes',[H24, M60, S60, MS, length(S)]));
//WriteLn(Format('%.2d:%.2d:%.2d.%.3dms   %d bytes',[H24, M60, S60, MS, length(S)]));

  WriteMapBuffer(chr($8E) + Format('%.2d:%.2d:%.2d.%.3dms   %d bytes',[H24, M60, S60, MS, length(S)])+#13#10);


  N:=0;                                        // characters written so far on current line screen line
  C:=$80 + 15+16+32;                           // colours for non-ascii characters: bright white text (15),
                                               // alternates between cyan (16+32) and green (32) background
  for I:=1 to length(S) do
  begin
    if (S[I]<#32) or (S[I]>#126) then case S[I] of #07:begin                   // bell
                                                         inc(N, 5);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=5
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<BEL>');
                                                         C:=C xor 16
                                                       end;
                                                   #08:begin                   // backspace
                                                         inc(N, 4);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=4
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<BS>');
                                                         C:=C xor 16
                                                       end;
                                                   #09:begin                   // tab
                                                         inc(N, 5);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=5
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<TAB>');
                                                         C:=C xor 16
                                                       end;
                                                   #10:begin                   // linefeed
                                                         inc(N, 4);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=4
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<LF>');
                                                         C:=C xor 16
                                                       end;
                                                   #13:begin                   // carriage return
                                                         inc(N, 4);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=4
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<CR>');
                                                         C:=C xor 16
                                                       end;
                                                   #27:begin                   // escape
                                                         inc(N, 5);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=5
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<ESC>');
                                                         C:=C xor 16
                                                       end;
                                                  #127:begin                   // delete
                                                         inc(N, 5);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=5
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<DEL>');
                                                         C:=C xor 16
                                                       end
                                                else   begin
                                                         inc(N, 6);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=6
                                                                         end;
                                                         WriteMapBuffer(chr(C) + '<0x' + IntToHex(ord(S[I]), 2) + '>');
                                                         C:=C xor 16
                                                      end
                                      end  { of case }
                                 else                  begin                   // printable ascii character
                                                         inc(N, 1);
                                                         if N>limit then begin
                                                                           WriteMapBuffer(#$8F + #13#10);
                                                                           N:=1
                                                                         end;
                                                         WriteMapBuffer(#$8F + S[I])
                                                       end
  end;
  WriteMapBuffer(#$8F + #13#10#13#10)
end;


procedure CloseCommPort;
var mark:int64;
begin
  CONNECTED:=0;

  SerialTicker:=3;
  mark:=GetTickCount64;
  repeat until (SerialTicker=0) or (timesince(mark)>300);

  LCFn:=1;
  try CloseHandle(SerialHandle) except end;
  LCFn:=0;


  CommName:='';
  CommRate:=0
end;


procedure SetupCommPort(CommPortName:string; BaudRate, BitCount, Parity, StopBits:integer);
var DeviceName:array [0..80] of char;              //  5,6,7,8   0,1,2     1,2
           DCB:TDCB;                               //            0=none
       CommTOs:TCommTimeouts;                      //            1=odd
         error:DWORD;                              //            2=even
          proc,comspec:string;
        action:word;
  function noFS(S:string):string;
  begin
    S:=trim(S);
    if (S<>'') and (S[length(S)]='.') then setlength(S, length(S)-1);
    result:=S
  end;

begin
//ShowMessage(CommPortName+':'+IntToStr(BaudRate)+', bits='+IntToStr(BitCount)+', parity='+IntToStr(Parity)+', stopbits='+IntToStr(StopBits));
  CONNECTED:=0;
  try CloseHandle(SerialHandle) except end;

  try
    StrPCopy(DeviceName, copy('\\.\'+CommPortName, 1, 80));            // 80 characters max
    proc:='CreateFile';
    SerialHandle:=CreateFile(DeviceName,                               // create (== open)
                             GENERIC_READ or GENERIC_WRITE,
                             0, Nil,
                             OPEN_EXISTING,
                             FILE_ATTRIBUTE_NORMAL, 0);
    if (SerialHandle=INVALID_HANDLE_VALUE) then
    begin
      error:=GetLastError;
      MessageDlg('GFXterm - Error',
                 #13+pL+'Serial I/O error: '+proc+' failed'+pR+#13+
                 #13+
                     pL+'('+IntToStr(error)+')  "'+noFS(SysErrorMessage(error))+'"'+pR+#13+
                     pL+'CommPort = '+CommPortName+pR+#13,
                 mtError, [mbOk], 0);
      exit
    end;

    proc:='SetupComm';
    while not SetupComm(SerialHandle, 32768, 1024) do                  // configure - buffer sizes
    begin
      error:=GetLastError;
      action:=MessageDlg('GFXterm - Error',
                         #13+pL+'Serial I/O error: '+proc+' failed'+pR+#13+
                         #13+
                             pL+'('+IntToStr(error)+')  "'+noFS(SysErrorMessage(error))+'"'+pR+#13+
                             pL+'CommPort = '+CommPortName+pR+#13,
                         mtWarning, mbAbortRetryIgnore, 0);
      case action of mrIgnore:break;
                      mrRetry:begin end
                  else        begin
                                try CloseHandle(SerialHandle) except end;
                                exit
                              end
      end  { of case }
    end;

    fillchar(DCB, sizeof(DCB), 0);             // zero everything in DCB
    DCB.DCBlength:=sizeof(DCB);                // fill in DCB size parameter
    DCB.Flags:=$0001;                          // select binary transfer mode

//  comspec:='baud='+IntToStr(38400)+' parity=n data=8 stop=1'#0;      // port parameters
    comspec:='baud='+IntToStr(BaudRate);
    Case Parity of 0:comspec:=comspec+' parity=n';
                   1:comspec:=comspec+' parity=o';
                   2:comspec:=comspec+' parity=e';
    end;  { of case } 
    comspec:=comspec+' data='+IntToStr(BitCount);
    comspec:=comspec+' stop='+IntToStr(StopBits)+#0;
//  ShowMessage(comspec);

    proc:='BuildCommDCB';
    while not BuildCommDCB(@comspec[1], DCB) do                        // build DCB
    begin
      error:=GetLastError;
      action:=MessageDlg('GFXterm - Error',
                         #13+pL+'Serial I/O error: '+proc+' failed'+pR+#13+
                         #13+
                             pL+ '('+IntToStr(error)+')  "'+noFS(SysErrorMessage(error))+'"'+pR+#13+
                             pL+'CommPort = '+CommPortName+pR+#13,
                         mtWarning, mbAbortRetryIgnore, 0);
      case action of mrIgnore:break;
                      mrRetry:begin end
                  else        begin
                                try CloseHandle(SerialHandle) except end;
                                exit
                              end
      end  { of case }
    end;

    proc:='SetCommState';
    while not SetCommState(SerialHandle, DCB) do                       // configure - DCB 
    begin                                                              // NOTE: some microchip devices may return an
      error:=GetLastError;                                             // error code 31 even if there is no failure.
      action:=MessageDlg('GFXterm - Error',                            // in this case, click 'Ignore' to continue.
                         #13+pL+'Serial I/O error: '+proc+' failed'+pR+#13+
                         #13+
                             pL+'('+IntToStr(error)+')  "'+noFS(SysErrorMessage(error))+'"'+pR+#13+
                             pL+'CommPort = '+CommPortName+pR+#13,
                         mtWarning, mbAbortRetryIgnore, 0);
      case action of mrIgnore:break;
                      mrRetry:begin end
                  else        begin
                                try CloseHandle(SerialHandle) except end;
                                exit
                              end
      end  { of case }
    end;

    with CommTOs do
    begin
      ReadIntervalTimeout:=0;      // MAXDWORD // 1  // 10  // 0
      ReadTotalTimeoutMultiplier:=0;           // 0  // 0
      ReadTotalTimeoutConstant:=0;             // 1  // 10  // 300
      WriteTotalTimeoutMultiplier:=0;          // 0  // 0
      WriteTotalTimeoutConstant:=0             // 0  // 10  // 300
    end;

    proc:='SetCommTimeouts';
    while not SetCommTimeouts(SerialHandle, CommTOs) do                // configure - timeouts
    begin
      error:=GetLastError;
      action:=MessageDlg('GFXterm - Error',
                         #13+pL+'Serial I/O error: '+proc+' failed'+pL+#13+
                         #13+
                             pL+'('+IntToStr(error)+')  "'+noFS(SysErrorMessage(error))+'"'+pL+#13+
                             pL+'CommPort = '+CommPortName+pR+#13,
                         mtWarning, mbAbortRetryIgnore, 0);
      case action of mrIgnore:break;
                      mrRetry:begin end
                  else        begin
                                try CloseHandle(SerialHandle) except end;
                                exit
                              end
      end  { of case }
    end

  except
    try CloseHandle(SerialHandle); except end;
    MessageDlg('GFXterm - Error',
               #13+pL+'Serial I/O error: '+proc+' exception'+pR+#13+
               #13+
                   pL+'CommPort = '+CommPortName+pR+#13,
               mtError, [mbOk], 0);
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
  CONNECTED:=2;
  ScrollLCK:=false                                                     // ensure that scroll lock is OFF when we are first connected    
end;



type TSerialThread = class(TThread)
     private
     protected
       procedure Execute; override;
     end;

// serial I/O thread, used to (1) read data from then (2) write data to the serial port
procedure TSerialThread.Execute;
const WriteTimeOut=10;                                                 // 10ms maximum time spent writing
       ReadTimeOut=10;                                                 // 10ms maximum time spent reading
var get, got, put, reason:DWORD;
                 CommStat:TComStat;
               T0, T1, T2:int64;
       I, J, K, ErrorFlag:integer;
                   Buffer:str255;
                       ch:char;
               TempHandle:THandle;
begin
  while true do
  begin
    while SerialToIdle do
    begin
      sleep(20);
      if SerialTicker<>0 then dec(SerialTicker)
    end;

    TS8:=GetTickCount64;
    T0:=TS8;
    T1:=T0;                                                            // set T0 and T1 to current time
    T2:=T1+ReadTimeOut;                                                // set up timeout 10ms in future

// ******** read data from serial port and place into RxBuffer *****************
    
    if (CONNECTED=2) then
    repeat
      RxBusy:=true;
      Buffer:='';
      ErrorFlag:=0;

      try
        LCFn:=8; 
        if not ClearCommError(SerialHandle, reason, @CommStat) then ErrorFlag:=31;     // ClearCommError failed
        LCFn:=0
      except
        LCFn:=0;
        ErrorFlag:=32                                                                  // ClearCommError exception
      end;

      if ErrorFlag=0 then
      begin
        get:=min(CommStat.cbInQue, 250);                               // number of characters waiting, read a maximum of 250
 
        if get=0 then got:=0 else                                      // skip ReadFile if nothing waiting
        try 
          LCFn:=6; 
          if ReadFile(SerialHandle, Buffer[1], get, got, nil) then SetLength(Buffer, got)
                                                              else ErrorFlag:=33;      // ReadFile failed
          LCFn:=0
        except
          LCFn:=0;
          ErrorFlag:=34                                                                // ReadFile exception
        end
      end;

      if ErrorFlag=0 then begin
                            if got<>0 then                                       // data has been read in from serial port
                            begin
                              TS1:=GetTickCount64;
                              SetLength(Buffer, got);
                              if DEBUGMODE=1 then LogEXTS(Buffer);

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
                            end                           
                          end
                     else begin                                                  // ERROR - disconnect and advise main program
                            CONNECTED:=0;
                            ErrorData[1]:=GetLastError;
                            ErrorPort:=CommName;  
                            ErrorCode:=ErrorFlag;
                            CommName:='';
                            CommRate:=0;

                            LCFn:=1;
                            try CloseHandle(SerialHandle); except end;
                            LCFn:=0
                          end;

      T1:=GetTickCount64;                                              // after we have done stuff, update  T1 to current time
      RxBusy:=false
    until (CONNECTED<>2) or (got=0) or (T1>T2);


    T2:=T1+WriteTimeOut;                                               // set up timeout 10ms in future


// ******** write data contained in TxBuffer to serial port ********************
    while (CONNECTED=2) and (TxBuffer.head<>TxBuffer.tail) and (T1<T2) do
    begin                                                              // write while connected, and more to write, and within 10ms timeout
      TxBusy:=true;
      Buffer:='';
      ErrorFlag:=0;

      while (length(Buffer)<250) and (TxBuffer.head<>TxBuffer.tail) do
      begin
        ch:=TxBuffer.data[TxBuffer.tail];
        TxBuffer.tail:=(TxBuffer.tail+1) mod sizeof(TxBuffer.data);
        Buffer:=Buffer+ch
      end;

      try
        LCfn:=7;
        if not WriteFile(SerialHandle, Buffer[1], length(Buffer), put, nil) then ErrorFlag:=35;
        LCFn:=0                                                                        // WriteFile failed
      except
        LCFn:=0;
        ErrorFlag:=36                                                                  // WriteFile exception
      end;

      if ErrorFlag=0 then TS2:=GetTickCount64                          // successful write to serial port
                     else begin                                        // ERROR - disconnect and advise main program
                            CONNECTED:=0;
                            ErrorData[1]:=GetLastError;
                            ErrorPort:=CommName;
                            ErrorCode:=ErrorFlag;
                            CommName:='';
                            CommRate:=0;

                            LCFn:=1;
                            try CloseHandle(SerialHandle) except end;
                            LCFn:=0
                          end;

      T1:=GetTickCount64;                                              // after we have done stuff, update  T1 to current time
      TxBusy:=false
    end;

// ******** check USB serial port is still 'alive' *****************************
    if (CONNECTED=2) and USBChangeFlag then
    begin
      CkBusy:=true;
      USBChangeFlag:=false;
      ErrorFlag:=0;
      Buffer:='\\.\'+CommName+#00;

      try
        LCFn:=9;
        TempHandle:=CreateFile(@Buffer[1],  // TempName,
                               GENERIC_READ or GENERIC_WRITE,
                               0, Nil,
                               OPEN_EXISTING,
                               FILE_ATTRIBUTE_NORMAL, 0);
        LCFn:=0;

        if GetLastError=ERROR_FILE_NOT_FOUND then ErrorFlag:=37;
        // 0:present and available  (ERROR_SUCCESS)
        // 2:port is not present    (ERROR_FILE_NOT_FOUND)
        // 5:present and in use     (ERROR_ACCESS_DENIED)

        try CloseHandle(TempHandle); except end;
      except
        LCFn:=0;
        ErrorFlag:=38
      end;

      if ErrorFlag<>0 then begin
                             CONNECTED:=0;
                             ErrorData[1]:=ERROR_FILE_NOT_FOUND;
                             ErrorPort:=CommName;
                             ErrorCode:=ErrorFlag;
                             LCFn:=1;
                             CommName:='';
                             CommRate:=0;

                             try CloseHandle(SerialHandle); except end;
                             LCFn:=0
                           end;

      T1:=GetTickCount64;                                              // after we have done stuff, update  T1 to current time
      CkBusy:=false
    end;


    I:=T1-T0;                                                          // always comes out 1ms or less, so hardly worth counting!
    if CONNECTED=2 then sleep(max(10, 20-I))
                   else sleep(20);
    if SerialTicker<>0 then dec(SerialTicker)
  end
end;




