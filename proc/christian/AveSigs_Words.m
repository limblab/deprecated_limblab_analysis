function [AveSigs] = AveSigs_Words(signals,wordsVect,startWord,Word1,Word2)
    % this function averages signals (e.g. Firing Rate, EMGs) Between
    % consecutive words (between Word1 and Word2
    % the first colomn of the signals array should be a time vector in
    % seconds
    
    % get the ts pairs of all word1 and word2 pairs within trials
    ts_pairs = Get_Words_ts_pairs(startWord, Word1, Word2, wordsVect);
    
    % Now, average signals according to ts_pairs
    numTrials = size(ts_pairs,1);
    numSigs = size(signals,2)-1;
    AveSigs = zeros(numTrials,numSigs);
    
    for i=1:numTrials
        AveSigs(i,:) = mean(signals( signals(:,1)>ts_pairs(i,1) & signals(:,1)<ts_pairs(i,2),2:end));
    end

end