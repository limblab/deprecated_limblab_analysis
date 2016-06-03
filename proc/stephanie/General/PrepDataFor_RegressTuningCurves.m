

% Make a fr file
% fr || nxv array where n is firing rate for each trial and v is each
% neuron

%% Make trial table
trialtable = wf_trial_table(out_struct);

% Prune trial table ------------------------------------------------------
%Get rid of anomalies in the trial table (From Ricky)
remove_index = [];
for iCol=[2 3 4 5]
    [tempa tempb] = hist(trialtable(:,iCol),1000);
    cumsum_temp = cumsum(tempa/sum(tempa));
    remove_under = tempb(find(cumsum_temp<0.02,1,'last'));
    if ~isempty(remove_under)
        remove_under_idx = find(trialtable(:,iCol)<remove_under);
        if length(remove_under_idx)/size(trialtable,1)<0.02
            remove_index = [remove_index find(trialtable(:,iCol)<remove_under)'];
        end
    end
    remove_above = tempb(find(cumsum_temp>0.98,1,'first'));
    if ~isempty(remove_above)
        remove_above_idx = find(trialtable(:,iCol)>remove_above);
        if length(remove_above_idx)/size(trialtable,1)<0.02
            remove_index = [remove_index find(trialtable(:,iCol)>remove_above)'];
        end
    end
end
remove_index = unique(remove_index);
trialtable(remove_index,:) = [];

%Extra pruning
%Get rid of anomalies in the trial table
getrid =  find(trialtable(:,7) == -1);
trialtable(getrid,:)=[];
%Get rid of failed trials
failures =  find(trialtable(:,9) ~= 82);
trialtable(failures,:)=[];
%% -------------------------------------------------------------------------


% Get the indices for the sorted cells
sortedUnitIndices = []; ind=1;
for a = 1:length(out_struct.units)
    if out_struct.units(1,a).id(2)~=0
        sortedUnitIndices(ind) = a;
        ind = ind+1;
    end
end

pi = 3.14;
for i=1:length(trialtable)
    switch trialtable(i,10)
        case 1
            theta(i) = 0;
        case 2
            theta(i) = pi/4;
        case 3
            theta(i) = pi/2;
        case 4
            theta(i) = (3*pi)/4;
        case 5
            theta(i) = pi;
        case 6
            theta(i) = (5*pi)/4;
        case 7
            theta(i) = (3*pi)/2;
        case 8
            theta(i) = (7*pi)/4;
    end
end
theta = theta;

fr = NaN(length(trialtable),length(sortedUnitIndices));
for trialInd = 1:length(trialtable)
    
    OuterHoldStart = trialtable(trialInd,8)-0.5;
    OuterHoldEnd = trialtable(trialInd,8);
    
    for a = 1:length(sortedUnitIndices)
        unitIndex = sortedUnitIndices(a);
        spikes = find((out_struct.units(1,unitIndex).ts >= OuterHoldStart)&(out_struct.units(1,unitIndex).ts <= OuterHoldEnd));
        fr(trialInd,a) = length(spikes)/0.5;         
    end
    
end



