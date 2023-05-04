unit server2;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Windows;

implementation



function ConsoleHandler(dwCtrlType:DWORD):BOOL; stdcall;
begin
  case dwCtrlType of CTRL_CLOSE_EVENT:result:=false;   // console window closing -> we close too
                     CTRL_BREAK_EVENT:result:=true;    // avoid terminating with break
                         CTRL_C_EVENT:result:=true     // avoid terminating with ctrl-C
                  else                result:=false    // all others are unhandled
  end  { of case }
end;



type MapBuffer=record
                 data:array [0..$0FFFF] of char;               // 64k, resides within win32 page file
                 head:integer;
                 tail:integer
               end;

const MapName:string='';               // name of shared mapped memory object used to talk to console server
      MapFile:HANDLE=0;                // file handle of mapped memory object
       MapPtr:^MapBuffer=nil;          // pointer to mapped block of memory

var ch:char;
     K:integer;
     C:COORD;

begin
  if paramcount<>0 then
  begin
// configure communications from GUI, using a shared block of memory
    MapName:=paramstr(1);

    MapFile:=OpenFileMapping(                                          // OPEN AN EXISTING MAPPING
               FILE_MAP_ALL_ACCESS,                                    // read/write access
               false,                                                  // do not inherit the name
               PChar(MapName));                                        // name of mapping object
    if MapFile=0 then halt(1);

    MapPtr:=MapViewOfFile(MapFile,                                     // handle to map object
              FILE_MAP_ALL_ACCESS,                                     // read/write permission
              0,
              0,
              sizeof(MapPtr^));
    if MapPtr=nil then halt(2);

    if not AllocConsole then halt(3) else
    begin
// configure for Write and WriteLn to function with the console window
// see: https://github.com/ultibohub/FPC/blob/master/source/rtl/win/syswin.inc  (line 497-> )
// and: https://forum.lazarus.freepascal.org/index.php?topic=44828.15  (Reply #17)
      StdInputHandle:=0;
      StdOutputHandle:=0;
      StdErrorHandle:=0;
      IsConsole:=True;                                                 // in System unit
      SysInitStdIO;                                                    // in System unit

      SetConsoleCtrlHandler(@ConsoleHandler, true);                    // hook for ctrl-C, break, and close
      SetConsoleMode(StdInputHandle, ENABLE_QUICK_EDIT_MODE or ENABLE_EXTENDED_FLAGS);
      with C do begin X:=80; Y:=2000 end;                              // ^---- enable mouse to select text
      SetConsoleScreenBufferSize(StdOutputHandle, C);                  // 2000 line scrollback
      SetConsoleTitle('Server');

      writeln;
      writeln(#218, StringOfChar('-', 30), #191);
      writeln(#179, StringOfChar(' ', 30), #179);
      writeln(#179, '    GFXterm Console Server    ', #179);
      writeln(#179, '    ', MapName, StringOfChar(' ', 26-length(MapName)), #179);
      writeln(#179, StringOfChar(' ', 30), #179);
      writeln(#192, StringOfChar('-', 30), #217);
      writeln;

// server loop
      repeat
        while MapPtr^.head=MapPtr^.tail do sleep(10);                  // wait for head<>tail -> new data ready

        K:=MapPtr^.tail;
        ch:=MapPtr^.data[K];
        K:=(K+1) mod sizeof(MapPtr^.data);
        MapPtr^.tail:=K;

        if ch<#$80 then write(ch)                                      // 0x00 to 0x7F -> write character to the console
                   else SetConsoleTextAttribute(StdOutputHandle, ord(ch) and $7F)      // 0x80 and above -> set colour
      until false
    end
  end
end.

