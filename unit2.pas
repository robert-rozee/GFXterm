unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, LCLType, LCLIntf;

type

  { TForm2 }

  TForm2 = class(TForm)
    Panel1: TPanel;
    Colour0: TLabel;
    Colour1: TLabel;
    Colour2: TLabel;
    Colour3: TLabel;
    Colour4: TLabel;
    Colour5: TLabel;
    Colour6: TLabel;
    Colour7: TLabel;
    Colour8: TLabel;
    Colour9: TLabel;
    Colour10: TLabel;
    Colour11: TLabel;
    Colour12: TLabel;
    Colour13: TLabel;
    Colour14: TLabel;
    Colour15: TLabel;
    Label0: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Shape1: TShape;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SpinEditChange(Sender: TObject);
    procedure PALnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
//  Form2: TForm2;                       // not needed here - form is created by caller
    PaletteRO,                           // read-only palette
    PaletteRW:array [0..15] of TColor;   // working (RW) palette

implementation

{$R *.lfm}

{ TForm2 }

var Colour:array [0..15] of TLabel;
     Index:integer;



procedure TForm2.FormCreate(Sender: TObject);
var I,L,R,G,B:integer;

begin
  Colour[0]:=Colour0;
  Colour[1]:=Colour1;
  Colour[2]:=Colour2;
  Colour[3]:=Colour3;
  Colour[4]:=Colour4;
  Colour[5]:=Colour5;
  Colour[6]:=Colour6;
  Colour[7]:=Colour7;
  Colour[8]:=Colour8;
  Colour[9]:=Colour9;
  Colour[10]:=Colour10;
  Colour[11]:=Colour11;
  Colour[12]:=Colour12;
  Colour[13]:=Colour13;
  Colour[14]:=Colour14;
  Colour[15]:=Colour15;

  for I:=0 to 15 do
  begin
    Colour[I].Color:=PaletteRW[I];     // load up colour patches from working (RW) palette
    L:=Colour[I].Color;
    R:=(L and $FF);
    G:=((L shr 8) and $FF);
    B:=((L shr 16) and $FF);
    L:=((2126*R)+(7152*G)+(0722*B)) div 10000;         // calculate brightness level

    if L>127 then Colour[I].Font.Color:=clBlack
             else Colour[I].Font.Color:=clWhite
  end;

  Index:=-1;                                           // make sure updates are disabled!
  SpinEdit1.Value:=Colour[0].Color and $FF;
  SpinEdit2.Value:=(Colour[0].Color shr 8) and $FF;
  SpinEdit3.Value:=(Colour[0].Color shr 16) and $FF;
  Colour[0].Font.Style:=[fsBold];
  Colour[0].Font.Size:=12;
  Index:=0                                             // ready to go!
end;


procedure TForm2.SpinEditChange(Sender: TObject);      // does most of the heavy lifting
var R,G,B,L:integer;
begin
  if Index in [0..15] then                             // skip if updates disabled
  begin
    R:=SpinEdit1.Value;
    G:=SpinEdit2.Value;
    B:=SpinEdit3.Value;

    Colour[Index].Color:=R+(G shl 8)+(B shl 16);
    L:=((2126*R)+(7152*G)+(0722*B)) div 10000;         // calculate brightness level

    if L>127 then Colour[Index].Font.Color:=clBlack
             else Colour[Index].Font.Color:=clWhite
  end
end;


procedure TForm2.PALnClick(Sender: TObject);           // one of the colour patches have been clicked
var I:integer;
begin
  for I:=0 to 15 do if Sender=Colour[I] then begin     // this is the active patch
                                               Colour[I].Font.Style:=[fsBold];
                                               Colour[I].Font.Size:=12;
                                               Index:=-1;                      // disable updates
                                               SpinEdit1.Value:=Colour[I].Color and $FF;
                                               SpinEdit2.Value:=(Colour[I].Color shr 8) and $FF;
                                               SpinEdit3.Value:=(Colour[I].Color shr 16) and $FF;
                                               Index:=I                        // enable updates
                                             end
                                        else begin     // this is an inactive patch
                                               Colour[I].Font.Style:=[];
                                               Colour[I].Font.Size:=10
                                             end
end;


procedure TForm2.Button1Click(Sender: TObject);        // 'reset ONE' button
var test:boolean;
begin
  test:=(GetKeyState(VK_CONTROL)<0);
  if Index in [0..15] then
  if test then begin
                 SpinEdit1.Value:=random(256);
                 SpinEdit2.Value:=random(256);
                 SpinEdit3.Value:=random(256)
               end
          else begin
                 SpinEdit1.Value:=PaletteRO[index] and $FF;
                 SpinEdit2.Value:=(PaletteRO[index] shr 8) and $FF;
                 SpinEdit3.Value:=(PaletteRO[index] shr 16) and $FF
               end
end;


procedure TForm2.Button2Click(Sender: TObject);        // 'reset ALL' button
var I,temp:integer;
      test:boolean;
begin
  test:=(GetKeyState(VK_CONTROL)<0);
  if Index in [0..15] then
  begin
    temp:=Index;

    for I:=temp+1 to temp+16 do
    begin
      Index:=(I mod 16);
      if test then begin
                     SpinEdit1.Value:=random(256);
                     SpinEdit2.Value:=random(256);
                     SpinEdit3.Value:=random(256)
                   end
              else begin
                     SpinEdit1.Value:=PaletteRO[index] and $FF;
                     SpinEdit2.Value:=(PaletteRO[index] shr 8) and $FF;
                     SpinEdit3.Value:=(PaletteRO[index] shr 16) and $FF
                   end
    end;
    Index:=temp
  end
end;


procedure TForm2.Button3Click(Sender: TObject);        // 'save' button
var f:TCustomForm;
    I:integer;
begin
  f:=GetParentForm(Self);
  if f<>nil then
  begin
    f.ModalResult:=mrOk;
    for I:=0 to 15 do PaletteRW[I]:=Colour[I].Color    // store new colours into working (RW) palette
  end;
end;


procedure TForm2.Button4Click(Sender: TObject);        // 'cancel' button
var f:TCustomForm;
begin
  f:=GetParentForm(Self);
  if f<>nil then f.ModalResult:=mrCancel
end;



end.

