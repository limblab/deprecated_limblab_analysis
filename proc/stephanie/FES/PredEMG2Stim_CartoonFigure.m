PredEMG2Stim_CartoonFigure

for i = 1:nbr_emgs
% For each separate EMG      
        if EMG_pred(i) < bmi_fes_stim_params.EMG_min(i)
            
            stim_PW(i)  = 0;
        elseif EMG_pred(i) > bmi_fes_stim_params.EMG_max(i)
            
            stim_PW(i)  = bmi_fes_stim_params.PW_max(i);
        else
            stim_PW(i)  = ( EMG_pred(i) - bmi_fes_stim_params.EMG_min(i) )* ...
                ( bmi_fes_stim_params.PW_max(i) - bmi_fes_stim_params.PW_min(i) ) ...
                / ( bmi_fes_stim_params.EMG_max(i) - bmi_fes_stim_params.EMG_min(i) ) ...
                + bmi_fes_stim_params.PW_min(i);
        end
end
    

% for all i
EMG_min = .3; EMG_max = 1;
PW_max = 400; PW_min = 10;
EMGpred = [.3 .6 .8 1];
stim_PW=[];
for a = 1:length(EMGpred)
    stim_PW(a)  = ( EMGpred(a) - EMG_min )* ...
        ( PW_max - PW_min ) ...
        / (EMG_max - EMG_min ) ...
        + PW_min;
end

figure; hold on;
% y is stimPW
% x is EMG pred
EMGmin = [0 .1 .2 .3];
plot(EMGmin, [0 0 0 0], '-b','LineWidth',3);
EMGmax = [1 1.2 1.3 1.4];
plot(EMGmax, [400 400 400 400], '-b','LineWidth',3);
plot(EMGpred,stim_PW,'b','LineWidth',3);
xlabel('EMG prediction')
ylabel('Pulse Width (us)')
