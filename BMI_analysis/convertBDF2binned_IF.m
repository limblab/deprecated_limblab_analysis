function binnedData = convertBDF2binned_IF(varargin)
        %argin : (datastructname, binsize, starttime, endtime, EMG_highpass, EMG_lowpass)

%% Initialization

    if (nargin <1 || nargin == 3 || nargin > 7)
        disp('Wrong number of arguments');
        disp(sprintf('Usage: \nconvertBDF2binned( datastructname, [binsize], [starttime, endtime],[EMG_hp, EMG_lp]'));
        disp('  - datastructname        : string of bdf.mat file path and name, or name of preloaded BDF structure');
        disp('  - [binsize]             : opt. desired bin size in second (e.g. 0.02)');
        disp('  - [starttime, stoptime] : time at which to start/stop extracting and binning data (use 0.0 for stoptime = end of data)');
        disp('  - [EMG_hp, EMG_lp]      : high pass and low pass cut off frequencies for EMG filtering');
        disp(sprintf('\n'));
        return;
    end
    
    %add path to spike binning function
    addpath ../spike
 
    
    datastructname = varargin{1};

    %Load the file or structure
%    datapath = 'C:\Monkey\Theo\Data\BDFStructs\';
%    datastruct = loaddatastruct([datapath datastructname],'binned');
    datastruct = LoadDataStruct(datastructname,'bdf');

    if isempty(datastruct)
       disp(sprintf('Could not load structure %s',datastructname));
       return
    end

    if ~isfield(datastruct, 'emg')
        disp(sprintf('No EMG data is found in structure " %s " ',datastructname));
        disp('data conversion aborted');
        return
    end
    if ~isstruct(datastruct.units)
        disp(sprintf('No spike data is found in structure " %s " ',datastructname));
        disp('data convertion aborted');
        return
    end
        
    %Default Parameters (all units are in seconds):
    binsize = 0.02;
    starttime = 0.0;
    duration = datastruct.emg.data(end,1);
    stoptime = floor(duration);
    EMG_hp = 50; % default high pass at 50 Hz
    EMG_lp = 10; % default low pass at 10 Hz

    %optional parameters overridding
    if (nargin >= 2)
        binsize = varargin{2};
    end
    if (nargin >=4)
        starttime = varargin{3};
        stoptime = varargin{4};
    end
    if (nargin ==6)
        EMG_hp = varargin{5};
        EMG_lp = varargin{6};
    end

    
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
    
    %Other time and frequency parameters
    numberbins = (stoptime-starttime)/binsize;              %frame for binned data:
    emgsamplerate = datastruct.emg.emgfreq;                 %Rate at which emg data were actually acquired.
    timeframe = (starttime:binsize:stoptime-binsize)';      %Time vector of the binned data, mostly for plotting

%% Bin EMG Data

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%Want to assemble the analog data that is to be analyzed into a single
    %%%matrix.  Each column is a different analog signal. If desired, the analog data is
    %%%filtered and downsampled according to input specifications.
    %%%EMG data is hi-pass filtered at 50Hz unless otherwise specified, it is
    %%%then rectified and low pass filtered at 10Hz, again unless otherwise
    %%%specified.  Finally it is downsampled to match the desired binsize.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EMGname = char(zeros(1,8));
    numEMGs = length(datastruct.emg.emgnames);
    emgguide = char(zeros(numEMGs,length(EMGname)));
    
    
    for i=1:numEMGs
        
        EMGname = char(strrep(datastruct.emg.emgnames(i),'EMG_',''));
        emgguide(i,1:length(EMGname)) = EMGname;
    end
    
    %Pre-allocate matrix for binned EMG
    emgdatabin = zeros(numberbins,numEMGs);

    % Filter EMG data
    [bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params
    tempEMGs = datastruct.emg.data(starttime*emgsamplerate+1:stoptime*emgsamplerate,2:numEMGs+1); % *500; % Convert to mV
    tempEMGs = filtfilt(bh,ah,tempEMGs); %highpass filter
    tempEMGs = abs(tempEMGs); %rectify
    tempEMGs = filtfilt(bl,al,tempEMGs); %lowpass filter
    for i=1:numEMGs
        %remove offset
%            tempEMGs(:,i)=tempEMGs(:,i)-min(tempEMGs(:,i)); %remove offset

        %downsample EMG data to desired bin size
        emgdatabin(:,i) = resample(tempEMGs(:,i), 1/binsize, emgsamplerate);
    end    
    clear tempEMGs bh ah bl al;
    
%% Bin Spike Data
    
    %decide which signals to use: minimum of 20 spikes/mins on average:
    minimumspikenumber = (stoptime-starttime)/3;
    totalnumunits = length(datastruct.units);
    numusableunits = 0;
    units_to_use = zeros(1,totalnumunits);
    maxnum_ts = 0;
    binframe = zeros(1,numberbins);
    
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
        disp('The data does not contain any unit with a minimum of 0.3 spike/sec');
        disp('Data convertion aborted');
        clear all;
        return
    end    
    
    % Pre-allocate accordingly
    spikeguide= char(zeros(numusableunits,length('ee00u0'))); %preallocate space for spikeguide
    spikeratedata=zeros(numberbins,numusableunits);
    
    % Create the spikeguide with electrode names
    for i=1:numusableunits
        spikeguide(i,:)=['ee' sprintf('%02d', datastruct.units(units_to_use(i)).id(1)) 'u' sprintf('%1d',datastruct.units(units_to_use(i)).id(2)) ];
    end

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
      
%%%%%%%% much slower and more complicated way of doing the same thing: %%%%%%%%%
%     for i = 1:numusableunits
%         for b = 0:numberbins-1
%             current_bin_time = (starttime+b*binsize); % lower time limit from which we bin, non-inclusive
% 
%             ts_to_bin = datastruct.units(units_to_use(i)).ts( and( gt(datastruct.units(units_to_use(i)).ts, current_bin_time), ... %greater than (starttime + lag) and...
%                                                                      le(datastruct.units(units_to_use(i)).ts, current_bin_time+binsize) ));  %lower or eq to (start+lag) + binsize
%             spikeratedata(b+1,i) = length(ts_to_bin)/binsize; % convert to firing rate and fill spikeratedata
%         end
%     end

    binnedData = struct('timeframe',timeframe,...
                           'emgguide',emgguide,...
                           'emgdatabin',emgdatabin,...
                           'spikeguide',spikeguide,...
                           'spikeratedata',spikeratedata);
                               
%% Save the binned data in a mat file
    
%      
%     [FileName,PathName] = uiputfile( datastructname, 'Save binned data file as');
%     fullfilename = fullfile(PathName , FileName);
%         
%     if isequal(FileName,0) || isequal(PathName,0)
%         disp('The binned data structure was not saved!')
%     else       
%          save(fullfilename, 'binnedData');
%          disp(['File: ', fullfilename,' saved successfully'])
% %        save(fullfilename, 'emgguide', 'emgdatabin','timeframe');
%     end
end
