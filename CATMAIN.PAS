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
// 18.07.24 .. V4.0.0 Simulation code moved to Model data unit


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
    MaxMarkers = 500 ;
    NumBytesPerMarker = 40 ;
    FileHeaderSize = (MaxMarkers+10)*NumBytesPerMarker ;
    DataFileExtension = '.cat' ;



type


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
    mnWebHelp: TMenuItem;
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
    procedure mnWebHelpClick(Sender: TObject);

  private
    { Private declarations }

    ADC : Array[0..MaxPoints-1] of SmallInt ;
    NumPointsInBuf : Integer ;   // No. of data points in buffer
    StartPoint : Integer ;       // Starting point of chart display
    InitialMixing : Cardinal ;
    MarkerList : TStringList ;   // Chart annotation list
    UnsavedData : Boolean ;

    procedure UpdateDisplay ;

    procedure AddChartAnnotations ;
    procedure UpdateDisplayDuration ;






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

uses PrintUnit, shared , CatModel;

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

     // Fill lists of available drugs
     Model.GetListofDrugs( cbAgonist, dtAgonist ) ;
     Model.SetDoseList( cbAgonist, cbAgonistDose );

     Model.GetListofDrugs( cbAntagonist, dtAntagonist ) ;
     Model.SetDoseList( cbAntagonist, cbAntagonistDose );

     Model.GetListofDrugs( cbUnknown, dtUnknown ) ;
     Model.SetDoseList( cbUnknown, cbUnknownDose );

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

     { Clear buffer  }
     for i := 0 to MaxPoints-1 do ADC[i] := 0 ;
     StartPoint :=  0 ;
     scDisplay.SetDataBuf( @ADC[StartPoint] ) ;
     scDisplay.XOffset := -1 ;
     NumPointsInBuf := 0 ;
     MarkerList.Clear ;

     bStart.Enabled := True ;
     bStop.Enabled := False ;
     bStopStimulator.Enabled := False ;
     bStartStimulator.Enabled := not bStopStimulator.Enabled ;

     Model.InitializeSimulation ;
     end;


procedure TMainForm.FormDestroy(Sender: TObject);
// ---------------------------
// Tidy up when form destroyed
// ---------------------------
begin

    MarkerList.Free ;

end;


procedure TMainForm.TimerTimer(Sender: TObject);
// ---------------------
// Timed event scheduler
// ---------------------
var
    i,j,ch : Integer ;
    ABP,HR,NicMem,SkelMus : single ;
begin

     if not bStart.Enabled then
        begin

        // Stimulate selected nerve pathways
        if bStopStimulator.Enabled then Model.StimulateNerves( bStopStimulator.Enabled,
                                                               ckVagusNerve.Checked,
                                                               ckNicMembrane.Checked,
                                                               ckSKeletalMuscle.Checked ) ;

        { Calculate next set of simulation values }
        for i := 0 to 4 do
            begin

            Model.DoSimulationStep( ABP, HR, SkelMus, NicMem ) ;

            j := NumPointsInBuf*scDisplay.NumChannels ;


            ADC[j+chABP] := Round( (ABP*BPMax) /scDisplay.ChanScale[chABP]);
            ADC[j+chHR] := Round( (HR)/scDisplay.ChanScale[chHR]);
            ADC[j+ChNIC] :=  Round( NicMem/scDisplay.ChanScale[chNIC]) ;
            ADC[j+ChSKM] := Round( SkelMus/scDisplay.ChanScale[chSKM]) ;

            Inc(NumPointsInBuf) ;

            // Ensure trace does not exceed display range
            for ch := 0 to scDisplay.NumChannels-1 do if ADC[j+ch] > scDisplay.Ymax[ch] then
                begin
                scDisplay.Ymax[ch] := scDisplay.Ymax[ch]*1.1 ;
                end ;
            scDisplay.Invalidate ;

            end;


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




procedure TMainForm.cbAgonistChange(Sender: TObject);
// ==============================
// Agonist drug selection changed
// ==============================
begin
    Model.SetDoseList( cbAgonist, cbAgonistDose ) ;
end;


procedure TMainForm.cbAntagonistChange(Sender: TObject);
// ==============================
// Antaonist drug selection changed
// ==============================
begin
    Model.SetDoseList( cbAntagonist, cbAntagonistDose ) ;
end;


procedure TMainForm.cbUnknownChange(Sender: TObject);
// ==============================
// Unknown drug selection changed
// ==============================
begin
    Model.SetDoseList( cbUnknown, cbUnknownDose ) ;
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

    Model.Drugs[iDrug].DoseInjected := Model.Drugs[iDrug].DoseInjected + Dose ;

    // Set close arterial injection flag
    Model.Drugs[iDrug].CloseArterialInjection := rbCloseArterialInjection.Checked ;

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
    ChartAnnotation := format('%s %.3g %s',[Model.Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
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
    Model.Drugs[iDrug].DoseInjected := Model.Drugs[iDrug].DoseInjected + Dose ;
    Model.Drugs[iDrug].CloseArterialInjection := False ;

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
    ChartAnnotation := format('%s %.3g %s',[Model.Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
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
    Model.Drugs[iDrug].DoseInjected := Model.Drugs[iDrug].DoseInjected + Dose ;
    Model.Drugs[iDrug].CloseArterialInjection := False ;

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
    ChartAnnotation := format('%s %.3g %s',[Model.Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
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
        Model.InitializeSimulation ;
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

     Model.InitializeSimulation ;

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


procedure TMainForm.mnWebHelpClick(Sender: TObject);
// --------------------------------------
// Web Help - Wiki from GitHub repository
// --------------------------------------
var
  URL: string;
begin
  URL := 'https://github.com/johndempster/Cat/wiki';
{$IFDEF MSWINDOWS}
  URL := StringReplace(URL, '"', '%22', [rfReplaceAll]);
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
  {$ENDIF}

  {$IFDEF MACOS}
      _system(PAnsiChar('open ' + AnsiString(URL)));
    {$ENDIF}
end;


procedure TMainForm.mnNewCatClick(Sender: TObject);
// --------------------
// Start new experiment
// --------------------
begin
     if MessageDlg('New Experiment! Are you sure?', mtConfirmation,
        [mbYes,mbNo],0) = mrYes then
        begin
        Model.InitializeSimulation ;
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




end.
