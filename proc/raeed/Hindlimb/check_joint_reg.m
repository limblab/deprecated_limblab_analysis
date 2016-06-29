%% checking joint regression consistency
joint_fit_same = zeros(size(joint_fit_con));
for i = 1:length(joint_fit_con)
    con_pred = joint_fit_con{i}.PredictorNames;
    unc_pred = joint_fit_unc{i}.PredictorNames;
    
    joint_fit_same(i) = isempty(setxor(con_pred,unc_pred));
end