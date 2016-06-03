function params = RP_plot_xcorr(data_struct,params)

RP = data_struct.RP;
bdf = data_struct.bdf;

if isempty(RP.BMI)
    return
end

neuron_cols = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'chan')));
if RP.BMI.params.arm_params.use_brd
    emg_1 = 'BRD';
else
    emg_1 = 'BI';
end
emg_cols = find(~cellfun(@isempty,strfind(RP.BMI.params.headers,['EMG_' emg_1])));
emg_cols = [emg_cols find(~cellfun(@isempty,strfind(RP.BMI.params.headers,'EMG_TRI')))];

%%
clear max_xcorr max_xcorr_lag min_xcorr min_xcorr_lag
params.fig_handles(end+1) = figure;
for iEMG = 1:length(emg_cols)
    for iNeuron = 1:length(neuron_cols)
        [c,lags] = xcorr(RP.BMI.data(:,emg_cols(iEMG)),...
            RP.BMI.data(:,neuron_cols(iNeuron)),10,'coeff');       
        [a,b] = max(c);        
        max_xcorr(iEMG,iNeuron) = a;
        max_xcorr_lag(iEMG,iNeuron) = RP.BMI.params.params.binsize*lags(b);
        [a,b] = min(c);        
        min_xcorr(iEMG,iNeuron) = a;
        min_xcorr_lag(iEMG,iNeuron) = lags(b);
    end
    subplot(1,length(emg_cols),iEMG)
    plot(max_xcorr_lag(iEMG,:),max_xcorr(iEMG,:),'.')    
    xlabel('lag (s)')
    ylabel('max xcorr EMG-spikes')
    title(RP.BMI.params.headers(emg_cols(iEMG)),'Interpreter','none')
end
    
