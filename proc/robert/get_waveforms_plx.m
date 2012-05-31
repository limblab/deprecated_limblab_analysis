function units = get_waveforms_plx(filename, opts)
% get_waveforms_plx extracts the spike waveforms from the named plx file
%   UNITS = get_waveforms_plx(FILENAME, VERBOSE) returns the bdf.units 
%       structure from the named plx file.  It works in the same way as
%       get_units_plx, but includes the waveforms info alongside the ts
%       info in bdf.units.  

% $Id: get_units_plx.m 321 2010-12-07 21:53:04Z ricardo $

[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, ...
    PreThresh, SpikePeakV, SpikeADResBits, SlowPeakV, ...
    SlowADResBits, Duration, DateTime] = plx_information(filename);

    if opts.verbose        
        disp('Reading units...')
        
        disp(['Opened File Name: ' OpenedFileName]);
        disp(['Version: ' num2str(Version)]);
        disp(['Frequency : ' num2str(Freq)]);
        disp(['Comment : ' Comment]);
        disp(['Date/Time : ' DateTime]);
        disp(['Duration : ' num2str(Duration)]);
        disp(['Num Pts Per Wave : ' num2str(NPW)]);
        disp(['Num Pts Pre-Threshold : ' num2str(PreThresh)]);
        % some of the information is only filled if the plx file version is >102
        if ( Version > 102 )
            if ( Trodalness < 2 )
                disp('Data type : Single Electrode');
            elseif ( Trodalness == 2 )
                disp('Data type : Stereotrode');
            elseif ( Trodalness == 4 )
                disp('Data type : Tetrode');
            else
                disp('Data type : Unknown');
            end
            
            disp(['Spike Peak Voltage (mV) : ' num2str(SpikePeakV)]);
            disp(['Spike A/D Resolution (bits) : ' num2str(SpikeADResBits)]);
            disp(['Slow A/D Peak Voltage (mV) : ' num2str(SlowPeakV)]);
            disp(['Slow A/D Resolution (bits) : ' num2str(SlowADResBits)]);
        end
    end
    
    
    % Get general info needed for events and units
    [tscounts, ~, evcounts] = plx_info(filename,1);
    % when keeping all waveforms, wfcounts (2nd arg) will be = tscounts
    % tscounts, wfcounts are indexed by (unit+1,channel+1)
    % tscounts(:,ch+1) is the per-unit counts for channel ch
    % sum( tscounts(:,ch+1) ) is the total wfs for channel ch (all units)
    % [nunits, nchannels] = size( tscounts )
    % To get number of nonzero units/channels, use nnz() function
    
    % gives actual number of units (including unsorted) and actual number of
    % channels plus 1
    [max_num_units num_channels] = size(tscounts);
    
    % what is the difference at this point between OpenedFileName and
    % filename?
    % get some other info about the spike channels.
    % nspk (arg 1) is the # of spike channels
    % spk_filters is a logical array of which spike (notch?) filters were on
    % [~,spk_filters] = plx_chan_filters(filename);
    [~,spk_gains] = plx_chan_gains(filename);
    [~,spk_threshs] = plx_chan_thresholds(filename);
    % [~,spk_names] = plx_chan_names(filename);
    % assume that the number of elements in spk_threshs will be =
    % num_total_units defined on the next line.
    
    % Get Units 
    num_total_units = sum(sum(tscounts > 0));
    ids = cell(1, num_total_units);
    tss = cell(1, num_total_units);
    NPPW = zeros(1,num_total_units);
    preThreshold = zeros(1,num_total_units);
    waves = cell(1, num_total_units);
    chan_thresholds = cell(1, num_total_units);
    unit_counter = 1;

    for chan = 1:num_channels-1
        if opts.verbose
            disp(sprintf('Spike channel: %d', chan));
        end
        for unit = 1:max_num_units-1
            % only create a unit if it has spikes
            if (tscounts(unit+1, chan+1) > 0)
%                 [n, ts] = plx_ts(filename, chan, unit);

                % there is also a plx_waves_v; the primary difference
                % between the two seems to me that the wave output of
                % plx_waves is in integers, and the wave output of
                % plx_waves_v is in flots, which are equal to the
                % wave output of plx_waves / 16384
                [n, npw, ts, wave] = plx_waves(filename, chan, unit);
                % number of points per wave
                % NPPW(unit_counter)=npw;                
                ids{unit_counter} = [chan unit];
                tss{unit_counter} = ts;
                waves{unit_counter}=wave;
                chan_thresholds{unit_counter}=spk_threshs(chan);
                
                unit_counter = unit_counter + 1;
            end
        end
    end

    units = struct('id', ids, 'ts', tss, 'thresh', chan_thresholds, ...
        'points_per_wave', NPW, 'pre_threshold', PreThresh, ...
        'waveforms', waves);     
end
