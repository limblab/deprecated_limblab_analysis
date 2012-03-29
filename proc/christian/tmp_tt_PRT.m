tt = bd_trial_table(out_struct);

tt= binnedData.trialtable;

FES_Rew_idx   = find(tt(:,4)==0 & tt(:,7) == double('R'));
Catch_Rew_idx = find(tt(:,4)==1 & tt(:,7) == double('R'));

PRT_FES   = tt(  FES_Rew_idx,6)-tt(  FES_Rew_idx,5);
PRT_Catch = tt(Catch_Rew_idx,6)-tt(Catch_Rew_idx,5);

FilePath = 'C:\Monkey\Jaco\Data\tt\';
bslashes = strfind(out_struct.meta.filename,'\');
FileName = [ out_struct.meta.filename(bslashes(end)+1:end-4) '_tt.mat'];
% FileName = 'Jaco_02-01-11_002';
% [FileName,FilePath] = uiputfile( fullfile(FilePath,FileName), 'Save file');

fullfilename = fullfile(FilePath, FileName);
save(fullfilename,'tt');

%% -----------------------------------------

FileName = 'Strick_mid_7-13-10_001.mat';
% tt = wf_trial_table(out_struct);
% out_struct.tt = tt;
% binnedData.tt = tt;

% original EMG order: [1-FDS1 2-FDS2 3-FDP1 4-ECR2 5-FCU2 6-FCR2 7-FCR1 8-ECR1 9-FDP2 10-ECU1 11-ECU2]
% new EMG order for polar plot:
%           [FCR2 ECR1 ECR2 ECU1 ECU2 FCU FDP1 FDP2 FDS1 FDS2 FCR1]
% EMGorder = [6 8 4 10 11 5 3 9 1 2 7];

% switch mislabelled EMG:
EMGorder = [1 2 8 4 5 11 7 3 9 10 6];

% EMGorder = [6 8 4 10 11 5 3 9 1 2 7];
% binnedData.emgdatabin   = binnedData.emgdatabin(:,EMGorder);
binnedData.emgguide     = binnedData.emgguide(EMGorder,:);
out_struct.emg.emgnames = out_struct.emg.emgnames(:,EMGorder);
% out_struct.emg.data     = out_struct.emg.data(:,EMGorder);

Datapath = 'C:\Documents and Settings\Christian\Desktop\Adaptation2_new_sort\';
fullfilename = fullfile([Datapath 'BDFStructs\'],FileName);
save(fullfilename,'out_struct');
fullfilename = fullfile([Datapath 'BinnedData\'],FileName);
save(fullfilename,'binnedData');
clear