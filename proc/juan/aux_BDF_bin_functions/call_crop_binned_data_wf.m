%
% Crop binned_data from a 'Wrist Flexion' task in intervals defined by two
% words. The function can take a BDF that will be first converted into a
% binned_data struct
%
%   function cropped_binned_data = call_crop_binned_data_wf( data_struct, ...
%                                   word_i, word_f, varargin )
%
% Inputs (opt)              : [default]
%   data_struct             : array of BDFs or binned_data structs
%   word_i                  : word that defines the beginning of the
%                               interval ('start','ot_on','go')
%   word_f                  : word that defines the end of the interval
%                               ('ot_on','go','end','R')
%   (bin_size)              : [0.05 s] bin size for binning a BDF
%
% Outputs
%   cropped_binned_data     : cropped binned_data struct
%
%
% Usage:
%   cropped_binned_data = call_crop_binned_data_wf( binned_data, word_i, word_f )
%   cropped_binned_data = call_crop_binned_data_wf( bdf, word_i, word_f )
%   cropped_binned_data = call_crop_binned_data_wf( bdf, word_i, word_f, bin_size )
  

function cropped_binned_data = call_crop_binned_data_wf( data_struct, word_i, word_f, varargin )


% see if the data_struct is of type bdf or binned_data. If it is a BDF, bin
% it
if ~isfield(data_struct,'timeframe')
    % get desired bin size
    if nargin == 4
        bin_pars.binsize    = varargin{1};
    % or set it to default
    else
        bin_pars.binsize    = 0.05;
    end
    % start and stop times are set to ensure compatibility with the
    % dim_reduction code
    bin_pars.starttime      = ceil(bdf.pos(1,1)/bin_size)*bin_size;
    bin_pars.stoptime       = floor(bdf.pos(end,1)/bin_size)*bin_size;
    % bin each BDF
    for i = 1:length(data_struct)
        binned_data_array(i) = convertBDF2binned(data_struct(i),bin_pars);
    end
else
    binned_data_array       = data_struct;
end

clear data_struct;
    
% get the column of the words
switch word_i
    case 'start'
        indx_i              = 1;
    case 'ot_on'
        indx_i              = 6;
    case 'go'
        indx_i              = 7;
    otherwise
        error([word_i ' not supported for this task']);
end

switch word_f
    case 'ot_on'
        indx_f              = 6;
    case 'go'
        indx_f              = 7;
    case 'end'
        indx_f              = 8;
    case 'R'
        indx_f              = 8; % code will then look at whether the monkey got a reward
    otherwise
        error([word_i ' not supported for this task']);
end


nbr_bdfs                    = length(binned_data_array);


for i = 1:nbr_bdfs

    % get trial table and store it in a N x 2 matrix with times for
    % cropping 
    trial_table             = binned_data_array(i).trialtable;
    cropping_times          = [trial_table(:,indx_i), trial_table(:,indx_f)];

    % if the end word is 'R' (reward), get rid of the trials without a reward
    if word_f == 'R'
        cropping_times(trial_table(:,9) ~= double('R'),:) = [];
        binned_data_array(i).trialtable( binned_data_array(i).trialtable(:,9) ...
            ~= double('R'), : ) = [];
    end

    % call cropping function
    cropped_binned_data(i)  = crop_binned_data( binned_data_array(i), cropping_times );

    
    clear trial_table cropping_times;
end