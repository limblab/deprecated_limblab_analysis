
%Context dependence
% This script runs analyses for my context dependence study. This includes
% plotting mean force versus mean firing rate for individual cells
% Input: bdf

% Make trial table
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
% -------------------------------------------------------------------------

%Fix trial table for the task
%Numbers the targets 1-3 going from low to high force
TNumbers = unique(sort(trialtable(:,2)));
for i=1:length(trialtable)
    switch trialtable(i,2)
        case TNumbers(1)
            trialtable(i,10)=1;
        case TNumbers(2)
            trialtable(i,10)=2;
        case TNumbers(3)
            trialtable(i,10)=3;
    end
end



%---------------------------------------------------------------------
start = trialtable(1,1);
finish = trialtable(1,8);
OTon = trialtable(1,6);


OTonInd = find(abs(out_struct.force.data(:,1) - OTon) < 0.001);
OTminusHold = OTon-0.5;
OTminusHoldind = find(abs(out_struct.force.data(:,1) - OTminusHold) < 0.001);
Indices = find(out_struct.force.data(:,1)>=start & out_struct.force.data(:,1)<=finish);
Force = hypot(out_struct.force.data(Indices,2), out_struct.force.data(Indices,3));
figure
plot(out_struct.force.data(Indices,1), out_struct.force.data(Indices,2),'b-')
hold on
plot(out_struct.force.data(Indices,1), Force,'g-')
plot(out_struct.force.data(OTonInd,1),out_struct.force.data(OTonInd,2),'r*','MarkerSize', 20)
plot(out_struct.force.data(OTminusHoldind,1),out_struct.force.data(OTminusHoldind,2),'k*','MarkerSize', 20)


OTonInd = find(abs(out_struct.pos(:,1) - OTon) < 0.001);
OTminusHold = OTon-0.5;
OTminusHoldind = find(abs(out_struct.pos(:,1) - OTminusHold) < 0.001);
Indices = find(out_struct.pos(:,1)>=start & out_struct.pos(:,1)<=finish);
Position = hypot(out_struct.pos(Indices,2), out_struct.pos(Indices,3));


figure
plot(out_struct.pos(Indices,1), out_struct.pos(Indices,2),'b-')
hold on
plot(out_struct.pos(Indices,1), Position,'g-')
plot(out_struct.pos(OTonInd,1),out_struct.pos(OTonInd,2),'r*','MarkerSize', 20)
plot(out_struct.pos(OTminusHoldind,1),out_struct.pos(OTminusHoldind,2),'k*','MarkerSize', 20)