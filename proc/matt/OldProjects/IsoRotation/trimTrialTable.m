function trialTable =  trimTrialTable(trialTable)

% exclude failed trials
trialTable=trialTable(trialTable(:,9)==82,:);

% Exclude trials that are abnormally short or abnormally long
%   How to decide? remove one standard deviation
meanTime = mean(trialTable(:,8)-trialTable(:,7));
stdTime = std(trialTable(:,8)-trialTable(:,7));
trialTable = trialTable(trialTable(:,8)-trialTable(:,7) < meanTime + stdTime,:);
trialTable = trialTable(trialTable(:,8)-trialTable(:,7) > meanTime - stdTime,:);

% Now that the really large trials are gone, do it again to shrink the set
meanTime = mean(trialTable(:,8)-trialTable(:,7));
stdTime = std(trialTable(:,8)-trialTable(:,7));
trialTable = trialTable(trialTable(:,8)-trialTable(:,7) < meanTime + 0.2*stdTime,:);
trialTable = trialTable(trialTable(:,8)-trialTable(:,7) > meanTime - stdTime,:);