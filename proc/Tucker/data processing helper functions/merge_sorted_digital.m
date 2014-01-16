function NEV_out=merge_sorted_digital(NEV,NEV_nodigital)
%saves only the spikes and header information from an NEV object. the 
%primary purpose of this is to exclude the digital data, which makes 
%offline sorter much slower to respond.   
    
    if ~isempty(NEV_nodigital.Data.SerialDigitalIO.TimeStamp)
        warning('MERGE_SORTED_DIGITAL:OverwritingDigitalData','The NEV given as the second argument has digital data. This data will be overwritten')
    end

    NEV_out=NEV_nodigital;
    
    NEV_out.Data.SerialDigitalIO.TimeStamp=NEV.Data.SerialDigitalIO.TimeStamp;
    NEV_out.Data.SerialDigitalIO.TimeStampSec=NEV.Data.SerialDigitalIO.TimeStampSec;
    NEV_out.Data.SerialDigitalIO.InsertionReason=NEV.Data.SerialDigitalIO.InsertionReason;
    NEV_out.Data.SerialDigitalIO.UnparsedData=NEV.Data.SerialDigitalIO.UnparsedData;
end