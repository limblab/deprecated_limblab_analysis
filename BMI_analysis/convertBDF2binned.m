function binnedData = convertBDF2binned(datastruct,varargin)
% converts a BDF to the binned format, according to parameters specified in argstruct
%
% binnedData = convertBDF2binned(datastruct,[params])
%
%         datastruct              : string of bdf.mat file path and name, or string of BDF in workspace, or BDF structure directly
%
%         params fields:            [default values]
%             binsize             : [0.05] desired bin size in second
%             starttime, stoptime : [0.0 end] time at which to start/stop extracting and binning data (use 0.0 for stoptime = end of data)
%             HP, Lp              : [50 10] high pass and low pass cut off frequencies for EMG filtering
%             minFiringRate       : [0.0] minimum firing rate a units needs to be included in the data
%             NormData            : [false] specify whether the output data is to be normalized to unity
%             FindStates          : [false] Whether the data in classified in discret states
%             Unsorted            : [true] Whether to use the unsorted units in the analysis
%             TriKernel           : [false] Whether to use a triangular kernel to smooth the firing rate
%             sig                 : [0.04] sigma value for creating triangular kernel
%             ArtRemEnable        : [false] Whether or not to attempt detecting and deleting artifacts
%             NumChan             : [10] Number of channels from which the artifact removal needs to detect simultaneous spikes to consider it an artifact
%             TimeWind            : [0.0005] time window, in seconds, over which the artifact remover will consider event to be "simultaneous"

if ~isstruct(datastruct)
    %Load the file or structure
    datastruct = LoadDataStruct(datastruct);
    if isempty(datastruct)
        error('can''t load file');
    end
end

%update missing params with default values
params = get_default_binning_params(datastruct, varargin{:});

if isempty(params)
    disp('Invalid binning parameter(s)');
    return
end

if isempty(datastruct)
   disp('Could not load BDF');
   binnedData=[];
   return
end


if params.ArtRemEnable
    disp('Looking for Artifacts...');
    datastruct = artifact_removal(datastruct,params.NumChan,params.TimeWind, 1);
end

%-------------------------------------------------------------------------
%Create triangular kernel for convolution with spikes  %(SHT and SNN, added 3/8/12)
     
%1) Initialize an array that stores the times from -support to support
%    at binWidth resolution
binWidth = params.binsize;      %Double check that your units make sense!
support = sqrt(6) * params.sig;
numBins = floor(support/binWidth);
maxTime = binWidth * numBins;
times = -maxTime:binWidth:(maxTime+(0.1*binWidth));
% 2) Compute the two constants
const1 = 1 / (6 * params.sig^2);
const2 = sqrt(6) * params.sig;
% 3) Compute the kernel
kernel = const1 * (const2 - abs(times));
%--------------------------------------------------------------------------
%% Other time and frequency parameters
numberbins = round((params.stoptime-params.starttime)/params.binsize);      
timeframe = ones(numberbins,1);
timeframe = timeframe.*(params.starttime:params.binsize:params.stoptime-params.binsize)';

%% Bin EMG Data

if ~isfield(datastruct, 'emg')
    fprintf('No EMG data was found\n');
    emgdatabin = [];
    emgguide = [];
else

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Want to assemble the emg data into a single
    % matrix. Each column is a different analog signal. If desired, the analog data is
    % filtered and downsampled according to input specifications.
    % EMG data is hi-pass filtered at 50Hz, rectified and low pass filtered
    % at 10Hz, unless otherwise specified. It is downsampled to match the desired binsize.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    emgsamplerate = datastruct.emg.emgfreq;   %Rate at which emg data were actually acquired.
    numEMGs = length(datastruct.emg.emgnames);
    emgguide = cell(1,numEMGs);
    emgtimebins = find(datastruct.emg.data(:,1)>=params.starttime & datastruct.emg.data(:,1)<params.stoptime);

    for i=1:numEMGs
        emgguide{i} = strrep(datastruct.emg.emgnames{i},'EMG_','');
    end

    %Pre-allocate matrix for binned EMG 
    emgdatabin = zeros(numberbins,numEMGs);

    % Filter EMG data
    [bh,ah] = butter(4, params.EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
    [bl,al] = butter(4, params.EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

    for E=1:numEMGs
        % Filter EMG data
        tempEMG = double(datastruct.emg.data(emgtimebins,E+1));
        if ~isfield(datastruct.emg,'rectified')            
            tempEMG = filtfilt(bh,ah,tempEMG); %highpass filter
            tempEMG = abs(tempEMG); %rectify
            tempEMG = filtfilt(bl,al,tempEMG); %lowpass filter
        end
        %downsample EMG data to desired bin size
%             emgdatabin(:,E) = resample(tempEMG, 1/binsize, emgsamplerate);
        emgdatabin(:,E) = interp1(datastruct.emg.data(emgtimebins,1), tempEMG, timeframe,'linear','extrap');
    end

    %Normalize EMGs        
    if params.NormData
        for i=1:numEMGs
%             emgdatabin(:,i) = emgdatabin(:,i)/max(emgdatabin(:,i));
            %dont use the max because of artefact, use 99% percentile
            EMGNormRatio = prctile(emgdatabin(:,i),99);
            emgdatabin(:,i) = emgdatabin(:,i)/EMGNormRatio;
        end
    end

    clear tempEMG bh ah bl al emgtimebins EMGname numEMGs EMGNormRatio;
end

%% Bin Force - Not implemented for handle force yet, only WF and other lab 1 stuff.
if ~isfield(datastruct, 'force') 
    fprintf('No force data was found\n');
    forcedatabin = [];
    forcelabels = [];
else
    if isstruct(datastruct.force)
        %datastruct is using the lab 1 WF format
        numforcech = length(datastruct.force.labels);
        forcetimebins = find(datastruct.force.data(:,1)>=params.starttime & datastruct.force.data(:,1)<params.stoptime);
        forcelabels = datastruct.force.labels;

        %downsample force data to desired bin size
    %         forcedatabin = resample(datastruct.force.data(forcetimebins,2:end), 1/binsize, forcesamplerate);
        forcedatabin = interp1(datastruct.force.data(forcetimebins,1), datastruct.force.data(forcetimebins,2:end), timeframe,'linear','extrap');
    else
        %datastruct is using the lab3 &lab6 robottask format
        numforcech=size(datastruct.force,2)-1;%1 time col, and the rest are data cols
        if numforcech~=2
            warning('convertBDF2binned:MoreThan2RobotForces','convertBDF2binned assumes the robottask force structure is a matrix with 3 columns [time,Fx,Fy]. This structure has a different number of channels, so the force labels may be incorrect.')
        end
        forcetimebins=find(datastruct.force(:,1)>=params.starttime & datastruct.force(:,1)<params.stoptime);
        forcelabels={'Force_X','Force_y'};
        %downsample force data to desired bin size
        forcedatabin = interp1(datastruct.force(forcetimebins,1), datastruct.force(forcetimebins,2:end), timeframe,'linear','extrap');
    end
    if params.NormData
        %Normalize Force
        for i=1:numforcech
%             forcedatabin(:,i) = forcedatabin(:,i)/max(abs(forcedatabin(:,i)));
            %dont use the max because of possible outliars, use 99% percentile
            forceNormRatio = prctile(abs(forcedatabin(:,i)),99);
            forcedatabin(:,i) = forcedatabin(:,i)/forceNormRatio;
        end        
    end
    clear forcetimebins forcename numforcech forceNormRatio;
end

%% Bin Cursor Position
if ~isfield(datastruct, 'pos')
    %disp(sprintf('No cursor data is found in structure " %s " ',datastructname));
    cursorposbin = [];
elseif ~isempty(datastruct.pos)
    cursorposbin = interp1(datastruct.pos(:,1), datastruct.pos(:,2:3), timeframe,'linear','extrap');
else
    cursorposbin = [];
end

cursposlabels = {'x_pos','y_pos'};

%% Bin Velocity
if ~isfield(datastruct, 'vel')
    if isfield(datastruct,'pos') && ~isempty(cursorposbin)
        %derive freshly binned pos data
        [~,vel] = gradient(cursorposbin, params.binsize);
        magn = sqrt(sum(vel.^2,2));
        velocbin = [vel magn];
        clear vel;
    else
        %disp(sprintf('No cursor/velocity data is found in structure " %s " ',datastructname));
        velocbin = [];
    end
else
    velocbin = interp1(datastruct.vel(:,1), datastruct.vel(:,2:3), timeframe,'linear','extrap');
    velocbin(timeframe<datastruct.vel(1,1),:) = 0;
    vel_magn = sqrt(velocbin(:,1).^2+velocbin(:,2).^2);
    velocbin = [velocbin vel_magn];
end

veloclabels ={'x_vel','y_vel','vel_magn'};

%% Bin Acceleration
if ~isfield(datastruct, 'acc')
    if isfield(datastruct,'pos') && ~isempty(velocbin)
        %derive freshly binned vel data
        [~,acc] = gradient(velocbin(:,1:end-1),params.binsize);
        magn = sqrt(sum(acc.^2,2));
        accelbin = [acc magn];
        clear acc;
    else
        %disp(sprintf('No cursor/acceleration data is found in structure " %s " ',datastructname));
        accelbin = [];
    end
else
    accelbin = interp1(datastruct.acc(:,1), datastruct.acc(:,2:3), timeframe,'linear','extrap');
    acc_magn = sqrt(accelbin(:,1).^2+accelbin(:,2).^2);
    accelbin = [accelbin acc_magn];
end

acclabels = {'x_acc', 'y_acc','acc_magn'};

%% Bin Spike Data

if ~isfield(datastruct, 'units')
    warning('No spikes in data file!');
    spikeratedata = [];
    neuronIDs = [];
else

    %decide which signals to use: minimum of "minFiringRate spikes/sec on average:
    minimumspikenumber = (params.stoptime-params.starttime)*params.minFiringRate;
    totalnumunits = length(datastruct.units);
    numusableunits = 0;
    units_to_use = zeros(1,totalnumunits);
    maxnum_ts = 0;
    
    %Identify the sorted units %%%with minimum spike rate%%%
    for i=1:totalnumunits

        if isempty(datastruct.units(i).id) || datastruct.units(i).id(2)==255 ...
             || (datastruct.units(i).id(2)==0 && ~params.Unsorted)
            % skip empty units or id#255 (noise?)
            % skip unit id 0 if params.Unsorted is false
            continue;
        end
        
        num_ts = length(datastruct.units(i).ts);

        if num_ts >= minimumspikenumber
            numusableunits = numusableunits+1;
            units_to_use(numusableunits) = i;
            maxnum_ts = max(num_ts, maxnum_ts);
        end
    end
    units_to_use = nonzeros(units_to_use);

    if (numusableunits < 1)
        fprintf('The data does not contain any unit with a minimum of %g spike/sec',params.minFiringRate);
        spikeratedata = [];
        neuronIDs = [];
    else   
        neuronIDs = zeros(numusableunits,2);
        spikeratedata=zeros(numberbins,numusableunits);
        
        % Create the neuronID field with electrode and unit numbers
        for i=1:numusableunits
            neuronIDs(i,:) = datastruct.units(units_to_use(i)).id;
        end

       if ~params.TriKernel
            % Create the spike data matrix, using the specified bin size and
            % identified units
            for unit = 1:numusableunits

             %get the binned data from the desired timeframe
             binneddata=train2bins(datastruct.units(units_to_use(unit)).ts,timeframe);

             %convert to firing rate and store in spike data matrix
             spikeratedata(:,unit) = binneddata /params.binsize;
             end
       else
            BinTimes = params.starttime:params.binsize:params.stoptime;
            % spikeStartTime is the initial time in the spikeArray
            spikeStartTime = BinTimes(1);
            for unit = 1:numusableunits

                spkTimes = datastruct.units(units_to_use(unit)).ts;
                
                % Now fill the spikeRaster with the appropriate counts 

                spikeBins = round((spkTimes - spikeStartTime) * (1/binWidth));
                spikeBins = spikeBins(spikeBins > 0);
                spikeBins = spikeBins(spikeBins <= numBins);
                spikeRaster = zeros(1,length(BinTimes));
                spikeRaster(spikeBins(unit)) = 1;

%                 firingRate(:,unit) = conv(spikeRaster, kernel);
                spikeratedata(:,unit) = conv(spikeRaster, kernel);
                %firingRate = firingRate((extraBins+1):(length(firingRate) - extraBins));
            end
           
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
         targets.centers = datastruct.targets.centers( datastruct.targets.centers(:,1)>=timeframe(1) & ...
                                                       datastruct.targets.centers(:,1)<=timeframe(end),: );                                            
     end
                                                   
     if isfield(datastruct.targets, 'rotation')                                            
         targets.rotation = datastruct.targets.rotation( datastruct.targets.rotation(:,1)>=timeframe(1) & ...
                                                        datastruct.targets.rotation(:,1)<=timeframe(end),: );
     end

end

%% Trial Table
if (isfield(datastruct,'words') && ~isempty(datastruct.words))
    tt = [];
    tt_labels = [];
    
    start_trial_words = datastruct.words( bitand(hex2dec('f0'),datastruct.words(:,2)) == hex2dec('10') ,2);
    if ~isempty(start_trial_words)
        start_trial_code = start_trial_words(1);
        if ~isempty(find(start_trial_words ~= start_trial_code, 1))
           warning('BDF:inconsistentBehaviors','Not all trials are the same type');
        end

        if start_trial_code == hex2dec('17')
            % wrist_flexion_task
            [tt, tt_labels] = wf_trial_table(datastruct);
            tt = tt(tt(:,1)>=timeframe(1) & tt(:,8)<=timeframe(end),:);
        elseif start_trial_code == hex2dec('11')
            %center_out_task
        elseif start_trial_code == hex2dec('12')
            %random_walk_task
        elseif start_trial_code == hex2dec('1b')
            %visual search task
            tt = vs_trial_table(datastruct);                
        elseif start_trial_code == hex2dec('19')
            %ball_drop_task
            tt = bd_trial_table(datastruct);
            tt = tt(tt(:,1)>=timeframe(1) & tt(:,6)<=timeframe(end),:);       
        elseif start_trial_code == hex2dec('16')
            %multi_gadget_task
            tt = mg_trial_table(datastruct);
            tt = tt(tt(:,1)>=timeframe(1) & tt(:,11)<=timeframe(end),:);
        else
            warning('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
        end
    end
    
else
    warning('BDF:noWords','No WORDs are present');
    tt = [];
    tt_labels = [];        
end
    
%% Stimulator Commands
stimT= [];
stim  =[];
if isfield(datastruct,'stim') 
    if isa(datastruct.stim,'numeric')
        %%% Bin at binsize or Stim period??
        % bin at stim period, stim[] array includes timestamps in first column
        [stim, stimT] = binPW_atStimFreq(datastruct.stim);
    end
end

%% State
state = [];
if isfield(datastruct,'state')
    state = zeros(size(timeframe));
    t = params.starttime;
    t_idx = find(datastruct.state(:,1)==t);
    datastruct_dt = round(1000*diff(datastruct.state(1:2,1)))/1000;
    samples_per_bin = binWidth/datastruct_dt;
    for iBin = 1:length(timeframe)-1
        state(iBin) = mean(datastruct.state(t_idx:t_idx+samples_per_bin-1,2));
        t_idx = t_idx+samples_per_bin;
    end
    state(end) = mean(datastruct.state(t_idx:t_idx+samples_per_bin-1,2));
else
    state = [];
end

%% Outputs
binnedData = struct('timeframe',timeframe,...
                    'meta',datastruct.meta,...
                    'emgguide',{emgguide},...
                    'emgdatabin',emgdatabin,...
                    'forcelabels',{forcelabels},...
                    'forcedatabin',forcedatabin,...
                    'neuronIDs',neuronIDs,...
                    'spikeratedata',spikeratedata,...
                    'cursorposlabels',{cursposlabels},...
                    'cursorposbin',cursorposbin,...
                    'velocbin',velocbin,...
                    'veloclabels',{veloclabels},...
                    'accelbin',accelbin,...
                    'acclabels',{acclabels},...
                    'words',words,...
                    'targets',targets,...
                    'trialtable',tt,...
                    'trialtablelabels',{tt_labels},...
                    'stim',stim,...
                    'stimT',stimT,...
                    'state',state);        
        
end
