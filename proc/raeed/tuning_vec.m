%%
ul = unit_list(bdf_istuned);
tuning_vec = zeros(length(bdf_istuned.units),3);
tuning_vec_units = ul;
for i = 1:length(tuning_vec)
    tuning_vec(i,1:2) = bdf_istuned.units(i).id;
    tuning_vec(i,3) = bdf_istuned.units(i).tuned;
end

%take out unsorted and invalidated units and untuned units
tuned_single = tuning_vec(tuning_vec(:,2)~=255 & tuning_vec(:,2)~=0 & tuning_vec(:,3),:);