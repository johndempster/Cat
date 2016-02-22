unit Options;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs;

type
  TOptionsFrm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    BPGrp: TGroupBox;
    ckBPShow: TCheckBox;
    Label1: TLabel;
    BPColor: TShape;
    HRGrp: TGroupBox;
    Label2: TLabel;
    HRColor: TShape;
    ckHRShow: TCheckBox;
    NMGrp: TGroupBox;
    Label3: TLabel;
    NMColor: TShape;
    ckNMShow: TCheckBox;
    SKGrp: TGroupBox;
    Label4: TLabel;
    SKColor: TShape;
    ckSKShow: TCheckBox;
    ColorDialog1: TColorDialog;
    procedure BPColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SKColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HRColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NMColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsFrm: TOptionsFrm;

implementation

{$R *.DFM}

procedure TOptionsFrm.BPColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if ColorDialog1.execute then
        BPcolor.brush.color := ColorDialog1.color ;
     end;

procedure TOptionsFrm.SKColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if ColorDialog1.execute then
        SKcolor.brush.color := ColorDialog1.color ;
     end;

procedure TOptionsFrm.HRColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if ColorDialog1.execute then
        HRcolor.brush.color := ColorDialog1.color ;
     end;

procedure TOptionsFrm.NMColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if ColorDialog1.execute then
        NMcolor.brush.color := ColorDialog1.color ;
     end;

end.
