unit CatMain;
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
// 01.02.20 ..


interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, ExtCtrls,
  Printers, Vcl.ComCtrls,math, HTMLHelpViewer, shellapi, system.types, system.uitypes,
  ScopeDisplay, ValidatedEdit, System.StrUtils, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg  ;

const
     MaxPoints = 10000000 ;
     MaxDisplayPoints = 4000 ;
     BPMax = 200 ;
     MaxADCValue = 2047 ;
     MinADCValue = -2048 ;
    MaxMarkers = 500 ;
    NumBytesPerMarker = 40 ;
    FileHeaderSize = (MaxMarkers+10)*NumBytesPerMarker ;
    DataFileExtension = '.cat' ;

     ChABP = 0 ;   // Arterial blood pressure channel }
     ChHR = 1 ;    // Heart rate channel }
     ChNIC = 2 ;   // Nictitating membrane }
     ChSKM = 3 ;   // Skeletal muscle
     None = -1. ;

     NMMax = 100 ;
     SKMax = 100 ;


type
    TDrugProperties = record
                    Potency : single ;
                    Efficacy : single ;

                    end ;

    TDrug = class(TObject)
            public
            Name : string[40] ;
            ShortName : string ;
            Dose : single ;
            DoseInjected : single ;
            Conc : single ;
            OpioidR : TDrugProperties ;            // Opiate receptors
            AlphaAdR : TDrugProperties ;
            AlphaAdRNicMem : TDrugProperties ;
//            Alpha2AdR : TDrugProperties ;
            BetaAdR : TDrugProperties ;
            BetaAdRHeart : TDrugProperties ;
            MusChR : TDrugProperties ;
            MusChRHeart : TDrugProperties ;
            NicChR : TDrugProperties ;
            NicChRParasympathetic : TDrugProperties ;
            NicChRSympathetic : TDrugProperties ;
            NicChRGanglionBlock : TDrugProperties ;
            NicChRNicMemGanglion : TDrugProperties ;
            NicChRNMJ : TDrugProperties ;
            ChEsterase : TDrugProperties ;
            HMCaChannel : TDrugProperties ;
            SMCaChannel : TDrugProperties ;
            AdenR : TDrugProperties ;
            H1R : TDrugProperties ;
            OnRate : single ;
            RemovalRate : single ;
            MinDose : single ;
            MaxDose : single ;
            Antagonist : Boolean ;
            CloseArterialInjection : Boolean ;
            constructor Create(
                        NameIn : String ;
                        ShortNameIn : string
                        ) ;
            end ;


    TTime = record
          time : single ;
          diastole : single ;
          systole : single ;
          step : single ;
          next : single ;
          StimVagus : single ;
          StimSkeletalMuscle : single ;
          StimNicMembrane : single ;
          end ;

    TBP = record
        diastolic : single ;
        systolic : single ;
        mean : single ;
        value : single ;
        Sum : single ;
        nAvg : Integer ;
        end ;

    THeart = record
           Rate : Single ;
           SystolicForce : Single ;
           MusChR : single ;
           BetaAdR : single ;
           end ;

    TMuscle = record
           Contraction : single ;
           Twitch : single ;
           Contracture : single ;
           PeakTwitch : single ;
           StimulusInterval : single ;
           Stimulated : boolean ;
           AlphaR : single ;
           NicChR : single ;
           end ;

    TNerve = record
           Stimulated : boolean ;
           StimulusInterval : single ;
           StimulusActivity : single ;
           Activity : single ;
           end ;



TString6 = string[6] ;
TFileBuf = Array[0..511] of single ;

  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    mnFile: TMenuItem;
    mnNewCat: TMenuItem;
    mnLoadCat: TMenuItem;
    mnSaveCat: TMenuItem;
    mnPrint: TMenuItem;
    PrintSetup1: TMenuItem;
    mnExit: TMenuItem;
    mnHelp: TMenuItem;
    mnContents: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    Page: TPageControl;
    ChartTab: TTabSheet;
    PictureTab: TTabSheet;
    ExpImage: TImage;
    scDisplay: TScopeDisplay;
    Timer: TTimer;
    TDisplayPanel: TPanel;
    lbTDisplay: TLabel;
    Label1: TLabel;
    edTDisplay: TValidatedEdit;
    bTDisplayDouble: TButton;
    bTDisplayHalf: TButton;
    edStartTime: TValidatedEdit;
    sbDisplay: TScrollBar;
    bStart: TButton;
    bStop: TButton;
    ControlsGrp: TGroupBox;
    TissueGrp: TGroupBox;
    bNewExperiment: TButton;
    GroupBox6: TGroupBox;
    PageControl1: TPageControl;
    AgonistsTab: TTabSheet;
    Label2: TLabel;
    cbAgonist: TComboBox;
    cbAgonistDose: TComboBox;
    bAddAgonist: TButton;
    AntagonistsTab: TTabSheet;
    Label4: TLabel;
    cbAntagonist: TComboBox;
    cbAntagonistDose: TComboBox;
    UnknownsTab: TTabSheet;
    Label7: TLabel;
    cbUnknown: TComboBox;
    cbUnknownDose: TComboBox;
    bAddUnknown: TButton;
    bAddAntagonist: TButton;
    mnEdit: TMenuItem;
    mnCopyData: TMenuItem;
    mnCopyImage: TMenuItem;
    PrinterSetupDialog: TPrinterSetupDialog;
    ckVagusNerve: TCheckBox;
    ckNicMembrane: TCheckBox;
    ckSkeletalMuscle: TCheckBox;
    bStartStimulator: TButton;
    bStopStimulator: TButton;
    rbVenousInjection: TRadioButton;
    rbCloseArterialInjection: TRadioButton;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure mnExitClick(Sender: TObject);
    procedure mnContentsClick(Sender: TObject);
    procedure mnLoadCatClick(Sender: TObject);
    procedure mnSaveCatClick(Sender: TObject);
    procedure mnNewCatClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PrintSetup1Click(Sender: TObject);
    procedure cbAgonistChange(Sender: TObject);
    procedure cbAntagonistChange(Sender: TObject);
    procedure cbUnknownChange(Sender: TObject);
    procedure bAddAgonistClick(Sender: TObject);
    procedure bAddAntagonistClick(Sender: TObject);
    procedure bAddUnknownClick(Sender: TObject);
    procedure edStartTimeKeyPress(Sender: TObject; var Key: Char);
    procedure edTDisplayKeyPress(Sender: TObject; var Key: Char);
    procedure bTDisplayDoubleClick(Sender: TObject);
    procedure bTDisplayHalfClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnCopyImageClick(Sender: TObject);
    procedure mnCopyDataClick(Sender: TObject);
    procedure mnPrintClick(Sender: TObject);
    procedure bNewExperimentClick(Sender: TObject);
    procedure scDisplayCursorChange(Sender: TObject);
    procedure bStartStimulatorClick(Sender: TObject);
    procedure bStopStimulatorClick(Sender: TObject);

  private
    { Private declarations }

    ADC : Array[0..MaxPoints-1] of SmallInt ;
    NumPointsInBuf : Integer ;   // No. of data points in buffer
    StartPoint : Integer ;       // Starting point of chart display
    InitialMixing : Cardinal ;
    MarkerList : TStringList ;   // Chart annotation list

    LastAgonist : Integer ;      // Index of last agonist in drug list
    LastAntagonist : Integer ;      // Index of last antagonist in drug list

   UnsavedData : Boolean ;
   t : TTime ;
   {Standard drugs }
   Drugs : Array[0..50] of TDrug ;
   MusChR : single ;                { Proportion of muscarinic cholinoceptors activated }
   NicChR : single ;                { Proportion of nicotinic cholinoceptors activated }
   NicChRDesensitization : single ; { Proportion of nicotinic cholinoceptors activated at NMJ }
   NicChRGanglionBlock : single ;   // Nicotinic cholinoceptor activation on parasympathetic ganglion neurons
   NicChRNicMemGanglion : single ;  // Nicotinic cholinoceptor activation on nictitating membrane ganglion neurons
   ChEsterase : single ;            // Proportion of cholinesterase active
   AlphaAdR : single ;             { Proportion of Alpha1 adrenoceptors activated }
   BetaAdR : single ;              { Proportion of beta-1 adrenoceptors activated }
   AdenR : single ;                { Proportion of adenosine receptors activated }
   CaChannels : single ;           { Proportion of heart muscle Ca channels blocked }
   OpioidR : single ;              // Opioid receptors
   H1R : single ;                  // Histamine H1 receptors
   Baroreceptors : single ;        // Baroreceptor activation
   PulseInterval : single ;        // Heart pulse interval (s)

   // Index into Drugs[] of neurotransmitters activated by selected nerve pathways
   iVagusStim : Integer ;               // Vagus nerve nerve stimulus transmitter release
   iVagusBaroreceptors : Integer ;      // Vagus nerve trasmitter release by baroreceptor activity
   iAcceleransBaroreceptors : Integer ; // Accelerans nerve transmitter release by baroreceptor activity
   iRestingSympathetic : Integer ;       // Accelerans nerve transmitter release by
   iNMJ : Integer ;                     // NMJ nerve stimulation
   iNicMemPreGanglionic : Integer ;     // Nictitating membrane pre-ganglionic stimulation
   iNicMemPostGanglionic : Integer ;    // Nictitating membrane post-ganglionic stimulation

   Heart : THeart ;       // Heart state
   SkelMuscle : TMuscle ; // Skeletal muscle state
   NicMem : TMuscle ;    // Nictitating membrane state
   BP : TBP ;

   Dead : boolean ;
   Dying : LongInt ;
   Fibrillation : single ;

    procedure StimulateNerves ;
    procedure CalculateTrace ;
    procedure InitializeSimulation ;
    procedure SetAgonistPotency(
              var Drug : TDrugProperties ;
              Potency : single
              ) ;

    procedure SetAntagonistPotency(
              var Drug : TDrugProperties ;
              Potency : single
              ) ;

    Function ReceptorActivation(
          iDrug : Integer ;
          Dose : single ;
          Drug : TDrugProperties ;
          var Numerator : single ;
          var Denominator : single ;
          nPower : Integer
          ) : single ;

    procedure UpdateDisplay ;

    procedure AddChartAnnotations ;
    procedure UpdateDisplayDuration ;

    function AddNoise( Proportion : single ) : single ;
    function ExtractFloat ( CBuf : string ; Default : Single ) : extended ;


    procedure SetDoseList(
              cbDrug : TComboBox ;
              cbDose : TComboBox ) ;

   procedure AddDrugMarker(
             ChartAnnotation : String
             ) ;

   procedure LoadFromFile( FileName : String ) ;
   procedure SaveToFile( FileName : String ) ;

  public
    { Public declarations }
    ProgName : string ;
    WinDir : PChar ;
  end;



var
  MainForm: TMainForm;

implementation

uses PrintUnit, shared ;

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
{ ------------------------------------
  Initialisations when form is created
  ------------------------------------}
var
    i : Integer ;
begin
     Caption := 'Anaesthetised Cat (c) J. Dempster, University of Strathclyde (1996-2021) V3.0.0 (01.02.21)' ;

     ProgName := Caption ;

     Application.HelpFile := ExtractFilePath(ParamStr(0)) + 'cat.chm';

     // Create annotation list
     MarkerList := TStringList.Create ;

     for i := 0 to High(Drugs) do Drugs[i] := Nil ;

     InitializeSimulation ;

     end;


procedure TMainForm.FormDestroy(Sender: TObject);
// ---------------------------
// Tidy up when form destroyed
// ---------------------------
var
    i : Integer ;
begin
    MarkerList.Free ;

    for i := 0 to High(Drugs) do if Drugs[i] <> Nil then Drugs[i].Free ;

end;

procedure TMainForm.InitializeSimulation ;
{ ---------------------------------------------
  Set up initial conditions for simulation
  15/10/97 Better temporary file allocation
  ----------------------------------------}

const
     pFilePrefix : PChar = 'RCV' ;
     FastOn = 0.2 ;
     FastOff = 0.1 ;
     SlowOn = 0.03  ; //0.075
     SlowOff = 0.005 ;
     NerveOn = 50.0 ;
     NerveOff = 50.0 ;
var
   iDrug,i : Integer ;
begin

     Caption := ProgName ;

     {Initialise drug doses and potencies }
     for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
         begin
         Drugs[i].Free ;
         Drugs[i] := Nil ;
         end;

//   Standard Drugs
//   --------------

     iDrug := 0 ;

     // Adrenaline - Adrenoceptor agonist (Alpha = Beta)
     Drugs[iDrug] := TDrug.Create( 'Adrenaline', 'Adr' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 6E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdRNicMem, 6E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, 3.5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, 3.5E-4 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     // Noradrenaline Adrenoceptor agonist (Alpha > Beta )
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Noradrenaline', 'Nor' ) ; // Adrenoceptor agonist
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 2E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdRNicMem, 5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, {7.5E-4} 2.0E-3) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, {7.5E-4 } 2.0E-3 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     // Isoprenaline - Beta adrenoceptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Isoprenaline', 'Iso' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, 5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, 5E-4 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     // Phenylephrine - Alpha adrenoceptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Phenylephrine', 'Phe' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 5E-3 ) ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdRNicMem, 5E-3 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-1 ;
     Inc(iDrug) ;

     // Cholinoceptor agonist
     Drugs[iDrug] := TDrug.Create( 'Acetylcholine', 'Ach' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate :=FastOff ;
     SetAgonistPotency( Drugs[iDrug].MusChR, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].MusChRHeart, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChR, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 0.3) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1.0 ;

     { Acetylcholine (when injected in artery to tibialis muscle) }
 {    ArterialAcetylcholine.Dose := 0. ;
     ArterialAcetylcholine.DoseInjected := 0. ;
     ArterialAcetylcholine.ed50 := 0.002*AddNoise( 0.5 ) ;
     ArterialAcetylcholine.OnRate := 0.1 ;
     ArterialAcetylcholine.RemovalRate := 0.08 ;
     Inc(iCount) ;
     ArterialAcetylcholine.Index := iCount ;
     ShortName[ArterialAcetylcholine.Index] := 'Ach(Art)' ;
     DoseUnits[iCount] := 'ug/kg' ;}

     // Cholinoceptor agonist (non hydrolysable)
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Carbachol', 'CCH' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].NicChR, 0.3 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 0.3) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1.0 ;

     { Suxaamethonium  (depolarizing neuromuscular blocker nicotinic receptor agonist) }
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Suxamethonium', 'Sux' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff*0.5 ;
     SetAgonistPotency( Drugs[iDrug].NicChR, 0.03) ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 0.03) ;
     Drugs[iDrug].MinDose := 0.01 ;
     Drugs[iDrug].MaxDose := 5.0 ;

     // H receptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Histamine', 'His' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].H1R, 0.3 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;


//     Inc(iDrug) ;
//     Drugs[iDrug] := TDrug.Create(  'Acetylcholine', 'Ach' ) ;
//     Drugs[iDrug].OnRate := FastOn ;
//     Drugs[iDrug].RemovalRate := FastOff*2.0 ;
//     SetAgonistPotency( Drugs[iDrug].MusChR, 5E-3 ) ;
 //    SetAgonistPotency( Drugs[iDrug].NicChR, 0.15 ) ;
  //   SetAgonistPotency( Drugs[iDrug].NicChRDesensitization, 0.15 ) ;
//     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 0.3 ) ;
//     SetAgonistPotency( Drugs[iDrug].BetaAdR, 0.15 ) ;
  //   Drugs[iDrug].MinDose := 1E-3 ;
  //   Drugs[iDrug].MaxDose := 1. ;

     // Adenosine Adenoine receptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Adenosine', 'Ade' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AdenR, 0.4 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Morphine Opioid receptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Morphine', 'Mor' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].OpioidR, 0.5 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     LastAgonist := iDrug ;

//   Antagonists
//   -----------

     // Beta adrenceptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Propranolol', 'Pro' ) ;  { Beta Adr. }
     Drugs[iDrug].OnRate := SlowOn ;                         { Antagonist }
     Drugs[iDrug].RemovalRate := SlowOff ;                   { Potency modified 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].BetaAdR, 0.5 ) ;
     SetAntagonistPotency( Drugs[iDrug].BetaAdRHeart, 0.5 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     // ALpha adrenceptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Phentolamine', 'Phe' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].AlphaAdR, 0.1 ) ;
     SetAntagonistPotency( Drugs[iDrug].AlphaAdRNicMem, 0.1 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     // Tubocurarine nicotinic receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Tubocurarine', 'Tub' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].NicChR, 0.2 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChRGanglionBlock, 0.1 ) ;
     SetAntagonistPotency( Drugs[iDrug].NicChRNMJ, 0.2 ) ;
     SetAgonistPotency( Drugs[iDrug].H1R, 3.0 ) ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Gallamine nicotinic + muscarinic receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Gallamine', 'Gal' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff*2.0 ;
     SetAntagonistPotency( Drugs[iDrug].NicChR, 0.75 ) ;
//     SetAgonistPotency( Drugs[iDrug].NicChRGanglionBlock, 0.5 ) ;
     SetAntagonistPotency( Drugs[iDrug].MusChR, 0.5 ) ;
     SetAntagonistPotency( Drugs[iDrug].MusChRHeart, 0.5 ) ;
     SetAntagonistPotency( Drugs[iDrug].NicChRNMJ, 0.75 ) ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Atracurium nicotinic receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Atracurium', 'Atc' ) ;
     Drugs[iDrug].OnRate := SlowOn*1.5 ;
     Drugs[iDrug].RemovalRate := SlowOff*4.0 ;
     SetAntagonistPotency( Drugs[iDrug].NicChR, 0.15 ) ;
     SetAntagonistPotency( Drugs[iDrug].NicChRGanglionBlock, 1.125 ) ;
     SetAntagonistPotency( Drugs[iDrug].NicChRNMJ, 0.15 ) ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Vecuronium nicotinic receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Vecuronium', 'Vec' ) ;
     Drugs[iDrug].OnRate := SlowOn*1.5 ;
     Drugs[iDrug].RemovalRate := SlowOff*4.0 ;
     SetAntagonistPotency( Drugs[iDrug].NicChR, 0.04 ) ;
     SetAntagonistPotency( Drugs[iDrug].NicChRGanglionBlock, 0.45 ) ;
     SetAntagonistPotency( Drugs[iDrug].NicChRNMJ, 0.04 ) ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     { Hexamethonium  (nicotinic ganglion blocker) }
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Hexamethonium', 'Hex' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].NicChRGanglionBlock, 0.5 ) ;
     Drugs[iDrug].MinDose := 0.5 ;
     Drugs[iDrug].MaxDose := 50.0 ;

     // Neoostigmine anticholinersterase
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Neostigmine', 'Neo' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].ChEsterase, 0.1 ) ;
     Drugs[iDrug].MinDose := 0.01 ;
     Drugs[iDrug].MaxDose := 1.0 ;

     // Physostigmine anticholinersterase
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Physostigmine', 'Phy' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].ChEsterase, 0.1 ) ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 1.0 ;

     // Atropine muscarinic receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Atropine', 'Atr' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].MusChR, 0.1 ) ; {Potency reduced to 0.1 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].MusChRHeart, 0.1 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Mepyramine H1 receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Mepyramine', 'Mep' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].H1R, 0.5 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Verapamil Ca channel blocker
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Verapamil', 'Ver' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].HMCaChannel, 0.75 ) ;
     SetAgonistPotency( Drugs[iDrug].SMCaChannel, 0.75 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     // Naloxone Opioid receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Naloxone', 'Nal' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].OpioidR, 0.04 ) ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 1.0 ;
     LastAntagonist := iDrug ;


     // Create list of known agonists and antagonists and dose list for first in list

     cbAgonist.Clear ;
     for i := 0 to LastAgonist do cbAgonist.Items.AddObject( Drugs[i].Name, TObject(i)) ;
     SetDoseList( cbAgonist, cbAgonistDose ) ;

     cbAntagonist.Clear ;
     for i := LastAgonist+1 to LastAntagonist do cbAntagonist.Items.AddObject( Drugs[i].Name, TObject(i)) ;
     SetDoseList( cbAntagonist, cbAntagonistDose ) ;

//   UNKNOWN DRUGS
//   -------------

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Drug A', 'A' ) ; // Acetylcholine
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate :=FastOff ;
     SetAgonistPotency( Drugs[iDrug].MusChR, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].MusChRHeart, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChR, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 0.3) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1.0 ;


     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug B', 'B' ) ;     { Adenosine  }
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AdenR, 0.4 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug C', 'C' ) ;    { Isoprenaline }
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, 5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, 5E-4 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug D', 'D' ) ;    { Noradrenaline }
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 2E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdRNicMem, 5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, {7.5E-4} 2.0E-3) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, {7.5E-4 } 2.0E-3 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug H', 'H' ) ;     { Propanalol }
     Drugs[iDrug].OnRate := SlowOn ;                         { Antagonist }
     Drugs[iDrug].RemovalRate := SlowOff ;                   { Potency modified 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].BetaAdR, 0.5 ) ;
     SetAntagonistPotency( Drugs[iDrug].BetaAdRHeart, 0.5 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug I', 'I' ) ;     { Verapamil }
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].HMCaChannel, 0.75 ) ;
     SetAgonistPotency( Drugs[iDrug].SMCaChannel, 0.75 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 100. ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug K', 'K' ) ;   { Atropine }
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].MusChR, 0.1 ) ; {Potency reduced to 0.1 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].MusChRHeart, 0.1 ) ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Create list of unknown drugs

     cbUnknown.Clear ;
     for i := LastAntagonist+1 to iDrug do cbUnknown.Items.AddObject( Drugs[i].Name, TObject(i)) ;
    SetDoseList( cbUnknown, cbUnknownDose ) ;


{    *** NERVE STIMULATION **************************************************}

     // Accelerans post ganglionic transmitter release
     // Activates beta adrenoceptors on heart
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Accelerans', '' ) ;
     Drugs[iDrug].OnRate := NerveOn ;
     Drugs[iDrug].RemovalRate := NerveOff ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, 1.0 ) ;
     iAcceleransBaroreceptors := iDrug ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Resting Sympathetic', '' ) ;
     Drugs[iDrug].OnRate := NerveOn ;
     Drugs[iDrug].RemovalRate := NerveOff ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 1.0 ) ;
     iRestingSympathetic := iDrug ;

     // Vagus nerve post-ganglion transmitter release produced by baroreceptor activity
     // Activates muscarinic cholinoceptors on heart
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'VagusBaroreceptors', '' ) ;
     Drugs[iDrug].OnRate := NerveOn ;
     Drugs[iDrug].RemovalRate := NerveOff ;
     SetAgonistPotency( Drugs[iDrug].MusChRHeart, 1.0 ) ;
     iVagusBaroreceptors := iDrug ;

     // Vagus nerve post-ganglion transmitter release produced by nerve stimulation
     // Activates muscarinic cholinoceptors on heart
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'VagusStim', '' ) ;
     Drugs[iDrug].OnRate := NerveOn*0.025 ;
     Drugs[iDrug].RemovalRate := NerveOff*0.05 ;
     SetAgonistPotency( Drugs[iDrug].MusChRHeart, 1.0 ) ;
     iVagusStim := iDrug ;

     { Pre-ganglionic nerve innervating nictitating membrane stimulates nicotonic choliniceptors }
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'NicMemPreGanglionic', 'NicMemPreGanglionic' ) ;
     Drugs[iDrug].OnRate := NerveOn*0.05 ;
     Drugs[iDrug].RemovalRate := NerveOff*0.1 ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 1.0 ) ;
     iNicMemPreGanglionic := iDrug ;

     { Post-ganglionic nerve innervating nictitating membrane stimulates alpha adrenoceptors }
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'NicMemPostGanglionic', 'NicMemPostGanglionic' ) ;
     Drugs[iDrug].OnRate := NerveOn*0.05 ;
     Drugs[iDrug].RemovalRate := NerveOff*0.1 ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdRNicMem, 1.0 ) ;
     iNicMemPostGanglionic := iDrug ;

     // Skeletal muscle nerve stimulation
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'NicChNMJ', 'AChNMJ' ) ;
     Drugs[iDrug].OnRate := NerveOn ;
     Drugs[iDrug].RemovalRate := NerveOff ;
     SetAgonistPotency( Drugs[iDrug].NicChRNMJ, 1.0 ) ;
     iNMJ := iDrug ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     { Chart recorder traces }

     { Setuo chart display }
     scDisplay.TScale := 1/20.0 ;

     scDisplay.MaxADCValue := MaxADCValue ;
     scDisplay.MinADCValue := MinADCValue ;
     scDisplay.DisplayGrid := True ;

     scDisplay.MaxPoints := Round( 500.0 / scDisplay.TScale ) ;
     scDisplay.NumPoints := 0 ;
     scDisplay.NumChannels := 4 ;
     sbDisplay.Max := 0 ;

     scDisplay.TScale := 1/20.0 ;
     edTDisplay.LoLimit := 1.0/scDisplay.TScale ;
     edTDisplay.HiLimit := 1E5 ;
     edTDisplay.Scale := scDisplay.TScale ;
     edStartTime.Scale := scDisplay.TScale ;
     edTDisplay.Value := 500.0 / edTDisplay.Scale ;
     scDisplay.XMin := 0 ;
     scDisplay.XMax := scDisplay.MaxPoints -1 ;

     { Blood pressure }
     scDisplay.ChanName[ChABP] := 'ABP' ;
     scDisplay.ChanUnits[ChABP] := 'mmHg' ;
     scDisplay.ChanScale[ChABP] := BPMax / MaxADCValue ;
     scDisplay.ChanZero[ChABP] := 0.0 ;
     scDisplay.ChanOffsets[ChABP] := chABP ;
     scDisplay.yMax[ChABP] := 120.0/scDisplay.ChanScale[ChABP] ;
     scDisplay.yMin[ChABP]:= -10.0/scDisplay.ChanScale[ChABP] ;
     scDisplay.ChanVisible[ChABP] := True ;

     { Heart rate }
     scDisplay.ChanName[chHR] := 'HR' ;
     scDisplay.ChanUnits[chHR] := 'BPM' ;
     scDisplay.ChanZero[chHR] := 0.0 ;
     scDisplay.ChanScale[ChHR] := 400.0 / MaxADCValue ;
     scDisplay.ChanOffsets[chHR] := chHR ;
     scDisplay.yMax[chHR]  := 150.0/scDisplay.ChanScale[ChHR] ;
     scDisplay.yMin[chHR]:= -10.0/scDisplay.ChanScale[ChHR] ;
     scDisplay.ChanVisible[chHR] := True ;

     { Nictitating membrane }
     scDisplay.ChanName[chNIC] := 'NIC' ;
     scDisplay.ChanUnits[chNIC] := 'gms' ;
     scDisplay.ChanScale[chNIC] := 200.0 / MaxADCValue ;
     scDisplay.ChanZero[chNIC] := 0.0 ;
     scDisplay.ChanOffsets[chNIC] := chNIC ;
     scDisplay.yMax[chNIC] := 100.0/scDisplay.ChanScale[chNIC] ;
     scDisplay.yMin[chNIC]:= -scDisplay.yMax[chNIC]*0.1 ;
     scDisplay.ChanVisible[chNIC] := True ;

     { Skeletal muscle }
     scDisplay.ChanName[chSKM] := 'SKM' ;
     scDisplay.ChanUnits[chSKM] := 'gms' ;
     scDisplay.ChanScale[chSKM] := (SKMax*1.1) / MaxADCValue ;
     scDisplay.ChanZero[chSKM] := 0.0 ;
     scDisplay.ChanOffsets[chSKM] := chSKM ;
     scDisplay.yMax[chSKM] := (SKMax*0.8)/scDisplay.ChanScale[chSKM] ;
     scDisplay.yMin[chSKM]:= -scDisplay.yMax[chSKM]*0.1 ;
     scDisplay.ChanVisible[chSKM] := True ;

     { Create a set of zero level cursors }
     scDisplay.ClearHorizontalCursors ;
     for i := 0 to scDisplay.NumChannels-1 do
         begin
         scDisplay.AddHorizontalCursor( i, clRed, True, '' ) ;
         scDisplay.HorizontalCursors[i] := 0 ;
         end;

     // Vertical readout cursor
     scDisplay.ClearVerticalCursors ;
     scDisplay.AddVerticalCursor(-1,clGreen, '?y') ;
     scDisplay.VerticalCursors[0] := scDisplay.MaxPoints div 2 ;

     t.next := -1.0 ;

     t.Step := 0.02 ;
     t.time := 0. ;
     t.systole := 0. ;
     bp.value := 100.0/BPMAX ;
     bp.mean := bp.value ;                            // Mean BP at restring level
     bp.Sum := bp.mean ;
     bp.nAvg := 1 ;
     baroreceptors := 0.5 ;                           // No baroreceptor activity
     NicChRDesensitization := 1.0 ;                   // No nicotinic receptor desensitization
     PulseInterval := 60.0 / 100.0 ;

     { Clear buffer  }
     for i := 0 to MaxPoints-1 do ADC[i] := 0 ;
     StartPoint :=  0 ;
     scDisplay.SetDataBuf( @ADC[StartPoint] ) ;
     scDisplay.XOffset := -1 ;
     NumPointsInBuf := 0 ;
     MarkerList.Clear ;

     Dead := False ;
     Dying := 0 ;
     Fibrillation := 0.0 ;
     bStart.Enabled := True ;
     bStop.Enabled := False ;
     bStopStimulator.Enabled := False ;
     bStartStimulator.Enabled := not bStopStimulator.Enabled ;
     end ;


procedure TMainForm.TimerTimer(Sender: TObject);
// ---------------------
// Timed event scheduler
// ---------------------
var
    i : Integer ;
begin

     if not bStart.Enabled then
        begin

        // Stimulate selected nerve pathways
        if bStopStimulator.Enabled then StimulateNerves ;

        { Calculate next set of simulation values }
        for i := 0 to 4 do CalculateTrace ;

        UpdateDisplay ;
        InitialMixing := InitialMixing + 1 ;
        if NumPointsInBuf >= MaxPoints then bStart.Enabled := True ;

        end
     else
        begin
        // Display
        if scDisplay.XOffset <> sbDisplay.Position then
           begin
           scDisplay.XOffset := sbDisplay.Position ;
           edStartTime.Value := scDisplay.XOffset ;
           scDisplay.SetDataBuf( @ADC[sbDisplay.Position*scDisplay.NumChannels] ) ;
           scDisplay.NumPoints := Min( scDisplay.MaxPoints,
                                       sbDisplay.Max - sbDisplay.Position) ;
           // Add annotations to chart
           AddChartAnnotations ;
           scDisplay.Invalidate ;
           end ;
        end ;

end;

procedure TMainForm.StimulateNerves ;
// -------------------------
// Stimulate selected nerves
// -------------------------
const
    StimVagusPeriod = 5.0 ;
    StimSkeletalMusclePeriod = 1.0 ;
    StimNicMembranePeriod = 5.0 ;
var
    i : Integer ;
    Num,Denom : single ;
begin

    // Vagus nerve
    if bStopStimulator.Enabled and ckVagusNerve.Checked and (t.time >= t.StimVagus) then
        begin

       { Opioid receptor activation }
       for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
           OpioidR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].OpioidR,Num,Denom,1 ) ;

       { Adenosine receptor activation }
       for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
           AdenR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].AdenR,Num,Denom,1 ) ;

        Drugs[iVagusStim].DoseInjected := 3.0*(1.0 - AdenR)*(1.0 - NicChRGanglionBlock) ;

        t.StimVagus := t.time + StimVagusPeriod ;
        end ;

     // Skeletal muscle
    if bStopStimulator.Enabled and ckSkeletalMuscle.Checked and (t.time >= t.StimSkeletalMuscle) then
       begin
       // Cholinesterase inactivation (0=activate,1=inactive
       for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
           ChEsterase := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].ChEsterase,Num,Denom,1 ) ;

       // Nicotinic receptor activation at neuromuscular junction
       Drugs[iNMJ].DoseInjected := 2.0 + ChEsterase*50.0 ;
       t.StimSkeletalMuscle := t.time + StimSkeletalMusclePeriod ;

       end ;

     { * Nictitating Membrane *
         Affected by Ganglion blocking drugs, adrenoceptor agonists
         adenosine (blocks) and morphine (blocks) }

    if bStopStimulator.Enabled and (t.time > t.StimNicMembrane) and ckNicMembrane.checked then
       begin
       Drugs[iNicMemPreGanglionic].DoseInjected := 5.0*(1.0 - AdenR) ;
       t.StimNicMembrane := t.time + StimNicMembranePeriod ;
       end ;

end;


procedure TMainForm.UpdateDisplay ;
// -------------------
// Update chart display
// -------------------
var
    ch,StartPoints : Integer ;
begin

     // Ensure that horizontal cursor remains at zero
     for ch := 0 to scDisplay.NumChannels-1 do
         begin
         if scDisplay.HorizontalCursors[ch] <> 0 then scDisplay.HorizontalCursors[ch] := 0 ;
         end;

    if scDisplay.NumPoints >= scDisplay.MaxPoints then
       begin
       StartPoints := scDisplay.MaxPoints div 10 ;
       sbDisplay.Position := NumPointsInBuf - StartPoints + 1 ;
       scDisplay.XOffset := sbDisplay.Position ;
       scDisplay.SetDataBuf( @ADC[sbDisplay.Position*scDisplay.NumChannels] ) ;
       sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
       edStartTime.HiLimit := sbDisplay.Max ;
       // Add annotations to chart
       AddChartAnnotations ;
       end ;

    scDisplay.DisplayNewPoints( NumPointsInBuf - scDisplay.XOffset ) ;

end ;


procedure TMainForm.AddChartAnnotations ;
// -------------------------------------
// Add drug annotations to chart display
// -------------------------------------
var
    i : Integer ;
    MarkerPosition : Integer ;
begin

     scDisplay.ClearMarkers ;
     for i := 0 to MarkerList.Count-1 do
         begin
         MarkerPosition := Integer(MarkerList.Objects[i]) - scDisplay.XOffset ;
         if (MarkerPosition > 0) and (MarkerPosition < scDisplay.MaxPoints) then
            begin
            scDisplay.AddMarker( MarkerPosition, MarkerList.Strings[i] ) ;
            end ;
         end ;
     end ;




procedure TMainForm.CalculateTrace ;
{ ---------------------------------
  Calculate next step in simulation
  ---------------------------------}
var
   dbp,PeripheralFlow,BPResting : single ;
   ch,i,j : Integer ;
   Num,Denom : single ;
   Smooth : single ;
   PotencyMultiplier : single ;
begin

     { Update drugs in circulation }
     for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
         begin
         Drugs[i].Dose := Drugs[i].Dose
                          + Drugs[i].OnRate*t.step*(Drugs[i].DoseInjected - Drugs[i].Dose)
                          - Drugs[i].Dose*Drugs[i].RemovalRate*t.step ;
         Drugs[i].Dose := Max( Drugs[i].Dose, 0.0 ) ;
         Drugs[i].DoseInjected := Drugs[i].DoseInjected - Drugs[i].DoseInjected*Drugs[i].RemovalRate*t.step ;
         Drugs[i].DoseInjected := Max( Drugs[i].DoseInjected, 0.0 ) ;

         end ;

      { Opioid receptor activation }
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          OpioidR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].OpioidR,Num,Denom, 2 ) ;

      { Adenosine receptor activation }
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          AdenR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].AdenR,Num,Denom,2 ) ;

      // Cholinesterase activity
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          ChEsterase := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].ChEsterase,Num,Denom,2 ) ;

      { Nicotinic (ganglion) cholinoceptor activation }
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          NicChR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].NicChR,Num,Denom, 2 ) ;

      { Histamine H1 receptor activation }
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          H1R := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].H1R,Num,Denom, 2 ) ;

     { Vagus nerve stimulation (Blocked by morphine ) }

       { Set vagus nerve activity to a base level (0.1) +
         activity due baroceptors activated by high B.P. }
       Smooth := 0.1*t.step / Min(PulseInterval,10.0) ;
       bp.mean := Smooth*bp.value + (1.0-Smooth)*bp.mean ;
       BPResting := 100.0/BPMAX ;
       Baroreceptors := 1.0 / (1.0 + exp( -(bp.mean - BPResting)/0.12)) ;
 //  Baroreceptors := 0.5 ;

      // Nicotinic cholinoceptor channel block on ganglion neuronss
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          NicChRGanglionBlock := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].NicChRGanglionBlock,Num,Denom, 2 ) ;

       { Release of Ach from vagus nerve blocked either by
         block of ganglionic transmission OR by presynaptic
         transmitter release block by morphine }
       { V2.2 1/10/97 Cholinesterase inhibition now enhances release of
         Ach from vagus, requested by EGR }

       Drugs[iVagusBaroreceptors].Dose := 0.6*Baroreceptors
                                          * (1.0 + (ChEsterase*10.0) )
                                          * (1.0 - NicChRGanglionBlock)
                                          * (1. - AdenR) ;

     { Effects on muscarinic Ach receptors
       Combination of vagus nerve activity (blockable by ganglion blockers),
       and circulating Ach act as agonists. Atropine and Hyoscine act
       as MachR blockers. Effect of Ach is enhanced by presence of
       an anticholinesterase }
//     CirculatingAcetylcholine := Acetylcholine.Dose * ( 2. - Cholinesterase ) ;
//     Acetylcholine.RemovalRate := 0.003*(1. + Cholinesterase ) ;

      // Muscarinic cholinoceptors on heart activation
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          Heart.MusChR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].MusChR,Num,Denom, 2 ) ;

     // Ca channel block
     for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
         CaChannels := 1.0 - ReceptorActivation(i,Drugs[i].Dose,Drugs[i].HMCaChannel,Num,Denom, 2 ) ;

     // Transmitter release from post-ganglionic nerves acting on heart
     Drugs[iAcceleransBaroreceptors].Dose := 0.6*(1.0 - Baroreceptors)
                                            * (1.0 - NicChRGanglionBlock)
                                            * (1. - AdenR) ;

     // Resting sympathetic nerve activity
  //   Drugs[iRestingSympathetic].Dose := 0.1*(1.0 - NicChRGanglionBlock) ;

      // Adrenoceptor activation
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          AlphaAdR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].AlphaAdR,Num,Denom, 2 ) ;

      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          BetaAdR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].BetaAdR,Num,Denom, 2 ) ;

      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          Heart.BetaAdR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].BetaAdRHeart,Num,Denom, 2 ) ;

      // Muscarinic receptor activation
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          Heart.MusChR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].MusChRHeart,Num,Denom, 2 ) ;

//      outputdebugstring(pchar(format('%.3g',[Heart.MusChR])));

      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          MusChR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].MusChR,Num,Denom, 2 ) ;

//     Update Heart Rate
      Heart.Rate := 1. + (85.0
                     - 100.*Heart.MusChR
                     - 110.*AdenR
                     + 220.*Heart.BetaAdR*(1.0-Heart.MusChR) )*CaChannels;
      Heart.Rate := Max(Heart.Rate, 0.01);
      PulseInterval := 60. / Max(Heart.Rate,1.0) ;

     // Update vasculature perpherhal resistance
     PeripheralFlow := 1.0
                       - 1.0*AlphaAdR
                       - 0.325*(1.0 - CaChannels)
                       + {1.75}2.2*BetaAdR
                       + 0.75*MusChR
                       + 0.7*AdenR
                       + 2.5*H1R  ;

     // Update Blood Pressure
     dbp := (Heart.SystolicForce*0.5*(2.0-bp.value) - (PeripheralFlow)*bp.value)*t.step ;
     bp.value := Max((bp.value + dbp),0.0) ;

     if( t.time >= t.systole ) then
         begin
  //     Update heart force
         Heart.SystolicForce := 0.3 +(
                                2.0
                                + 3.5*Heart.BetaAdR
                                - 1.0*Heart.MusChR
                                - 3.25*AdenR
                                 )*CaChannels ;
         Heart.SystolicForce := Max( 0.01,Heart.SystolicForce ) ;
         t.diastole := t.time + Min(0.11,PulseInterval/4.0 );
         t.systole := t.systole + PulseInterval ;
         end ;

     if ( t.time >= t.diastole ) then
         begin
//         bp.systolic := bp.value ;
         t.diastole := 1E30 ;
         Heart.SystolicForce := 0.;
         end ;

     { * Nerve-evoked skeletal muscle contractions *
       Blocked by Tubocurarine & Gallamine
       Block reversed by Neostigmine, Physostigmine }

     { High doses of carbachol and acetylcholine (in the presense of
       anti-cholinesterase) desensitise the neuromuscular junction ) }

       { ** Contracture of skeletal muscle caused by injection of
         Ach directly into artery supplying muscle **
         See page 17.21 Bowman & Rand }

       { Effective Ach concentration boosted by inhibiting cholinesterase }

      // Nicotinic cholinoceptor activation
      for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
          begin
          if ANSIContainsText(Drugs[i].Name,'acetylcholine') then PotencyMultiplier := 1.0/(1.0+ChEsterase*4.0)
                                                             else PotencyMultiplier := 1.0 ;
          if Drugs[i].CloseArterialInjection then
             begin
             // If close arterial injection of nicotinic agonist, use general NicChR drug potencies
             SkelMuscle.NicChR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].NicChR,Num,Denom, 1 ) ;
             end
          else begin
             // Otherwise only nerve released Ach activates receptors at neuromuscular junction
             SkelMuscle.NicChR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].NicChRNMJ,Num,Denom, 1 ) ;
             end;

          end ;

       // Desensitization of junctional receptors after activation by circulating nicotinic agonists
       NicChRDesensitization := (1.0-0.01)*NicChRDesensitization + (0.01)*(1.0 / (1.0 + (NicChR*NicChR)*30.0)) ;

       // Peak skeletal muscle twitch
       SkelMuscle.Contraction := SKMax*AddNoise(0.03) * ( 1./ ( 1. + exp(-((SkelMuscle.NicChR- 0.6)/0.1))  ))
                                 *NicChRDesensitization ;

       // Nictitating membrane
       // ====================

       // Nicotinic cholinoceptors on ganglion neurons activation
       for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
           NicChRNicMemGanglion := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].NicChRNicMemGanglion,Num,Denom, 1 ) ;

       // Nicotinic cholinoceptor channel block on sympathetic ganglion neuronss
       for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
           NicChRGanglionBlock := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].NicChRGanglionBlock,Num,Denom, 1 ) ;

       // Transmitter release (noradrenaline) from post-gagnglionic nerves
       Drugs[iNicMemPostGanglionic].Dose := NicChRNicMemGanglion
                                            *(1. - AdenR)
                                            *(1. - OpioidR)
                                            *(1.0 - NicChRGanglionBlock) ;

       // Activation of adrenoceptors on nictitating membrane
       for i := 0 to High(Drugs) do if Drugs[i] <> Nil then
           NicMem.AlphaR := ReceptorActivation(i,Drugs[i].Dose,Drugs[i].AlphaAdRNicMem,Num,Denom, 1 ) ;
       NicMem.Contraction :=  NMMax*NicMem.AlphaR ;

     { The cat dies if the B.P. falls too low for too long }
     if not Dead then begin
        if bp.mean*BPMAX < 20. then Inc(Dying)
                               else Dying := 0 ;
        if Dying = 600 then begin
 {          bp.mean := 0. ;
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
           Dead := True ;}
           end ;
        end
     else begin
        bp.mean := 0. ;
        bp.value := 0. ;
        bp.systolic := 0. ;
        Heart.Rate := 0. ;
        SkelMuscle.Contraction := 0. ;
        NicMem.PeakTwitch:= 0. ;
        NicMem.Contraction := 0. ;
        end ;

     // Updata chart data buffers

     j := NumPointsInBuf*scDisplay.NumChannels ;
     Inc(NumPointsInBuf) ;

     ADC[j+chABP] := Round( (bp.value*BPMax) /scDisplay.ChanScale[chABP]);
     ADC[j+chHR] := Round( (Heart.Rate*AddNoise(0.01))/scDisplay.ChanScale[chHR]);
     ADC[j+ChNIC] :=  Round( NicMem.Contraction/scDisplay.ChanScale[chSKM]) ;
     ADC[j+ChSKM] := Round( SkelMuscle.Contraction/scDisplay.ChanScale[chSKM]) ;

     // Ensure trace does not exceed display range
     for ch := 0 to scDisplay.NumChannels-1 do
         if ADC[j+ch] > scDisplay.Ymax[ch] then
            begin
            scDisplay.Ymax[ch] := scDisplay.Ymax[ch]*1.1 ;
            scDisplay.Invalidate ;
            end ;

     t.time := t.time + t.Step ;
     end ;


procedure TMainForm.cbAgonistChange(Sender: TObject);
// ==============================
// Agonist drug selection changed
// ==============================
begin
    SetDoseList( cbAgonist, cbAgonistDose ) ;
end;


procedure TMainForm.cbAntagonistChange(Sender: TObject);
// ==============================
// Antaonist drug selection changed
// ==============================
begin
    SetDoseList( cbAntagonist, cbAntagonistDose ) ;
end;


procedure TMainForm.cbUnknownChange(Sender: TObject);
// ==============================
// Unknown drug selection changed
// ==============================
begin
    SetDoseList( cbUnknown, cbUnknownDose ) ;
end;


procedure TMainForm.edStartTimeKeyPress(Sender: TObject; var Key: Char);
// ------------------
// Start time changed
// ------------------
begin
    if Key = #13 then
       begin
       sbDisplay.Position := Round(edStartTime.Value) ;
       end;
    end;


procedure TMainForm.edTDisplayKeyPress(Sender: TObject; var Key: Char);
// -------------------------------
// Display window duration changed
// -------------------------------
begin
    if Key = #13 then UpdateDisplayDuration ;
    end;



function TMainForm.AddNoise(
         Proportion : single
         ) : single ;
{ -----------------------------------------------
  Create a random scaling factor 1 +/- Proportion
  -----------------------------------------------}
begin
     AddNoise := 1. + ((2.*random)-1. )*Proportion ;
     end ;


function TMainForm.ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
{ ---------------------------------------------------
  Extract a floating point number from a string which
  may contain additional non-numeric text
  ---------------------------------------}
var
   CNum : string ;
   i : integer ;
begin
     CNum := '' ;
     for i := 1 to length(CBuf) do
         begin
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


procedure TMainForm.FormResize(Sender: TObject);
// ----------------------------------------
// Resize form components when size changed
// ----------------------------------------
var
   MinHeight,MinWidth : Integer ;
begin
     MinWidth := TDisplayPanel.Width + 20 ;
     MinHeight := TDisplayPanel.Height + 100 ;
     if ClientHeight < MinHeight then ClientHeight := Minheight ;
     if ClientWidth < MinWidth then ClientWidth := MinWidth ;

     Page.Width := ClientWidth - Page.Left - 5 ;
     Page.Height := ClientHeight - Page.Top - 5 ;

     TDisplayPanel.Top := ChartTab.ClientHeight - TDisplayPanel.Height - 10 ;
     TDisplayPanel.Width := ChartTab.ClientWidth - TDisplayPanel.Left - 10 ;
     bTDisplayDouble.Left := TDisplayPanel.ClientWidth - bTDisplayDouble.Width ;
     edTDisplay.Left := bTDisplayDouble.Left - edTDisplay.Width - 5 ;
     bTDisplayHalf.Left := EdTDisplay.Left - bTDisplayHalf.Width - 5;
     lbTDisplay.Left := bTDisplayHalf.Left - lbTDisplay.Width - 5 ;
     sbDisplay.Width := lbTDisplay.Left - sbDisplay.Left - 5 ;

     scDisplay.Height := TDisplayPanel.Top - scDisplay.Top - 10 ;
     scDisplay.Width := ChartTab.CLientWidth - scDisplay.Left - 10 ;

     ExpImage.Width := Max(Round(PictureTab.ClientWidth*0.9),465) ;
     ExpImage.Height :=  Max(Round(ExpImage.Width*(329.0/465.0)),329) ;
     ExpImage.Left := (PictureTab.ClientWidth - ExpImage.Width) div 2 ;
     ExpImage.Top := (PictureTab.ClientHeight - ExpImage.Height) div 2 ;

     end;


procedure TMainForm.bStopClick(Sender: TObject);
// --------------------
// Stop chart recording
// --------------------
begin

     sbDisplay.Max := NumPointsInBuf - 1 ;
     bStart.Enabled := True ;
     bStop.Enabled := False ;
     mnFile.Enabled := True ;

     end;


procedure TMainForm.bStopStimulatorClick(Sender: TObject);
// ------------------------
// Stop stimulating nerves
// ------------------------
begin
    bStopStimulator.Enabled := False ;
    bStartStimulator.Enabled := not bStopStimulator.Enabled ;
end;


procedure TMainForm.bTDisplayDoubleClick(Sender: TObject);
// --------------------------------
// Increase display duration by 25%
// --------------------------------
begin
    edTDisplay.Value := edTDisplay.Value*1.25 ;
    UpdateDisplayDuration ;
    end;


procedure TMainForm.bTDisplayHalfClick(Sender: TObject);
// --------------------------
// Decrease display duration
// --------------------------
begin
    edTDisplay.Value := edTDisplay.Value*(1.0/1.25) ;
    UpdateDisplayDuration ;
    end;


procedure TMainForm.UpdateDisplayDuration ;
// ------------------------------
// Update display window duration
// ------------------------------
begin
    scDisplay.MaxPoints :=  Round(edTDisplay.Value) ;
    scDisplay.XMax := scDisplay.MaxPoints -1 ;
    scDisplay.VerticalCursors[0] := scDisplay.MaxPoints div 2 ;
    scDisplay.NumPoints := NumPointsInBuf - scDisplay.XOffset ;
    scDisplay.invalidate ;
    end;


procedure TMainForm.scDisplayCursorChange(Sender: TObject);
// --------------------------------------------
// Display cursor moved or display zoom changed
// --------------------------------------------
var
    ch : Integer ;
begin
     // Ensure that unnecessaray negative display ranges cannot be selected
     for ch := 0 to scDisplay.NumChannels-1 do
         if scDisplay.YMin[ch] < (-scDisplay.YMax[ch]*0.1) then
            begin
            scDisplay.YMin[ch] := -scDisplay.YMax[ch]*0.1 ;
            scDisplay.Invalidate ;
            end;
end;


procedure TMainForm.bAddAgonistClick(Sender: TObject);
// ----------------------------
// Add selected dose of agonist
// ----------------------------
var
    iDrug : Integer ;
    Dose,Scale : Single ;
    ChartAnnotation,Units : string ;
begin

    iDrug := Integer(cbAgonist.Items.Objects[cbAgonist.ItemIndex]);
    Dose := 1E-6*Integer(cbAgonistDose.Items.Objects[cbAgonistDose.ItemIndex]);

    Drugs[iDrug].DoseInjected := Drugs[iDrug].DoseInjected + Dose ;

    // Set close arterial injection flag
    Drugs[iDrug].CloseArterialInjection := rbCloseArterialInjection.Checked ;

    if Dose < 1.0 then
       begin
       Units := 'ug/kg';
       Scale := 1000.0 ;
       end
    else
       begin
       Units := 'mg/kg';
       Scale := 1.0 ;
       end ;

    // Add chart annotation
    ChartAnnotation := format('%s %.3g %s',
                       [Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;

end;


procedure TMainForm.bAddAntagonistClick(Sender: TObject);
// -------------------------------
// Add selected dose of antagonist
// -------------------------------
var
    iDrug : Integer ;
    Dose,Scale : Single ;
    ChartAnnotation,Units : string ;
begin

    iDrug := Integer(cbAntagonist.Items.Objects[cbAntagonist.ItemIndex]);
    Dose := 1E-6*Integer(cbAntagonistDose.Items.Objects[cbAntagonistDose.ItemIndex]);
    Drugs[iDrug].DoseInjected := Drugs[iDrug].DoseInjected + Dose ;
    Drugs[iDrug].CloseArterialInjection := False ;

    if Dose < 1.0 then
       begin
       Units := 'ug/kg';
       Scale := 1000.0 ;
       end
    else
       begin
       Units := 'mg/kg';
       Scale := 1.0 ;
       end ;

    // Add chart annotation
    ChartAnnotation := format('%s %.3g %s',
                       [Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;

end;


procedure TMainForm.bAddUnknownClick(Sender: TObject);
// --------------------------------
// Add selected dose of unknown drug
// ---------------------------------
var
    iDrug : Integer ;
    Dose,Scale : Single ;
    ChartAnnotation,Units : string ;
begin

    iDrug := Integer(cbUnknown.Items.Objects[cbUnknown.ItemIndex]);
    Dose := 1E-6*Integer(cbUnknownDose.Items.Objects[cbUnknownDose.ItemIndex]);
    Drugs[iDrug].DoseInjected := Drugs[iDrug].DoseInjected + Dose ;
    Drugs[iDrug].CloseArterialInjection := False ;

    if Dose < 1.0 then
       begin
       Units := 'ug/kg';
       Scale := 1000.0 ;
       end
    else
       begin
       Units := 'mg/kg';
       Scale := 1.0 ;
       end ;

    // Add chart annotation
    ChartAnnotation := format('%s %.3g %s',
                       [Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;

end;


procedure TMainForm.bNewExperimentClick(Sender: TObject);
// ---------------------------------
// Start new experiment with new rat
// ---------------------------------
begin
     if MessageDlg('New Experiment! Are you sure?', mtConfirmation,
        [mbYes,mbNo],0) = mrYes then
        begin
        InitializeSimulation ;
        end;

end;

procedure TMainForm.bStartClick(Sender: TObject);
// ---------------------
// Start chart recording
// ---------------------
begin

     bStart.Enabled := False ;
     bStop.Enabled := True ;
     bStart.Enabled := False ;
     mnFile.Enabled := False ;
     // Disable changes to normal/pithed state once experiment started
     UnSavedData := True ;

     end;


procedure TMainForm.bStartStimulatorClick(Sender: TObject);
// ------------------------
// Start stimulating nerves
// ------------------------
begin
    bStopStimulator.Enabled := True ;
    bStartStimulator.Enabled := not bStopStimulator.Enabled ;
    t.StimVagus := 0.0 ;
    t.StimSkeletalMuscle := 0.0 ;
    t.StimNicMembrane := 0.0 ;

end;

procedure TMainForm.mnExitClick(Sender: TObject);
{ -----------------
  Stop the program
  ----------------}
begin
     Close ;
     end ;


procedure TMainForm.mnContentsClick(Sender: TObject);
// -----------------------
//  Help/Contents menu item
//  -----------------------
var
   pWinDir : PChar ;
   FileName : string ;
begin


     GetMem( pWinDir, 512 ) ;
     GetWindowsDirectoryW( pWinDir, 256 ) ;
     FileName := pWinDir + '\hh.exe' ;

     ShellExecute( Handle,PChar('open'),
                   PChar(FileName),
                   PChar(Application.HelpFile),
                   nil,
                   SW_SHOWNORMAL) ;
     FreeMem( pWinDir ) ;
     end;


procedure TMainForm.mnCopyDataClick(Sender: TObject);
// ----------------------------------------------------
// Copy sample values of displayed signals to clipboard
// ----------------------------------------------------
begin
     scDisplay.CopyDataToClipboard ;
     end;


procedure TMainForm.mnCopyImageClick(Sender: TObject);
// -----------------------------------------
// Copy image of displayed trace to clipboad
// -----------------------------------------
var
    ch : integer ;
begin

     for ch  := 0 to scDisplay.NumChannels-1 do
         scDisplay.ChanCalBar[ch] :=  scDisplay.ChanGridSpacing[ch] ;

     scDisplay.TCalBar := scDisplay.TimeGridSpacing/scDisplay.TScale ;
     scDisplay.PrinterFontName := 'Arial' ;
     scDisplay.PrinterFontSize := 10 ;
     scDisplay.MetafileWidth := 1000 ;
     scDisplay.MetafileHeight := 600 ;
     scDisplay.PrinterPenWidth := 2 ;
     scDisplay.CopyImageToClipBoard ;

     end;


procedure TMainForm.SaveToFile(
          FileName : String
          ) ;
// ----------------------------
// Save chart recording to file
// ----------------------------
var
   Header : array[1..FileHeaderSize] of ansichar ;
   i : Integer ;
   FileHandle : THandle ;
begin

     FileHandle := FileCreate( FileName ) ;
     if Integer(FileHandle) < 0 then Exit ;

     { Initialise empty header buffer with zero bytes }
     for i := 1 to sizeof(Header) do Header[i] := #0 ;

     AppendInt( Header, 'NPOINTS=', NumPointsInBuf ) ;

     AppendInt( Header, 'NMARKERS=', MarkerList.Count ) ;
     for i := 0 to MarkerList.Count-1 do
         begin
         AppendInt( Header, format('MKP%d=',[i]), Integer(MarkerList.Objects[i])) ;
         AppendString( Header, format('MKT%d=',[i]), MarkerList.Strings[i] ) ;
         end ;

     // Write header
     FileWrite( FileHandle, Header, SizeOf(Header)) ;

     // Write chart data
     FileWrite( FileHandle, ADC, NumPointsInBuf*scDisplay.NumChannels*2 ) ;

     // Close file
     FileClose( FileHandle ) ;

     UnSavedData := False ;
     end ;


procedure TMainForm.LoadFromFile(
          FileName : String
          ) ;
// ----------------------------
// Load chart recording from file
// ----------------------------
var
   Header : array[1..FileHeaderSize] of ansichar ;
   i : Integer ;
   FileHandle : Integer ;
   NumMarkers : Integer ;
   MarkerPoint : Integer ;
   MarkerText : String ;
begin

     NumPointsInBuf := 0 ;

     FileHandle := FileOpen( FileName, fmOpenRead ) ;
     if FileHandle < 0 then Exit ;

     FileSeek( FileHandle, 0, 0 ) ;

     // Clear header
     for i := 1 to High(Header) do Header[i] := #0 ;

     // Read header
     FileRead(FileHandle, Header, Sizeof(Header)) ;

     InitializeSimulation ;

     NumPointsInBuf := 0 ;
     ReadInt( Header, 'NPOINTS=', NumPointsInBuf ) ;

     ReadInt( Header, 'NMARKERS=', NumMarkers ) ;
     MarkerList.Clear ;
     for i := 0 to NumMarkers-1 do
         begin
         ReadInt( Header, format('MKPOINT%d=',[i]), MarkerPoint) ;
         ReadInt( Header, format('MKP%d=',[i]), MarkerPoint) ;
         ReadString( Header, format('MKTEXT%d=',[i]), MarkerText ) ;
         ReadString( Header, format('MKT%d=',[i]), MarkerText ) ;
         MarkerList.AddObject( MarkerText, TObject(MarkerPoint)) ;
         end ;

     if NumPointsInBuf > 0 then
        begin
        FileRead( FileHandle, ADC, NumPointsInBuf*scDisplay.NumChannels*2 ) ;
        end ;

     // Close data file
     FileClose( FileHandle ) ;

     UnsavedData := False ;
     scDisplay.XOffset := -1 ;
     sbDisplay.Position := 0 ;
     sbDisplay.Max := NumPointsInBuf ;
     scDisplay.Invalidate ;

     end ;



procedure TMainForm.mnLoadCatClick(Sender: TObject);
// -------------------------
// Load experiment from file
// -------------------------
begin

    if UnSavedData then
        begin
        if MessageDlg('Existing experiment will be overwritten! Are you sure?', mtConfirmation,
           [mbYes,mbNo],0) = mrNo then Exit ;
        end ;

   OpenDialog.options := [ofPathMustExist] ;
   OpenDialog.FileName := '' ;

   OpenDialog.DefaultExt := DataFileExtension ;
   //OpenDialog.InitialDir := OpenDirectory ;
   OpenDialog.Filter := format( ' Experiment (*%s)|*%s',
                                [DataFileExtension,DataFileExtension]) ;
   OpenDialog.Title := 'Load Experiment ' ;

   // Open selected data file
   if OpenDialog.execute then LoadFromFile( OpenDialog.FileName ) ;

   end;


procedure TMainForm.mnSaveCatClick(Sender: TObject);
// -----------------------
// Save experiment to file
// -----------------------
begin

     { Present user with standard Save File dialog box }
     SaveDialog.options := [ofHideReadOnly,ofPathMustExist] ;
     SaveDialog.FileName := '' ;
     SaveDialog.DefaultExt := DataFileExtension ;
     SaveDialog.Filter := format( '  Experiment (*%s)|*%s',
                                  [DataFileExtension,DataFileExtension]) ;
     SaveDialog.Title := 'Save Experiment' ;

     if SaveDialog.Execute then SaveToFile( SaveDialog.FileName ) ;

     end ;


procedure TMainForm.mnNewCatClick(Sender: TObject);
begin
     if MessageDlg('New Experiment! Are you sure?', mtConfirmation,
        [mbYes,mbNo],0) = mrYes then
        begin
        InitializeSimulation ;
        end;
     end;


procedure TMainForm.mnPrintClick(Sender: TObject);
// ---------------------------
// Print displayed chart trace
// ---------------------------
var
    ch : Integer ;
begin
     PrintFrm.Left := Left + 50 ;
     PrintFrm.Top := Top + 50 ;
     PrintFrm.ShowModal ;
     if PrintFrm.ModalResult = mrOK then
        begin
        scDisplay.PrinterLeftMargin := 25 ;
        scDisplay.PrinterRightMargin := 25 ;
        scDisplay.PrinterTopMargin := 25 ;
        scDisplay.PrinterBottomMargin := 25 ;
        for ch := 0 to scDisplay.NumChannels-1 do
            scDisplay.ChanCalBar[ch] :=  scDisplay.ChanGridSpacing[ch] ;
        scDisplay.TCalBar := scDisplay.TimeGridSpacing/scDisplay.TScale ;
        scDisplay.PrinterFontName := 'Arial' ;
        scDisplay.PrinterFontSize := 10 ;
        scDisplay.PrinterPenWidth := 2 ;
        scDisplay.Print ;
        end ;
     end;


procedure TMainForm.FormActivate(Sender: TObject);
begin

     REsize ;

     end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     if MessageDlg( 'Exit Program! Are you Sure? ', mtConfirmation,
        [mbYes,mbNo], 0 ) = mrYes then CanClose := True
                                  else CanClose := False ;
     end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
// -----------------------------------------
// Close form and dispose of created objects
// -----------------------------------------
begin

     Timer.Enabled := False ;


     end;


constructor TDrug.Create(
          NameIn : String ;
          ShortNameIn : string
          ) ;
// ------------------
// Create drug object
// ------------------
begin
     Inherited Create   ;
     Name := NameIn ;
     ShortName := ShortNameIn ;
     Dose := 0.0 ;
     DoseInjected := 0.0 ;
     Conc := 0.0 ;
     AlphaAdR.Efficacy := None ;
     AlphaAdR.Potency := None ;
     AlphaAdRNicMem.Efficacy := None ;
     AlphaAdRNicMem.Potency := None ;
     BetaAdR.Efficacy := None ;
     BetaAdR.Potency := None ;
     BetaAdRHeart.Efficacy := None ;
     BetaAdRHeart.Potency := None ;
     MusChR.Efficacy := None ;
     MusChR.Potency := None ;
     MusChRHeart.Efficacy := None ;
     MusChRHeart.Potency := None ;
     NicChR.Efficacy := None ;
     NicChR.Potency := None ;
     NicChRSympathetic.Efficacy := None ;
     NicChRSympathetic.Potency := None ;
     NicChRParasympathetic.Efficacy := None ;
     NicChRParasympathetic.Potency := None ;
     NicChRGanglionBlock.Efficacy := None ;
     NicChRGanglionBlock.Potency := None ;
     NicChRNicMemGanglion.Efficacy := None ;
     NicChRNicMemGanglion.Potency := None ;
     NicChRNMJ.Efficacy := None ;
     NicChRNMJ.Potency := None ;
     ChEsterase.Efficacy := None ;
     ChEsterase.Potency := None ;
     HMCaChannel.Efficacy := None ;
     HMCaChannel.Potency := None ;
     SMCaChannel.Efficacy := None ;
     SMCaChannel.Potency := None ;
     AdenR.Efficacy := None ;
     AdenR.Potency := None ;
     OpioidR.Efficacy := None ;
     OpioidR.Potency := None ;
     H1R.Efficacy := None ;
     H1R.Potency := None ;

     OnRate := 1.0 ;
     RemovalRate := 0.05 ;
     CloseArterialInjection := False ;
     end ;


procedure TMainForm.SetAgonistPotency(
          var Drug : TDrugProperties ;
          Potency : single
          ) ;
begin
      if Potency <> None then
        begin
        Drug.Potency := Potency{*AddNoise(0.5)} ;
        { Efficacy - 1.0=agonist, 0.0=antagonist }
        Drug.Efficacy := 1.0 ;
        end
     else Drug.Efficacy := None ;
     end ;


function TMainForm.ReceptorActivation(
          iDrug : Integer ;
          Dose : single ;
          Drug : TDrugProperties ;
          var Numerator : single ;
          var Denominator : single ;
          nPower : Integer
          ) : single ;
var
   x : single ;
   i : Integer ;
begin

     if iDrug = 0 then
        begin
        Numerator := 0.0 ;
        Denominator := 1.0 ;
        end ;
     if Drug.Efficacy <> None then
        begin
        x := 0.0 ;
        for i := 0 to nPower-1 do x := x + Dose/Drug.Potency ;
        Denominator := Denominator + x ;
        Numerator := Numerator + Drug.Efficacy*x ;
        end ;
     if Denominator > 0. then Result := Numerator/Denominator
                         else Result := 0. ;

     end ;


procedure TMainForm.SetAntagonistPotency(
          var Drug : TDrugProperties ;
          Potency : single
          ) ;
begin
      if Potency <> None then
        begin
        Drug.Potency := Potency*AddNoise(0.5) ;
        { Efficacy - 1.0=agonist, 0.0=antagonist }
        Drug.Efficacy := 0.0 ;
        end
     else Drug.Efficacy := None ;
     end ;


procedure TMainForm.AddDrugMarker(
          ChartAnnotation : String
          ) ;
// ------------------------------
// Add drug addition/wash marker
// ------------------------------
begin
     if MarkerList.Count < MaxMarkers then
        begin
        ChartAnnotation := AnsiReplaceStr( ChartAnnotation, '-00', '-' ) ;
        ChartAnnotation := AnsiReplaceStr( ChartAnnotation, '00E', '0E' ) ;
        MarkerList.AddObject( ChartAnnotation, TObject(NumPointsInBuf) ) ;
        scDisplay.AddMarker( NumPointsInBuf - scDisplay.XOffset, ChartAnnotation ) ;
        end ;
     end ;


procedure TMainForm.PrintSetup1Click(Sender: TObject);
{ ------------------------------------
  Menu - Open printer setup dialog box
  ------------------------------------}
begin
     PrinterSetupDialog.Execute ;
     end;


procedure TMainForm.SetDoseList(
          cbDrug : TComboBox ;
          cbDose : TComboBox ) ;
// -----------------------------
// Create list of available doses
// -----------------------------
var
    iDrug,i : Integer ;
    Scale,Dose : Single ;
    Units : String ;
begin

   cbDose.Clear ;

   if cbDrug.Items.Count > 1 then
      begin
      cbDrug.ItemIndex := Max(cbDrug.ItemIndex,0) ;
      iDrug := Integer(cbDrug.Items.Objects[cbDrug.ItemIndex]) ;
      if Drugs[iDrug].MinDose < 0.1 then
         begin
         Scale := 1000.0 ;
         Units := 'ug/kg' ;
         end
      else
         begin
         Scale := 1.0 ;
         Units := 'mg/kg' ;
         end ;

      Dose := Drugs[iDrug].MinDose ;
      cbDose.Clear ;
      while Dose <= Drugs[iDrug].MaxDose do
       begin
       if Dose <= Drugs[iDrug].MaxDose then cbDose.Items.Add( format(' %.4g %s ',[Dose*Scale,Units]) ) ;
       if (2.0*Dose) <= Drugs[iDrug].MaxDose then cbDose.Items.Add( format(' %.4g %s ',[2.0*Dose*Scale,Units]) ) ;
       if (5.0*Dose) <= Drugs[iDrug].MaxDose then cbDose.Items.Add( format(' %.4g %s ',[5.0*Dose*Scale,Units]) ) ;
       Dose := Dose*10.0 ;
       end ;
     cbDose.ItemIndex := 0 ;

     // Add dose in ng/kg in objects field

     for i := 0 to cbDose.Items.Count-1 do
         begin
         Dose := ExtractFLoat( cbDose.Items[i], 0.0 );
         if ContainsText(cbDose.Text,'ug/kg') then Scale := 1000.0
         else if ContainsText(cbDose.Text,'mg/kg') then Scale := 1E6
         else Scale := 1.0 ;
         cbDose.Items.Objects[i] := Tobject(Round(Dose*Scale)) ;
         end;
     end ;
end ;


end.
