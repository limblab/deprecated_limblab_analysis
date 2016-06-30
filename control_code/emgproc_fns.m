function emg_average = emgproc_fns(emg_data, sample_rate, timewindow)

%emg_data is output of stimrec, stimpulses also same as used in stimrec.
%Timewindow is start/end of analyzed chunk, in milliseconds post-trigger,
%i.e. [5 15]

%From the useful chunk of code in findPeakPS:
%
% RespEnd=round(handles.SampFreq*handles.Twitch(2)/1000);
% RespBeg=round(handles.SampFreq*handles.Twitch(1)/1000+1);
% for i=1:c
%     peak(i,repeat)=max(cumsum(abs(data(RespBeg:RespEnd,i))));
% end

%% Common constants
    stimpulses = size(emg_data,3); 
    num_recording_channels = size(emg_data,2);
    
%% Actual calculation
timewindow = timewindow/1000; %Convert to seconds
startsample = sample_rate*timewindow(1);
endsample = sample_rate*timewindow(2);
emg_average = zeros(num_recording_channels,stimpulses);
for i = 1:num_recording_channels
    %All recorded EMG channels
    for j = 1:stimpulses
%         emg_average(i,j) = sum(abs(emg_data(startsample:endsample,i,j))); 
        emg_average(i,j) = sum(emg_data(startsample:endsample,i,j)); 
    end
end
