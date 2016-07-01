% GetFixTrialTable
function trialtable = GetFixTrialTable(binnedData,tasktype)

% Make trial table
trialtable = binnedData.trialtable;

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
% -------------------------------------------------------------------------

%Fix trial table for the task
%Numbers the targets 1-3 going from low to high force
if tasktype == 'generalize'
    TNumbers = unique(trialtable(:,2));
    for i=1:length(trialtable)
        switch trialtable(i,2)
            case TNumbers(1)
                trialtable(i,10)=1;
            case TNumbers(2)
                trialtable(i,10)=2;
            case TNumbers(3)
                trialtable(i,10)=3;
            case TNumbers(4)
                trialtable(i,10)=4;
            case TNumbers(5)
                trialtable(i,10)=5;
            case TNumbers(6)
                trialtable(i,10)=6;
        end
    end
end

if tasktype == 'contextdep'
    TNumbers = unique(trialtable(:,2));
    if TNumbers(1) < 0
        TNumbers = sort(TNumbers,'descend');
    else
        TNumbers = sort(TNumbers,'ascend');
    end
    
    for i=1:length(trialtable(:,1))
        switch trialtable(i,2)
            case TNumbers(1)
                trialtable(i,10)=1;
            case TNumbers(2)
                trialtable(i,10)=2;
            case TNumbers(3)
                trialtable(i,10)=3;
        end
    end
end
% -------------------------------------------------------------------------
