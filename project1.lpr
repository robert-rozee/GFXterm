program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF WINDOWS}
  Server2,
  {$ENDIF}
  Interfaces,     // this includes the LCL widgetset
  Forms, Unit1;
//Unit2, Unit3, Unit4, Unit5;     // not needed, as listed under 'uses' in Unit1

{$R *.res}

begin
  RequireDerivedFormResource:=True;
//Application.Scaled:=True;                    // this line may need commenting out for earlier versions of lazarus
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run
end.

