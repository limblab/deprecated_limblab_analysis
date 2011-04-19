function binnedData = convertBDF2binned(varargin)
        %argin : (datastructname, binsize, starttime, endtime, EMG_highpass, EMG_lowpass, minFiringRate, NormData,FindStates)

%% Initialization

if (nargin <1 || nargin == 3 || nargin > 9)
    disp('Wrong number of arguments');
    disp(sprintf('Usage: \nconvertBDF2binned( datastructname, [binsize], [starttime, endtime],[EMG_hp, EMG_lp]'));
    disp('  - datastructname        : string of bdf.mat file path and name, or name of preloaded BDF structure');
    disp('  - [binsize]             : [0.02] opt. desired bin size in second');
    disp('  - [starttime, stoptime] : [0.0 end] time at which to start/stop extracting and binning data (use 0.0 for stoptime = end of data)');
    disp('  - [EMG_hp, EMG_lp]      : [50 10] high pass and low pass cut off frequencies for EMG filtering');
    disp('  - [minFiringRate]       : [0.0] minimum firing rate a units needs to be included in the data');
    disp('  - [NormData]            : [false] specify whether the output data is to be normalized to unity');
    disp('  - [FindStates]          : [false] Whether the data in classified in discret states');
    disp(sprintf('\n'));
    return;
end

datastructname = varargin{1};

%Load the file or structure
datastruct = LoadDataStruct(datastructname);

if isempty(datastruct)
   disp(sprintf('Could not load structure %s',datastructname));
   binnedData=[];
   return
end

%Default Parameters (all units are in seconds):
binsize = 0.02;
starttime = 0.0;
if isfield(datastruct, 'emg')
    duration = double(datastruct.emg.data(end,1));
elseif isfield(datastruct,'force')
    duration = double(datastruct.force.data(end,1));
elseif isfield(datastruct,'pos')
    duration = double(datastruct.pos(end,1)-datastruct.pos(1,1));
else
    warning('BDF2BIN: no emg or force field present in input structure');
end

stoptime = floor(duration);
EMG_hp = 50; % default high pass at 50 Hz
EMG_lp = 10; % default low pass at 10 Hz
minFiringRate = 0.0; %default min firing rate to include a unit in the data
NormData = false;
Find_States=false;

%optional parameters overridding
if (nargin >= 2)
    binsize = varargin{2};
end
if (nargin >=4)
    starttime = varargin{3};
    stoptime = varargin{4};
end
if (nargin >=6)
    EMG_hp = varargin{5};
    EMG_lp = varargin{6};
end
if (nargin >=7)
    minFiringRate = varargin{7};
end
if (nargin >= 8)
    NormData = varargin{8};
end
if (nargin == 9)
    Find_States = varargin{9};
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
    binnedData = [];
    return
end

%Other time and frequency parameters
numberbins = (stoptime-starttime)/binsize;      
timeframe = ones(numberbins,1,'single');
timeframe = timeframe.*(starttime:binsize:stoptime-binsize)';      %Time vector of the binned data, mostly for plotting

%% Bin EMG Data

if ~isfield(datastruct, 'emg')
    disp(sprintf('No EMG data is found in structure " %s " ',datastructname));
    emgdatabin = [];
    emgguide = [];
else

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%Want to assemble the analog data that is to be analyzed into a single
    %%%matrix.  Each column is a different analog signal. If desired, the analog data is
    %%%filtered and downsampled according to input specifications.
    %%%EMG data is hi-pass filtered at 50Hz unless otherwise specified, it is
    %%%then rectified and low pass filtered at 10Hz, again unless otherwise
    %%%specified.  Finally it is downsampled to match the desired binsize.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    emgsamplerate = datastruct.emg.emgfreq;   %Rate at which emg data were actually acquired.
    EMGname = char(zeros(1,12));
    numEMGs = length(datastruct.emg.emgnames);
    emgguide = char(zeros(numEMGs,length(EMGname)));
    emgtimebins = single(starttime*emgsamplerate+1:stoptime*emgsamplerate);


    for i=1:numEMGs
        EMGname = char(strrep(datastruct.emg.emgnames(i),'EMG_',''));
        emgguide(i,1:length(EMGname)) = EMGname;
    end

    %Pre-allocate matrix for binned EMG -- single precision!
    emgdatabin = zeros(numberbins,numEMGs,'single');

    % Filter EMG data
    [bh,ah] = butter(4, EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(4, EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

    for E=1:numEMGs
        % Filter EMG data
        tempEMG = datastruct.emg.data(emgtimebins,E+1);
        tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
        tempEMG = abs(tempEMG); %rectify
        tempEMG = filtfilt(bl,al,tempEMG); %lowpass filter

        %downsample EMG data to desired bin size
%             emgdatabin(:,E) = resample(tempEMG, 1/binsize, emgsamplerate);
        emgdatabin(:,E) = interp1(datastruct.emg.data(emgtimebins,1), tempEMG, timeframe,'linear',0);
    end

    %Normalize EMGs        
    if NormData
        for i=1:numEMGs
            emgdatabin(:,i) = emgdatabin(:,i)/max(emgdatabin(:,i));
        end
    end

    clear tempEMG bh ah bl al emgtimebins EMGname numEMGs;
end

%% Bin Force
if ~isfield(datastruct, 'force')
    disp(sprintf('No force data is found in structure " %s " ',datastructname));
    forcedatabin = [];
    forcelabels = [];
else
    forcesamplerate = datastruct.force.forcefreq;   %Rate at which emg data were actually acquired.
    forcename = char(zeros(1,12));
    numforcech = length(datastruct.force.labels);
    forcelabels = char(zeros(numforcech,length(forcename)));
    forcetimebins = single(starttime*forcesamplerate+1:stoptime*forcesamplerate);

    for i=numforcech:-1:1
        forcename = char(datastruct.force.labels(i));
        forcelabels(i,1:length(forcename))= forcename;
    end

    %downsample force data to desired bin size
%         forcedatabin = resample(datastruct.force.data(forcetimebins,2:end), 1/binsize, forcesamplerate);
    forcedatabin = interp1(datastruct.force.data(forcetimebins,1), datastruct.force.data(forcetimebins,2:end), timeframe,'linear',0);

    if NormData
        %Normalize Force
        for i=1:numforcech
            forcedatabin(:,i) = forcedatabin(:,i)/max(abs(forcedatabin(:,i)));
        end        
    end

    clear forcesamplerate forcetimebins forcename numforcech;
end

%% Bin Cursor Position
if ~isfield(datastruct, 'pos')
    %disp(sprintf('No cursor data is found in structure " %s " ',datastructname));
    cursorposbin = [];
else
    cursorposbin = single(interp1(datastruct.pos(:,1), datastruct.pos(:,2:3), timeframe,'linear',0));
end

cursposlabels(1:2,1:12) = [char(zeros(1,12));char(zeros(1,12))];
cursposlabels(1,1:5)= 'x_pos';
cursposlabels(2,1:5)= 'y_pos';

if NormData
    %Normalize Cursor and Target position with same x and y ratios
    %first, calculate the ratio for cursor and use it later also for
    %target corners
    NormRatios = 1./max(abs(cursorposbin));
    %Normalize cursor position
    cursorposbin = cursorposbin.*repmat(NormRatios,numberbins,1);
end


%% Bin Velocity (Magnitude only)
if ~isfield(datastruct, 'vel')
    %disp(sprintf('No cursor data is found in structure " %s " ',datastructname));
    velocbin = [];
else
    velocbin = single(interp1(datastruct.vel(:,1), datastruct.vel(:,2:3), timeframe,'linear',0));
    vel_magn = sqrt(velocbin(:,1).^2+velocbin(:,2).^2);
    velocbin = [velocbin vel_magn];
end

veloclabels(1:3,1:12) = [char(zeros(1,12));char(zeros(1,12));char(zeros(1,12))];
veloclabels(1,1:5)= 'x_vel';
veloclabels(2,1:5)= 'y_vel';
veloclabels(3,1:8)= 'vel_magn';

if NormData
    %Normalize velocity from 0 to 1
    velocbin = velocbin/max(velocbin);
end

%% Bin Spike Data

if ~isfield(datastruct, 'units')
    disp(sprintf('No spike data is found in structure " %s " ',datastructname));
    spikeratedata = [];
    spikeguide = [];
else

    %decide which signals to use: minimum of "minFiringRate spikes/sec on average:
    minimumspikenumber = (stoptime-starttime)*minFiringRate;
    totalnumunits = length(datastruct.units);
    numusableunits = 0;
    units_to_use = zeros(1,totalnumunits);
    maxnum_ts = 0;

    %Identify the sorted units %%%with minimum spike rate%%%
    for i=1:totalnumunits

        if isempty(datastruct.units(i).id)
            continue;
        end
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
        disp(sprintf('The data does not contain any unit with a minimum of %g spike/sec',minFiringRate));
        spikeratedata = [];
        spikeguide = [];
    else   

        % Pre-allocate accordingly - singles!
        spikeguide= char(zeros(numusableunits,length('ee00u0'))); %preallocate space for spikeguide
        spikeratedata=zeros(numberbins,numusableunits,'single');

        % Create the spikeguide with electrode names
        for i=1:numusableunits
            spikeguide(i,:)=['ee' sprintf('%02d', datastruct.units(units_to_use(i)).id(1)) 'u' sprintf('%1d',datastruct.units(units_to_use(i)).id(2)) ];
        end


        % Create the spike data matrix, using the specified bin size and
        % identified units
        for unit = 1:numusableunits

            %get the binned data from the desired timeframe plus one bin before
            binneddata=train2bins(datastruct.units(units_to_use(unit)).ts,starttime:binsize:stoptime);

            %and get rid of the extra bins at beginnning, it contains all the ts
            %from the beginning of file that are < starttime. Here I want
            %starttime to be the lower bound of the first bin.
            binneddata = single(binneddata(2:end));

            %convert to firing rate and store in spike data matrix
            spikeratedata(:,unit) = binneddata' /binsize;
        end
    end        
end

%% Words
%(see outputs)
if ~isfield(datastruct,'words')
    words = [];    
else
    words = datastruct.words(datastruct.words(:,1)>=timeframe(1) & datastruct.words(:,1)<=timeframe(end),:);
end

%% Targets
%(see outputs)
if ~isfield(datastruct,'targets')
    targets.corners = [];
    targets.rotation= [];
else
     if isfield(datastruct.targets, 'corners')
         targets.corners = datastruct.targets.corners( datastruct.targets.corners(:,1)>=timeframe(1) & ...
                                                       datastruct.targets.corners(:,1)<=timeframe(end),: );                                            
     end
     
     if isfield(datastruct.targets, 'centers')
         targets.centers = datastruct.targets.center( datastruct.targets.centers(:,1)>=timeframe(1) & ...
                                                       datastruct.targets.centers(:,1)<=timeframe(end),: );                                            
     end
                                                   
     if isfield(datastruct.targets, 'rotation')                                            
         targets.rotation = datastruct.targets.rotation( datastruct.targets.rotation(:,1)>=timeframe(1) & ...
                                                        datastruct.targets.rotation(:,1)<=timeframe(end),: );
     end

    %Normalize Cursor and Target position with same x and y ratios     
    if NormData && isfield(datastruct.targets, 'corners')
        %target x corners
        targets.corners(:,[2 4]) = targets.corners(:,[2 4])*NormRatios(1);
        %target y corners
        targets.corners(:,[3 5]) = targets.corners(:,[3 5])*NormRatios(2);                                            
    end
    
    if NormData && isfield(datastruct.targets, 'centers')
        numtgt = (size(targets.corners,2)-1)/2;
        %target x centers
        targets.centers(:,2:2:(2+2*(numtgt-1))) = targets.centers(:,2:2:(2+2*(numtgt-1)))*NormRatios(1);
        %target y centers
        targets.centers(:,3:2:(3+2*(numtgt-1))) = targets.centers(:,3:2:(3+2*(numtgt-1)))*NormRatios(1);
    end
end

%% Trial Table
if (isfield(datastruct,'words') && ~isempty(datastruct.words))
    center_out_task=0;
    robot_task = 0;
    wrist_flexion_task =0;
    ball_drop_task = 0;
    multi_gadget_task=0;
    random_walk_task=0;
    
    start_trial_words = datastruct.words( bitand(hex2dec('f0'),datastruct.words(:,2)) == hex2dec('10') ,2);
    if ~isempty(start_trial_words)
        start_trial_code = start_trial_words(1);
        if ~isempty(find(start_trial_words ~= start_trial_code, 1))
           close(h);
           error('BDF:inconsistentBehaviors','Not all trials are the same type');
        end

        if start_trial_code == hex2dec('17')
            wrist_flexion_task = 1;
        elseif (start_trial_code >= hex2dec('11') && start_trial_code <= hex2dec('15')) ||...
                start_trial_code == hex2dec('1a') || start_trial_code == hex2dec('1c')
            robot_task = 1;
            if start_trial_code == hex2dec('11')
                center_out_task = 1;
            elseif start_trial_code == hex2dec('12')
                random_walk_task = 1;
            end
        elseif start_trial_code == hex2dec('1B')
            robot_task = 1;
        elseif start_trial_code == hex2dec('19')
            ball_drop_task = 1;
        elseif start_trial_code == hex2dec('16')
            multi_gadget_task = 1;
        else
            %close(h);
            error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
        end
    end

    if ball_drop_task
        tt = bd_trial_table(datastruct);
    else
        tt = [];
    end
else
        warning('BDF:noWords','No WORDs are present');
        tt = [];
end
    
%% Stimulator Commands
% if isfield(datastruct,'stim') 
%     if isa(datastruct.stim,'numeric')
%         
%         chans    = unique(datastruct.stim(:,2));
%         numchans = length(chans);
%
%         %%% Bin at binsize or Stim period??
%
%     end
% end
        

%% Movement States
if ~Find_States
    states = [];
    statemethods = [];
else
    states = NaN(numberbins,2);
    statemethods(1:2,1:12) = [char(zeros(1,12));char(zeros(1,12))];   
    tt = vs_trial_table(datastruct);
    
    % 1- Classify states according to a velocity threshold:
    states(:,1) = vel_magn >= std(vel_magn);
    statemethods(1,1:10) = 'Vel thresh';
    
%     % 2- Classify states according to a Global Firing Rate threshold:
%     states(:,2) = GFR_clas(spikeratedata,binsize);
%     statemethods(2,1:10) = 'GFR thresh';
    
    % 2- Classify states according to naive Bayesian using all datapoints for training
    states(:,2) = perf_bayes_clas(spikeratedata,binsize,vel_magn);
    statemethods(2,1:14) = 'Complete Bayes';
    
    % 3- Classify states according to naive Bayesian using velocity peaks for training
    states(:,3) = peak_bayes_clas(spikeratedata,binsize,vel_magn);
    statemethods(3,1:10) = 'Peak Bayes';
    
    % 4- Classify states according to Linear Discriminant Analysis using velocity peaks for training
    states(:,4) = perf_LDA_clas(spikeratedata,binsize,vel_magn);
    statemethods(4,1:12) = 'Complete LDA';
    
    % 5- Classify states according to Linear Discriminant Analysis using velocity peaks for training
    states(:,5) = peak_LDA_clas(spikeratedata,binsize,vel_magn);
    statemethods(5,1:8) = 'Peak LDA';
    
end

%% Outputs
binnedData = struct('timeframe',timeframe,...
                    'emgguide',emgguide,...
                    'emgdatabin',emgdatabin,...
                    'forcelabels',forcelabels,...
                    'forcedatabin',forcedatabin,...
                    'spikeguide',spikeguide,...
                    'spikeratedata',spikeratedata,...
                    'cursorposlabels',cursposlabels,...
                    'cursorposbin',cursorposbin,...
                    'velocbin',velocbin,...
                    'veloclabels',veloclabels,...
                    'words',words,...
                    'targets',targets,...
                    'states',states,...
                    'statemethods',statemethods,...
                    'trialtable',tt);
                               
%% resample function for single-precision (embeded function):

function Y = downSample(X,NewSR,OrigSR)
   % downSample the sequence in vector X at NewSR/OrigSR times the original sample rate.
   % OrigSR must be a multiple of NewSR

    binsToKeep = int32(1:round(OrigSR/NewSR):length(X));
    Y = X(binsToKeep);
end
        
        
end
