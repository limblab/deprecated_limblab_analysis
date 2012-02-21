function EMGfilt(y,emgsamplerate,wsz,EMG_lp)

% analyze raw signal?

[P,f]=powspect(y,wsz,emgsamplerate,1);
powerMat=[f', cumsum(P(1:length(f)))/sum(P(1:length(f)))]; 
% powerMat(1:10,:)

% assumes wsz=256
fprintf('%.2f%% of power was below 10 Hz before filtering.\n', ...
    100*interp1(powerMat(2:3,1),powerMat(2:3,2),10))

% filter

EMG_hp = 50; % default high pass at 50 Hz
% EMG_lp = 5; % default low pass at 10 Hz
% if ~exist('emgsamplerate','var')
%     emgsamplerate=2000; %default
% end

[bh,ah] = butter(2, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
[bl,al] = butter(2, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
tempEMG=y;
tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
tempEMG = abs(tempEMG); %rectify
y = filtfilt(bl,al,tempEMG); %lowpass filter

% analyze filtered...
[P,f]=powspect(y,wsz,emgsamplerate,1);
powerMat=[f', cumsum(P(1:length(f)))/sum(P(1:length(f)))]; 

% assumes wsz=256, powerMat(2,1)=7.x Hz and powerMat(3,1)=15.x Hz.
fprintf('%.2f%% of power was below 10 Hz after filtering at %dHz.\n', ...
    100*interp1(powerMat(2:3,1),powerMat(2:3,2),10),EMG_lp)
