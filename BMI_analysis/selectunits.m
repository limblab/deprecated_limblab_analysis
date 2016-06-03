function varargout = selectunits(varargin)
        %argin : (datastructname, binsize, starttime, endtime, minFiringRate, numunits)

%% Initialization

    if (nargin ~= 6)
        disp('Wrong number of arguments');
        disp(sprintf('Usage: \selectunits( datastructname, [binsize], [starttime, endtime],[EMG_hp, EMG_lp]'));
        disp('  - datastructname        : string of bdf.mat file path and name, or name of preloaded BDF structure');
        disp('  - binsize               : opt. desired bin size in second (e.g. 0.02)');
        disp('  - starttime, stoptime   : time at which to start/stop extracting data (use 0.0 for stoptime = end of data)');
        disp('  - minFiringRate         : minimum firing rate a units needs to be included in the data');
        disp('  - numunits              : number of best units to select');
        disp(sprintf('\n'));
        return;
    end
    
    %add path to spike binning function
    addpath ../
    addpath ../spike
 
    
    datastructname = varargin{1};

    %Load the file or structure
    datastruct = LoadDataStruct(datastructname,'bdf');

    if isempty(datastruct)
       disp(sprintf('Could not load structure %s',datastructname));
       return
    end

    if ~isstruct(datastruct.units)
        disp(sprintf('No spike data is found in structure " %s " ',datastructname));
        disp('data convertion aborted');
        return
    end

    %input parameters
    duration = datastruct.emg.data(end,1);
    stoptime = floor(duration);
    binsize = varargin{2};
    starttime = varargin{3};
    stoptime = varargin{4};
    minFiringRate = varargin{5};
    numbestunits = varargin{6};

    
%% Validation of time parameters
    
    if (starttime <0.0 || starttime > duration-binsize) %making sure the start time is valid, must be at least 10 secs before eof    
        disp(sprintf('Start time must be between %.1f and %.1f seconds',0.0,duration-binsize)); %
        disp(sprintf('Start time set to beginning of data (0.0 seconds)'));
        starttime =  0.0;
    else
        disp(sprintf('Start time set to %.1f seconds',starttime));
    end
    if stoptime ==0
        stoptime = floor(duration);
        disp(sprintf('Stop time set to end of data (floored to %.1f seconds)', stoptime));
    elseif (stoptime <binsize || stoptime > duration)
        disp(sprintf(['Stop time must be at least one bin after start time and cannot be higher than file duration (%.1f)\n' ...
                     '"Stoptime" set to end of data (%.1f seconds).'],duration,floor(duration)));
        stoptime = floor(duration);
    else
        stoptime = floor(stoptime); 
        disp(sprintf('Stop time set to %.1f seconds',stoptime));
    end
        
    if mod(1,binsize)
        disp('Please choose a binsize that is a factor of 1');
        disp('data conversion aborted');
        return
    end
    
    [timeBefore, timeAfter]=PWTH_GUI();    
    
    if timeBefore <= 1
        disp(' ''TimeBefore'' must be at least one second in order to compare peak with background activity');
        return
    end

    %Other time and frequency parameters
    numberbins = (stoptime-starttime)/binsize;              %frame for binned data
    numberbinsave = (timeAfter- -timeBefore)/binsize;       %frame for binned data
    timeframe = (starttime:binsize:stoptime-binsize)';      %Time vector of the binned data, mostly for plotting
    
%% Bin Spike Data
    
    %decide which signals to use: minimum of 'minFiringRate spikes/sec on average:
    minimumspikenumber = (stoptime-starttime)*minFiringRate;
    totalnumunits = length(datastruct.units);
    numusableunits = 0;
    units_to_use = zeros(1,totalnumunits);
    maxnum_ts = 0;
    word_pickup = 144;
    
    %Identify the sorted units %%%with minimum spike rate%%%
    for i=1:totalnumunits
        
        % skip unsorted units, which are mostly noise. skip units id 255,
        % in autosort, I don't know what this is...
        if (datastruct.units(i).id(2)==0 || datastruct.units(i).id(2)==255)
            continue; 
        end
        
        num_ts = length(datastruct.units(i).ts);
        
        if num_ts > minimumspikenumber
            numusableunits = numusableunits+1;
            units_to_use(numusableunits) = i;
            maxnum_ts = max(num_ts, maxnum_ts);
        end
    end
    units_to_use = nonzeros(units_to_use);
    
    if (numusableunits < 1)
        disp(sprintf('The data does not contain any unit with a minimum of %.1f spike/sec',minFiringRate));
        disp('Data convertion aborted');
        clear all;
        return
    end    
    
    % Pre-allocate accordingly
    spikeratedata=zeros( numberbins,numusableunits);
    
    % Create the spike data matrix, using the specified bin size and
    % identified units - but first, convert to instantaneous firing rate
    for unit = 1:numusableunits
        insta_rate = zeros(length(datastruct.units(units_to_use(unit)).ts)-1,2);
        insta_rate(:,1) = datastruct.units(units_to_use(unit)).ts(2:end);
        
        for i = 1:length(datastruct.units(units_to_use(unit)).ts)-1
            insta_rate(i,2) = 1/(datastruct.units(units_to_use(unit)).ts(i+1)-datastruct.units(units_to_use(unit)).ts(i));
        end
        
        spikeratedata(:,unit) = interp1(insta_rate(:,1),insta_rate(:,2),timeframe, 'linear', 0);
    end

    %Average the firing rate of all units around pickup-time
    Spike_PWTH = PWTH([timeframe spikeratedata],1/binsize,datastruct.words,...
                      word_pickup, timeBefore, timeAfter);
    clear spikerateave;
    
%% Select best units based on std of 1st second of average

    %get the peak firing rate from each unit
    peaks = max(Spike_PWTH(:,2:end));
    stdevs = std(Spike_PWTH(1:2/binsize,2:end));
    
    SNRs = peaks./(1+stdevs);

    thresh = 0.1;
    step = 0.05;
    tempbest = size(SNRs(SNRs>thresh),2);   

    while tempbest > numbestunits
        thresh = thresh + step*(tempbest-numbestunits);
        tempbest = size(SNRs(SNRs>thresh),2);
        if tempbest < numbestunits
            while tempbest <numbestunits
                thresh = thresh - step*2*(numbestunits-tempbest);
                tempbest = size(SNRs(SNRs>thresh),2);
            end
            step = step/5;
        end
    end
    
    bestunits = units_to_use( SNRs>thresh );
    
    bestunitsIDs = zeros(size(bestunits,1),2);
    for i = 1:size(bestunitsIDs,1)
        bestunitsIDs(i,:)=datastruct.units(1,bestunits(i)).id;
    end
    
%% Outputs    
    varargout(1) = {bestunitsIDs};
    if nargout > 1
        varargout(2) = {Spike_PWTH};
    end
    if nargout > 2
        varargout(3) = {bestunits};
    end
    if nargout > 3
        varargout(4) = {thresh};
    end
    if nargout > 4
        disp('Wrong number of outputs');
    end
    
end
   
