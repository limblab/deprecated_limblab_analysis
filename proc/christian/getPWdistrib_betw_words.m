function binnedPW = getPWdistrib_betw_words(datastruct, chs, binsize, startWord, Word1, Word2)

    % get the ts pairs of all word1 and word2 pairs within trials
    ts_pairs = Get_Words_ts_pairs(startWord, Word1, Word2, datastruct.words);
    
    
    
    % for each pair, get PW distribution and add it to the total
    numchs = length(chs);
    binnedPW = zeros(200/binsize,numchs);
    numTrials = size(ts_pairs,1);
    for i=1:numTrials
        for j=1:numchs
            binnedPW(:,j) = binnedPW(:,j) + PWdistrib(chs(j),binsize, datastruct.stim( datastruct.stim(:,1)>=ts_pairs(i,1) & datastruct.stim(:,1)<ts_pairs(i,2),:));
        end
    end
end