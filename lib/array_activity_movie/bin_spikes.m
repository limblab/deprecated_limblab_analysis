function binned = bin_spikes(bdf, fps, start_time,ff)
%SUB-FUNCTION OF 'array_movie'
%This function takes an input bdf and bins unit activity into bins of
%length determined by 'fps' starting at time 'start_time' 
%Code primarily taken from Christian Ethier's "BMIDataAnalyzer" GUI
%M-file "convertBDF2binned.m"

binned = struct('spike_list',[], 'spike_rates',[]);

%% Initialization

%Default settings
binsize = 1/fps;        %bin length in seconds (as are all time units)
start    = start_time;  %start time

if isfield(bdf,'emg')
    duration = double( bdf.emg.data(end,1) );
elseif isfield(bdf,'force')
    duration = double( bdf.force(end,1) );
elseif isfield(bdf,'pos')
    duration = double( bdf.pos(end,1) - bdf.pos(1,1) );
else
    disp('bin_spikes: no emg, force, or pos field present in input')
    duration = 30; %arbitrary length that should be longer than what is actually wanted
end
        
stop     = floor(duration + start);     %stop time
num_bins = floor( (stop - start)/binsize );
min_rate = 0;                   %minimum firing rate
%% Bin Spike Data

if ~isfield(bdf, 'units')
    
    disp('No spike data is found in structure')
    spike_list  = [];
    spike_rates = [];
    
else

    %decide which signals to use: minimum of min_rate spikes/sec on average:
    min_spike_num    = (stop - start)*min_rate;
    total_num_units  = length(bdf.units);
    num_usable_units = 0;
    units_to_use     = zeros(1,total_num_units);
    max_num_ts       = 0;

    %Identify the sorted units %%%with minimum spike rate%%%
    for i = 1:total_num_units

        if isempty( bdf.units(i).id )
            continue;
        end
        % skip unsorted units, which are mostly noise. skip units id 255,
        % in autosort, I don't know what this is...
        if ( bdf.units(i).id(2) == 0 || bdf.units(i).id(2) == 255 )
            continue; 
        end

        num_ts = length( bdf.units(i).ts );

        if num_ts > min_spike_num
            num_usable_units               = num_usable_units + 1;
            units_to_use(num_usable_units) = i;
            max_num_ts                     = max(num_ts, max_num_ts);
        end
    end 
    units_to_use = nonzeros(units_to_use);

    if (num_usable_units < 1)
        disp(sprintf('The data does not contain any unit with a minimum of %g spike/sec',min_rate));
        spike_rates = []; %#ok<NASGU>
        spike_list  = []; %#ok<NASGU>
    else   

        % Pre-allocate accordingly - singles!
        spike_list  = zeros(num_usable_units, 1); %preallocate space for spike_list
        spike_rates = zeros(num_bins, num_usable_units, 'single');

        % Create the spike_list with electrode names
        for i = 1 : num_usable_units
            spike_list(i) = bdf.units( units_to_use(i) ).id(1);
        end


        % Create the spike data matrix, using the specified bin size and
        % identified units
        for unit = 1 : num_usable_units

            %get the binned data from the desired timeframe plus one bin before
            binneddata = train2bins( bdf.units( units_to_use(unit) ).ts, start:binsize:stop );

            %and get rid of the extra bins at beginnning, it contains all the ts
            %from the beginning of file that are < start. Here I want
            %start to be the lower bound of the first bin.
            binneddata = single( binneddata(2:end) );

            %convert to firing rate and store in spike data matrix
            spike_rates(:,unit) = binneddata' / binsize;
        end
    end %closing "if (num_usable_units < 1)..."    
end %closing "if ~isfield(bdf, 'units')..."

%% Smoothing Spike Rates

[b,a] = butter(4,ff);
smoothed_rates = filtfilt(b,a,spike_rates);
%for i = 1:length(smoothed_rates) %don't want any negative values that might come about from smoothing/filtering
%    if (smoothed_rates(i) < 0), smoothed_rates(i) = 0; end
%end
smoothed_rates(smoothed_rates<0) = 0;

binned.spike_list     = spike_list;
binned.spike_rates    = spike_rates;
binned.smoothed_rates = smoothed_rates;


