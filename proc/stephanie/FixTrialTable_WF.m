function trialtable = FixTrialTable_WF(trialtable);
%Put inside trial table

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