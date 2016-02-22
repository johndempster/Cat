unit Cat;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    GroupBox1: TGroupBox;
    edBPSys: TEdit;
    Label1: TLabel;
    Mean: TLabel;
    edBPMean: TEdit;
    Label3: TLabel;
    edBPDia: TEdit;
    HRGrp: TGroupBox;
    edHR: TEdit;
    NicGrp: TGroupBox;
    edNicMem: TEdit;
    TibGrp: TGroupBox;
    EdSkeletalMuscle: TEdit;
    MainMenu1: TMainMenu;
    StandardDrugs: TMenuItem;
    Unknowns: TMenuItem;
    Help: TMenuItem;
    Exit1: TMenuItem;
    Exit: TMenuItem;
    GroupBox2: TGroupBox;
    ScrollBar1: TScrollBar;
    bStart: TButton;
    bStop: TButton;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.TimerTimer(Sender: TObject);
var
   xPix,yPix,ch : Integer ;
begin
     case State of
     begin
          Recording : Begin
                t := t + tStep ;
                if t > Channel[0].xMax then begin
                   InitializeDisplay ;
                   t := Channel[0].xMin ;
                   end ;
                CalculateTraces ;

                xPix := Trunc( (t - Channel[ch].xMin)*Channel[ch].xScale ;
                for ch := 0 to LastChannel do begin
                    yPix := Channel[ch].Bottom -
                            Trunc( Trace[ch]*Channel[ch].yScale ) ;
                    pbDisplay.canvas.MoveTo( OldPos.x, OldPos.y ) ;
                    pbDisplay.canvas.LineTo( xPix, yPix ) ;
                    OldPos[ch] := Point( xPix, yPix ) ;
                    end ;
                t := t + tStep ;
                end ;
          end ;
     end;


procedure InitializeDisplay ;
{ ----------------------------
  Initialise a display window
  ---------------------------}
var
   Height,ch,cTop : LongInt ;
begin

     { Set trace colour }

     PB.canvas.pen.color := Channel[0].color ;

     { Determine number of channels in use and the height
       available for each channel }

     Height := PB.Height div LastChannel+1 ;

     { Define display area for each channel in use }

     cTop := 0 ;
     for ch := 0 to LastChannel do begin
         Channel[ch].Left := 0 ;
         Channel[ch].Right := PB.width ;
         Channel[ch].Top := cTop ;
         Channel[ch].Bottom := Channel[ch].Top + Height ;
         Channel[ch].xMin := Channel[0].xMin ;
         Channel[ch].xMax := Channel[0].xMax ;
         Channel[ch].xScale := (Channel[ch].Right - Channel[ch].Left) /
                            (Channel[ch].xMax - Channel[ch].xMin ) ;
         Channel[ch].yScale := (Channel[ch].Bottom - Channel[ch].Top) /
                            (Channel[ch].yMax - Channel[ch].yMin ) ;
         cTop := cTop + Height ;
         end ;

     pbDisplay.canvas.brush.color := clWhite ;
     pbDisplay.canvas.fillrect(PB.canvas.ClipRect);

     {TMinLabel.caption := Format( '%5.4g m', [Channel[0].xMin] ) ;
     TMaxLabel.caption := Format( '%5.4g m', [Channel[0].xMax] ) ;}

     { Display Channel Name(s) }

     for ch := 0 to LastChannel do
         pbDisplay.Canvas.TextOut( Channel[ch].Left,
         (Channel[ch].Top + Channel[ch].Bottom) div 2,' ' + Channel[ch].ADCName ) ;

     end ;



procedure TForm1.FormCreate(Sender: TObject);
var
   ch : Integer ;
begin
     Channel[BP].ADCName := 'BP' ;
     Channel[BP].ADCUnits := 'mmHg' ;
     Channel[BP].yMin := 0. ;
     Channel[BP].yMax := BPMax ;
     Channel[BP].color := clBlue ;
     Channel[HR].ADCName := 'HR' ;
     Channel[HR].ADCUnits := 'BPM' ;
     Channel[HR].yMin := 0. ;
     Channel[HR].yMax := HRMax ;
     Channel[HR].color := clRed ;
     Channel[SK].ADCName := 'Sk.Mus.' ;
     Channel[SK].ADCUnits := 'gms' ;
     Channel[SK].yMin := 0. ;
     Channel[Sk].yMax := SKMax ;
     Channel[Sk].color := clGreen ;
     Channel[Nm].ADCName := 'Nic.Mem.' ;
     Channel[Nm].ADCUnits := 'gms' ;
     Channel[Nm].yMin := 0. ;
     Channel[Nm].yMax := NMMax ;
     Channel[Nm].color := clYellow ;

     for ch := 0 to LastChannel
         Channel[ch].xMin := 0 ;
         Channel[ch].xMax := ChartWidth ;
         end ;

     end;

end.
