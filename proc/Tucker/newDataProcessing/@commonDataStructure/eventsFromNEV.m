function eventsFromNEV(cds,opts)
    %takes a cds handle and an NEVNSx structure and returns the words and
    %databursts fields to populate those fields of the cds
    if ~isempty(cds.NEV.Data.SerialDigitalIO.TimeStamp)  
        event_data = double(cds.NEV.Data.SerialDigitalIO.UnparsedData);
        event_ts = cds.NEV.Data.SerialDigitalIO.TimeStampSec';       

        idx=cds.skipResets(event_ts);
        if ~isempty(idx)
            event_data = event_data( (idx(end)+1):end);
            event_ts   = event_ts(   (idx(end)+1):end);
        end
        clear idx;

        % Check if file was recorded before the digital input cable was
        % switched.
        if datenum(opts.dateTime) - datenum('14-Jan-2011 14:00:00') < 0 
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
            %parse words array into databursts and event-words tables
            min_db_val = hex2dec('F0');
            max_db_val = hex2dec('FF');

            %generate the databursts array:
            db_list = actual_words( actual_words(:,2) >= min_db_val & actual_words(:,2) <= max_db_val, :);
            if isempty(db_list)
                databursts = [];
            else   
                % Find datablock frames
                frame_idx = find( diff(db_list(:,1)) > .01 ) + 1; % For some reason, there is up to 5 ms between some of the bytes in WF
                frame_idx = [1; frame_idx];

                databursts = cell(length(frame_idx), 2);
                for i = 1:length(frame_idx)
                    idx = frame_idx(i);
                    databursts{i,1} = db_list(idx,1);
                    try 
                        num_bytes = (db_list(idx, 2) - min_db_val) + 16*(db_list(idx+1, 2) - min_db_val);
                        raw_bytes = db_list(idx:idx+num_bytes*2-1, 2)';
                        half_bytes = reshape(raw_bytes,2,[]) - min_db_val;
                        databursts{i,2} = 16*half_bytes(2,:) + half_bytes(1,:);
                    catch
                        databursts{i,2} = NaN;
                    end
                end
            end
            %sanitize the databursts of any databursts that arent the apparent size of the databurst:
            dbSize=mode(cellfun(@length,databursts(:,2)));
            databursts=databursts(cellfun(@(x)length(x)==dbSize,databursts(:,2)),:);
            %convert databursts into table:
            databursts=table(cell2mat(databursts(:,1)),cell2mat(databursts(:,2:end)),'VariableNames',{'ts','db'});
            databursts.Properties.VariableUnits={'s','int'};
            databursts.Properties.VariableDescriptions={'timestamp of databurst in seconds','row vector containing databurst'};
            databursts.Properties.Description='list of all databursts captured during data collection';  
            set(cds,'databursts',databursts)

            %generate the words table from the non-databurst words:
            actual_words = actual_words( actual_words(:,2) < min_db_val, :);
            actual_words=table(actual_words(:,1),actual_words(:,2),'VariableNames',{'ts','word'});
            actual_words.Properties.VariableUnits={'s','int'};
            actual_words.Properties.VariableDescriptions={'timestamp of word in seconds','word value'};
            actual_words.Properties.Description='list of all words captured during data collection';
            set(cds,'words',actual_words)
            %log the     
            evntData=loggingListenerEventData('eventsFromNEV',[]);
            notify(cds,'ranOperation',evntData)
        end
    end
end