%% Adapt: Init optimal filter:
Adapt.Enable = true;
Adapt.jtype = 2;
filt_zeros = filter;
% step_LR = 1e-10;
% LR_vals = 1e-10:step_LR:2e-
% LR_vals =[1e-9 5e-9 10e-9 20e-9 30e-9 40e-9 50e-9 60e-9 70e-9 80e-9 90e-9 100e-9 ]
LR_vals =[13e-9 14e-9 15e-9 16e-9 17e-9 18e-9 19e-9]
iter = length(LR_vals);
R2_t = zeros(iter,1);
for i=1:iter
Adapt.LR = LR_vals(i);
filt_zeros.H = zeros(size(filter.H));
[R2A0_r, filter_out, PredData, vaf, mse, ActSignalsTrunk]= PeriodicR2_2(filt_zeros,testData,foldlength,Adapt);
R2_t(i)=mean(R2A0_r(:));
sprintf('Progreso %f%%',i/iter*100)
end
plot(LR_vals,R2_t,'*')
title(sprintf('mean R2 vs LR'));
xlabel('LR values');
ylabel('R2');