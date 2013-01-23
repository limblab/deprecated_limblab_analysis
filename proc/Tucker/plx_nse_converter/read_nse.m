%get name of file to convert
[fname,fpath]=uigetfile('*.nev', 'Select file to convert');

Filename=strcat(fpath,fname);
FieldSelectionFlags=[1 1 0 0 1];
HeaderExtractionFlag=1;
ExtractMode=1;
ExtractionModeVector=[];


%[Timestamps, ScNumbers, CellNumbers, Features, Samples, Header] =  Nlx2MatSpike( Filename, FieldSelectionFlags,HeaderExtractionFlag, ExtractMode, ExtractionModeVector);
[Timestamps, EventIDs, TTLs, Extras, EventStrings, Header] = Nlx2MatEV(fname, [1 1 1 1 1], 1, 1, [] );
%   [TimeStamps, EventIDs, TTLs, Extras, EventStrings, Header] = Nlx2MatEV( Filename, FieldSelectionFlags, HeaderExtractionFlag, ExtractMode, ExtractionModeVector );