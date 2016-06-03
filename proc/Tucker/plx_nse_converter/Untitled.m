% getting .nse data into matlab:

 % NLX2MATSPIKE Imports data from Neuralynx NSE, NST and NTT files to Matlab variables.
 
    [Timestamps, ScNumbers, CellNumbers, Features, Samples, Header] =
                       Nlx2MatSpike( Filename, FieldSelectionFlags,
                       HeaderExtractionFlag, ExtractMode, ExtractionModeVector);
                       
%NLX2MATEV Imports data from Neuralynx NEV files to Matlab variables.
 
    [TimeStamps, EventIDs, TTLs, Extras, EventStrings, Header] =
                       Nlx2MatEV( Filename, FieldSelection, ExtractHeader,
                                  ExtractMode, ModeArray );