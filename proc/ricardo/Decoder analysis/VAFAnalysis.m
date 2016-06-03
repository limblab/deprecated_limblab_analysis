%% VAF analysis

target_folder = ['D:\Jaco_8I1\Jaco_2016-02-16_DCO\'];
params.file_prefix = 'Jaco_2016-02-16_DCO_001-VAFs_EMG_';

all_files = dir([target_folder params.file_prefix '*']);
all_files = {all_files.name}';

sampling_freq = [];
for iFile = 1:length(all_files)
    sampling_freq(iFile) = str2double(all_files{iFile}(length(params.file_prefix)+1:end-4));
end

[sampling_freq,new_order] = sort(sampling_freq);
all_files = all_files(new_order);

threshold = [];
for iFile = 1:length(all_files)
    load([target_folder all_files{iFile}])
    temp = cell2mat(cellfun(@mean,VAF,'UniformOutput',false)');
    [~,idx] = max(mean(temp(:,2:3),2));
    threshold(iFile) = threshold_vector(idx);
    VAF_max{iFile} = VAF{threshold(iFile)}(:,2:3);
end

%%
figure;
hold on
errorbar(-.1,mean(VAF_spikes(:,2)),std(VAF_spikes(:,3)),'b');
errorbar(.1,mean(VAF_spikes(:,3)),std(VAF_spikes(:,3)),'r');
for iFile = 1:length(all_files)
    errorbar(iFile-.1,mean(VAF_max{iFile}(:,1)),std(VAF_max{iFile}(:,1)),'b');
    errorbar(iFile+.1,mean(VAF_max{iFile}(:,2)),std(VAF_max{iFile}(:,2)),'r');
    samp_freq_cell{iFile} = num2str(sampling_freq(iFile));
end
set(gca,'XTick',0:length(all_files))
set(gca,'XTickLabel',['Spikes' samp_freq_cell])
ylim([0 1])
ylabel('VAF')
xlabel('Continuous data sampling frequency (Hz)')
title('EMG VAF for spikes obtained at different sampling frequencies')
legend('Tri','Brd')