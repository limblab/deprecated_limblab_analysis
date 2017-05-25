function binnedData = convert2BDF2Binned(varargin)
% convert2BDF2Binned([cerebus_filename],[binning_parameters])

if nargin
    cerebus_filename = varargin{1};
    [datapath,filename] = fileparts(cerebus_filename);
else
    [filename, datapath] = uigetfile( { '*.nev'}, 'Open Cerebus Data File' );
    cerebus_filename = fullfile(datapath,filename);
    filename = filename(1:end-4); % remove the extension
end

BDF_filename = [filename '_BDF.mat'];
bin_filename = [filename '_bin.mat'];

if nargin >1
    use_default = varargin{2};
else
    use_default = false;
end

if use_default
    BDF2BinArgs = [];
else
    BDF2BinArgs = convertBDF2binnedGUI;
end
    
fprintf('Converting %s to BDF structure...\n',cerebus_filename);
% BDF = get_cerebus_data(cerebus_filename,'verbose');
BDF = get_nev_mat_data(cerebus_filename,'verbose','ignore_jumps','nokin');

fprintf('Saving BDF structure %s...\n',BDF_filename);
save([datapath filesep BDF_filename], 'BDF');
fprintf('Done.\n');

if use_default
    BDF2BinArgs = get_default_binning_params(BDF);
end

fprintf('Binning data: %s...\n', BDF_filename);
binnedData = convertBDF2binned(BDF,BDF2BinArgs);
fprintf('Saving binned data file %s...\n',bin_filename);
save([datapath filesep bin_filename], 'binnedData');
fprintf('Done.\n');

    