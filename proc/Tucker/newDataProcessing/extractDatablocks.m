function [filtered_words, datablocks] = extractDatablocks(words)
% [FILTERED_WORDS, DATABLOCKS] = EXTRACT_DATABLOCKS(WORDS)
%
% Takes a list of event codes WORDS arranged as two columns with timestamps
% first and byte values second, and returns two variables with the
% datablocks extracted.  FILTERED_WORDS contains just the event codes with
% the datablocks removed.  DATABLOCKS contains a list of the datablocks as
% an Nx2 cell array where the first column is the time stamps and the
% second column each contains a list of bytes corresponding to the content
% of the datablock.

% $Id$

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
%     frame_idx = find( diff(db_list(:,1)) > .005 ) + 1;
    frame_idx = find( diff(db_list(:,1)) > .01 ) + 1; % For some reason, there is up to 5 ms between some of the bytes in WF
    frame_idx = [1; frame_idx];
    
    datablocks = cell(length(frame_idx), 2);
    for i = 1:length(frame_idx)
        idx = frame_idx(i);
        datablocks{i,1} = db_list(idx,1);
        try 
            num_bytes = (db_list(idx, 2) - min_db_val) + 16*(db_list(idx+1, 2) - min_db_val);
            raw_bytes = db_list(idx:idx+num_bytes*2-1, 2)';
            half_bytes = reshape(raw_bytes,2,[]) - min_db_val;
            datablocks{i,2} = 16*half_bytes(2,:) + half_bytes(1,:);
        catch
            datablocks{i,2} = NaN;
        end
    end
end
