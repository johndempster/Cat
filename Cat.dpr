program Cat;

uses
  Forms,
  Catmain in 'CATMAIN.PAS' {MainForm},
  Global in 'GLOBAL.PAS',
  Addlow in 'ADDLOW.PAS' {AddDoseLow},
  Addhigh in 'ADDHIGH.PAS' {AddDoseHigh},
  Options in 'OPTIONS.PAS' {OptionsFrm},
  About in 'ABOUT.PAS' {AboutFrm},
  HTMLHelpViewer in '..\Components\HTMLHelpViewer.pas';

{$R *.RES}

begin
  Application.Title := 'The Virtual Cat';
  Application.HelpFile := 'cat.chm';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAddDoseLow, AddDoseLow);
  Application.CreateForm(TAddDoseHigh, AddDoseHigh);
  Application.CreateForm(TOptionsFrm, OptionsFrm);
  Application.CreateForm(TAboutFrm, AboutFrm);
  Application.Run;
end.
