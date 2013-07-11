function saveNEVOnlySpikes2(NEV,fname)
%saves only the spikes and header information from an NEV object. the 
%primary purpose of this is to exclude the digital data, which makes 
%offline sorter much slower to respond.    
    NEV.Data.SerialDigitalIO.TimeStamp=[];
    NEV.Data.SerialDigitalIO.TimeStampSec=[];
    NEV.Data.SerialDigitalIO.InsertionReason=[];
    NEV.Data.SerialDigitalIO.UnparsedData=[];

    
    saveNEV(NEV,fname,'report')
end