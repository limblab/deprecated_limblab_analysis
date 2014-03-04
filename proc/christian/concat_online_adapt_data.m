function varargout = concat_online_adapt_data(filename, extractNEV)

if extractNEV
    binnedData = convert2BDF2Binned(filename);
else
    binnedData = LoadDataStruct(filename);
end

[filepath, file_prefix] = fileparts(filename);

file_prefix = file_prefix(1:end-4);  %remove the '_00x' or '_bin' string at the end of file name

spikes       = load([filepath filesep file_prefix '_spikes.txt']);
emg_preds    = load([filepath filesep file_prefix '_emgpreds.txt']);
cursor_preds = load([filepath filesep file_prefix '_curspreds.txt']);
cursor_pos   = load([filepath filesep file_prefix '_cursorpos.txt']);
params       = load([filepath filesep file_prefix '_params.mat']);

%% Manually Align Cerebus and ascii recordings
% spikes = spikes(2:end, :);
% new_tf = [ cursor_preds(2:end,1); cursor_preds(end,1)+0.05];
% cursor_preds(:,1) = new_tf;
% emg_preds(:,1) = new_tf;
% cursor_pos(:,1)= new_tf;

%% reshape to match data

binnedData.emg_preds    = interp1(emg_preds(:,1),emg_preds(:,2:end),binnedData.timeframe,'linear','extrap');
binnedData.cursor_pos   = interp1(cursor_pos(:,1),cursor_pos(:,2:end),binnedData.timeframe,'linear','extrap');
binnedData.cursor_preds = interp1(cursor_preds(:,1),cursor_preds(:,2:end),binnedData.timeframe,'linear','extrap');
binnedData.adapt_params = params;
%
% figure; plot(binnedData.timeframe,binnedData.cursor_pos(:,1));
% hold on;plot(binnedData.timeframe,binnedData.cursorposbin(:,1),'--r');
%%

struct_name = [file_prefix '_adapt_data'];

% eval([struct_name '= struct(''cursor_pos'',cursor_pos,''cursor_preds'',cursor_preds,''emg_preds'',emg_preds,''spikes'',spikes,''params'',params);']);

% assignin('base',struct_name,eval(struct_name))
assignin('base',struct_name,binnedData);

% varargout = {eval(struct_name),binnedData};
varargout = {binnedData};

eval([struct_name '= binnedData;']);
save([filepath filesep struct_name '.mat'],struct_name);



    