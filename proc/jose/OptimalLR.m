%% Adapt: Init optimal filter:
Adapt.Enable = true;
Adapt.jtype = 2;
% step_LR = 1e-10;
% LR_vals = 1e-10:step_LR:2e-
% LR_vals =[1e-11 1e-10 1e-9 1e-8 1e-7 1e-6]
LR_vals =[5e-9 1e-8 5e-8]
iter = length(LR_vals);
R2_t = zeros(iter,1);
for i=1:iter
Adapt.LR = LR_vals(i);
[R2AF, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filter,testData,foldlength,Adapt);
R2_t(i)=mean(R2AF(:));
sprintf('Progreso %f%%',i/iter*100)
end
plot(R2_t,'*')
title(sprintf('mean R2 vs LR'));
xlabel('# iterations)');
ylabel('R2');