function varargout = concat_online_adapt_data(varargin)
%  varargin = {use_default_binning_params}
use_default_binning_params= 1;

if nargin
    use_default_binning_params = varargin{1};
end

[FileNames,PathNames] = getMultipleFiles('Select BMI Files to Concatenate');
num_files = length(FileNames);
if ~num_files
    return;
end
bd = cell(num_files,1);


for i = 1:num_files
    
    filepath = PathNames{i};
    [~,file_prefix,fe] = fileparts(FileNames{i});
    if strcmp(fe,'.nev')
        bd{i} = convert2BDF2Binned(fullfile(PathNames{i},FileNames{i}),use_default_binning_params);
    elseif strcmp(fe,'.mat')
        bd{i} = LoadDataStruct(fullfile(PathNames{i},FileNames{i}));
    else
        fprintf('Unrecognized file format: ''%s''. File Skipped',fe);
    end
    
    while strcmp( file_prefix(end-3),'_') || strcmp( file_prefix(end),'_')
        if strcmp( file_prefix(end-3),'_')
            file_prefix = file_prefix(1:end-4);  %remove the '_00x' or '_bin' string at the end of file name
        elseif strcmp( file_prefix(end),'_')
            file_prefix = file_prefix(1:end-1); %remove the '_' at the end of file name (Central was not autoincrementing file #)
        end
    end
    
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
    start_bin = find(emg_preds(:,1)>=bd{i}.timeframe(1),1,'first');
    stop_bin  = find(emg_preds(:,1)<=bd{i}.timeframe(end),1,'last');
    
    bd{i}.emg_preds    = interp1(emg_preds(start_bin:stop_bin,1),emg_preds(start_bin:stop_bin,2:end),bd{i}.timeframe,'linear','extrap');
    bd{i}.cursor_pos   = interp1(cursor_pos(start_bin:stop_bin,1),cursor_pos(start_bin:stop_bin,2:end),bd{i}.timeframe,'linear','extrap');
    bd{i}.cursor_preds = interp1(cursor_preds(start_bin:stop_bin,1),cursor_preds(start_bin:stop_bin,2:end),bd{i}.timeframe,'linear','extrap');

    spikes = spikes(2:end,:);
    start_bin = find(spikes(:,1)>=bd{i}.timeframe(1),1,'first');
    stop_bin  = find(spikes(:,1)<=bd{i}.timeframe(end),1,'last');
    
    bd{i}.online_spikes= interp1(spikes(start_bin:stop_bin,1),spikes(start_bin:stop_bin,2:end),bd{i}.timeframe,'linear','extrap');
    bd{i}.adapt_params = params;
    
    % verify that cursor position is aligned
%     figure; plot(bd{i}.timeframe,bd{i}.cursor_pos(:,1));
%     hold on;plot(bd{i}.timeframe,bd{i}.cursorposbin(:,1),'--r');
    %%
    
    struct_name = [file_prefix '_adapt_data'];
    
    % eval([struct_name '= struct(''cursor_pos'',cursor_pos,''cursor_preds'',cursor_preds,''emg_preds'',emg_preds,''spikes'',spikes,''params'',params);']);
    
    % assignin('base',struct_name,eval(struct_name))
    assignin('base',struct_name,bd{i});
    
    % varargout = {eval(struct_name),bd{i}};
    varargout = bd(i);
    
    eval([struct_name '= bd{i};']);
    save([filepath filesep struct_name '.mat'],struct_name);
    
end

    