unit About;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls;

type
  TAboutFrm = class(TForm)
    OKBtn: TBitBtn;
    lbName: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    GroupBox1: TGroupBox;
    edName: TEdit;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutFrm: TAboutFrm;

implementation

{$R *.DFM}

uses catmain ;


procedure TAboutFrm.FormShow(Sender: TObject);
begin
     lbName.caption := MainForm.Caption ;
     end;

end.
