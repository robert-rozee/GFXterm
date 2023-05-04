unit Unit5;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls, Math;

type

  { TForm5 }

  TForm5 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
//  Form5: TForm5;                       // not needed here - form is created by caller
    AreaInfo:record
               defROWS, defCOLS:integer;       // default number of columns and rows (at initial run, RO)
               minROWS, minCOLS:integer;       // minimum number of columns and rows (pick 'sensible' values, RO)
               maxROWS, maxCOLS:integer;       // maximum number of columns and rows (dimensions of TextStore, RO)
               cellW  , cellH  :integer;       // current width and height of a single character cell (RO)
               maxAW  , maxAH  :integer;       // maximum TEXT AREA width and height (in pixels, RO)
               COLS   , ROWS   :integer        // current columns and rows (RW: passed in, updated on exit if new values are OK)
             end;  { of record }


implementation

{$R *.lfm}

{ TForm5 }

procedure TForm5.Button1Click(Sender: TObject);
var f:TCustomForm;
begin
  f:=GetParentForm(Self);
  if f<>nil then f.ModalResult:=mrCancel
end;



procedure TForm5.Button2Click(Sender: TObject);
var f:TCustomForm;
    ok:boolean;
begin
  with AreaInfo do ok:=((SPinEdit1.Value*cellW)<=maxAW) and ((SPinEdit2.Value*cellH)<=maxAH);

  if not ok then ShowMessage(#13+'      Too Many Columns or Rows to Fit Monitor      '+#13) else with AreaInfo do
  begin
    ok:=(COLS<>SPinEdit1.Value) or (ROWS<>SPinEdit2.Value);            // check if nothing has been changed

    COLS:=SPinEdit1.Value;
    ROWS:=SPinEdit2.Value;

    f:=GetParentForm(Self);
    if f<>nil then if ok then f.ModalResult:=mrOK                      // return mrOK if ROWS or COLS have changed
                         else f.ModalResult:=mrClose                   // return mrClose if no updates required
  end
end;



procedure TForm5.Button3Click(Sender: TObject);
begin
  with AreaInfo do
  begin
    SPinEdit1.Value:=max(minCOLS, min(defCOLS, maxCOLS));
    SPinEdit2.Value:=max(minROWS, min(defROWS, maxROWS))
  end
end;


var Initialize:boolean;                                                // set true each time form is used


procedure TForm5.FormCreate(Sender: TObject);
begin
  Initialize:=true
end;



procedure TForm5.FormActivate(Sender: TObject);
begin
  if Initialize then with AreaInfo do                                  // we only pass here ONCE upon each showing of form
  begin
//  writeln(maxCOLS:8, maxROWS:8, COLS:8, ROWS:8, minCOLS:8, minROWS:8);
    SpinEdit1.MinValue:=minCOLS;
    SpinEdit2.MinValue:=minROWS;
    SpinEdit1.MaxValue:=maxCOLS;
    SpinEdit2.MaxValue:=maxROWS;
    SPinEdit1.Value:=max(minCOLS, min(COLS, maxCOLS));                 // just to be sure that the values are between min and max limite
    SPinEdit2.Value:=max(minROWS, min(ROWS, maxROWS));
    Initialize:=false
  end
end;





end.

