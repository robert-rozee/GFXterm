////////////////////////////////////////////////////////////////////////////////
//
// contains the code used by the Win32 version of this program to implement
// the console server interface (server1) for the GUI exe. this involves:
// 1. an independant thead to handle launching and monitoring a 2nd copy
//    of the exe to act as the console handler (server2);
// 2. interface to handle stuffing data into the ring buffer that resides
//    in shared memory
////////////////////////////////////////////////////////////////////////////////


type MapBuffer=record
                 data:array [0..$0FFFF] of char;                       // 64k shared mempry block, resides within win32 page file
                 head:integer;
                 tail:integer
               end;


const LaunchServer2:boolean=false;                                     // signal to launch server2
      Server2Active:boolean=false;                                     // true while server2 is running
            MapName:string='';                                         // name of shared mapped memory object used to talk to console server
            MapFile:HANDLE=0;                                          // file handle of mapped memory object
             MapPtr:^MapBuffer=nil;                                    // pointer to mapped block of memory



procedure WriteMapBuffer(S:string);                                    // place characters into shared memory (ring buffer)
var I, K:integer;
begin
  if MapPtr<>nil then for I:=1 to length(S) do
  begin
    K:=(MapPtr^.head+1) mod sizeof(MapPtr^.data);                      // new head value (used after insertion completed)

    if K<>MapPtr^.tail then                                            // skip if tail collision (ring buffer is full)
    begin
      MapPtr^.data[MapPtr^.head]:=S[I];                                // insert character at ring buffer head
      MapPtr^.head:=K                                                  // update head index (so it points to the next free slot)
    end
  end
end;




type TRunServerThread = class(TThread)
     private
     protected
       procedure Execute; override;
     end;



// separate thread used to check for command to activate server2
procedure TRunServerThread.Execute;
const ticker:integer=0;
var I:integer;
    S:string;
begin
  S:='"'+ParamStr(0)+'" '+MapName;                                     // exe name (including path) used to start up server2
  while true do
  begin
    if ticker>0 then dec(ticker);                                     // count down (from ticker:=5 below)
    if ticker=1 then MapPtr^.head:=MapPtr^.tail;                      // 200ms has passed -> clear ring buffer

    if not LaunchServer2 then sleep(50) else
    begin
      LaunchServer2:=false;
      Server2Active:=true;
      try
        I:=ExecuteProcess(S, '', []);                                  // uses 2mb of RAM, but waits for process to exit   :-(
        case I of 1:Windows.MessageBox(0, 'Server Failure at: OpenFileMapping', nil, MB_OK);
                  2:Windows.MessageBox(0, 'Server Failure at: MapViewOfFile', nil, MB_OK);
                  3:Windows.MessageBox(0, 'Server Failure at: AllocConsole', nil, MB_OK)
        end  { of case }                                               // exits with 0xC000013A when console window closed
      except
        Windows.MessageBox(0, 'Exception Raised Launching Server', nil, MB_OK)
      end;
      Server2Active:=false;
      DEBUGMODE:=0;                                                    // server dead -> deactive any diagnostics
      ticker:=5                                                        // 200ms after server dies, clear ring buffer
    end
  end
end;   
