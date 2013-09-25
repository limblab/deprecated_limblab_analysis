function [filtered_words, datablocks] = extract_datablocks(words)
% [FILTERED_WORDS, DATABLOCKS] = EXTRACT_DATABLOCKS(WORDS)
%
% Takes a list of event codes WORDS arranged as two columns with timestamps
% first and byte values second, and returns two variables with the
% datablocks extracted.  FILTERED_WORDS contains just the event codes with
% the datablocks removed.  DATABLOCKS contains a list of the datablocks as
% an Nx2 cell array where the first column is the time stamps and the
% second column each contains a list of bytes corresponding to the content
% of the datablock.

% $Id: extract_datablocks.m 146 2009-10-09 16:59:40Z brian $

min_db_val = hex2dec('F0');
max_db_val = hex2dec('FF');

filtered_words = words( words(:,2) < min_db_val, :);

if nargout > 1
    % Get datablock words
    db_list = words( words(:,2) >= min_db_val & words(:,2) <= max_db_val, :);
    if isempty(db_list)
        datablocks = [];
        return
    end    
    
    % Find datablock frames
    frame_idx = find( diff(db_list(:,1)) > .01 ) + 1; % For some reason, there is up to 5 ms between some of the bytes in WF
    if length(frame_idx)>0
        
        %include the first datablock
        frame_idx = [1; frame_idx];

        %include the last datablock
        frame_idx = [frame_idx ; length(db_list(:,1))];

        db_lengths=diff(frame_idx);
        numwords=median(db_lengths);

        %locate any bad databursts that are in the middle of the
        %session and warn the user
        bad_db=find( db_lengths ~= numwords );
        
        disp('The following databursts are inconsistent with the detected databurst size:')
        for i=1:length(bad_db)
            disp(strcat(  'Burst #: ',num2str(bad_db(i)),' At timestamp: ',num2str(db_list(frame_idx(bad_db(i)))), ' and has size: ',num2str(db_lengths(bad_db(i))),' words'  ));
        end
        disp(strcat('Databursts not containing: ',num2str(numwords),' words will be entered as NaN, rather than a full databurst'))
        if (isempty(find(db_lengths==numwords)))
            error('get_cerebus_data:calc_from_raw:extract_datablocks:NoMedianDataburstLength','The computed median number of words does not match any of the actual databursts. Check to see that you have more than 2 databursts, and that your databursts are of consistent size.')
        end
    else
            error('get_cerebus_data:calc_from_raw:extract_datablocks:NoDataBursts','No pause between databurst words was detected. Cannot identify good databursts. File may be corrupt or truncated')
    end
     
    datablocks = cell(length(frame_idx), 2);
    for i = 1:length(frame_idx)
        idx = frame_idx(i);
        datablocks{i,1} = db_list(idx,1);
        try 
            num_bytes = (db_list(idx, 2) - min_db_val) + 16*(db_list(idx+1, 2) - min_db_val);
            if (num_bytes ~= numwords/2)
                error('get_cerebus_data:calc_from_raw:extract_datablocks:DataburstSizeError','The databurst size does not match the size selected for this trial')
            end
            raw_bytes = db_list(idx:idx+num_bytes*2-1, 2)';
            half_bytes = reshape(raw_bytes,2,[]) - min_db_val;
            datablocks{i,2} = 16*half_bytes(2,:) + half_bytes(1,:);
        catch
            disp(strcat('Encountered error converting databurst #:',num2str(i)))
            disp(lasterror)
            datablocks{i,2} = NaN;
        end
    end
end
