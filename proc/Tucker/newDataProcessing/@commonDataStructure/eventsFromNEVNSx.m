function eventsFromNEVNSx(cds,NEVNSx)
    %takes a cds handle and an NEVNSx structure and returns the words and
    %databursts fields to populate those fields of the cds
    if ~isempty(NEVNSx.NEV.Data.SerialDigitalIO.TimeStamp)  
        event_data = double(NEVNSx.NEV.Data.SerialDigitalIO.UnparsedData);
        event_ts = NEVNSx.NEV.Data.SerialDigitalIO.TimeStampSec';       

        idx=skip_resets(event_ts);
        if ~isempty(idx)
            event_data = event_data( (idx(end)+1):end);
            event_ts   = event_ts(   (idx(end)+1):end);
        end
        clear idx;

        % Check if file was recorded before the digital input cable was
        % switched.
        DateTime = [int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(1)) ...
        ' ' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEVNSx.NEV.MetaTags.DateTimeRaw(8))];

        if datenum(DateTime) - datenum('14-Jan-2011 14:00:00') < 0 
            % The input cable for this was bugged: Bits 0 and 8
            % are swapped.  The WORD is mostly on the high byte (bits
            % 15-9,0) and the ENCODER is mostly on the
            % low byte (bits 7-1,8).
            all_words = [event_ts, bitshift(bitand(hex2dec('FE00'),event_data),-8)+bitget(event_data,1)];
        else
            %The WORD is on the high byte (bits
            % 15-8) and the ENCODER is on the
            % low byte (bits 8-1).
            all_words = [event_ts, bitshift(bitand(hex2dec('FF00'),event_data),-8)];
        end             

        % Remove all zero words.
        actual_words = all_words(logical(all_words(:,2)),:);
        % Remove all repeated words (due to encoder data timing)
        word_indices_remove = find(diff(actual_words(:,1))<0.0005 & diff(actual_words(:,2))==0)+1;

        if ~isempty(word_indices_remove)
            word_indices_keep = setxor(word_indices_remove,1:length(actual_words));
            actual_words = actual_words(word_indices_keep,:);
        end
        if  exist('actual_words','var')
            [words, databursts] = extract_datablocks(actual_words);
        end
        words=table(words(:,1),words(:,2),'VariableNames',{'ts','word'});
        words.Properties.VariableUnits={'s','int'};
        words.Properties.VariableDescriptions={'timestamp of word in seconds','word value'};
        words.Properties.Description='list of all words captured during data collection';
        %cds.setField('words',words) 
        set(cds,'words',words)
        databursts=table(cell2mat(databursts(:,1)),cell2mat(databursts(:,2:end)),'VariableNames',{'ts','db'});
        databursts.Properties.VariableUnits={'s','int'};
        databursts.Properties.VariableDescriptions={'timestamp of databurst in seconds','row vector containing databurst'};
        databursts.Properties.Description='list of all databursts captured during data collection';           
        %cds.setField('databursts',databursts);
        set(cds,'databursts',databursts)
    end
    cds.addOperation(mfilename('fullpath'))
end