function ts_pairs = Get_Words_ts_pairs(startWord, Word1, Word2, wordsVect)

% This function returns ts_pairs, a 2 column matrix containing on each rows
% the time stamps of 2 words within the same trial. Word1 and Word2 should
% be sequential within the trial.
% startWord: the start word for the task
% Word1, Word2: the two words from which you want to extract the ts
% WordsVect: a 2 column matrix of words as found in the bdf struct

%get the words ts
Start_ts = wordsVect(wordsVect(:,2)==startWord,1);
Word1_ts = wordsVect(wordsVect(:,2)==Word1 & wordsVect(:,1)>Start_ts(1),1);
Word2_ts = wordsVect(wordsVect(:,2)==Word2 & wordsVect(:,1)>Start_ts(1),1);

% %Use only Word2 after first Word1 occurance
% Word2_ts=Word2_ts(Word2_ts>Word1_ts(1));

ts_pairs = zeros(min(length(Word1_ts),length(Word2_ts)),2);

%Make sure we use pairs of Word1, Word2 that are from same trials
for i=1:length(Start_ts)
    if i==length(Start_ts)
        spot=Word1_ts(Word1_ts>=Start_ts(i));
        if ~isempty(spot)
            ts_pairs(i,1) = spot(1);
        end
        spot=Word2_ts(Word2_ts>Start_ts(i));
        if ~isempty(spot)
        ts_pairs(i,2) = spot(1);
        end
    else
        spot = Word1_ts(Word1_ts>=Start_ts(i) & Word1_ts<Start_ts(i+1));
        if ~isempty(spot)
            ts_pairs(i,1) = spot(1);
        end
        spot = Word2_ts(Word2_ts>Start_ts(i) & Word2_ts<Start_ts(i+1));
        if ~isempty(spot)
            ts_pairs(i,2) = spot(1);
        end
    end
end

%discard trials in which Word1 and Word2 did not both occur
ts_pairs = ts_pairs(ts_pairs(:,1) & ts_pairs(:,2),:);

end