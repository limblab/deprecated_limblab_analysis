function build_KF(dataFile,delayBins,startTime,endTime,genPlots)
% function build_KF(dataFile,delayBins,startTime,endTime,genPlots)
%
% Builds a Kalman Filter from a CENTER OUT data file specified in DATAFILE.
%
% If dataFile is a Plexon file or bdf file, the build_KF will convert it
% to a binnedData file with 50ms bins in order to train the KF.
%
% DELAYBINS specifies the delay between spikes and predicitons in bins. 
% Default is 0 (use current observations).
%
% STARTTIME specifies the initial time in seconds from which to consider
% data for the decoder.  Default is 1s (to cut off junk data from Plexon).
%
% ENDTIME specifies the final time in seconds from which to consider data
% for the decoder.  Default is 0 (end of file).
%
% GENPLOTS should be 1 to generate plots of the fit. Default is 0.

% check inputs
if (nargin < 1 || nargin > 6);
    disp('wrong number of inputs')
    return
end
if (nargin < 5)
    genPlots = 0;
    if (nargin < 4)
        endTime = 0;
        if (nargin < 3)
            startTime = 1;
            if (nargin == 1)
                delayBins = 0;
            end
        end
    end
end

% set paths to include necessary functions
if isempty(strfind(path,'Kalman'))
    addpath('Kalman'); % for kalman_filter
    addpath('KPMstats'); % for gaussian_prob in kalman_filter
end
if (exist('BMI_analysis','dir') ~= 7)
    load_paths; % for s1_analysis functions
end

% enter handle offsets... only necessary for binnedData files
x_offset = 0;
y_offset = 0;

[pathstr, name, ext] = fileparts(dataFile);

% if dataFile is a .plx file convert it to bdf and load into workspace
if strcmp(ext,'.plx')
    disp('converting .plx file to bdf...');
    out_struct = get_plexon_data(dataFile);
else
    load(dataFile);
end

% if dataFile is bdf covert it to binnedData file with 50ms bins
if exist('out_struct','var')
    disp('extracting offsets...');
    x_offset = bytes2float(out_struct.databursts{1,2}(7:10));
    y_offset = bytes2float(out_struct.databursts{1,2}(11:14));
    disp('converting bdf file to binnedData...');
    assignin('base','temp_out_struct',out_struct);
    binnedData = convertBDF2binned('temp_out_struct', 0.05, startTime, endTime);
    evalin('base','clear temp_out_struct');
end
if  exist('bdf','var')
    disp('extracting offsets...');
    x_offset = bytes2float(bdf.databursts{1,2}(7:10));
    y_offset = bytes2float(bdf.databursts{1,2}(11:14));
    disp('converting bdf file to binnedData...');
    assignin('base','temp_out_struct',bdf);
    binnedData = convertBDF2binned('temp_out_struct', 0.05, startTime, endTime);
    evalin('base','clear temp_out_struct');
end

% to remove potential small timing discrepencies
binnedData.timeframe = round(binnedData.timeframe.*1000)./1000;

binsize = binnedData.timeframe(2) - binnedData.timeframe(1); % in seconds
neuronIDs = spikeguide2neuronIDs(binnedData.spikeguide);
outnames = ['x_pos       ';
            'y_pos       ';
            'x_vel       ';
            'y_vel       ';
            'x_accel     ';
            'y_accel     ';
            'one         '];
FromData = [name ext];

pos = binnedData.cursorposbin + repmat([x_offset y_offset],length(binnedData.cursorposbin),1);
% vel = binnedData.velocbin(:,1:2);
% acc = binnedData.accelbin(:,1:2);
vel = [0 0; diff(pos)]/binsize;
acc = [0 0; diff(vel)]/binsize;
% spikes = binnedData.spikeratedata;
% use principal components
PCcoeffs = princomp(binnedData.spikeratedata);
spikes = binnedData.spikeratedata*(PCcoeffs(1:75,:))'; % adjust number of PCs as needed

state = [pos vel acc ones(length(pos),1)];


[A, C, Q, R] = train_kf(state(delayBins+1:end,:), spikes(1:end-delayBins,:));

%% Test and plot predictions

if genPlots

    [pred_state, V, VV, loglik] = kalman_filter(spikes(1:end-delayBins,:)', A, C, Q, R, state(1,:)', zeros(size(state,2)));
%     [pred_state, V, VV, loglik] = kalman_filter(spikes(1:end-delayBins,:)', A, C, Q, R, zeros(size(state,2),1), zeros(size(state,2)));
    
    [xpr2 xpvaf xpmse] = getvaf(pos(delayBins+1:end,1),pred_state(1,:)');
    [ypr2 ypvaf ypmse] = getvaf(pos(delayBins+1:end,2),pred_state(2,:)');
    [xvr2 xvvaf xvmse] = getvaf(vel(delayBins+1:end,1),pred_state(3,:)');
    [yvr2 yvvaf yvmse] = getvaf(vel(delayBins+1:end,2),pred_state(4,:)');

    figure; plot(binsize:binsize:binsize*length(pred_state),vel(delayBins+1:end,1),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(3,:),'r')
    title(['x velocity prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(xvvaf)])
    xlabel('time (s)')
    ylabel('velocity (cm/s)')

    figure; plot(binsize:binsize:binsize*length(pred_state),vel(delayBins+1:end,2),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(4,:),'r')
    title(['y velocity prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(yvvaf)])
    xlabel('time (s)')
    ylabel('velocity (cm/s)')

    figure; plot(binsize:binsize:binsize*length(pred_state),pos(delayBins+1:end,1),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(1,:),'r')
    title(['x position prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(xpvaf)])
    xlabel('time (s)')
    ylabel('position (cm)')

    figure; plot(binsize:binsize:binsize*length(pred_state),pos(delayBins+1:end,2),'k'); hold on; plot(binsize:binsize:binsize*length(pred_state),pred_state(2,:),'r')
    title(['y position prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(ypvaf)])
    xlabel('time (s)')
    ylabel('position (cm)')

    figure; plot(pred_state(1,:),pred_state(2,:),'r');
    title(['KF position prediction, delay = ' num2str(delayBins) ' vaf = ' num2str(mean([xpvaf ypvaf]))])
    xlabel('x (cm)')
    ylabel('y (cm)')

end

disp(['file saved as ' pathstr '\' name '_KF.mat']);
save([pathstr '\' name '_KF.mat'],'A','C','Q','R','binsize','delayBins','neuronIDs','outnames','FromData');

end