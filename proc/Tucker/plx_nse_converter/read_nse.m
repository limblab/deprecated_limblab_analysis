%get name of file to convert
[fname,fpath]=uigetfile('*.nse', 'Select file to convert');

Filename=strcat(fpath,fname);
FieldSelectionFlags=[1 1 1 1 1];
HeaderExtractionFlag=1;
ExtractMode=1;
ExtractionModeVector=[];
[Timestamps, ScNumbers, CellNumbers, Features, Samples, Header] =  Nlx2MatSpike( Filename, FieldSelectionFlags,HeaderExtractionFlag, ExtractMode, ExtractionModeVector);