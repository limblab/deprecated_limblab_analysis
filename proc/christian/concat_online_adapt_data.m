function varargout = concat_online_adapt_data(cerebusfilename)

[filepath, filename] = fileparts(cerebusfilename);
filename = filename(1:end-4); %remove file number (e.g. _001)

binnedData = convert2BDF2Binned(cerebusfilename);
% binnedData = LoadDataStruct([filepath '\Cerebus_File_24-Jan-2014-174124005_bin.mat']);

spikes       = load([filepath filesep filename '_spikes.txt']);
emg_preds    = load([filepath filesep filename '_emgpreds.txt']);
cursor_preds = load([filepath filesep filename '_curspreds.txt']);
cursor_pos   = load([filepath filesep filename '_cursorpos.txt']);
params       = load([filepath filesep filename '_params.mat']);

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
figure; plot(binnedData.timeframe,binnedData.cursor_pos(:,1));
hold on;plot(binnedData.timeframe,binnedData.cursorposbin(:,1),'--r');
%%

struct_name = [filename '_adapt_data'];

eval([struct_name '= struct(''cursor_pos'',cursor_pos,''cursor_preds'',cursor_preds,''emg_preds'',emg_preds,''spikes'',spikes,''params'',params);']);

assignin('base',struct_name,eval(struct_name))
assignin('base','binnedData',binnedData);

varargout = {eval(struct_name),binnedData};
save([filepath filesep eval(struct_name)],struct_name);



    