%
% Bin EMG data
%
%   function binned_emg_data = convertEMG_BDF2binned( bdf_array ,varargin )
% 
% Inputs (optional)         : [default]
%   bdf_array               : BDF or array of BDFs
%   (bin_size)              : [0.05] bin size in ms
%   (binning_params)        : [default_binning_params] struct of type
%                               defined in get_default_binning_params.m
%
% Outouts:
%   binned_emg_data         : struct with binned_EMG and recording into
%
%
% Note: this function is just a copy of the EMG binning part of
% convertBDF2binned.m
%

function binned_emg_data = convertEMG_BDF2binned( bdf_array ,varargin )


nbr_bdfs                = length(bdf_array);

% Input params
if nargin == 2
    if ~isstruct(varargin{1})
        for i = 1:nbr_bdfs
            temp_params.binsize  = varargin{1};
            temp_params = get_default_binning_params( bdf_array(i), temp_params );
            params(i)   = temp_params; clear temp_params;
        end
    else
        for i = 1:nbr_bdfs
            params(i)   = get_default_binning_params( bdf_array(i), varargin{1} );
        end
    end
elseif nargin == 1
    for i = 1:nbr_bdfs
        params(i)       = get_default_binning_params( bdf_array(i) );
    end
end


for i = 1:nbr_bdfs
    
    % From here, the code is copied from convertBDF2binned
    emgsamplerate       = bdf_array(i).emg.emgfreq;   %Rate at which emg data were actually acquired.
    numEMGs             = length(bdf_array(i).emg.emgnames);
    emglabels           = cell(1,numEMGs);
    
    % calculate nbr EMG samples to bin
    emgtimebins         = find(bdf_array(i).emg.data(:,1)>=params(i).starttime & ...
                            bdf_array(i).emg.data(:,1)<params(i).stoptime);
    % calculate how many bins we'll obtain ...
    numberbins          = round((params(i).stoptime-params(i).starttime)/params(i).binsize);      
    % ... and create time vector
    timeframe           = ones(numberbins,1);
    timeframe           = timeframe.*(params(i).starttime:params(i).binsize:params(i).stoptime-params(i).binsize)';

    % cell array with EMG names
    for ii = 1:numEMGs
        emglabels{ii}   = strrep(bdf_array(i).emg.emgnames{ii},'EMG_','');
    end

    %Pre-allocate matrix for binned EMG 
    emgdatabin          = zeros(numberbins,numEMGs);

    % Filter EMG data
    [bh,ah]             = butter(4, params(i).EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al]             = butter(4, params(i).EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

    for E=1:numEMGs
        % Process EMG data (high-pass, rectification + low-pass filtering)
        tempEMG         = double(bdf_array(i).emg.data(emgtimebins,E+1));
        if ~isfield(bdf_array(i).emg,'rectified')            
            tempEMG     = filtfilt(bh,ah,tempEMG); %highpass filter
            tempEMG     = abs(tempEMG); %rectify
            tempEMG     = filtfilt(bl,al,tempEMG); %lowpass filter
        end
        %downsample EMG data to desired bin size
%             emgdatabin(:,E) = resample(tempEMG, 1/binsize, emgsamplerate);
        emgdatabin(:,E) = interp1(bdf_array(i).emg.data(emgtimebins,1), tempEMG, timeframe,'linear','extrap');
    end

    % Normalize EMGs        
    if params(i).NormData
        for ii=1:numEMGs
%             emgdatabin(:,i) = emgdatabin(:,i)/max(emgdatabin(:,i));
            % dont use the max because artefacts, use 99% percentile
            EMGNormRatio = prctile(emgdatabin(:,ii),99);
            emgdatabin(:,ii) = emgdatabin(:,ii)/EMGNormRatio;
        end
    end

    clear tempEMG bh ah bl al emgtimebins EMGname numEMGs EMGNormRatio numberbins;
    
    % Up to here, the code is copied from convertBDF2binned

    % assign output variables 
    binned_emg_data(i).data     = emgdatabin;
    binned_emg_data(i).t        = timeframe;
    binned_emg_data(i).labels   = emglabels;
    binned_emg_data(i).fs       = emgsamplerate;
    binned_emg_data(i).meta.filename    = bdf_array(i).meta.filename;
    binned_emg_data(i).meta.hp_filt     = params(i).EMG_hp;
    binned_emg_data(i).meta.lp_filt     = params(i).EMG_lp;
    binned_emg_data(i).meta.norm        = params(i).NormData;
    
    clear emgdatabin emglabels emgsamplerate timeframe;
end