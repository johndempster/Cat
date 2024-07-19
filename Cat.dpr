program Cat;

uses
  Forms,
  CATMAIN in 'CATMAIN.PAS' {MainForm},
  PrintUnit in 'PrintUnit.pas' {PrintFrm},
  CatModel in 'CatModel.pas' {Model: TDataModule};

{$R *.RES}

begin
  Application.Title := 'Anaesthetizerd Cat';
  Application.HelpFile := '';
  Application.CreateForm(TModel, Model);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPrintFrm, PrintFrm);

  Application.Run;
end.
