%
% Calculate neuron firing rate of a BDF (or an array of BDFs)
%
%   function binned_FR = calculate_FR( bdf, varargin )
%
% Syntax:
%   function binned_FR = calculate_FR( bdf )
%   function binned_FR = calculate_FR( bdf, bin_width )
%   function binned_FR = calculate_FR( bdf, kernel )
%   function binned_FR = calculate_FR( bdf, kernel, bin_width, gauss_SD, kernel_width )
%
%
% Inputs (opt):             [defaults]
%   bdf                     : BDF struct
%   (kernel)                : ['none'] kernel for smoothing binned FRs
%                               ('gauss' or 'none')
%   (bin_width)             : [5] bin width (ms)
%   (gauss_SD)              : [5] SD of the Gaussian kernel
%   (kernel_width)          : [50 ms] width of the gaussian kernel
%
% Output:
%   binned_FR               : out struct, with summary statistics and an
%                               array with the binned FRs and a time vector
%                               in col 1
%

function binned_FR = calculate_FR( bdf, varargin )


nbr_bdfs                = length(bdf);

% input arguments
if nargin == 2
    if isnumeric(varargin{1})
        bin_width       = varargin{1};
        kernel          = 'none';
    elseif ischar
        kernel          = varargin{1}; % if Gaussian with no params, use defaults
        if strcmp(kernel,'none')
            bin_width   = 0.005; 
        elseif strcmp(kernel,'gauss')
            bin_width   = 0.05;
            kernel_width = 0.05;
            gauss_SD    = 5;
        end
    end
elseif nargin == 5
    kernel              = varargin{1};
    bin_width           = varargin{2};
    gauss_SD            = varargin{3};
    kernel_width        = varargin{4};
else
    bin_width           = 0.005;
    kernel              = 'none';
end


% -------------
% bin and smooth the firings
for i = 1:nbr_bdfs
    % create time vector
    t_i                 = 0:bin_width:(bdf(i).meta.duration-bin_width);
    % bin and smooth the data
    switch kernel
        case 'none'
            nbr_units   = length(bdf(i).units);
            bin_FR      = zeros(length(t_i),nbr_units);
            for ii = 1:nbr_units
                bin_FR(:,ii)  = train2bins( bdf(i).units(ii).ts, t_i );
            end
            bin_FR      = [t_i', bin_FR];
        case 'gauss'
            bin_FR      = gaussian_smoothing( bdf, bin_width, gauss_SD, kernel_width );
    end

    % return variable
    if nbr_bdfs > 1
        binned_FR{i}.binned_FR = bin_FR;
        clear t_i bin_FR;
    end
end


% -------------
% do some basic stats store some metadata
if nbr_bdfs > 1
    for i = 1:nbr_bdfs
        binned_FR{i}.meta.filename  = bdf(i).meta.filename;
        binned_FR{i}.meta.datetime  = bdf(i).meta.datetime;
        
        binned_FR{i}.bin_width      = bin_width;
        binned_FR{i}.kernel.type    = kernel;
        switch kernel
            case 'none'
                binned_FR{i}.kernel.gauss_width = [];
                binned_FR{i}.kernel.gauss_SD =  [];
            case 'gauss'
                binned_FR{i}.kernel.gauss_width = kernel_width;
                binned_FR{i}.kernel.gauss_SD =  gauss_SD;
        end
        
        binned_FR{i}.mean_FR        = mean(binned_FR{i}.binned_FR(:,2:end)/bin_width,1);
        binned_FR{i}.std_FR         = std(binned_FR{i}.binned_FR(:,2:end)/bin_width,0,1);
    end
else
    binned_FR.meta.filename         = bdf.meta.filename;
    binned_FR.meta.datetime         = bdf.meta.datetime;
    
    binned_FR.bin_width             = bin_width;
    binned_FR.kernel.type           = kernel;
    switch kernel
        case 'none'
            binned_FR.kernel.gauss_width = [];
            binned_FR.kernel.gauss_SD =  [];
        case 'gauss'
            binned_FR.kernel.gauss_width = kernel_width;
            binned_FR.kernel.gauss_SD =  gauss_SD;
    end
    
    binned_FR.mean_FR   = mean(binned_FR.binned_FR(:,2:end),1);
    binned_FR.std_FR    = std(binned_FR.binned_FR(:,2:end),0,1);
end