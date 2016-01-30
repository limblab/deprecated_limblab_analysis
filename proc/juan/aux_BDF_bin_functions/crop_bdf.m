%
% Crop BDFs between certain specific times t_i and t_f
%
%   function cropped_bdf = crop_bdf( bdf_array )
% 
% Input (optional):
%   bdf_array               : array of BDFs
%   (t_i)                   : initial time for cropping (s)
%   t_f                     : final time for cropping (s). If passing an
%                               array of BDFs and set to 'min', it will
%                               crop all the BDFs to the minimum common
%                               duration 
%
% Output:
%   cropped_bdf             : cropped BDFs
%
% Note: the current version ignores raw analog data and does not crop
% good_kin_data
%


function cropped_bdf = crop_bdf( bdf_array, varargin )

nbr_bdfs                = length(bdf_array);

% read input parameters
if nargin == 2
    % in this case the specified time is the desired end of the BDFs
    if isnumeric(varargin{1})
        t_f             = varargin{1};
    % or the minimum common duration
    elseif ischar(varargin{1})
        if strcmp(varargin{1},'min')
            t_f         = min(arrayfun(@(x)x.meta.duration, bdf_array));
            disp(['minimum common duration is: ' num2str(t_f)]);
        end
    end
    t_i                 = 0; % set to zero for cropping
elseif nargin == 3
    % in this case the specified times are the desired start and end of the
    % BDFs, in this order
    t_i                 = varargin{1};
    t_f                 = varargin{2};
else
    error('The function only takes 2 or 3 input arguments');
end


% ------------------
% Some checks
% check that t_i < t_f
if t_i > t_f 
    error('t_i cannot be < t_f'); 
end;
% check that the duration of each BDF is equal or longer that t_f
for i = 1:nbr_bdfs
   if bdf_array(i).meta.duration < t_f
       error(['duration of BDF(' num2str(t_f) ') < t_f']); 
   end
end


% ------------------
% Crop!
for i = 1:nbr_bdfs
    
    % in META, update duration and add t_i and t_f in FileSepTime
    bdf_array(i).meta.duration   = t_f - t_i;
    bdf_array(i).meta.FileSepTime(1) = t_i;
    bdf_array(i).meta.FileSepTime(2) = t_f;

    % UNITS
    for ii = 1:length(bdf_array(i).units)
       % crop the beginning
       indx_i           = find(bdf_array(i).units(ii).ts<t_i);
       bdf_array(i).units(ii).ts(indx_i) = [];
       bdf_array(i).units(ii).waveforms(indx_i,:) = [];
       % crop the end
       indx_f           = find(bdf_array(i).units(ii).ts>=(t_f -t_i));
       bdf_array(i).units(ii).ts(indx_f) = [];
       bdf_array(i).units(ii).waveforms(indx_f,:) = [];
    end
    clear indx*;

    % RAW
    % -- the current version ignores raw analog data
    % words
    indx_i               = find(bdf_array(i).raw.words(:,1)<t_i);
    bdf_array(i).raw.words(indx_i,:)     = [];
    indx_f               = find(bdf_array(i).raw.words(:,1)>t_f,1,'first');
    bdf_array(i).raw.words(indx_f:end,:) = [];
    clear indx*;

    indx_i               = find(bdf_array(i).raw.enc(:,1)<t_i);
    bdf_array(i).raw.enc(indx_i,:)       = [];
    indx_f               = find(bdf_array(i).raw.enc(:,1)>t_f,1,'first');
    bdf_array(i).raw.enc(indx_f:end,:)    = [];
    clear indx*;

    % EMG
    indx_i               = find(bdf_array(i).emg.data(:,1)<t_i);
    bdf_array(i).emg.data(indx_i,:)      = [];
    indx_f               = find(bdf_array(i).emg.data(:,1)>t_f,1,'first');
    bdf_array(i).emg.data(indx_f:end,:)   = [];
    clear indx*;

    % FORCE
    indx_i               = find(bdf_array(i).force.data(:,1)<t_i);
    bdf_array(i).force.data(indx_i,:)    = [];
    indx_f               = find(bdf_array(i).force.data(:,1)>t_f,1,'first');
    bdf_array(i).force.data(indx_f:end,:) = [];
    clear indx*;

    % WORDS
    indx_i               = find(bdf_array(i).words(:,1)<t_i);
    bdf_array(i).words(indx_i,:)         = [];
    indx_f               = find(bdf_array(i).words(:,1)>t_f,1,'first');
    bdf_array(i).words(indx_f:end,:)     = [];
    clear indx*;

    % DATABURSTS
    for ii = 1:length(bdf_array(i).databursts)
        if bdf_array(i).databursts{ii,1} > t_i
    indx_i = ii; break; end, end

    for ii = 1:indx_i
        bdf_array(i).databursts{ii,1}   = [];
        bdf_array(i).databursts{ii,2}   = [];
    end

    for ii = 1:length(bdf_array(i).databursts)
        if bdf_array(i).databursts{ii,1} > t_f
    indx_f = ii; break; end, end
    
    if exist('indx_f','var') % in case no databurst falls after t_f
        for ii = indx_f:length(bdf_array(i).databursts)
            bdf_array(i).databursts{ii,1}   = [];
        end
    end
    clear indx*;
    
    % POS
    indx_i               = find(bdf_array(i).pos(:,1)<t_i);
    bdf_array(i).pos(indx_i,:)         = [];
    indx_f               = find(bdf_array(i).pos(:,1)>t_f,1,'first');
    bdf_array(i).pos(indx_f:end,:)     = [];
    clear indx*;
    
    % TARGETS
    indx_i               = find(bdf_array(i).targets.corners(:,1)<t_i);
    bdf_array(i).targets.corners(indx_i,:) = [];
    indx_f               = find(bdf_array(i).targets.corners(:,1)>t_f,1,'first');
    bdf_array(i).targets.corners(indx_f:end,:) = [];
    clear indx*;
   
    % GOOD_KINETIC_DATA
    % ToDo
end

% Return variable
cropped_bdf             = bdf_array;