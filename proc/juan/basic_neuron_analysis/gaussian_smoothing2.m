%
% Bin and smooth firing rates using Gaussian Kernel and bin the rest of the
% BDF (optional). The user can choose the size of the bins and the SD of
% the Gaussian kernel; the length of the kernel is fixed to 3·SD.
%
%   function smoothed_FR = gaussian_smoothing2( bdf, varargin )
%
%
% Input parameters (opt)    : [defaults]
%   bdf                     : BDF data struct or array of BDFs
%   (transform)             : ['sqrt'] transform binned firing rates
%                               (options: 'sqrt', 'none')
%   (bin_size)              : [0.05] bin width (s)
%   (kernel_SD)             : [0.05] SD of the Gaussian kernel (s)
%
% Output parameters:
%   smoothed_FR             : matrix with smoothed fire rates
%   (binned_data)           : binned data struct
%
%
% Note: the smoothing code is based on smoother.m, implemented in Byron's
% yu GPFA library
%


function [smoothed_FR, varargout] = gaussian_smoothing2( bdf, varargin )


% get input parameters
if nargin >= 2
   transform            = varargin{1}; 
else
   transform            = 'sqrt'; 
end

if nargin == 4
    bin_size            = varargin{2};
    kernel_SD           = varargin{3};
else
    bin_size            = 0.050;
    kernel_SD           = 0.050;
end


% -------------------------------------------------------------------------
% 1. bin the data

% if we also want the binned_data struct, bin the whole BDF
if nargout == 2
    bin_pars.binsize    = bin_size;
    bin_pars.starttime  = bdf(1).pos(1,1);
    bin_pars.stoptime   = bdf(1).pos(end,1);
    binned_data         = convertBDF2binned(bdf,bin_pars);
    % store the binned firing rates into a variable, which will be used for
    % subsequent calculations. This is for compatibility with when the user
    % doesn't want to bin the BDF
    binned_spikes       = binned_data.spikeratedata*bin_size;
% otherwise, just bin the spikes
else
    % get start and end times
    t_start             = bdf.pos(1,1);
    t_end               = bdf.pos(end,1);
    % time vector for binning
    t_bins              = t_start:bin_size:t_end;
    % preallocate matrix
    binned_spikes       = zeros(length(t_bins)-1,length(bdf.units));
    % bin
    disp(['Binning data in ' num2str(round(1000*bin_size)) ' ms bins...']);
    for i = 1:length(bdf.units)
        ts              = bdf.units(i).ts;
        ts              = ts( ts >= t_start & ts <= t_end );
        binned_spikes(:,i) = histcounts(ts,t_bins);
    end
end

clear bdf ts;

% -------------------------------------------------------------------------
% 2. transformation (variance stabilization) of the firing rates
% -- temporarily as a new field; in the future it will overwrite the binned
% spike rates
switch transform
    % sqrt transform of the firing rates
    case 'sqrt'
        binned_spikes_transf    = sqrt(binned_spikes);
    case 'none'
        binned_spikes_transf    = binned_spikes;
    otherwise
        error('wrong variance stabilization method');
end


% -------------------------------------------------------------------------
% 3. Gaussian smoothing

disp('Smoothing the firing rates...');

% get nbr of channels and nbr of samples
[nbr_samples, nbr_chs]  = size(binned_spikes_transf);
% preallocate return matrix
smoothed_FR             = zeros(nbr_samples,nbr_chs);

% kernel half length is 3·SD out
kernel_hl               = ceil( 3 * kernel_SD / (bin_size) );
% create the kernel --it will have length 2*kernel_hl+1
kernel                  = normpdf( -kernel_hl*(bin_size) : ...
                            bin_size : kernel_hl*(bin_size), ...
                            0, kernel_SD );
% compute normalization factor --this factor depends on the number of taps
% actually used 
nm                      = conv(kernel,ones(1,nbr_samples))';

% do the smoothing
for i = 1:nbr_chs
    aux_smoothed_FR     = conv(kernel,binned_spikes_transf(:,i)) ./ nm;
    % cut off the edges so that the result of conv is same length as the
    % original data
	smoothed_FR(:,i)    = aux_smoothed_FR(kernel_hl+1:end-kernel_hl);
end


% -------------------------------------------------------------------------
% 4. Return data

% return binned data
if nargout == 2
    % store transformation method
    binned_data.spiketransfmethod = transform;
    % add Gaussian Kernel info?
    % add smoothed data
    binned_data.smoothedspikerate = smoothed_FR;
    varargout{1}        = binned_data;
end

% add time axis in the first column of smoothed_FR 
% -- legacy, remove in newer versions
t_axis                  = 0:bin_size:bin_size*(size(smoothed_FR,1)-1);
smoothed_FR             = [t_axis' smoothed_FR];