%%
tuning_vec = zeros(length(bdf_tuning.units),3);
tuning_vec_units = ul;
for i = 1:length(tuning_vec)
    tuning_vec(i,1:2) = bdf_tuning.units(i).id;
    tuning_vec(i,3) = bdf_tuning.units(i).tuned;
end