program Cat;

uses
  Forms,
  CatMain in 'CatMain.PAS' {MainForm},
  PrintUnit in 'PrintUnit.pas' {PrintFrm};

{$R *.RES}

begin
  Application.Title := 'Anaesthetizerd Cat';
  Application.HelpFile := '';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPrintFrm, PrintFrm);
  Application.Run;
end.
