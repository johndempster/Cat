unit CatModel;
// -------------
// Tissue models
// -------------
// 18.07.24 Model code moved from CatMain to CatModel


interface

uses
  System.SysUtils, System.Classes, Stdctrls, Strutils ;

const

    None = -1. ;  // No Potency flag
    MaxDrugs = 100 ;
    // Drug available for applying to tissue flags

    dtAgonist = 0 ;
    dtAntagonist = 1 ;
    dtUnknown = 3 ;
    dtNerve = 4 ;

     ChABP = 0 ;   // Arterial blood pressure channel }
     ChHR = 1 ;    // Heart rate channel }
     ChNIC = 2 ;   // Nictitating membrane }
     ChSKM = 3 ;   // Skeletal muscle

     NMMax = 100 ;
     SKMax = 100 ;

     BPMax = 200 ;
     MaxADCValue = 2047 ;
     MinADCValue = -2048 ;


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
            DrugType : Integer ;
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


  TModel = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    LastAgonist : Integer ;      // Index of last agonist in drug list
    LastAntagonist : Integer ;      // Index of last antagonist in drug list


   t : TTime ;
   {Standard drugs }

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
   StimulationInProgress : Boolean ;

   function AddNoise( Proportion : single ) : single ;

  public
    { Public declarations }

    NumDrugs : Integer ;                                // No. drugs available
    Drugs : Array[0..MaxDrugs] of TDrug ;               // Drug properties array

    procedure InitializeSimulation ;

    procedure DoSimulationStep( var ArterialBP : single ;
                                var HeartRate : single ;
                                var SkeletalMuscleContraction : single ;
                                var NicMemContraction : single ) ;

    procedure StimulateNerves( StimulationOn : Boolean ;  // TRUE = Stimulation On
                               VagusNerve : Boolean ;
                               SkeletalMuscle : Boolean ;
                               NicMembrane : Boolean ) ;

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

    procedure SetDoseList(
              cbDrug : TComboBox ;
              cbDose : TComboBox ) ;

   procedure GetListOfDrugs(
              DrugList : TComboBox ;         // Return list of drugs
              DrugType : Integer ) ;         // Type of drug (Agonist,Antagonist,Unknown)

   function ExtractFloat ( CBuf : string ; Default : Single ) : extended ;

  end;

var
  Model: TModel;

implementation


{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses math ;

procedure TModel.DataModuleCreate(Sender: TObject);
// ------------------------------------
// Initialisations when form is created
// ------------------------------------
var
    i : Integer ;
begin

     // Ensure drugs array has Nil entries
     for i := 0 to High(Drugs) do Drugs[i] := Nil ;

     // Initialise simulation conditions & drugs
     InitializeSimulation ;

end;

procedure TModel.DataModuleDestroy(Sender: TObject);
// --------------------------------------
// Free resources when form is desttroyed
// --------------------------------------
var
    i : integer ;
begin
    for i := 0 to High(Drugs) do if Drugs[i] <> Nil then Drugs[i].Free ;
    end;


procedure TModel.InitializeSimulation ;
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



     {Initialise drug doses and potencies }
     for i := 0 to MaxDrugs do if Drugs[i] <> Nil then
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
     Drugs[iDrug].DrugType := dtAgonist ;
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
     Drugs[iDrug].DrugType := dtAgonist ;

     // Isoprenaline - Beta adrenoceptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Isoprenaline', 'Iso' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, 5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, 5E-4 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;
     Drugs[iDrug].DrugType := dtAgonist ;

     // Phenylephrine - Alpha adrenoceptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Phenylephrine', 'Phe' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdR, 5E-3 ) ;
     SetAgonistPotency( Drugs[iDrug].AlphaAdRNicMem, 5E-3 ) ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-1 ;
     Drugs[iDrug].DrugType := dtAgonist ;

     // Cholinoceptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Acetylcholine', 'Ach' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate :=FastOff ;
     SetAgonistPotency( Drugs[iDrug].MusChR, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].MusChRHeart, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChR, 0.001 ) ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 0.3) ;
     Drugs[iDrug].DrugType := dtAgonist ;
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
     Drugs[iDrug].DrugType := dtAgonist ;

     { Suxaamethonium  (depolarizing neuromuscular blocker nicotinic receptor agonist) }
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Suxamethonium', 'Sux' ) ;
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff*0.5 ;
     SetAgonistPotency( Drugs[iDrug].NicChR, 0.03) ;
     SetAgonistPotency( Drugs[iDrug].NicChRNicMemGanglion, 0.03) ;
     Drugs[iDrug].DrugType := dtAgonist ;
     Drugs[iDrug].MinDose := 0.01 ;
     Drugs[iDrug].MaxDose := 5.0 ;

     // H receptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Histamine', 'His' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].H1R, 0.3 ) ;
     Drugs[iDrug].DrugType := dtAgonist ;
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
     Drugs[iDrug].DrugType := dtAgonist ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Morphine Opioid receptor agonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Morphine', 'Mor' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].OpioidR, 0.5 ) ;
     Drugs[iDrug].DrugType := dtAgonist ;
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
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     // ALpha adrenceptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Phentolamine', 'Phe' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].AlphaAdR, 0.1 ) ;
     SetAntagonistPotency( Drugs[iDrug].AlphaAdRNicMem, 0.1 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
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
     Drugs[iDrug].DrugType := dtAntagonist ;
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
     Drugs[iDrug].DrugType := dtAntagonist ;
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
     Drugs[iDrug].DrugType := dtAntagonist ;
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
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     { Hexamethonium  (nicotinic ganglion blocker) }
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Hexamethonium', 'Hex' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].NicChRGanglionBlock, 0.5 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 0.5 ;
     Drugs[iDrug].MaxDose := 50.0 ;

     // Neoostigmine anticholinersterase
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Neostigmine', 'Neo' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].ChEsterase, 0.1 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 0.01 ;
     Drugs[iDrug].MaxDose := 1.0 ;

     // Physostigmine anticholinersterase
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Physostigmine', 'Phy' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].ChEsterase, 0.1 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 1.0 ;

     // Atropine muscarinic receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Atropine', 'Atr' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].MusChR, 0.1 ) ; {Potency reduced to 0.1 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].MusChRHeart, 0.1 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Mepyramine H1 receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Mepyramine', 'Mep' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].H1R, 0.5 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     // Verapamil Ca channel blocker
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Verapamil', 'Ver' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].HMCaChannel, 0.75 ) ;
     SetAgonistPotency( Drugs[iDrug].SMCaChannel, 0.75 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     // Naloxone Opioid receptor antagonist
     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create( 'Naloxone', 'Nal' ) ;
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].OpioidR, 0.04 ) ;
     Drugs[iDrug].DrugType := dtAntagonist ;
     Drugs[iDrug].MinDose := 1E-2 ;
     Drugs[iDrug].MaxDose := 1.0 ;
     LastAntagonist := iDrug ;

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
     Drugs[iDrug].DrugType := dtUnknown ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1.0 ;


     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug B', 'B' ) ;     { Adenosine  }
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].AdenR, 0.4 ) ;
     Drugs[iDrug].DrugType := dtUnknown ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug C', 'C' ) ;    { Isoprenaline }
     Drugs[iDrug].OnRate := FastOn ;
     Drugs[iDrug].RemovalRate := FastOff ;
     SetAgonistPotency( Drugs[iDrug].BetaAdR, 5E-4 ) ;
     SetAgonistPotency( Drugs[iDrug].BetaAdRHeart, 5E-4 ) ;
     Drugs[iDrug].DrugType := dtUnknown ;
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
     Drugs[iDrug].DrugType := dtUnknown ;
     Drugs[iDrug].MinDose := 1E-4 ;
     Drugs[iDrug].MaxDose := 1E-2 ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug H', 'H' ) ;     { Propanalol }
     Drugs[iDrug].OnRate := SlowOn ;                         { Antagonist }
     Drugs[iDrug].RemovalRate := SlowOff ;                   { Potency modified 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].BetaAdR, 0.5 ) ;
     SetAntagonistPotency( Drugs[iDrug].BetaAdRHeart, 0.5 ) ;
     Drugs[iDrug].DrugType := dtUnknown ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10. ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug I', 'I' ) ;     { Verapamil }
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAgonistPotency( Drugs[iDrug].HMCaChannel, 0.75 ) ;
     SetAgonistPotency( Drugs[iDrug].SMCaChannel, 0.75 ) ;
     Drugs[iDrug].DrugType := dtUnknown ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 100. ;

     Inc(iDrug) ;
     Drugs[iDrug] := TDrug.Create(  'Drug K', 'K' ) ;   { Atropine }
     Drugs[iDrug].OnRate := SlowOn ;
     Drugs[iDrug].RemovalRate := SlowOff ;
     SetAntagonistPotency( Drugs[iDrug].MusChR, 0.1 ) ; {Potency reduced to 0.1 4/7/00}
     SetAntagonistPotency( Drugs[iDrug].MusChRHeart, 0.1 ) ;
     Drugs[iDrug].DrugType := dtUnknown ;
     Drugs[iDrug].MinDose := 0.1 ;
     Drugs[iDrug].MaxDose := 10.0 ;


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

     NumDrugs := iDrug + 1 ;

     { Chart recorder traces }


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


     Dead := False ;
     Dying := 0 ;
     Fibrillation := 0.0 ;
     StimulationInProgress := False ;

     end ;




procedure TModel.DoSimulationStep( var ArterialBP : single ;
                                   var HeartRate : single ;
                                   var SkeletalMuscleContraction : single ;
                                   var NicMemContraction : single ) ;

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

     // Return resulst for this time point ;
     ArterialBP := BP.Value ;
     HeartRate := Heart.Rate ;
    SkeletalMuscleContraction := SkelMuscle.Contraction ;
    NicMemContraction := NicMem.Contraction ;


     t.time := t.time + t.Step ;
     end ;


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


procedure TModel.SetAgonistPotency(
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


function TModel.ReceptorActivation(
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


procedure TModel.SetAntagonistPotency(
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

procedure TModel.StimulateNerves( StimulationOn : Boolean ;  // TRUE = Stimulation On
                                  VagusNerve : Boolean ;
                                  SkeletalMuscle : Boolean ;
                                  NicMembrane : Boolean ) ;
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

    if StimulationOn and not StimulationInProgress then
       begin
       t.StimVagus := 0.0 ;
       t.StimSkeletalMuscle := 0.0 ;
       t.StimNicMembrane := 0.0 ;
       end;
    StimulationInProgress := StimulationOn ;

    // Vagus nerve
    if StimulationOn and VagusNerve and (t.time >= t.StimVagus) then
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
    if StimulationOn and SkeletalMuscle and  (t.time >= t.StimSkeletalMuscle) then
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

    if StimulationOn and (t.time > t.StimNicMembrane) and NicMembrane then
       begin
       Drugs[iNicMemPreGanglionic].DoseInjected := 5.0*(1.0 - AdenR) ;
       t.StimNicMembrane := t.time + StimNicMembranePeriod ;
       end ;

end;



procedure TModel.SetDoseList(
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


procedure TModel.GetListOfDrugs(
          DrugList : TComboBox ;         // Return list of drugs
          DrugType : Integer ) ;        // Type of drug (Agonist,Antagonist,Unknown)
// ---------------------------------------
// Return list of drugs of specified type
// ---------------------------------------
var
    i : Integer ;
begin

     DrugList.Clear ;

     for i := 0 to NumDrugs-1 do
         if DrugType = Drugs[i].DrugType then
            begin
            DrugList.Items.AddObject( Drugs[i].Name, TObject(i)) ;
         end;

     DrugList.ItemIndex := 0 ;

     end ;

function TModel.AddNoise(
         Proportion : single
         ) : single ;
{ -----------------------------------------------
  Create a random scaling factor 1 +/- Proportion
  -----------------------------------------------}
begin
     AddNoise := 1. + ((2.*random)-1. )*Proportion ;
     end ;


function TModel.ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
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




end.
