% Smooth binned firing rates using Gaussian Kernel
%
%   function smoothed_FR = gaussian_smoothing( bdf, varargin )
%
%   Input parameters (opt)      [defaults]
%       bdf                     : BDF data struct
%       (bin_width)             : [0.05] bin width (s)
%       (gauss_SD)              : [5] SD Gaussian Kernel
%       (gauss_width)           : [0.05] width Gaussian kernel (s)
%
%   Output parameters:
%       Matrix with smoothed fire rates
%



function smoothed_FR = gaussian_smoothing( bdf, varargin )


% get input parameters
if nargin == 3
    bin_width           = varargin{1};
    gauss_SD            = varargin{2};
    gauss_width         = varargin{3};
else
    bin_width           = 0.050;
    gauss_SD            = 5;
    gauss_width         = 0.050; % ms
end


% --This part is adapted from Matt's calcFR.m
% define Gaussian kernel
sigma                   = gauss_width / pi;
% create time vector for applying the kernel 
ti                      = 0:bin_width:(bdf.meta.duration-bin_width);
% create matrix that will be filled with the smoothed FRs
smoothed_FR             = zeros(length(ti),size(bdf.units,2));

% do for all neurons
for i = 1:size(bdf.units,2)
    for ii = 1:length(ti)
        curT            = ti(ii);
        tau             = curT - bdf.units(i).ts( ( bdf.units(i).ts >= curT-gauss_SD*sigma & ...
                            bdf.units(i).ts < curT+gauss_SD*sigma) );
        smoothed_FR(ii,i) = sum( exp(-tau.^2/(2*sigma^2))/(sqrt(2*pi)*sigma) );
    end
end

% add a time vector in the first row
t_axis                  = 0:bin_width:bin_width*(size(smoothed_FR,1)-1);
smoothed_FR             = [t_axis' smoothed_FR];
