SFN_RawDataFigure

% Make a raster using the out_struct
% truncate units file
out_structTrunk = cell(length(out_struct.units),1);
for i = 1:length(out_struct.units) 
    indices = find(out_struct.units(i).ts>=127.05&out_struct.units(i).ts<=147);
    out_structTrunk{i,1} = out_struct.units(i).ts(indices);
end

out_structTrunk=out_structTrunk(~cellfun('isempty',out_structTrunk))

figure; hold on;
for i = 1:length(out_structTrunk)    
        ts = out_structTrunk{i};
        plot([ts ts]', [(i-1)*ones(size(ts)),i*ones(size(ts))]','k')
end
xlim([127.05 147])
        
%% Get only the EMGs you want in the data file
FCUind = strmatch('FCU',binnedData.emgguide(1,:)); FCUind = FCUind(1);
FCRind = strmatch('FCR',binnedData.emgguide(1,:)); FCRind = FCRind(1);
ECUind = strmatch('ECU',binnedData.emgguide(1,:)); ECUind = ECUind(1);
ECRind = strmatch('ECR',binnedData.emgguide(1,:)); ECRind = ECRind(1);
emg_vector = [FCUind FCRind ECUind ECRind];
% Make new binnedData file where the EMGs are where the spikes are (a hack
% so you can make predictions using EMGs as your input)
binnedData_4EMGs = binnedData;
binnedData_4EMGs.emgguide = binnedData.emgguide(:,emg_vector);
binnedData_4EMGs.emgdatabin =  binnedData.emgdatabin(:,emg_vector);


%% Make EMG predications from neurons
[EMGPreds,NeuronsNew,ActualEMGNew]=predMIMO4(binnedData_4EMGs.spikeratedata,neuron_decoder.H,1,1,binnedData_4EMGs.emgdatabin);
EMG_VAF = calculateVAF(EMGPreds,ActualEMGNew);
figure
LineWidth=1.5;xstart = 2550; xend=2950;

figure;hold on; plot(ActualEMGNew(:,1),'k','LineWidth',LineWidth); plot(EMGPreds(:,1),'r','LineWidth',LineWidth);
title(['FCU predictions | VAF = ' num2str(EMG_VAF(1))]);MillerFigure;xlim([xstart xend]);ylim([-.4 1.2])

figure;hold on; plot(ActualEMGNew(:,2),'k','LineWidth',LineWidth); plot(EMGPreds(:,2),'r','LineWidth',LineWidth);
title(['FCR predictions | VAF = ' num2str(EMG_VAF(2))]);MillerFigure;xlim([xstart xend]);ylim([-.4 1.2])

figure;hold on; plot(ActualEMGNew(:,3),'k','LineWidth',LineWidth); plot(EMGPreds(:,3),'r','LineWidth',LineWidth);
title(['ECU predictions | VAF = ' num2str(EMG_VAF(3))]);MillerFigure;xlim([xstart xend]);ylim([-.4 1.2])

figure;hold on; plot(ActualEMGNew(:,4),'k','LineWidth',LineWidth); plot(EMGPreds(:,4),'r','LineWidth',LineWidth);
title(['ECR predictions | VAF = ' num2str(EMG_VAF(4))]);MillerFigure;xlim([xstart xend]);ylim([-.4 1.2])
        
        
        
        
        
%% Make Force predictions

% Make force predictions from EMG
[CursorPreds,EMGNew,ActualCursorNew]=predMIMO3(binnedData_4EMGs.emgdatabin,emg_decoder.H,1,1,binnedData_4EMGs.cursorposbin);
Cursor_VAF = calculateVAF(CursorPreds,ActualCursorNew);
curstart = 2554; curend=2954;
% plotx
figure;plot(CursorPreds(:,1),'r');hold on; plot(ActualCursorNew(:,1),'k'); title(['X force predictions | VAF = ' num2str(Cursor_VAF(1))])
 title(['X force predictions | VAF = ' num2str(Cursor_VAF(1))]);MillerFigure;xlim([curstart curend])
 %  ploty
figure;plot(CursorPreds(:,2),'r');hold on; plot(ActualCursorNew(:,2),'k'); title(['Y force predictions | VAF = ' num2str(Cursor_VAF(2))])
 title(['Y force predictions | VAF = ' num2str(Cursor_VAF(2))]);MillerFigure;xlim([curstart curend])


