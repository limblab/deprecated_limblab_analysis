%Context dependence
% This script runs analyses for my context dependence study. This includes
% plotting mean force versus mean firing rate for individual cells
% Input: binnedData

% Prune trial table ------------------------------------------------------
%Get rid of anomalies in the trial table
getrid =  find(binnedData.trialtable(:,7) == -1);
binnedData.trialtable(getrid,:)=[];
%Get rid of failed trials
failures =  find(binnedData.trialtable(:,9) ~= 82);
binnedData.trialtable(failures,:)=[];
% -------------------------------------------------------------------------

%Find the outer target hold epoch


% Start at the end of the trial
%backtrack hold time

% for each trial, get end of trial time
% go back in time until
figure
InTarget = zeros(length(binnedData.trialtable),15);
for i=1:length(binnedData.trialtable)
    
    Go2EndIndices = []; XinTarget = []; YinTarget = [];
    Go2EndInTargetIndices = [];
    
    %look between outer target on and trial table
    endtime = binnedData.trialtable(i,8);
    gocue = binnedData.trialtable(i,7);
    % Get the timeframe indices between gocue and endtime
    Go2EndIndices = find( binnedData.timeframe > gocue & binnedData.timeframe < endtime );
   
    XinTarget = binnedData.cursorposbin(Go2EndIndices,1) > abs(binnedData.trialtable(i,2)) & binnedData.cursorposbin(Go2EndIndices,1) < abs(binnedData.trialtable(i,4));
    YinTarget = binnedData.cursorposbin(Go2EndIndices,2) > binnedData.trialtable(i,5) & binnedData.cursorposbin(Go2EndIndices,2) < binnedData.trialtable(i,3);
    
    InTargetIndices = [];
    counter = 1;
   
    for j = length(Go2EndIndices):-1:1
        if XinTarget(j) && YinTarget(j) == 1
            InTargetIndices(counter,1) = j;
            counter = counter+1;
        else
            break
        end
    end
      
    Go2EndInTargetIndices = Go2EndIndices(InTargetIndices);
    %InTarget(i,:) = flipud(Go2EndInTargetIndices)';
    Go2EndInTargetIndices  = flipud(Go2EndInTargetIndices)';
    
    
   
    
    
    BinnedForce = [];
    for b = 1:length(Go2EndInTargetIndices)
        % Get the average force during this epoch for every successful trial
        BinnedForce(b) = hypot(binnedData.forcedatabin(Go2EndInTargetIndices(b),1), binnedData.forcedatabin(Go2EndInTargetIndices(b),2));
    end
    TrialForce = mean(BinnedForce);
    
    
     % Get the average firing rate during this epoch for every successful trial
        for c = 50%:length(binnedData.spikeratedata(1,:)) %cycle through each cell
            TrialSpikeRate(c) = mean(binnedData.spikeratedata(Go2EndInTargetIndices));
        end
        
    
    % Plot average force (x) versus average firing rate (y)
    plot(TrialForce,TrialSpikeRate,'gx')
    hold on
    
    

end




% Plot average force (x) versus average firing rate (y)