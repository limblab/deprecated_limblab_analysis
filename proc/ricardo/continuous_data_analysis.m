% TODO: add anesthesia data
% datapath = 'D:\Data\Pedro_4C2\Raw\';
% filelist = dir([datapath 'Pedro_2012-08-07*.nev']);
% chan = 17;
anesthesia_level = [0.47 0.47 .5 .5 .52 .52 1 1 .52 .52 .6 .6 2 2 .6 .6 .62 .62...
    2.3 2.3 .7 .7 6 6 .7 .7 10 10 .7 .7 .6 .6 .5 .5];
anesthesia_time = 60*[-10 -3 -3 4 4 5.75 5.75 6.75 6.75 9 9 11.5 11.5 12.5 12.5...
    14 14 17 17 18 18 24 24 25 25 29 29 30 30 31.5 31.5 35.5 35.5 46];

% 
% crossing = [];
% num_crossings = zeros(1,length(filelist));
% for iFile = 1:length(filelist)
%     iFile
%     clear struct
%     struct = get_cerebus_data([datapath filelist(iFile).name]);
%     if iFile == 1
%         firstfilestart = datevec(struct.meta.datetime);
%         firstfilestart = (firstfilestart(4)*60+firstfilestart(5))*60+firstfilestart(6);
%     end
%     
%     filestart = datevec(struct.meta.datetime);
%     filestart = (filestart(4)*60+filestart(5))*60+filestart(6)-firstfilestart;
% 
%     fs = struct.raw.analog.adfreq(chan);
%     t = 1/fs:1/fs:length(struct.raw.analog.data{chan})/fs;
%     [b,a]=butter(4,250/(2*fs),'high');
%     continuous= double(struct.raw.analog.data{chan});
%     neuron = filtfilt(b,a,(continuous));
%     thres = -30;
%     thres_idx = find(neuron<thres);
%     num_crossings(iFile) = length(thres_idx); 
%     temp_crossing = t(thres_idx)+filestart;
%     thres_idx = thres_idx(diff(temp_crossing)>0.001);
%     crossing = [crossing t(thres_idx)+filestart];     %#ok<AGROW>
%     spikes{iFile} = zeros(length(thres_idx),100);
%     for iSpike = 1:size(spikes,1)
%         spikes{iFile}(iSpike,:) = neuron(thres_idx(iSpike)-29:thres_idx(iSpike)+70)'; %#ok<SAGROW>
%     end
% end
figure; 
plot(crossing,zeros(1,length(crossing)),'.')

rate = spikes2rate(crossing');
figure; 
plot(rate(:,1),rate(:,2),crossing,1000*ones(1,length(crossing)),'.')

[spike_train spike_train_times] = train2bins(crossing, 0.001);
k = 10*1000; 
gaussian_rate = gauss_rate(spike_train, k);

step = [zeros(1,k-1) ones(1,k+1)];
t = 0:0.001:spike_train_times(end);
firing_rate = zeros(1,length(t));
for iSpike = 1:length(crossing)
    iSpike
    indexes = find(t>=crossing(iSpike) & t<crossing(iSpike)+10*k/1000);
    temp_t = t(indexes);
    temp_fr = conv((temp_t-crossing(iSpike)).*exp(-(temp_t-crossing(iSpike))/k),step,'same');
    firing_rate(indexes) = firing_rate(indexes) + temp_fr/(k^2);
end

figure;
plot(t,firing_rate,anesthesia_time,anesthesia_level*max(firing_rate)/max(anesthesia_level))
xlim([0 t(end)])
xlabel('t(s)')

figure;
plot(t,gaussian_rate,anesthesia_time,anesthesia_level*max(gaussian_rate)/max(anesthesia_level))
xlim([0 t(end)])
xlabel('t(s)')