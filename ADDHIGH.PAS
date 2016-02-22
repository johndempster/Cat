unit Addhigh;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, SysUtils ;

const
    Units = 'mg/kg' ;

type
  TAddDoseHigh = class(TForm)
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    lbDrugName: TLabel;
    bOK: TBitBtn;
    cbDose: TComboBox;
    rgInjectionSite: TRadioGroup;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddDoseHigh: TAddDoseHigh;

implementation

{$R *.DFM}


procedure TAddDoseHigh.FormShow(Sender: TObject);
//  ------------------------------------------
// Initialise controls when form is displayed
// ------------------------------------------
begin
     cbDose.Clear ;
     cbDose.Items.Add( format( ' %.3g %s', [0.1,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [0.2,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [0.5,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [1.0,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [2.0,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [5.0,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [10.0,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [20.0,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [50.0,Units] )) ;
     cbDose.Items.Add( format( ' %.3g %s', [100.0,Units] )) ;
     cbDose.ItemIndex := 0 ;
     end;

end.
