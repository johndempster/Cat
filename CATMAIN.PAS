unit Catmain;
{OPTIMIZATION OFF}
{ ================================================
  The Virtual Cat ... Anaesthetised cat simulation
  ================================================}
{ (c) John Dempster 1996-98 }
{  9/10/96 ... V2.1 ACh (at high doses) now stimulates ganglia }
{ 24/10/96 ... V2.1a A1 receptors added to nic. mem. & heart help screens
                     Temp file now deleted }
{ 25/10/96 ...V2.1b A1 receptor-mediated block added to vagus & accelerans nerves
                    prog. now checks in file writes fail }
{ 14/11/96 ... V2.1c Temp. files now deleted when New Cat called }
{ 19/12/96 ... V2.1d Scrollbar limits now tested for validity on stop}
{ 1/10/97 ... V2.2 }
{ 13/10/97 ... V2.2a 5 unknown drugs now in use }
{ 16/10/97 ... V2.2b Drug M & Drug N names in add dose corrected }
{ 30/10/97 ... V2.2c Incorrect X axis scaling when a sub-set of channel
               printed out now fixed }
{ 5/2/98 ... V2.3 Close arterial injection of ACh added
                  High doses of ACh and CCh now desensitise nmj
                  Histamine substituted for verapamil in unknowns list}
{ 8/2/98 ... V2.3/95 Modified for Windows 95/Delphi V3.0 }
{ 20/9/98 ... V2.3a Channel labels now print out correct size }
{ 28/9/98 ... V2.3b Temporary files now in Windows temporary folder }
{ 6/10/98 ... V2.4 1998-99 unknowns added }
{ 22/10/98 ... V2.4a
               Cursor now reads chart correctly when only one channel is selected.
               Drug concentrations on chart now have 2 sign, figs.
               problems with errors printing drug names fixed }
{ 9/10/00  ... V2.5 Unknown drugs O, P, Q added }
{ 3/5/01   ... V2.5a Should now work with Italian/Spanish Windows Languages}
{ 29/8/01  ... V2.5.1 Compiled under Delphi V5 Optimisations turned off
               Error when closing under NT now fixed }
{ 17/10/01 ... V2.5.2 Help file no longer gets lost when .CAT files saved }
{ 22/9/02  ... V2.5.3 Concentrations can now be entered using Italian language settings}
{ 12/11/02 ... V2.5.4 Compiled under Delphi V7}
{ 9/5/03 ..... V2.5.5 All types of decimal separators now included in numbers}
{ 11/7/05 .... V2.5.6 Buffer now statically allocated }
// 22.9.11 ... V2.6 Help files now HTML help and works in Windows 7/Vista
//             V2.6.1 Help viewer is now called via ShellExecute to get
//                    help to display when run from a network drive under Windows 7
// 26.03.14 .. V2.6.2 Help file (cat.chm) now copied to and executed from local temporary folder
//             to display when run from a network drive under Windows 7
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, ExtCtrls, AddLow, AddHigh, Options,
  Printers, About, shellapi ;

const
     BPMax = 200 ;
     HRMax  = 300 ;
     NMMax = 100 ;
     SKMax = 100 ;
     ChBP = 0 ;
     ChBPAvg = 1 ;
     ChHR = 2 ;
     ChNM = 3 ;
     ChSK = 4 ;
     chMarker = 5 ;
     chMarkerValue = 6 ;
     ChannelLimit=7 ;
     NumChannels = ChannelLimit+1 ;

type
  TMainForm = class(TForm)
    pbDisplay: TPaintBox;
    BPGrp: TGroupBox;
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
    SkelGrp: TGroupBox;
    EdSkelMus: TEdit;
    MainMenu1: TMainMenu;
    StandardDrugs: TMenuItem;
    mndrugAL: TMenuItem;
    Help: TMenuItem;
    ControlGrp: TGroupBox;
    sbRecord: TScrollBar;
    bStart: TButton;
    bStop: TButton;
    Timer: TTimer;
    mnTubocurarine: TMenuItem;
    mnNoradrenaline: TMenuItem;
    mnAcetylcholine: TMenuItem;
    mnNeostigmine: TMenuItem;
    mnCarbachol: TMenuItem;
    mnAtropine: TMenuItem;
    mnHistamine: TMenuItem;
    mnHexamethonium: TMenuItem;
    mnGallamine: TMenuItem;
    mnVerapamil: TMenuItem;
    mnFile: TMenuItem;
    mnNewCat: TMenuItem;
    mnLoadCat: TMenuItem;
    mnSaveCat: TMenuItem;
    mnPrint: TMenuItem;
    PrintSetup1: TMenuItem;
    mnExit: TMenuItem;
    mnHelp: TMenuItem;
    edCursor: TEdit;
    mnMepyramine: TMenuItem;
    mnContents: TMenuItem;
    mnAbout: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    StimGrp: TGroupBox;
    ckStimulateVagus: TCheckBox;
    mnMorphine: TMenuItem;
    mnNaloxone: TMenuItem;
    mnAdenosine: TMenuItem;
    mn8SPT: TMenuItem;
    mnDrugA: TMenuItem;
    mnDrugB: TMenuItem;
    mnDrugC: TMenuItem;
    mnDrugD: TMenuItem;
    mnDrugE: TMenuItem;
    mnDrugF: TMenuItem;
    mnDrugG: TMenuItem;
    mnDrugH: TMenuItem;
    mndrugI: TMenuItem;
    mndrugJ: TMenuItem;
    mnDrugK: TMenuItem;
    mnDrugL: TMenuItem;
    ckStimulateNictMem: TCheckBox;
    mnDrugM: TMenuItem;
    mnDrugN: TMenuItem;
    ckStimulateSkelMus: TCheckBox;
    mnDrugO: TMenuItem;
    mnDrugP: TMenuItem;
    mnDrugQ: TMenuItem;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnTubocurarineClick(Sender: TObject);
    procedure mnNoradrenalineClick(Sender: TObject);
    procedure pbDisplayPaint(Sender: TObject);
    procedure mnNeostigmineClick(Sender: TObject);
    procedure mnCarbacholClick(Sender: TObject);
    procedure mnAtropineClick(Sender: TObject);
    procedure mnHistamineClick(Sender: TObject);
    procedure mnHexamethoniumClick(Sender: TObject);
    procedure mnGallamineClick(Sender: TObject);
    procedure mnVerapamilClick(Sender: TObject);
    procedure mnAcetylcholineClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure sbRecordChange(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure mnPrintClick(Sender: TObject);
    procedure pbDisplayMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure mnExitClick(Sender: TObject);
    procedure mnContentsClick(Sender: TObject);
    procedure mnAboutClick(Sender: TObject);
    procedure mnMepyramineClick(Sender: TObject);
    procedure mnLoadCatClick(Sender: TObject);
    procedure mnSaveCatClick(Sender: TObject);
    procedure mnNewCatClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure mnMorphineClick(Sender: TObject);
    procedure mnNaloxoneClick(Sender: TObject);
    procedure mnAdenosineClick(Sender: TObject);
    procedure mn8SPTClick(Sender: TObject);
    procedure mnDrugAClick(Sender: TObject);
    procedure mnDrugBClick(Sender: TObject);
    procedure mnDrugCClick(Sender: TObject);
    procedure mnDrugDClick(Sender: TObject);
    procedure mnDrugEClick(Sender: TObject);
    procedure mnDrugFClick(Sender: TObject);
    procedure mnDrugGClick(Sender: TObject);
    procedure mnDrugHClick(Sender: TObject);
    procedure mndrugIClick(Sender: TObject);
    procedure mndrugJClick(Sender: TObject);
    procedure mnDrugKClick(Sender: TObject);
    procedure mnDrugLClick(Sender: TObject);
    procedure mnDrugMClick(Sender: TObject);
    procedure mnDrugNClick(Sender: TObject);
    procedure PrintSetup1Click(Sender: TObject);
    procedure mnDrugOClick(Sender: TObject);
    procedure mnDrugPClick(Sender: TObject);
    procedure mnDrugQClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure InitializeDisplay ;
    procedure CalculateTrace ;
    procedure PrintTraces ;
    procedure InitializeSimulation ;
  public
    { Public declarations }
    ProgName : string ;
  end;

    TDrug = record
          Dose : single ;
          DoseInjected : single ;
          Conc : single ;
          OnRate : single ;
          RemovalRate : single ;
          ed50 : single ;
          ed50_alpha : single ;
          ed50_beta : single ;
          ed50g : single ;
          ed50m : single ;
          Index : Integer ;
          end ;

function MaxFlt( const Buf : array of Single ) : Single ;
function MinFlt( const Buf : array of Single ) : Single ;
function AddNoise( Proportion : single ) : single ;
Procedure UpdateCirculatingDrug( var Drug : TDrug ) ;
function ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
function PrinterPointsToPixels( PointSize : Integer ) : Integer ;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}
type
    TState = (Recording,Idle,Replay) ;
    TTime = record
          time : single ;
          diastole : single ;
          systole : single ;
          step : single ;
          SkelMuscleStimulus : single ;
          NictMemStimulus : single ;
          VagusStimulus : single ;
          end ;

    TBP = record
        diastolic : single ;
        systolic : single ;
        mean : single ;
        value : single ;
        end ;

    THeart = record
           Rate : Single ;
           SystolicForce : Single ;
           end ;

    TMuscle = record
           Contraction : single ;
           Twitch : single ;
           Contracture : single ;
           PeakTwitch : single ;
           StimulusInterval : single ;
           Stimulated : boolean ;
           end ;
    TMarker = record
            Index : single ;
            Value : single ;
            end ;
    TNerve = record
           Stimulated : boolean ;
           StimulusInterval : single ;
           StimulusActivity : single ;
           Activity : single ;
           end ;


TString6 = string[6] ;
TChannel = record
         xMin : single ;
         xMax : single ;
         yMin : single ;
         yMax : single ;
         xScale : single ;
         yScale : single ;
         Left : LongInt ;
         Right : LongInt ;
         Top : LongInt ;
         Bottom : LongInt ;
         TimeZero : single ;
         ADCUnits : {Tstring6} string;
         ADCName : {TString6} string ;
         ZeroIndex : LongInt ;
         CursorTime : single ;
         CursorValue : single ;
         color : TColor ;
         Value : single ;
         InUse : boolean ;
         end ;
         TBuf = Array[0..15871] of single ;
         TFileBuf = Array[0..511] of single ;

var
   State : TState ;
   OldPos : Array[0..ChannelLimit] of TPoint ;
   Channel : Array[0..Channellimit] of TChannel ;
   ShortName : Array[0..100] of string ;
   DoseUnits : Array[0..100] of string ;
   Buf : TBuf ;
   FileBuf : TFileBuf ;
   FileBufPointer, EndOfFileBuf : LongInt ;
   FileHandle : Integer ;
   FilePointer : LongInt ;
   FileName : string ;
   BufPointer,EndOfBuf,FirstQuarter,LastQuarter : LongInt ;
   Initialized : boolean ;
   t : TTime ;
   BP : TBP ;
   Heart : THeart ;
   Marker : TMarker ;
   SkelMuscle : TMuscle ;
   NictMem : TMuscle ;
   Vagus : TNerve ;
   Tubocurarine : TDrug ;
   Hyoscine : TDrug ;
   Gallamine : TDrug ;
   Neostigmine: TDrug ;
   Physostigmine : TDrug ;
   Morphine : TDrug ;
   Naloxone : TDrug ;
   Acetylcholine : TDrug ;
   ArterialAcetylcholine : TDrug ;
   Adenosine : TDrug ;
   EightSPT : TDrug ;
   Carbachol : TDrug ;
   ArterialCarbachol : TDrug ;
   Noradrenaline : TDrug ;
   Atropine : TDrug ;
   Histamine : TDrug ;
   Mepyramine : TDrug ;
   Hexamethonium : TDrug ;
   Verapamil : TDrug ;
   Atracurium : TDrug ;

   { Unknown drugs }
   DrugA : TDrug ;
   DrugB : TDrug ;
   DrugC : TDrug ;
   DrugD : TDrug ;
   DrugE : TDrug ;
   DrugF : TDrug ;
   DrugG : TDrug ;
   DrugH : TDrug ;
   DrugI : TDrug ;
   DrugJ : TDrug ;
   DrugK : TDrug ;
   DrugL : TDrug ;
   DrugM : TDrug ;
   DrugN : TDrug ;
   DrugO : TDrug ;
   DrugP : TDrug ;
   DrugQ : TDrug ;

   Ganglion : single ;
   ChartWidth : single ;
   VagusNerveAcetylcholine : single ;
   CirculatingAcetylcholine : single ;
   Baroreceptors : single ;
   Dead : boolean ;
   Dying : LongInt ;

procedure TMainForm.FormCreate(Sender: TObject);
{ ---------------------------------------
  Initialisations when program is started
  ---------------------------------------}
begin

     Caption := 'The Virtual Cat V2.6.2 (26/3/14)' ;
     ProgName := Caption ;

     Filehandle := -1 ;
     InitializeSimulation ;
     end;


procedure TMainForm.InitializeSimulation ;
{ -------------------------------------------------------
  Initialise simulation - Set all variable back to normal
  -------------------------------------------------------}
const
   pFilePrefix : PChar = 'CAT' ;

var
   ch,iCount,iNum : Integer ;
   x : single ;
   Done,Deleted : Boolean ;
   Prefix,TempName,TempPath : Array[0..255] of Char ;
   LocalHelpFile : string ;
begin
     { Close and delete the existing temp. file }
     if FileHandle >= 0 then begin
        FileClose( FileHandle ) ;
        FileHandle := -1 ;
        Deleted := DeleteFile( PChar(FileName) ) ;
        end ;

     { Get path to temporary file directory }
     GetTempPath( High(TempPath), TempPath ) ;

     { Create a temporary file name in that directory }
     iNum := GetTempFileName( TempPath, pFilePrefix, 0, TempName ) ;
     FileName := TempName ;

     Caption := ProgName ;

     { Open temporary file }
     FileHandle := FileCreate( FileName ) ;
     if FileHandle < 0 then begin
        MessageDlg('Cannot open work file!', mtWarning,[mbOK],0) ;
        close ;
        end ;

     // Get path to help file
     LocalHelpFile := TempPath + 'Cat.chm' ;
     CopyFile( Pchar(ExtractFilePath(ParamStr(0)) + 'Cat.chm'),
               Pchar(LocalHelpFile),
               false ) ;
     Application.HelpFile := LocalHelpFile ;

     iCount := 0 ;
     ShortName[0] := 'None' ;
     { Tubocurarine }

     Tubocurarine.Dose := 0. ;
     Tubocurarine.DoseInjected := 0. ;
     Tubocurarine.ed50 := 0.3*AddNoise( 0.5 ) ; {V2.1 = 0.17}
     Tubocurarine.ed50g := 4.*AddNoise( 0.5 ) ; {V2.1 = 0.5 }
     Tubocurarine.OnRate := 0.01 ;
     Tubocurarine.RemovalRate := 0.002 ;
     Inc(iCount) ;
     Tubocurarine.Index := iCount ;
     ShortName[Tubocurarine.Index] := 'Tub' ;
     DoseUnits[Tubocurarine.Index] := 'mg/kg' ;

     { Gallamine }
     Gallamine.Dose := 0. ;
     Gallamine.DoseInjected := 0. ;
     Gallamine.ed50 := 1.*AddNoise( 0.5 ) ;
     Gallamine.ed50g := 300.*AddNoise( 0.5 ) ;
     Gallamine.ed50m := 0.5*AddNoise( 0.5 ) ;
     Gallamine.OnRate := 0.01 ;
     Gallamine.RemovalRate := 0.004 ;
     Inc(iCount) ;
     Gallamine.Index := iCount ;
     ShortName[iCount] := 'Gal' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Neostigmine }
     Neostigmine.Dose := 0. ;
     Neostigmine.DoseInjected := 0. ;
     Neostigmine.ed50 := 0.1*AddNoise( 0.5 ) ;
     Neostigmine.OnRate := 0.01 ;
     Neostigmine.RemovalRate := 0.0005 ;
     Inc(iCount) ;
     Neostigmine.Index := iCount ;
     ShortName[Neostigmine.Index] := 'Neo' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Physostigmine }
     Physostigmine.Dose := 0. ;
     Physostigmine.DoseInjected := 0. ;
     Physostigmine.ed50 := 0.1*AddNoise( 0.5 ) ;
     Physostigmine.OnRate := 0.01 ;
     Physostigmine.RemovalRate := 0.0005 ;
     Inc(iCount) ;
     Physostigmine.Index := iCount ;
     ShortName[Physostigmine.Index] := 'Phy' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Morphine }
     Morphine.Dose := 0. ;
     Morphine.DoseInjected := 0. ;
     Morphine.ed50 := 5.*AddNoise( 0.5 ) ;
     Morphine.OnRate := 0.01 ;
     Morphine.RemovalRate := 0.0002 ;
     Inc(iCount) ;
     Morphine.Index := iCount ;
     ShortName[Morphine.Index] := 'Mor' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Naloxone (morphine antagonist) }
     Naloxone.Dose := 0. ;
     Naloxone.DoseInjected := 0. ;
     Naloxone.ed50 := 0.3*AddNoise( 0.5 ) ;
     Naloxone.OnRate := 0.01 ;
     Naloxone.RemovalRate := 0.00001 ;
     Inc(iCount) ;
     Naloxone.Index := iCount ;
     ShortName[Naloxone.Index] := 'Nal' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Acetylcholine }
     Acetylcholine.Dose := 0. ;
     Acetylcholine.DoseInjected := 0. ;
     Acetylcholine.ed50 := 0.001*AddNoise( 0.5 ) ;
     Acetylcholine.ed50g := 0.2*AddNoise( 0.5 ) ;
     Acetylcholine.OnRate := 0.02 ;
     Acetylcholine.RemovalRate := 0.003 ;
     Inc(iCount) ;
     Acetylcholine.Index := iCount ;
     ShortName[Acetylcholine.Index] := 'Ach' ;
     DoseUnits[iCount] := 'ug/kg' ;

     { Acetylcholine (when injected in artery to tibialis muscle) }
     ArterialAcetylcholine.Dose := 0. ;
     ArterialAcetylcholine.DoseInjected := 0. ;
     ArterialAcetylcholine.ed50 := 0.002*AddNoise( 0.5 ) ;
     ArterialAcetylcholine.OnRate := 0.1 ;
     ArterialAcetylcholine.RemovalRate := 0.08 ;
     Inc(iCount) ;
     ArterialAcetylcholine.Index := iCount ;
     ShortName[ArterialAcetylcholine.Index] := 'Ach(Art)' ;
     DoseUnits[iCount] := 'ug/kg' ;

     { Adenosine }
     Adenosine.Dose := 0. ;
     Adenosine.DoseInjected := 0. ;
     Adenosine.ed50 := 0.03*AddNoise( 0.5 ) ;
     Adenosine.OnRate := 0.022 ;
     Adenosine.RemovalRate := 0.0025 ;
     Inc(iCount) ;
     Adenosine.Index := iCount ;
     ShortName[Adenosine.Index] := 'Ade' ;
     DoseUnits[iCount] := 'mg/kg' ;


     { 8-SPT Adenosine antagonist }
     EightSPT.Dose := 0. ;
     EightSPT.DoseInjected := 0. ;
     EightSPT.ed50 := 1.*AddNoise( 0.5 ) ;
     EightSPT.OnRate := 0.022 ;
     EightSPT.RemovalRate := 0.00001 ;
     Inc(iCount) ;
     EightSPT.Index := iCount ;
     ShortName[EightSPT.Index] := '8SPT' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Carbachol }
     Carbachol.Dose := 0. ;
     Carbachol.DoseInjected := 0. ;
     Carbachol.ED50 := 0.001*AddNoise( 0.5 ) ;
     Carbachol.ED50g := 0.3*AddNoise( 0.5 ) ;
     Carbachol.OnRate := 0.02 ;
     Carbachol.RemovalRate := 0.003 ;
     Inc(iCount) ;
     Carbachol.Index := iCount ;
     ShortName[Carbachol.Index] := 'Cch' ;
     DoseUnits[iCount] := 'ug/kg' ;

     { Carbachol (injected in artery to skeletal muscle}
     ArterialCarbachol.Dose := 0. ;
     ArterialCarbachol.DoseInjected := 0. ;
     ArterialCarbachol.ED50 := 0.001*AddNoise( 0.5 ) ;
     ArterialCarbachol.OnRate := 0.1 ;
     ArterialCarbachol.RemovalRate := 0.05 ;
     Inc(iCount) ;
     ArterialCarbachol.Index := iCount ;
     ShortName[ArterialCarbachol.Index] := 'Cch(art)' ;
     DoseUnits[iCount] := 'ug/kg' ;

     { Noradrenaline }
     Noradrenaline.dose := 0. ;
     Noradrenaline.DoseInjected := 0. ;
     Noradrenaline.ED50_alpha := 0.01*AddNoise( 0.5 ) ;
     Noradrenaline.ED50_beta := 0.01*AddNoise( 0.5 ) ;
     Noradrenaline.OnRate := 0.02 ;
     Noradrenaline.RemovalRate := 0.008 ;
     Inc(iCount) ;
     Noradrenaline.Index := iCount ;
     ShortName[Noradrenaline.Index] := 'Nor' ;
     DoseUnits[iCount] := 'ug/kg' ;


     { Atropine }
     Atropine.Dose := 0. ;
     Atropine.DoseInjected := 0. ;
     Atropine.ED50 := 1.2*AddNoise( 0.5 ) ;
     Atropine.OnRate := 0.01 ;
     Atropine.RemovalRate := 0.00001 ;
     Inc(iCount) ;
     Atropine.Index := iCount ;
     ShortName[Atropine.Index] := 'Atr' ;

     { Hyoscine }
     Hyoscine.Dose := 0. ;
     Hyoscine.DoseInjected := 0. ;
     Hyoscine.ED50 := 0.9*AddNoise( 0.5 ) ;
     Hyoscine.OnRate := 0.01 ;
     Hyoscine.RemovalRate := 0.00001 ;
     Inc(iCount) ;
     Hyoscine.Index := iCount ;
     ShortName[Hyoscine.Index] := 'Hyo' ;
     DoseUnits[iCount] := 'mg/kg' ;


     { Histamine }
     Histamine.Dose := 0. ;
     Histamine.DoseInjected := 0. ;
     Histamine.ED50 := 1.*AddNoise( 0.5 ) ;
     Histamine.OnRate := 0.01 ;
     Histamine.RemovalRate := 0.008 ;
     Inc(iCount) ;
     Histamine.Index := iCount ;
     ShortName[Histamine.Index] := 'His' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Mepyramine (H1 antagonist) }
     Mepyramine.Dose := 0. ;
     Mepyramine.DoseInjected := 0. ;
     Mepyramine.ED50 := 1.*AddNoise( 0.5 ) ;
     Mepyramine.OnRate := 0.01 ;
     Mepyramine.RemovalRate := 0.00001  ;
     Inc(iCount) ;
     Mepyramine.Index := iCount ;
     ShortName[Mepyramine.Index] := 'Mep' ;
     DoseUnits[iCount] := 'mg/kg' ;


     { Hexamethonium  (nicotinic ganglion blocker) }
     Hexamethonium.Dose := 0. ;
     Hexamethonium.DoseInjected := 0. ;
     Hexamethonium.ED50 := 3.*AddNoise( 0.5 ) ;
     Hexamethonium.OnRate := 0.01 ;
     Hexamethonium.RemovalRate := 0.001 ;
     Inc(iCount) ;
     Hexamethonium.Index := iCount ;
     ShortName[Hexamethonium.Index] := 'Hex' ;
     DoseUnits[iCount] := 'mg/kg' ;


     { Verapamil (Ca channel blocker) }
     Verapamil.Dose := 0. ;
     Verapamil.DoseInjected := 0. ;
     Verapamil.ED50 := 5.*AddNoise( 0.5 ) ;
     Verapamil.OnRate := 0.02 ;
     Verapamil.RemovalRate := 0.0003 ;
     Inc(iCount) ;
     Verapamil.Index := iCount ;
     ShortName[Verapamil.Index] := 'Ver' ;
     DoseUnits[iCount] := 'mg/kg' ;

     { Atracurium }
     Atracurium.Dose := 0. ;
     Atracurium.DoseInjected := 0. ;
     Atracurium.ed50 := 0.15*AddNoise( 0.5 ) ;
     Atracurium.ed50g := 1000*AddNoise( 0.5 ) ;
     Atracurium.OnRate := 0.011 ;
     Atracurium.RemovalRate := 0.004 ;
     Inc(iCount) ;
     Atracurium.Index := iCount ;
     ShortName[Atracurium.Index] := 'Atc' ;
     DoseUnits[Atracurium.Index] := 'mg/kg' ;


     { Unknown drugs }
     Inc(iCount) ;
     DrugA.Index := iCount ;
     ShortName[iCount] := 'Dr A' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugB.index := iCount ;
     ShortName[iCount] := 'Dr B' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugC.Index := iCount ;
     ShortName[iCount] := 'Dr C' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugD.Index := iCount ;
     ShortName[iCount] := 'Dr D' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugE.Index := iCount ;
     ShortName[iCount] := 'Dr E' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugF.Index := iCount ;
     ShortName[iCount] := 'Dr F' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugG.Index := iCount ;
     ShortName[iCount] := 'Dr G' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugH.Index := iCount ;
     ShortName[iCount] := 'Dr H' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugI.Index := iCount ;
     ShortName[iCount] := 'Dr I' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugJ.Index := iCount ;
     ShortName[iCount] := 'Dr J' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugK.Index := iCount ;
     ShortName[iCount] := 'Dr K' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugL.Index := iCount ;
     ShortName[iCount] := 'Dr L' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugM.Index := iCount ;
     ShortName[iCount] := 'Dr M' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugN.Index := iCount ;
     ShortName[iCount] := 'Dr N' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugO.Index := iCount ;
     ShortName[iCount] := 'Dr O' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugP.Index := iCount ;
     ShortName[iCount] := 'Dr P' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;
     DrugQ.Index := iCount ;
     ShortName[iCount] := 'Dr Q' ;
     DoseUnits[iCount] := 'mg/kg' ;

     Inc(iCount) ;


     { Chart recorder traces }
     Channel[ChBP].ADCName := 'BP' ;
     Channel[ChBP].ADCUnits := 'mmHg' ;
     Channel[ChBP].yMin := 0. ;
     Channel[ChBP].yMax := BPMax ;
     Channel[ChBP].color := clBlue ;
     Channel[ChBP].InUse := True ;
     Channel[ChBPAvg].ADCName := '' ;
     Channel[ChBPAvg].ADCUnits := 'mmHg' ;
     Channel[ChBPAvg].yMin := 0. ;
     Channel[ChBPAvg].yMax := BPMax ;
     Channel[ChBPAvg].color := clBlack ;
     Channel[ChBPAvg].InUse := True ;
     Channel[ChHR].ADCName := 'HR' ;
     Channel[ChHR].ADCUnits := 'BPM' ;
     Channel[ChHR].yMin := 0. ;
     Channel[ChHR].yMax := HRMax ;
     Channel[ChHR].color := clRed ;
     Channel[ChHR].InUse := True ;
     Channel[ChSK].ADCName := 'Sk.Mus.' ;
     Channel[ChSK].ADCUnits := 'gms' ;
     Channel[ChSK].yMin := 0. ;
     Channel[ChSK].yMax := SKMax ;
     Channel[ChSK].color := clGreen ;
     Channel[ChSK].InUse := True ;
     Channel[ChNM].ADCName := 'Nic.Mem.' ;
     Channel[ChNM].ADCUnits := 'gms' ;
     Channel[ChNM].yMin := 0. ;
     Channel[ChNM].yMax := NMMax ;
     Channel[ChNM].color := clPurple ;
     Channel[ChNM].InUse := True ;

     t.Step := 0.04 ;
     t.time := 0. ;
     t.systole := 0. ;
     bp.value := 90. / 200. ;
     baroreceptors := bp.value ;

     t.SkelMuscleStimulus := 1. ;
     SkelMuscle.StimulusInterval := 1. ;
     SkelMuscle.PeakTwitch := 0. ;
     SkelMuscle.Twitch := 0. ;
     SkelMuscle.Contracture := 0. ;
     SkelMuscle.Contraction := 0. ;

     t.NictMemStimulus := 2. ;
     NictMem.StimulusInterval := 2.5 ;
     NictMem.PeakTwitch := 0. ;
     NictMem.Twitch := 0. ;

     t.VagusStimulus := 4. ;
     Vagus.StimulusInterval := 4. ;
     Vagus.Stimulated := True ;

     BufPointer := -1 ;
     EndOfBuf := ((High(Buf) + 1 ) div NumChannels) - 1;
     FirstQuarter := ((EndOfBuf+1) div 4) -1;
     LastQuarter := EndofBuf - FirstQuarter  ;
     ChartWidth := t.Step*High(Buf) / NumChannels ;
     for ch := 0 to ChMarker-1 do begin
         Channel[ch].xMin := 0 ;
         Channel[ch].xMax := EndOfBuf ;
         Channel[ch].Value := 0. ;
         end ;

     EndOfFileBuf := High(FileBuf) ;
     FileBufPointer := 0 ;
     Dead := False ;
     Dying := 0 ;
     InitializeDisplay ;
     State := Idle ;
     bStart.Enabled := True ;
     bStop.Enabled := False ;
     sbRecord.Enabled := False ;
     end ;


procedure TMainForm.TimerTimer(Sender: TObject);
{ ----------------------------------------------------
  Timed event scheduler ... does simulation time steps
  ----------------------------------------------------}
var
   xPix,yPix,ch,j,i,jTo,jFrom0,jFrom1,nw : LongInt ;
   OK : boolean ;
begin
     case State of

          { Create simulated cat experiment traces }
          Recording : Begin
                { Calculate next set of simulation values }
                CalculateTrace ;
                { Plot results on chart traces }
                xPix := Trunc( (BufPointer - Channel[0].xMin)*Channel[0].xScale ) ;
                for ch := 0 to chMarker-1 do begin
                    if Channel[ch].InUse then begin
                       j := BufPointer*NumChannels + ch ;
                       yPix := Channel[ch].Bottom -
                               Trunc( Buf[j]*Channel[ch].yScale ) ;
                       pbDisplay.canvas.pen.color := Channel[ch].color ;

                       { If no information about previous position ... used current }
                       if OldPos[ch].x = 0 then OldPos[ch] := Point( xPix, yPix ) ;
                       pbDisplay.canvas.MoveTo( OldPos[ch].x, OldPos[ch].y ) ;

                       pbDisplay.canvas.LineTo( xPix, yPix ) ;
                       OldPos[ch] := Point( xPix, yPix ) ;
                       end ;
                    end ;

                { Display marker at bottom of screen }
                j := BufPointer*NumChannels + chMarker ;
                if Buf[j] > 0. then begin
                   yPix := pbDisplay.Height - pbDisplay.canvas.TextHeight('X') ;
                   i := Trunc(Buf[j]) ;
                   pbDisplay.canvas.TextOut( xPix,yPix,ShortName[i] +
                                             format(' %.3g %s',[Buf[j+1],
                                                               DoseUnits[i]]) ) ;
                   end ;

                { Write results to file }
                j := BufPointer*NumChannels ;
                for ch := 0 to ChannelLimit do begin
                    FileBuf[FileBufPointer] := Buf[j+ch] ;
                    Inc(FileBufPointer) ;
                    end ;
                if FileBufPointer > EndofFileBuf then begin
                   if FileWrite(FileHandle,FileBuf,Sizeof(FileBuf))
                      <> Sizeof(FileBuf) then begin
                      bStop.click ;
                      MessageDlg('Out of disk space!', mtWarning,[mbOK],0) ;
                      end ;
                   FileBufPointer := 0 ;
                   end ;

                t.time := t.time + t.Step ;

                { If at end of display ... refresh display
                  retaining last 25% of traces }
                if BufPointer >= EndofBuf then begin
                   jTo := 0 ;
                   jFrom0 := LastQuarter*NumChannels ;
                   jFrom1 := (EndOfBuf+1)*NumChannels -1  ;
                   for j := jFrom0 to jFrom1 do begin
                       Buf[jTo] := Buf[j] ;
                       Inc(jTo) ;
                       end ;
                   BufPointer := FirstQuarter ;
                   InitializeDisplay ;
                   end ;
                end ;

          Replay : begin
                 { Replay recorded traces }
                 FilePointer := SizeOf(FileBuf)  ;
                 FilePointer := FilePointer*sbRecord.position ;
                 nw := FileSeek( FileHandle, FilePointer, 0 ) ;
                 nw := FileRead( FileHandle,Buf,Sizeof(Buf)) ;
                 BufPointer := ((nw) div (4*NumChannels)) - 1 ;
                 InitializeDisplay ;
                 State := Idle ;
                 end ;
          end ;
     end;


procedure TMainForm.InitializeDisplay ;
{ ----------------------------
  Initialise a display window
  13/10/97 Grid added
  ---------------------------}
var
   Height,ch,cTop,xPix,yPix,yPixTop,yPixBottom,i,j,n,k : LongInt ;
   x,y,yStep,xStep : single ;
begin

     { Determine number of channels in use }
     n := 0 ;
     for ch := 0 to ChMarker-1 do
         if (Channel[Ch].InUse) and (ch <> ChBPAvg) then Inc(n) ;
     if n <= 0 then n := 1 ;
     Height := (pbDisplay.Height - pbDisplay.canvas.TextHeight('X') ) div n ;

     { Define display area for each channel }
     cTop := 0 ;
     for ch := 0 to ChMarker-1 do begin
         if Channel[ch].InUse then begin
            Channel[ch].Left := 0 ;
            Channel[ch].Right := pbDisplay.width ;
            Channel[ch].Top := cTop ;
            Channel[ch].Bottom := Channel[ch].Top + Height ;
            Channel[ch].xMin := Channel[0].xMin ;
            Channel[ch].xMax := Channel[0].xMax ;
            Channel[ch].xScale := (Channel[ch].Right - Channel[ch].Left) /
                            (Channel[ch].xMax - Channel[ch].xMin ) ;
            Channel[ch].yScale := (Channel[ch].Bottom - Channel[ch].Top) /
                            (Channel[ch].yMax - Channel[ch].yMin ) ;
            if ch <> ChBP then cTop := cTop + Height ;
            end ;
         end ;

     { Erase display }
     pbDisplay.canvas.brush.color := clWhite ;
     pbDisplay.canvas.fillrect(pbDisplay.canvas.ClipRect);

     { Draw grid }
     for ch := 0 to chMarker-1 do begin
         if Channel[ch].InUse and (ch <> ChBPAvg) then begin
            { Grid colour }
            pbDisplay.canvas.pen.color := clGray ;
            { Horizontal grid }
            y := 0. ;
            if (Ch = ChBP) or (Ch = ChHR) then yStep := 20.
            else yStep := 10. ;

            while y <= (Channel[ch].yMax - yStep) do begin
                  yPix := Channel[ch].bottom -
                          Trunc( (y-Channel[ch].yMin)*Channel[ch].yScale ) ;
                  pbDisplay.canvas.Polyline( [Point(Channel[ch].Left, yPix),
                                              Point(Channel[ch].Right, yPix) ]) ;
                  y := y + yStep ;
                  end ;

            { Vertical grid lines }
            x := (Channel[0].xMax - Channel[0].xMin) / 10. ;
            yPixTop := Channel[ch].bottom -
                          Trunc((Channel[ch].yMax - yStep -Channel[ch].yMin)
                          *Channel[ch].yScale ) ;
            yPixBottom := Channel[ch].bottom -
                          Trunc((-Channel[ch].yMin)*Channel[ch].yScale ) ;
            xStep := x ;
            while x < Channel[0].xMax do begin
                  xPix := Trunc( (x - Channel[0].xMin)*Channel[0].xScale )
                          + Channel[0].Left ;
                  pbDisplay.canvas.Polyline( [Point(xPix, yPixTop),
                                              Point(xPix, yPixBottom)]) ;
                  x := x + xStep ;
                  end ;
            end ;
         end ;

     pbDisplay.canvas.pen.style := psSolid ;

     { Draw channels }
     for ch := 0 to chMarker-1 do begin
            if Channel[ch].InUse then begin
               pbDisplay.canvas.pen.color := Channel[ch].color ;
               for i := 0 to BufPointer do begin
                   xPix := Trunc( (i - Channel[0].xMin)*Channel[0].xScale ) ;
                   j := i*NumChannels + ch ;
                   yPix := Channel[ch].Bottom - Trunc( Buf[j]*Channel[ch].yScale ) ;
                   if i = 0 then pbDisplay.canvas.MoveTo( xPix, yPix )
                            else pbDisplay.canvas.LineTo( xPix, yPix ) ;
                   end ;
               if BufPointer >= 0 then OldPos[ch] := Point(xPix,yPix)
                                   else OldPos[ch] := Point( 0,0 ) ;
               end ;
            end ;

     { Display markers }
     for i := 0 to Bufpointer do begin
         j := i*NumChannels + chMarker ;
         if Buf[j] > 0. then begin
            xPix := Trunc( (i - Channel[0].xMin)*Channel[0].xScale ) ;
            yPix := pbDisplay.Height - pbDisplay.canvas.TextHeight('X') ;
            k := Trunc(Buf[j]) ;
            pbDisplay.canvas.TextOut( xPix,yPix,ShortName[k] +
                                      format(' %.3g %s',[Buf[j+1],
                                                         DoseUnits[k]]) ) ;

            end ;
         end ;

     { Display Channel Name(s) }
     for ch := 0 to ChMarker-1 do
         if (ch <> ChBPAvg) and Channel[ch].InUse then
            pbDisplay.Canvas.TextOut( Channel[ch].Left,
            Channel[ch].Top + pbDisplay.Canvas.TextHeight('X'),
            ' ' + Channel[ch].ADCName ) ;

     Initialized := True ;
     end ;


procedure TMainForm.PrintTraces ;
{ ------------------------------------
  Print hard copy of traces on screen
  -----------------------------------}
var
   LineSpace,ChanHeight,n,CTop,ch,i,j,k :LongInt ;
   TopMargin,BottomMargin,LeftMargin,RightMargin : LongInt ;
   x,xStep,y,yStep : single ;
   xPix,yPix,yPixTop,yPixBottom : LongInt ;
   PrChan : Array[0..ChannelLimit] of TChannel ;
begin
     { Set printer typeface and size }
     { Set plot size/fonts }
     Printer.canvas.font.name := 'Arial'  ;
{$IFDEF WIN32}
     Printer.canvas.font.Size := 10 ;
{$ELSE}
     Printer.canvas.font.height := PrinterPointsToPixels(10) ;
{$ENDIF}
    LineSpace := printer.canvas.textheight( 'X' ) ;

     screen.cursor := crHourGlass ;
     Printer.BeginDoc ;

     { Define plotting region on page }
     TopMargin := Printer.PageHeight div 8 ;
     BottomMargin := TopMargin*2 ;
     LeftMargin := printer.PageWidth div 8 ;
     RightMargin := LeftMargin ;

     { Set up printer page scaling }
     n := 0 ;
     for ch := 0 to ChMarker-1 do
         if (Channel[ch].InUse) and (ch<>ChBPAvg) then Inc(n) ;
     if n < 1 then n := 1 ;

     { Set position on page and scaling factor for each channel }
     ChanHeight := (Printer.PageHeight - TopMargin - BottomMargin) div n ;
     CTop := TopMargin ;
     for ch := 0 to ChMarker-1 do begin
         PrChan[ch] := Channel[ch] ;
         if PrChan[ch].InUse then begin
             PrChan[ch].Left := LeftMargin ;
             PrChan[ch].Right := Printer.PageWidth - RightMargin ;
             PrChan[ch].Top := CTop ;
             PrChan[ch].Bottom := PrChan[ch].Top + ChanHeight ;
             PrChan[ch].xScale := (PrChan[ch].Right - PrChan[ch].Left) /
                                  (PrChan[ch].xMax  - PrChan[ch].xMin ) ;
             PrChan[ch].yScale := (PrChan[ch].Bottom - PrChan[ch].Top) /
                                  (PrChan[ch].yMax   - PrChan[ch].yMin ) ;
             if ch<>ChBP then CTop := CTop + ChanHeight ;
             { Copy the channel scale settings for this channel to
               the marker channel to make sure it has appropriate X axis
               scale settings (any active channel will do) 30/10/97 }
             PrChan[ChMarker] := PrChan[ch] ;
             end ;
         end ;


     { Draw grid }
     for ch := 0 to chMarker-1 do begin
         if PrChan[ch].InUse and (ch <> ChBPAvg) then begin
            { Grid line style }
            Printer.canvas.pen.style := psDot ;
            { Horizontal grid }
            y := 0. ;
            if (Ch = ChBP) or (Ch = ChHR) then yStep := 20.
            else yStep := 10. ;
            while y <= (PrChan[ch].yMax - yStep) do begin
                  yPix := PrChan[ch].bottom -
                          Trunc( (y-PrChan[ch].yMin)*PrChan[ch].yScale ) ;
                  Printer.canvas.Polyline( [Point(PrChan[ch].Left, yPix),
                                            Point(PrChan[ch].Right, yPix) ]) ;
                  y := y + yStep ;
                  end ;

            { Vertical grid lines }
            x := (PrChan[ch].xMax - PrChan[ch].xMin) / 10. ;
            yPixTop := PrChan[ch].bottom -
                          Trunc((PrChan[ch].yMax - yStep -PrChan[ch].yMin)
                          *PrChan[ch].yScale ) ;
            yPixBottom := PrChan[ch].bottom -
                          Trunc((-PrChan[ch].yMin)*PrChan[ch].yScale ) ;
            xStep := x ;
            while x < PrChan[ch].xMax do begin
                  xPix := Trunc( (x - PrChan[ch].xMin)*PrChan[ch].xScale )
                          + PrChan[ch].Left ;
                  Printer.canvas.Polyline( [Point(xPix, yPixTop),
                                              Point(xPix, yPixBottom)]) ;
                  x := x + xStep ;
                  end ;
            end ;
         end ;

     Printer.canvas.pen.style := psSolid ;

     { Draw channels traces}
     for ch := 0 to chMarker-1 do begin
         if PrChan[ch].InUse then begin
            for i := 0 to BufPointer do begin
                xPix := Trunc( (i - PrChan[ch].xMin)*PrChan[ch].xScale )
                        + PrChan[ch].Left ;
                j := i*NumChannels + ch ;
                yPix := PrChan[ch].Bottom - Trunc( Buf[j]*PrChan[ch].yScale ) ;
                if i = 0 then Printer.canvas.MoveTo( xPix, yPix )
                         else Printer.canvas.LineTo( xPix, yPix ) ;
                end ;
            end ;
         end ;

     { Display Channel Names }
     Printer.Canvas.Font.Size := 10 ;
     for ch := 0 to ChMarker-1 do
         if PrChan[ch].InUse and (ch <> ChBPAvg) then
            Printer.Canvas.TextOut( PrChan[ch].Left,
                                    PrChan[ch].Top + LineSpace,
                                    ' ' + PrChan[ch].ADCName ) ;

{$IFDEF WIN32}
     Printer.canvas.font.Size := 8 ;
{$ELSE}
     Printer.canvas.font.height := PrinterPointsToPixels(8) ;
{$ENDIF}

     { Display markers }
     for i := 0 to Bufpointer do begin
         j := i*NumChannels + chMarker ;
         if Buf[j] > 0. then begin
            xPix := Trunc( (i - PrChan[chMarker].xMin)*PrChan[chMarker].xScale )
                    + PrChan[chMarker].Left ;
            yPix := (Printer.PageHeight - BottomMargin) + (LineSpace div 2) ;
            k := Trunc(Buf[j]) ;
            Printer.canvas.TextOut( xPix,yPix,ShortName[k] +
                                    format(' %.3g %s',[Buf[j+1],DoseUnits[k]]) ) ;
            end ;
         end ;

    { Print user name at top of page }
{$IFDEF WIN32}
     Printer.canvas.font.Size := 10 ;
{$ELSE}
     Printer.canvas.font.height := PrinterPointsToPixels(10) ;
{$ENDIF}
    LineSpace := printer.canvas.TextHeight('X') ;
    Printer.Canvas.TextOut(LeftMargin,TopMargin - LineSpace,
                           'User: ' + AboutFrm.edName.text ) ;

    { Print program ident. and date/time at bottom of page }
{$IFDEF WIN32}
     Printer.canvas.font.Size := 8 ;
{$ELSE}
     Printer.canvas.font.height := PrinterPointsToPixels(8) ;
{$ENDIF}
    LineSpace := printer.canvas.TextHeight('X') ;
    Printer.Canvas.TextOut( Printer.PageWidth div 20,
                            Printer.PageHeight - 2*LineSpace,
                            Caption + ' ' + DateTimeToStr(Now) ) ;

    Printer.EndDoc ;
    screen.cursor := crDefault ;
    end ;



procedure TMainForm.CalculateTrace ;
{ ---------------------------------
  Calculate next step in simulation
  ---------------------------------}
var
   dbp,PulseInterval,PeripheralFlow,x,sum : single ;
   AlphaR,BetaR,MachR,ADeR,OpioidR,HisR,Ca_channels,epc : single ;
   NorHeart,NicR,Accelerans,MachRHeart,BaroSS,Old : single ;
   Ach,Cholinesterase : single ;
   Desensitisation : single ;
   occupancy,efficacy : single ;
   ch,j : Integer ;

begin
     { Update drugs in circulation }
     UpdateCirculatingDrug( Tubocurarine ) ;
     UpdateCirculatingDrug( Hyoscine ) ;
     UpdateCirculatingDrug( Gallamine ) ;
     UpdateCirculatingDrug( Neostigmine ) ;
     UpdateCirculatingDrug( Physostigmine ) ;
     UpdateCirculatingDrug( Morphine ) ;
     UpdateCirculatingDrug( Naloxone ) ;
     UpdateCirculatingDrug( Acetylcholine ) ;
     UpdateCirculatingDrug( ArterialAcetylcholine ) ;
     UpdateCirculatingDrug( Adenosine ) ;
     UpdateCirculatingDrug( EightSPT ) ;
     UpdateCirculatingDrug( Carbachol ) ;
     UpdateCirculatingDrug( ArterialCarbachol ) ;
     UpdateCirculatingDrug( Noradrenaline ) ;
     UpdateCirculatingDrug( Histamine ) ;
     UpdateCirculatingDrug( Mepyramine ) ;
     UpdateCirculatingDrug( Atropine ) ;
     UpdateCirculatingDrug( Hexamethonium ) ;
     UpdateCirculatingDrug( Verapamil ) ;
     UpdateCirculatingDrug( Atracurium ) ;

     { Opioid receptor activation }
     sum := Morphine.Dose/Morphine.ED50 + Naloxone.Dose/Naloxone.ED50 ;
     occupancy := sum / ( 1. + sum ) ;
     efficacy := (Morphine.Dose/Morphine.ED50) / ( sum + 0.001 ) ;
     OpioidR := efficacy*occupancy ;

     { Adenosine receptor activation }
     sum := Adenosine.Dose/Adenosine.ED50 + EightSPT.Dose/EightSPT.ED50 ;
     occupancy := sum / ( 1. + sum ) ;
     efficacy := (Adenosine.Dose/Adenosine.ED50) / ( sum + 0.001 ) ;
     AdeR := efficacy*occupancy ;

     { Tubocurarine & morphine causes histamine release
       ... so include their additions to circulating histamine }
     Histamine.Dose := Histamine.Dose +
                               ((0.01*Histamine.ed50*Tubocurarine.dose) /
                               (Tubocurarine.dose + Tubocurarine.ed50))
                               + ((0.001*Morphine.ed50*Morphine.dose) /
                                 (Morphine.dose + Morphine.ed50)) ;

     { Histamine receptor activation }
     sum := Histamine.Dose/Histamine.ed50
            + Mepyramine.Dose/Mepyramine.ed50 ;
     occupancy := sum / ( 1. + sum ) ;
     efficacy := (Histamine.Dose/Histamine.ed50)/(sum + 0.001) ;
     HisR :=  efficacy*occupancy ;

     { Cholinesterase activity: 1=fully active, 0=inhibited
       Affects neuromuscular junction, ganglia, and causes
       an accumulation of Ach in circulation }

     Cholinesterase := 1. / ( 1. + Neostigmine.Dose/Neostigmine.ed50 +
                                   Physostigmine.Dose/Physostigmine.ed50 ) ;

     { Effects of nicotinic ganglion blockers on ganglionic transmission
       (Reversed by anticholinesterases ) }
       { V2.2 1/10/97 anticholinesterase reversal removed, requested by EGR }

     ganglion := 1. / ( 1. + {((1. + 9.*Cholinesterase)/10. ) *}
                             ( Hexamethonium.Dose/Hexamethonium.ed50
                               + Tubocurarine.Dose/Tubocurarine.ed50g
                               + Gallamine.Dose/Gallamine.ed50g ) );

     { If serum cholinesterase is inactivated, ach builds up in circulation }
     Acetylcholine.Dose := Acetylcholine.Dose +
                          (1. - Cholinesterase)*Acetylcholine.ed50*t.step*0.1 ;

     { Vagus nerve stimulation (Blocked by morphine ) }

       { Set vagus nerve activity to a base level (0.1) +
         activity due baroceptors activated by high B.P. }
       {BaroSS := 1. / ( 1. + exp( -((bp.mean*BPMax)-110. )/7. ) ) ; }
       Baroreceptors := Baroreceptors + MaxFlt([bp.mean*BPMax-120. ,0. ])/300. ;
       Baroreceptors := MinFlt( [MaxFlt([Baroreceptors*0.8,0. ]),1. ] ) ;
       Vagus.Activity := 0.9*Baroreceptors  + 0.04 ;

       { Add extra activity when Vagus is stimulated }
       if( (t.time > t.VagusStimulus) and ckStimulateVagus.checked ) then begin
            t.VagusStimulus := t.time + Vagus.StimulusInterval ;
            Vagus.StimulusActivity := 0.2;
            end
       else Vagus.StimulusActivity := MaxFlt( [Vagus.StimulusActivity*0.8,0.]) ;

       Vagus.Activity := Vagus.Activity + Vagus.StimulusActivity ;

       { Release of Ach from vagus nerve blocked either by
         block of ganglionic transmission OR by presynaptic
         transmitter release block by morphine }
       { V2.2 1/10/97 Cholinesterase inhibition now enhances release of
         Ach from vagus, requested by EGR }

       VagusNerveAcetylcholine := (4.0 + ( (1.0 - Cholinesterase)*10.0 ) )
                                  * Acetylcholine.ed50
                                  * ganglion
                                  * (1. - OpioidR)
                                  * (1. - AdeR)
                                  * Vagus.Activity ;

     { Effects on muscarinic Ach receptors
       Combination of vagus nerve activity (blockable by ganglion blockers),
       and circulating Ach act as agonists. Atropine and Hyoscine act
       as MachR blockers. Effect of Ach is enhanced by presence of
       an anticholinesterase }
     CirculatingAcetylcholine := Acetylcholine.Dose * ( 2. - Cholinesterase ) ;
     Acetylcholine.RemovalRate := 0.003*(1. + Cholinesterase ) ;

     sum := (  (VagusNerveAcetylcholine/Acetylcholine.ed50)
             + (CirculatingAcetylcholine/Acetylcholine.ed50)
             + (Carbachol.Dose/Carbachol.ed50)
             + (Atropine.Dose/Atropine.ed50)
             + (Hyoscine.Dose/Hyoscine.ed50)
             + (Gallamine.Dose/Gallamine.ed50m) );
     occupancy := sum / ( 1. + sum ) ;
     efficacy := (  VagusNerveAcetylcholine/Acetylcholine.ed50
                  + CirculatingAcetylcholine/Acetylcholine.ed50
                  + Carbachol.Dose/Carbachol.ed50 )/(sum + 0.001) ;
     MachRHeart :=  efficacy*occupancy ;

     { Effects on Ca channels (Verapamil) }

     ca_channels := 1./(1. + Verapamil.Dose/Verapamil.ed50);


     { Nicotinic receptor activity }
     sum := ( (CirculatingAcetylcholine/Acetylcholine.ed50g)
             + (Carbachol.Dose/Carbachol.ed50g) ) ;
     occupancy := sum / ( 1. + sum ) ;
     efficacy := ( + CirculatingAcetylcholine/Acetylcholine.ed50g
                   + Carbachol.Dose/Carbachol.ed50g )/(sum + 0.001) ;
     NicR :=  efficacy*occupancy ;

     Accelerans := (0.02*(1. - Baroreceptors) + 0.9*NicR )
                   * ganglion
                   * (1. - OpioidR)
                   * (1. - AdeR) ;

     { Update Heart Rate }

     { Noradrenaline dose acting on heart (from circulation and from
       accelerans nerve) }
     NorHeart := Noradrenaline.Dose + Accelerans*3.*Noradrenaline.ED50_beta ;

     { Effects on adrenoceptors }
     AlphaR := NorHeart/(NorHeart + Noradrenaline.ed50_alpha) ;
     BetaR := NorHeart/(NorHeart + Noradrenaline.ed50_beta) ;

     Heart.Rate := 1. + (120.
                     - 130.*MachRHeart
                     - 110.*AdeR
                     + 100.*BetaR )*ca_channels;
     Heart.Rate := MaxFlt([ Heart.Rate*AddNoise(0.02), 0.01 ] );
     PulseInterval := 60. / MaxFlt([Heart.Rate,1.]) ;

     { Update Blood Pressure }

     AlphaR := Noradrenaline.Dose /
              (Noradrenaline.Dose + Noradrenaline.ed50_alpha) ;
     BetaR := Noradrenaline.Dose /
              (Noradrenaline.Dose + Noradrenaline.ed50_beta) ;
     x := Acetylcholine.Dose * ( 2. - Cholinesterase ) ;

     sum := x/Acetylcholine.ed50 +
              (Carbachol.dose/Carbachol.ed50) +
              (Atropine.dose/Atropine.ed50) +
              (Hyoscine.dose/Hyoscine.ed50 ) ;
     occupancy := sum / ( 1. + sum ) ;
     efficacy := ( (x/Acetylcholine.ed50) +
                   (Carbachol.dose / Carbachol.ed50) ) / (sum + 0.001) ;
     MachR :=  efficacy*occupancy ;

     PeripheralFlow := 0.04 - AlphaR*0.03 - 0.013*(1. - ca_channels)
                       + 0.03*MachR
                       + 0.028*AdeR
                       + (0.07*hexamethonium.dose)/
                         (hexamethonium.dose+hexamethonium.ed50)
                       + (0.1*HisR) ;

     dbp := Heart.SystolicForce*0.5*(2.-bp.value) - PeripheralFlow*bp.value ;
     bp.value := (bp.value + dbp)*AddNoise(0.001) ;


     if( t.time >= t.systole ) then begin
            BetaR := NorHeart/(NorHeart + Noradrenaline.ed50_beta) ;
            Heart.SystolicForce := 0.02 +(0.13
                                  + 0.13*BetaR
                                  - 0.04*MachRHeart
                                  - 0.13*AdeR
                                  )*ca_channels ;
            Heart.SystolicForce := MaxFlt( [0.01,Heart.SystolicForce] ) ;
            t.diastole := t.time + 0.1 ;
            t.diastole := t.time + 0.1 ;
            t.systole := t.diastole + PulseInterval ;
            bp.diastolic := bp.value ;
            end ;

     if ( t.time >= t.diastole ) then begin

            bp.systolic := bp.value ;
            t.diastole := 1E30 ;

            edBPSys.text := format( '%3.0f mmHg', [bp.systolic*BPMax] ) ;
            edBPDia.text := format( '%3.0f mmHg', [bp.diastolic*BPMax] ) ;
            bp.mean := bp.diastolic + 0.3*(bp.systolic-bp.diastolic);
            edBPMean.text := format( '%3.0f mmHg', [bp.mean*BPMax] ) ;
            edHR.text := format( '%3.0f bpm', [Heart.Rate] ) ;

            Heart.SystolicForce := 0.;
            end ;


     { * Nerve-evoked skeletal muscle contractions *
       Blocked by Tubocurarine & Gallamine
       Block reversed by Neostigmine, Physostigmine }

     { High doses of carbachol and acetylcholine (in the presense of
       anti-cholinesterase) desensitise the neuromuscular junction ) }

     Ach := Acetylcholine.Dose*(1.0 + 10.0*(1.0 - Cholinesterase)) ;
     Sum := (Ach/(Acetylcholine.ED50*20.0)) + (Carbachol.Dose/(Carbachol.ED50*10.0)) ;
     Desensitisation := 1.0 / ( (Sum*Sum) + 1.0 ) ;

     if( t.time >= t.SkelMuscleStimulus ) and ckStimulateSkelMus.checked then begin
           t.SkelMuscleStimulus := t.time + SkelMuscle.StimulusInterval ;
           epc := (1.0 + 6.0*(1. - Cholinesterase))/
                  ( 1.0 + Tubocurarine.Dose/Tubocurarine.ED50
                       + Gallamine.Dose/Gallamine.ED50
                       + Atracurium.Dose/Atracurium.ED50 ) ;

           SkelMuscle.PeakTwitch := SKMax*0.55*AddNoise(0.03) *
           ( 1./ ( 1. + exp(-((epc- 0.6)/0.1))  )) *
           ( 1. + 0.5*(1. - Cholinesterase)/
                  (1.+ 4.*(Tubocurarine.Dose/Tubocurarine.ED50
                           + Gallamine.Dose/Gallamine.ED50
                           + Atracurium.Dose/Atracurium.ED50)) ) ;
           SkelMuscle.Twitch := SkelMuscle.PeakTwitch*Desensitisation ;
           edSkelMus.text := format( '%3.0f gms', [SkelMuscle.PeakTwitch] ) ;
           end
       else begin
           if not ckStimulateSkelMus.checked then SkelMuscle.PeakTwitch := 0.0 ;
           SkelMuscle.Twitch := SkelMuscle.Twitch / 4. ;
           end ;

       { ** Contracture of skeletal muscle caused by injection of
         Ach directly into artery supplying muscle **
         See page 17.21 Bowman & Rand }

       { Effective Ach concentration boosted by inhibiting cholinesterase }
       Ach := ArterialAcetylcholine.Dose * (5.0 - 4.0*Cholinesterase ) ;

       { Contracture inhibited by Nicotinic ACh receptor blockers }
       sum := (Ach/ArterialAcetylcholine.ed50) +
              (ArterialCarbachol.Dose/ArterialCarbachol.ed50) +
              (Tubocurarine.Dose/Tubocurarine.ED50)
              + (Atracurium.Dose/Atracurium.ED50)
              + (Gallamine.Dose/Gallamine.ED50) + 1E-4 ;
       occupancy := sum / ( 1.0 + sum ) ;
       efficacy := ( (Ach/ArterialAcetylcholine.ed50)
                     + (ArterialCarbachol.Dose/ArterialCarbachol.ed50) )
                   / (sum + 0.001) ;

       SkelMuscle.Contracture := SKMax * efficacy * occupancy * Desensitisation
                                 * AddNoise(0.03);

       { Total contraction is sum of nerve-evoked twitch and drug-evoked
         contracture }
       SkelMuscle.Contraction := SkelMuscle.Twitch + SkelMuscle.Contracture ;

       edSkelMus.text := format( '%3.0f gms',
                         [SkelMuscle.PeakTwitch+SkelMuscle.Contracture] ) ;

     { * Nictitating Membrane *
         Affected by Ganglion blocking drugs, adrenoceptor agonists
         adenosine (blocks) and morphine (blocks) }

       if( t.time > t.NictMemStimulus ) and ckStimulateNictMem.checked then begin
            t.NictMemStimulus := t.time + NictMem.StimulusInterval ;
            NictMem.PeakTwitch := (ganglion * (1. - AdeR) * (1. - OpioidR))
                                        *NMMax*0.5*AddNoise(0.03) ;
            NictMem.Contraction := NictMem.Contraction + NictMem.PeakTwitch ;
            edNicMem.text := format( '%3.0f gms', [NictMem.Contraction] ) ;
            end
       else begin
            NictMem.PeakTwitch := NictMem.PeakTwitch * 0.8 ;
            NictMem.Contraction :=  (NictMem.PeakTwitch
                                     + (0.5*NMMax*AlphaR) ) ;
            end ;

     { The cat dies if the B.P. falls too low for too long }
     if not Dead then begin
        if bp.mean*BPMAX < 20. then Inc(Dying)
                               else Dying := 0 ;
        if Dying = 600 then begin
           bp.mean := 0. ;
           bp.value := 0. ;
           bp.systolic := 0. ;
           Heart.Rate := 0. ;
           SkelMuscle.Contraction := 0. ;
           NictMem.Contraction := 0. ;
           j := pbDisplay.font.size ;
           pbDisplay.canvas.font.size := 16 ;
           pbDisplay.canvas.TextOut( pbDisplay.Width div 4,
                                     pbDisplay.Height div 2,
                                     'Your cat has just died!!!' ) ;
           pbDisplay.canvas.font.size := j ;
           Dead := True ;
           end ;
        end
     else begin
        bp.mean := 0. ;
        bp.value := 0. ;
        bp.systolic := 0. ;
        Heart.Rate := 0. ;
        SkelMuscle.Contraction := 0. ;
        NictMem.PeakTwitch:= 0. ;
        NictMem.Contraction := 0. ;
        end ;


     Inc(BufPointer) ;
     j := BufPointer*NumChannels ;
     Buf[j+chBP] := bp.value*BPMax ;
     Buf[j+chBPAvg] := bp.Mean*BPMax ;
     Buf[j+chHR] := Heart.Rate*AddNoise(0.01) ;
     Buf[j+chSK] := SkelMuscle.Contraction + AddNoise(0.5) ;
     Buf[j+chNm] := NictMem.Contraction + AddNoise(0.5) ;
     Buf[j+chMarker] := Marker.Index ;
     Marker.Index := 0. ;
     Buf[j+chMarkerValue] := Marker.Value ;

     end ;

function MaxFlt( const Buf : array of Single ) : Single ;
{ Return the largest value in the array 'Buf' }
var
   i : LongInt ;
   Max : Single ;
begin
     Max:= -1E38 ;
     for i := 0 to High(Buf) do
         if Buf[i] > Max then Max := Buf[i] ;
     Result := Max ;
     end ;

function MinFlt( const Buf : array of Single ) : Single ;
{ Return the smallest value in the array 'Buf' }
var
   i : LongInt ;
   Min : Single ;
begin
     Min:= 1E38 ;
     for i := 0 to High(Buf) do
         if Buf[i] < Min then Min := Buf[i] ;
     Result := Min ;
     end ;

function AddNoise( Proportion : single ) : single ;
{ -------------------------------------------------------
  Create a random scale factor varying over range defined
  by <proportion>
  -------------------------------------------------------}
begin
     AddNoise := 1. + ((2.*random)-1. )*Proportion ;
     end ;

Procedure UpdateCirculatingDrug( var Drug : TDrug ) ;
begin
     Drug.Dose := Drug.Dose + Drug.OnRate*(Drug.DoseInjected - Drug.Dose)
                            - (Drug.Dose*Drug.RemovalRate);
     Drug.Dose := MaxFlt( [Drug.Dose, 0. ] ) ;
     Drug.DoseInjected := MaxFlt( [Drug.DoseInjected -
                                   Drug.DoseInjected*Drug.RemovalRate, 0. ] ) ;
     end ;


procedure TMainForm.pbDisplayPaint(Sender: TObject);
begin
     InitializeDisplay ;
     end;


function ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
{ ---------------------------------------------------
  Extract a floating point number from a string which
  may contain additional non-numeric text
  ---------------------------------------
  Comma added to supported command Italian decimal separator}
var
   CNum : string ;
   i : integer ;
begin
     CNum := '' ;
     for i := 1 to length(CBuf) do begin
         if CBuf[i] in ['0'..'9', 'E', 'e', '+', '-', '.', ',' ] then
            CNum := CNum + CBuf[i]
         else CNum := CNum + ' ' ;
         end ;
     try
        if Length(CNum)>0 then ExtractFloat := StrToFloat( CNum )
                          else ExtractFloat := Default ;
     except
        on E : EConvertError do ExtractFloat := Default ;
        end ;
     end ;


procedure TMainForm.mnTubocurarineClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Tubocurarine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Tubocurarine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Tubocurarine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;



procedure TMainForm.mnNoradrenalineClick(Sender: TObject);
begin
     AddDoseLow.lbDrugName.caption := 'Noradrenaline' ;
     AddDoseLow.ShowModal ;
     if AddDoseLow.ModalResult = mrOK then begin
        Noradrenaline.DoseInjected := 0.001*ExtractFloat( AddDoseLow.cbDose.text, 1. ) ;
        Marker.Index := Noradrenaline.Index ;
        Marker.Value := ExtractFloat(AddDoseLow.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'ug/kg' ;
        end ;
     end ;


procedure TMainForm.mnNeostigmineClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Neostigmine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Neostigmine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Neostigmine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end ;

procedure TMainForm.mnCarbacholClick(Sender: TObject);
{ --------------------
  Inject carbachol
  --------------------}
begin
     AddDoseLow.lbDrugName.caption := 'Carbachol' ;
     AddDoseLow.ShowModal ;
     if AddDoseLow.ModalResult = mrOK then begin
        Carbachol.DoseInjected := 0.001*ExtractFloat( AddDoseLow.cbDose.text, 1. ) ;
        Marker.Value := ExtractFloat(AddDoseLow.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'ug/kg' ;
        if AddDoseLow.rgInjectionSite.ItemIndex = 1 then begin
           Marker.Index := ArterialCarbachol.Index ;
           ArterialCarbachol.DoseInjected := Carbachol.DoseInjected ;
           end
        else Marker.Index := Carbachol.Index ;
        end ;
     end ;


procedure TMainForm.mnAtropineClick(Sender: TObject);
{ --------------------
  Inject atropine
  --------------------}
begin
     AddDoseHigh.lbDrugName.caption := 'Atropine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Atropine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Atropine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;


procedure TMainForm.mnHistamineClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Histamine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Histamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Histamine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnHexamethoniumClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Hexamethonium' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Hexamethonium.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Hexamethonium.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;


procedure TMainForm.mnGallamineClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Gallamine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Gallamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Gallamine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnVerapamilClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Verapamil' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Verapamil.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Verapamil.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnAcetylcholineClick(Sender: TObject);
begin
     AddDoseLow.lbDrugName.caption := 'Acetylcholine' ;
     AddDoseLow.ShowModal ;
     if AddDoseLow.ModalResult = mrOK then begin
        Acetylcholine.DoseInjected := 0.001*ExtractFloat( AddDoseLow.cbDose.text, 1. ) ;
        Marker.Value := ExtractFloat(AddDoseLow.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'ug/kg' ;
        if AddDoseLow.rgInjectionSite.ItemIndex = 1 then begin
           Marker.Index := ArterialAcetylcholine.Index ;
           ArterialAcetylcholine.DoseInjected := Acetylcholine.DoseInjected ;
           end
        else Marker.Index := Acetylcholine.Index ;
        end ;
     end;

procedure TMainForm.mnMorphineClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Morphine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Morphine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Morphine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnNaloxoneClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Naloxone' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Naloxone.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Naloxone.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnAdenosineClick(Sender: TObject);
begin
     AddDoseLow.lbDrugName.caption := 'Adenosine' ;
     AddDoseLow.ShowModal ;
     if AddDoseLow.ModalResult = mrOK then begin
        Adenosine.DoseInjected := 0.001*ExtractFloat( AddDoseLow.cbDose.text, 1. ) ;
        Marker.Index := Adenosine.Index ;
        Marker.Value := ExtractFloat(AddDoseLow.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'ug/kg' ;
        end ;
     end;


procedure TMainForm.mn8SPTClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := '8-SPT' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        EightSPT.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := EightSPT.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;


procedure TMainForm.FormResize(Sender: TObject);
var
   MinHeight,MinWidth : Integer ;
begin

     MinWidth := ControlGrp.Width + StimGrp.Width + 20 ; ;
     MinHeight := BPgrp.Height + HRGrp.Height + NicGrp.Height +
                  SkelGrp.Height + ControlGrp.Height + 100 ;
     if ClientHeight < MinHeight then Height := Minheight ;
     if Width < MinWidth then Width := MinWidth ;

     BPGrp.Left := Width - BPGrp.Width - 20 ;
     HRGrp.Left := BPGrp.Left ;
     NicGrp.Left := BPGrp.Left ;
     SkelGrp.Left := BPGrp.Left ;
     ControlGrp.Top := ClientHeight - ControlGrp.Height - 10 ;
     pbDisplay.Height := ControlGrp.Top - pbDisplay.Top - 10 ;
     pbDisplay.Width := BPgrp.Left - pbDisplay.Left - 10 ;
     StimGrp.Top := ControlGrp.Top ;
     StimGrp.Left := ControlGrp.Left + ControlGrp.Width + 3 ;

     HRGrp.Top := pbDisplay.Top + pbDisplay.Height div 4 ;
     if HRGrp.Top <= BPGrp.Top + BPGrp.Height + 5 then
        HRGrp.Top := BPGrp.Top + BPGrp.Height + 5 ;
     NicGrp.Top := pbDisplay.Top + 2*pbDisplay.Height div 4 ;
     SkelGrp.Top := pbDisplay.Top + 3*pbDisplay.Height div 4 ;

     end;

procedure TMainForm.HelpClick(Sender: TObject);
begin
     OptionsFrm.BPColor.brush.color := Channel[ChBP].color ;
     OptionsFrm.ckBPShow.checked := Channel[ChBP].InUse ;
     OptionsFrm.HRColor.brush.color := Channel[ChHR].color ;
     OptionsFrm.ckHRShow.checked := Channel[ChHR].InUse ;
     OptionsFrm.SKColor.brush.color := Channel[ChSK].color ;
     OptionsFrm.ckSKShow.checked := Channel[ChSK].InUse ;
     OptionsFrm.NMColor.brush.color := Channel[ChNM].color ;
     OptionsFrm.ckNMShow.checked := Channel[ChNM].InUse ;
     OptionsFrm.ShowModal ;
     if OptionsFrm.ModalResult = mrOK then begin
        Channel[ChBP].color := OptionsFrm.BPColor.brush.color ;
        Channel[ChBP].InUse := OptionsFrm.ckBPShow.checked ;
        Channel[ChBPAvg].InUse := Channel[ChBP].InUse ;
        Channel[ChHR].color := OptionsFrm.HRColor.brush.color ;
        Channel[ChHR].InUse := OptionsFrm.ckHRShow.checked ;
        Channel[ChSK].color := OptionsFrm.SKColor.brush.color ;
        Channel[ChSK].InUse := OptionsFrm.ckSkShow.checked ;
        Channel[ChNM].color := OptionsFrm.NMColor.brush.color ;
        Channel[ChNM].InUse := OptionsFrm.ckNMShow.checked ;
        State := Replay ;
        end ;
     end;

procedure TMainForm.bStopClick(Sender: TObject);
var
   nBufs,FileLength : LongInt ;
begin
     State := Replay ;
     FileLength := FileSeek( FileHandle, 0, 2 ) ;
     nBufs := FileLength div SizeOf(FileBuf) ;
     if nBufs > 2 then begin
        sbRecord.Max := nBufs-1 ;
        sbRecord.Min := 0 ;
        sbRecord.Enabled := True ;
        end 
     else sbRecord.Enabled := False ;
     bStop.Enabled := False ;
     bStart.Enabled := True ;
     mnFile.Enabled := True ;
     if FileLength > 0 then sbRecord.Enabled := True
     end;

procedure TMainForm.sbRecordChange(Sender: TObject);
begin
     State := Replay ;
end;

procedure TMainForm.bStartClick(Sender: TObject);
var
   FileLength : LongInt ;
begin
     State := Recording ;
     FileLength := FileSeek( FileHandle, 0, 2 ) ;
     bStart.Enabled := False ;
     bStop.Enabled := True ;
     sbRecord.Enabled := False ;
     mnFile.Enabled := False ;
     BufPointer := -1 ;
     InitializeDisplay ;
     end;

procedure TMainForm.mnPrintClick(Sender: TObject);
begin
     PrintTraces ;
     end;


procedure TMainForm.pbDisplayMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   ch : Integer ;
   XValue,YValue : single ;
begin
     XValue := (X-Channel[0].left) / Channel[0].xScale + Channel[0].xMin ;
     for ch := 0 to ChMarker-1 do if Channel[ch].InUse then begin
         if (Y <= Channel[ch].Bottom) and (Y > Channel[ch].Top) then begin
            YValue := ( Channel[ch].Bottom - Y) / Channel[ch].yScale ;
            edCursor.text := format('T= %.1f s %s= %.1f %s',[ XValue,
                             Channel[ch].ADCName,
                             YValue,
                             Channel[ch].ADCUnits] ) ;
            end ;
         end ;
     end ;


procedure TMainForm.mnExitClick(Sender: TObject);
{ -----------------
  Stop the program
  ----------------}
begin
     Close ;
     end ;

procedure TMainForm.mnContentsClick(Sender: TObject);
begin
//     Application.HelpContext(20);
     // Note shell execute is used to prevent Navigation to the web page being cancelled
     // when file run from a network under Windows 7
     ShellExecute(Handle,'open', 'c:\windows\hh.exe',PChar(Application.HelpFile),
     nil, SW_SHOWNORMAL) ;
     end;

procedure TMainForm.mnAboutClick(Sender: TObject);
begin
     AboutFrm.ShowModal ;
     end;

procedure TMainForm.mnMepyramineClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Mepyramine' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Mepyramine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := Mepyramine.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;



procedure TMainForm.mnLoadCatClick(Sender: TObject);
{ -------------------------------------------
  Load an experiment from a .CAT storage file
  -------------------------------------------}
var
   TempHandle : Integer ;
   i,nBufs,FileLength,nw : longInt ;
   OK : boolean ;
begin
     if OpenDialog.execute then begin

           { Open .CAT file containing experiment }
           TempHandle := FileOpen( OpenDialog.FileName, fmOpenReadWrite ) ;
           Caption := ProgName + ' : ' + OpenDialog.FileName ;

           { Find out how big it is }
           FileLength := FileSeek( TempHandle, 0, 2 ) ;
           nBufs := FileLength div SizeOf(FileBuf) ;

           { Create an empty working file }
           if FileHandle >=0 then FileClose( FileHandle ) ;
           FileHandle := FileCreate( FileName ) ;

           { Copy data from .CAT storage file into work file }
           nw := FileSeek( TempHandle, 0, 0 ) ;
           for i := 1 to nBufs do begin
               nw := FileRead( TempHandle, FileBuf, Sizeof(FileBuf)) ;
               nw := FileWrite( FileHandle, FileBuf, Sizeof(FileBuf)) ;
               end ;

           if nw <> Sizeof(FileBuf) then
              MessageDlg('Out of disk space!', mtWarning,[mbOK],0) ;


           { Close .CAT file }
           FileClose( TempHandle ) ;

           sbRecord.Max := nBufs-1 ;
           sbRecord.Min := 0 ;
           bStart.Enabled := True ;
           bStop.Enabled := False ;
           if nBufs > 0 then sbRecord.Enabled := True ;
           State := Replay ;
           end ;
     end ;


procedure TMainForm.mnSaveCatClick(Sender: TObject);
{ -------------------------------------------
  Save an experiment to a .CAT storage file
  -------------------------------------------}
var
   TempHandle : Integer ;
   i,nw : longInt ;
begin
     if SaveDialog.execute then begin
        { Create .CAT storage file to hold experiment }
        TempHandle := FileCreate( SaveDialog.FileName ) ;

        Caption := ProgName + ' : ' + SaveDialog.FileName ;
        
        { Copy data from .CAT storage file into work file }
        FilePointer := FileSeek( FileHandle, 0, 0 ) ;
        for i := 1 to sbRecord.Max+1 do begin
            nw := FileRead( FileHandle, FileBuf, Sizeof(FileBuf));
            nw := FileWrite( TempHandle, FileBuf, Sizeof(FileBuf)) ;
            end ;
        { Close .CAT file }
        FileClose( TempHandle ) ;
        end ;
     end;


procedure TMainForm.mnNewCatClick(Sender: TObject);
{ ---------------------------
  Reinitialise the experiment
  ---------------------------}

begin
     if MessageDlg('New Experiment! Are you sure?', mtConfirmation,
        [mbYes,mbNo],0) = mrYes then begin
        if FileHandle >= 0 then begin
           FileClose( FileHandle ) ;
           FileHandle := -1 ;
           end ;
        InitializeSimulation ;
        end;
     end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
     AboutFrm.ShowModal ;
     end;


procedure TMainForm.mnDrugAClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug A' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Atropine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugA.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugBClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug B' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Hyoscine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugB.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugCClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug C' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Tubocurarine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugC.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugDClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug D' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Gallamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugD.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugEClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug E' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Atracurium.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugE.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
 end;

procedure TMainForm.mnDrugFClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug F' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Histamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugF.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugGClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug G' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Hyoscine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugG.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugHClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug H' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Gallamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugH.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mndrugIClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug I' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Histamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugI.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
      end;

procedure TMainForm.mndrugJClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug J' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Tubocurarine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugJ.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugKClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug K' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Atropine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugK.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugLClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug L' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Atracurium.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugL.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugMClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug M' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Tubocurarine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugM.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;


procedure TMainForm.mnDrugNClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug N' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Gallamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugN.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugOClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug O' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Hyoscine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugO.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugPClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug P' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Histamine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugP.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;

procedure TMainForm.mnDrugQClick(Sender: TObject);
begin
     AddDoseHigh.lbDrugName.caption := 'Drug Q' ;
     AddDoseHigh.ShowModal ;
     if AddDoseHigh.ModalResult = mrOK then begin
        Tubocurarine.DoseInjected := ExtractFloat( AddDoseHigh.cbDose.text, 1. ) ;
        Marker.Index := DrugQ.Index ;
        Marker.Value := ExtractFloat(AddDoseHigh.cbDose.text,1. ) ;
        DoseUnits[Trunc(Marker.Index)] := 'mg/kg' ;
        end ;
     end;



function PrinterPointsToPixels( PointSize : Integer ) : Integer ;
{ -------------------------------------------
  Convert from text size in points to pixels
  ------------------------------------------}
var
   PixelsPerInch : single ;
begin

     { Get height and width of page (in mm) and calculate
       the size of a pixel (in cm) }
     PixelsPerInch := GetDeviceCaps( printer.handle, LOGPIXELSX ) ;
     PrinterPointsToPixels := Trunc( (PointSize*PixelsPerInch) / 72. ) ;
     end ;





procedure TMainForm.PrintSetup1Click(Sender: TObject);
begin
     PrinterSetupDialog1.Execute ;
     end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin

        Timer.Enabled := False ;

        if FileHandle >= 0 then begin
           FileClose( FileHandle ) ;
           FileHandle := -1 ;
           end ;
        DeleteFile( PChar(FileName) ) ;
        end;

     
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     if MessageDlg('End the Experiment! Are you sure?', mtConfirmation,
        [mbYes,mbNo],0) = mrYes then CanClose := True
                                else CanClose := False ;
     end;

end.
