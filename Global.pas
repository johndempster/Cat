unit Global;

interface

uses Graphics ;

const
     ChannelLimit = 3 ;
     BP = 0 ;
     BPMax = 200 ;
     HR = 1 ;
     HRMax  = 300 ;
     NM = 2 ;
     NMMax = 100 ;
     SK = 3 ;
     SKMax = 100 ;
     ChartWidth = 2000 ;

type


TString4 = string[4] ;
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
Color : TColor ;
TimeZero : Single ;
ADCZero : LongInt ;
ADCSCale : Single ;
ADCCalibrationFactor : Single ;
ADCCalibrationValue : Single ;
ADCAmplifierGain : Single ;
ADCUnits : Tstring4 ;
ADCName : TString4 ;
CursorIndex : LongInt ;
CursorTime : Single ;
CursorValue : Single ;
DCOffset : LongInt ;
DCOffsetV : Single ;

end ;



TCursor = record
        Channel : LongInt ;
        MoveZero : Boolean ;
        Time : Single ;
        yValue : Single ;
        end ;


{ Global Variables }
const
NumSamplesPerSector = 256 ;
NumBytesPerSector = 512 ;

var
   Channel : array[0..ChannelLimit] of TChannel ;
   Curs : TCursor ;

implementation

end.
