%
% Compare PCs to muscle activity
%
%   function comp_dim_red_neurons_muscles( dim_red_FR, varargin )   
%
% Inputs (optional)         : [default]
%   dim_red_FR              : dim_red_FR struct (or a cell of structs).
%                               Obtained with dim_reduction.m
%   nbr_comps               : nbr of components in neural space
%   (bdf)                   : BDFs with the EMG activity, or 
%   (binned_emg)            : binned struct with binned EMGs,
%                               these have to be of same length as
%                               dim_red_FR.
%   (emg_preproc)           : [sum] EMG preprocessing ('sum','nnmf','none','pca')
%
%
% Syntax:
%   function comp_dim_red_neurons_muscles( dim_red_FR, nbr_comps )
%   function comp_dim_red_neurons_muscles( dim_red_FR, nbr_comps, bdf )
%   function comp_dim_red_neurons_muscles( dim_red_FR, nbr_comps, binned_emg )
%   function comp_dim_red_neurons_muscles( dim_red_FR, nbr_comps, bdf, emg_preproc)
%   function comp_dim_red_neurons_muscles( dim_red_FR, nbr_comps, binned_emg, emg_preproc)
%
% Note: when binning the EMG, it is normalized by default
%


function comp_dim_red_neurons_muscles( dim_red_FR, nbr_comps, varargin )


% normalize EMG y/n
norm_emg                    = true; % can be turned into a param

% read input params
if nargin >= 3
    if isfield(varargin{1},'meta')
        inarg_type          = 'bdf';
        bdf                 = varargin{1};
    else
        inarg_type          = 'bin';
        binned_data         = varargin{1};
    end
end
if nargin == 4
   emg_preproc              = varargin{2};
end


% check that the number of bdf/bin files is the same as the nbr of
% dim_red_FRs
if iscell(dim_red_FR)
    switch inarg_type
        case 'bdf'
            if length(dim_red_FR) ~= length(bdf)
                error('dimensions dim_red_FR ~= dimensions BDF');
            end
        case 'bin'
            if length(dim_red_FR) ~= length(binned_data)
                error('dimensions dim_red_FR ~= dimensions BDF');
            end
    end
end

% -------------------------------------------------------------------------
% Bin the EMG, if necessary

if iscell(dim_red_FR)
    nbr_bdfs                = length(dim_red_FR);
    bin_width_neurons       = mean(diff(dim_red_FR{1}.t));
    disp(['bin size (s): ' num2str(bin_width_neurons)]);
    switch inarg_type
        case 'bdf'
            % bin the EMG data
            if ~isfield(bdf, 'emg')
                error('No EMG data was found');
            else
                % By default, normalize the EMG
                params.NormData = norm_emg;
                % bin to the same width as the neurons
                params.binsize  = bin_width_neurons;
                binned_emg      = convertEMG_BDF2binned( bdf, ...
                                    bin_width_neurons );
            end
        case 'bin'
            % check bin width is the same for neurons and EMG
            if mean(diff(binned_emg(1).t)) ~= bin_width_neurons
                error('Bin size for neurons and EMG has to be the same');
            end
    end
else
    bin_width_neurons      = mean(diff(dim_red_FR.t));
    disp(['bin size (s): ' num2str(bin_width_neurons)]);
    switch inarg_type
        case 'bdf'
            % bin the EMG data
            if ~isfield(bdf, 'emg')
                error('No EMG data was found');
            else
               % By default, normalize the EMG
                params.NormData = norm_emg;
                % bin to the same width as the neurons
                params.binsize  = bin_width_neurons;
                binned_emg      = convertEMG_BDF2binned( bdf, ...
                                    bin_width_neurons );
            end
        case 'bin'
            % check bin width is the same for neurons and EMG
            if mean(diff(binned_emg.t)) ~= bin_width_neurons
                error('Bin size for neurons and EMG has to be the same');
            end
    end
end


% -------------------------------------------------------------------------
% Do some more EMG preprocessing
switch emg_preproc
    case 'sum'
        disp('EMG preprocessed adding up the EMGs of all the flexors and all the extensors')
        for i = 1:nbr_bdfs
            flexor_indx         = strncmp(binned_emg(i).labels,'F',1);
            ext_indx            = strncmp(binned_emg(i).labels,'F',1);
        end
        disp('ToDo');
    case 'pca'
        disp('EMG preprocessed with PCA')
        
    case 'nnmf'
        error('NNMF not yet implemented :-/');
    case 'none'
        disp('EMG not preprocessed');
end
    

% -------------------------------------------------------------------------
% Evaluate the relationship between PCA 



% -----------
% return variables
if iscell(dim_red_FR)
    for i = 1:nbr_bdfs
        nvm.raw.neurons(i) = dim_red_FR(i);
    end
end