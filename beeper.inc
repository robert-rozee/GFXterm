///////////////////////////////////////////////////////////////////////////////////
// remember to add -dUseCThreads to Project -> Project Options -> Custom Options //
///////////////////////////////////////////////////////////////////////////////////
//
// #############################################################################
// ## note that in order for Lazarus to link to the ALSA library, you need to ##
// ## have installed libasound2-dev at some point. this is achieved with:     ##
// ## sudo apt-get install libasound2-dev                                     ##
// #############################################################################
//
//
// include this file near the top of your implementation section with:
//
// {$I beeper.inc}
//
// and in your startup code activate the threading with:
//
// TCheckThread.Create(false)
//
// you also need to add -dUseCThreads to the compiler custom options
// for the threading to work. threading is used to allow the ALSAbeep
// routine to function without blocking the rest of your application.
//
// to queue a bell sounding do the following:
//
// if BELL<16 then inc(BELL);
//
// the variable BELL contains the number of queued bell activations,
// hence the placing of an upper limit to stop the sound driving you
// mad if you inadvertentantly queue up too many! the thread decrements
// the value of BELL as each bell sounding is processed, and you can
// check if the bell is currently sounding with:
//
// if BELL<>0 then...
//
///////////////////////////////////////////////////////////////////////////////////
//
// suggested improvements:
//
// - turn into a unit
// - use a suitable sample rate that is lower than 48000
// - as a simple "bell" can use a pre-encoded sample
// - use non-blocking ALSA calls so doesn't need threading
//
//
// Robert Rozee, 30-April-2020
// rozee@mail.com
//
///////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////
// the following constants define the bell waveform //
//////////////////////////////////////////////////////

const hA:integer=1;         //  SB1 - harmonic A (1 = fundamental)
      hB:integer=2;         //  SB2 - harmonic B
      hC:integer=5;         //  SB3 - harmonic C
      lA:integer=20;        //  SB4 - level (harmonic A)
      lB:integer=20;        //  SB5 - level (harmonic B)
      lC:integer=15;        //  SB6 - level (harmonic C)
      YD:integer=35;        //  SB7 - Y divisor
      fm:integer=75;        //  SB8 - modulation frequency
      lm:integer=20;        //  SB9 - modulation level
      tF:integer=10;        //        fade in/out (in ms)
{$IFDEF InterActive}
    Ymin:integer=0;         //  minimum Y value
    Ymax:integer=0;         //  maximum Y value
    save:boolean=false;
{$ENDIF}


{$IFDEF WINDOWS}
//////////////////////////////////////////////////////////////
// the below constants and functions are copied from the    //
// MMSystem unit that is part of Lazarus                    //
//////////////////////////////////////////////////////////////

const {%H-}SND_SYNC = 0;
      {%H-}SND_ASYNC = 1;
      {%H-}SND_NODEFAULT = 2;
      {%H-}SND_MEMORY = 4;
      {%H-}SND_LOOP = 8;
      {%H-}SND_NOSTOP = 16;
      {%H-}SND_ALIAS = $10000;

Function PlaySoundA(x1: LPCSTR; x2: HMODULE; x3: DWORD): BOOL;stdcall; external 'winmm.dll' name 'PlaySoundA';
Function PlaySoundW(x1: LPCWSTR; x2: HMODULE; x3: DWORD): BOOL;stdcall; external 'winmm.dll' name 'PlaySoundW';
Function PlaySound(x1: PChar; x2: HMODULE; x3: DWORD): BOOL;stdcall; external 'winmm.dll' name
{$ifdef UNICODE}'PlaySoundW' {$else}'PlaySoundA' {$endif};

//////////////////////////////////////////////////////////////

// structure from: http://soundfile.sapp.org/doc/WaveFormat/
type wavetype=record
                ChunkID      :array[1..4] of char;             // 0 offset
                ChunkSize    :DWORD;                           // 4
                Format       :array[1..4] of char;             // 8

                SubChunk1ID  :array[1..4] of char;             // 12
                SubChunkSize :DWORD;                           // 16
                AudioFormat  :WORD;                            // 20
                NumChannels  :WORD;                            // 22
                SampleRate   :DWORD;                           // 24
                ByteRate     :DWORD;                           // 28
                BlockAlign   :WORD;                            // 32
                BitsPerSample:WORD;                            // 34

                SubChunk2ID  :array[1..4] of char;             // 36
                SubChunk2Size:DWORD;                           // 40
                Data         :array[1..1] of byte              // raw data
              end;  { of record }

const wavefile:^wavetype=nil;
// the above MUST be global, as PlaySound exits _just_before_ the sound
// system completes playing - we hence need the data to be intact for a
// few 10's of milliseconds after MMSbeep has exited.
// addendum: we now hold the sample in memory until it is changed, which
// when used as a simple system bell is never. it is only a few k's for
// short beeps, and saves on recalculation on each call to MMSbeep().


procedure MMSbeep (frequency, duration, volume:integer; warble:boolean);
var SI:array[0..359] of integer;       // array of sine wave values, integers -10000..10000
var count1,count2, N1,N2,N3,N4, X1,X2,X3,X4, Y, Z, I:integer;
const {%H-}lastF:integer=-1;
      {%H-}lastD:integer=-1;
      {%H-}lastV:integer=-1;
      {%H-}lastW:boolean=false;
begin
//  PlaySound('SystemStart', 0, SND_ALIAS);
  frequency:=abs(frequency);                                           // -\
  duration:=abs(duration);                                             //   |-- ensure no parameters are negative
  volume:=abs(volume);                                                 // -/
  if frequency<20 then frequency:=20;                                  // -\
  if duration<50 then duration:=50;                                    //   |-- restrict parameters to usable ranges
  if volume>100 then volume:=100;                                      // -/

  if (lastD<>duration) then
  begin
    if wavefile<>nil then FreeMem(wavefile);
    wavefile:=GetMem(sizeof(wavetype)-sizeof(wavetype.Data)+(48*duration));
  end;

{$IFNDEF InterActive}
  if (lastF<>frequency) or (lastD<>duration) or (lastV<>volume) or (lastW<>warble) then
{$ENDIF}
  with wavefile^ do
  begin
    ChunkID      :='RIFF';
    ChunkSize    :=sizeof(wavetype)-sizeof(wavetype.Data)+(48*duration)-8;
    Format       :='WAVE';

    SubChunk1ID  :='fmt ';
    SubChunkSize :=16;
    AudioFormat  :=1;
    NumChannels  :=1;
    SampleRate   :=48000;
    ByteRate     :=48000;
    BlockAlign   :=1;
    BitsPerSample:=8;

    SubChunk2ID  :='data';
    SubChunk2Size:=48*duration;

    for I:=0 to 359 do SI[I]:=round(10000.0*sin(pi*I/180.0));          // single sine wave, scaled up to +/- 10,000

    X1:=0;                                                             // up/down counters used by unequal interval division
    N1:=0;                                                             // (harmonic A: 1 = fundamental)
    X2:=0;
    N2:=0;                                                             // (harmonic B)
    X3:=0;
    N3:=0;                                                             // (harmonic C)
    X4:=0;
    N4:=0;                                                             // low-frequency modulation
    Z:=0;

    count1:=0;                                                         // count1 counts up, count2 counts down
    count2:=(48*duration)-1;                                           // 0 -> 4799 and 4799 -> 0 respectively

    for I:=1 to 48*duration do
    begin
      Y:=(((lA*SI[X1]) + (lB*SI[X2]) + (lC*SI[X3])) * volume) div (YD*10000);
{$IFDEF InterActive}
      if Y<Ymin then Ymin:=Y;
      if Y>Ymax then Ymax:=Y;
{$ENDIF}
      if count1<48*tF then Data[I]:=128 + ((count1*Y) div (48*tF)) else        // 10ms feather in
      if count2<48*tF then Data[I]:=128 + ((count2*Y) div (48*tF)) else        // 10ms feather out
                           Data[I]:=128 + Y;

      if warble then Z:=(SI[X4]*lm) div 10000;                         // calculate new modulation value (frequency offset)

      inc(N1,(frequency+Z)*360*hA);                                    // harmonic A (1 = fundamental frequency)
      while (N1>0) do begin                                            // unequal interval division routine
                        dec(N1,48000);                                 // (a variation on Bresenham's Algorithm)
                        inc(X1)
                      end;
      X1:=X1 mod 360;

      inc(N2,(frequency+Z)*360*hB);                                    // harmonic B (2 works well here)
      while (N2>0) do begin                                            // unequal interval division routine
                        dec(N2,48000);                                 // (a variation on Bresenham's Algorithm)
                        inc(X2)
                     end;
      X2:=X2 mod 360;

      inc(N3,(frequency+Z)*360*hC);                                    // harmonic C (5 works well here)
      while (N3>0) do begin                                            // unequal interval division routine
                        dec(N3,48000);                                 // (a variation on Bresenham's Algorithm)
                        inc(X3)
                      end;
      X3:=X3 mod 360;

      inc(N4,fm*360);                                                  // modulation frequency
      while (N4>0) do begin                                            // unequal interval division routine
                        dec(N4,48000);                                 // (a variation on Bresenham's Algorithm)
                        inc(X4)
                      end;
      X4:=X4 mod 360;
{$IFDEF InterActive}
      if save then
      begin
        write(IntToStr(Data[I]):3,', ');
        if (I mod 16)=15 then writeln
      end;
{$ENDIF}
      inc(count1);
      dec(count2)
    end;

    lastF:=frequency;
    lastD:=duration;
    lastV:=volume;
    lastW:=warble
  end;

  PlaySound(PChar(wavefile), 0, SND_MEMORY + SND_ASYNC + SND_NODEFAULT)
end;

{$ELSE}

//////////////////////////////////////////////////////////////
// the below ALSA types, constants and functions are copied //
// from the pcm.inc file that is a part of fpAlsa           //
//////////////////////////////////////////////////////////////

const
  libasound = 'asound';

type
  { Signed frames quantity }
//Psnd_pcm_sframes_t = ^snd_pcm_sframes_t;
  snd_pcm_sframes_t = cint;

  { PCM handle }
  PPsnd_pcm_t = ^Psnd_pcm_t;
  Psnd_pcm_t = Pointer;

  { PCM stream (direction) }
//Psnd_pcm_stream_t = ^snd_pcm_stream_t;
  snd_pcm_stream_t = cint;

  { PCM sample format }
//Psnd_pcm_format_t = ^snd_pcm_format_t;
  snd_pcm_format_t = cint;

  { PCM access type }
//Psnd_pcm_access_t = ^snd_pcm_access_t;
  snd_pcm_access_t = cint;

  { Unsigned frames quantity }
//Psnd_pcm_uframes_t = ^snd_pcm_uframes_t;
  snd_pcm_uframes_t = cuint;

const
    { Playback stream }
    SND_PCM_STREAM_PLAYBACK: snd_pcm_stream_t = 0;

    { Unsigned 8 bit }
    SND_PCM_FORMAT_U8: snd_pcm_format_t = 1;

    { snd_pcm_readi/snd_pcm_writei access }
    SND_PCM_ACCESS_RW_INTERLEAVED: snd_pcm_access_t = 3;

function snd_pcm_open(pcm: PPsnd_pcm_t; name: PChar;
      stream: snd_pcm_stream_t; mode: cint): cint; cdecl; external libasound;

function snd_pcm_set_params(pcm: Psnd_pcm_t; format: snd_pcm_format_t;
      access: snd_pcm_access_t; channels, rate: cuint; soft_resample: cint;
      latency: cuint): cint; cdecl; external libasound;

function snd_pcm_writei(pcm: Psnd_pcm_t; buffer: Pointer;
      size: snd_pcm_uframes_t): snd_pcm_sframes_t; cdecl; external libasound;

function snd_pcm_recover(pcm: Psnd_pcm_t; err, silent: cint): cint; cdecl; external libasound;

function snd_pcm_drain(pcm: Psnd_pcm_t): cint; cdecl; external libasound;

function snd_pcm_close(pcm: Psnd_pcm_t): cint; cdecl; external libasound;

/////////////////////////////////////////////////////////////

var SI:array[0..359] of integer;                 // array of sine wave values, integers -10000..10000


function ALSAbeep(frequency, duration, volume:integer; warble:boolean):boolean;
const initial:boolean=true;
var buffer:array[0..9600-1] of byte;           // 1/5th second worth of samples @48000Hz
    frames:snd_pcm_sframes_t;                  // number of frames written (negative if an error occurred)
       pcm:PPsnd_pcm_t;                        // sound device handle
        FC:integer;
const device='default'+#00;                    // name of sound device
var count1,count2, N1,N2,N3,N4, X1,X2,X3,X4, Y, Z, I:integer;
begin
  result:=false;

  if snd_pcm_open(@pcm, @device[1], SND_PCM_STREAM_PLAYBACK, 0)=0 then
  begin
    if snd_pcm_set_params(pcm, SND_PCM_FORMAT_U8,
                               SND_PCM_ACCESS_RW_INTERLEAVED,
                               1,                        // number of channels
                               48000,                    // sample rate (Hz)
                               1,                        // resampling on/off
                               500000)=0 then            // latency (us)
    begin
      result:=true;

      frequency:=abs(frequency);                                       // -\
      duration:=abs(duration);                                         //   |-- ensure no parameters are negative
      volume:=abs(volume);                                             // -/
      if frequency<20 then frequency:=20;                              // -\
      if duration<50 then duration:=50;                                //   |-- restrict parameters to usable ranges
      if volume>100 then volume:=100;                                  // -/

      if initial then                                                  // code that only needs to be done ONCE
      begin                                                            //                                 ^^^^
        initial:=false;
        for I:=0 to 359 do SI[I]:=round(10000.0*sin(pi*I/180.0))       // single sine wave, scaled up to +/- 10,000
      end;

      X1:=0;                                                           // up/down counters used by unequal interval division
      N1:=0;                                                           // (harmonic A: 1 = fundamental)
      X2:=0;
      N2:=0;                                                           // (harmonic B)
      X3:=0;
      N3:=0;                                                           // (harmonic C)
      X4:=0;
      N4:=0;                                                           // low-frequency modulation
      Z:=0;

      count1:=0;                                                       // count1 counts up, count2 counts down
      count2:=(duration*48)-1;                                         // (at 48000Hz there are 48 samples per ms)

      while count2>0 do                                                // start making sound!
      begin
        FC:=0;
        for I:=0 to sizeof(buffer)-1 do                                // fill buffer with samples
        begin
          if count2>=0 then begin
                              Y:=(((lA*SI[X1]) + (lB*SI[X2]) + (lC*SI[X3])) * volume) div (YD*10000);
{$IFDEF InterActive}
                              if Y<Ymin then Ymin:=Y;
                              if Y>Ymax then Ymax:=Y;
{$ENDIF}
                              if count1<48*tF then buffer[I]:=128 + ((count1*Y) div (48*tF)) else    // 10ms feather in
                              if count2<48*tF then buffer[I]:=128 + ((count2*Y) div (48*tF)) else    // 10ms feather out
                                                buffer[I]:=128 + Y;
                              inc(FC);
//                            writeln(count1, #9, count2)              // check count-up and count-down values
                            end
                       else begin
                              buffer[I]:=128                           // no signal on trailing end of buffer, just in case
//                            if (FC mod 2400)<>0 then inc(FC)         // keep increasing FC until is a multiple of 2400
                            end;

          if warble then Z:=(SI[X4]*lm) div 10000;                     // calculate new modulation value (frequency offset)

          inc(N1,(frequency+Z)*360*hA);                                // harmonic A (1 = fundamental frequency)
          while (N1>0) do begin                                        // unequal interval division routine
                            dec(N1, 48000);                            // (a variation on Bresenham's Algorithm)
                            inc(X1)
                         end;
          X1:=X1 mod 360;

          inc(N2,(frequency+Z)*360*hB);                                // harmonic B (2 works well here)
          while (N2>0) do begin                                        // unequal interval division routine
                            dec(N2, 48000);                            // (a variation on Bresenham's Algorithm)
                            inc(X2)
                         end;
          X2:=X2 mod 360;

          inc(N3,(frequency+Z)*360*hC);                                // harmonic C (5 works well here)
          while (N3>0) do begin                                        // unequal interval division routine
                            dec(N3, 48000);                            // (a variation on Bresenham's Algorithm)
                            inc(X3)
                         end;
          X3:=X3 mod 360;

          inc(N4,fm*360);                                              // modulation frequency
          while (N4>0) do begin                                        // unequal interval division routine
                            dec(N4, 48000);                            // (a variation on Bresenham's Algorithm)
                            inc(X4)
                         end;
          X4:=X4 mod 360;

{$IFDEF InterActive}
          if save and (count2>0) then
          begin
            writeln(IntToStr(count1), #9, IntToStr(Buffer[I]), #9, IntToStr(Z), #9, IntToStr(FC));
// the above ONE line is for use with importing data in LibreOffice Calc to graph and check waveform

//          write(IntToStr(Buffer[I]):3,', ');
//          if (I mod 16)=15 then writeln
// the above TWO lines are to get data into a format that can be pasted into the win32 beeper code (MMSbeep)
          end;
{$ENDIF}

          inc(count1);
          dec(count2)
        end;

//      writeln(FC);
        frames:=snd_pcm_writei(pcm, @buffer, max(2400, FC));           // write AT LEAST one full period
        if frames<0 then frames:=snd_pcm_recover(pcm, frames, 0);      // try to recover from any error
        if frames<0 then break                                         // give up if failed to recover
      end;
      snd_pcm_drain(pcm)                                               // drain any remaining samples
    end;
    snd_pcm_close(pcm)
  end
end;
{$ENDIF}


////////////////////////////////////////////////////////////////////////////////

const BELL:byte=0;                     // increment value to sound bell
      BELLvolume:byte=50;              // (use byte to ensure is atomic)
       frequency:integer=440;          // default frequency

////////////////////////////////////////////////////////////////////////////////


type TCheckThread = class(TThread)
     private
     protected
       procedure Execute; override;
     end;


// separate thread used to check for command to activate bell
procedure TCheckThread.Execute;
const mark:int64=0;
begin
  while true do
  begin
    mark:=GetTickCount64;
    if BELL>4 then BELL:=4;                                            // IMPOSE A LIMIT OF MAX 4 QUEUED BELL REQUESTS
    if BELL>0 then begin
                     dec(BELL);
                     if BELLvolume=0 then sleep(10) else
                     begin
{$IFDEF WINDOWS}
                       MMSbeep(frequency, 100, BELLvolume, true);      // FINALLY, THIS WORKS!
{$ELSE}
                       ALSAbeep(frequency, 100, BELLvolume, true);     // fancy bell sound
{$ENDIF}
                       while (GetTickCount64-mark)<250 do sleep(10)    // maximum repetition rate of 4 beeps/second
                     end
                   end
              else sleep(10)
  end
end;

