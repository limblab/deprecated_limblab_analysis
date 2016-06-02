function binnedData = data_segment(binnedData,start, stop,time_or_bin)
%    returns a segment of the data in the form of a binnedData structure
%    between the provided start and stop times, which can be provided
%    either as a time in seconds or in bin number.
%    time_or_bin is a string, either 'time' or 'bin'

if strcmp(time_or_bin,'time')
    start = find(round(binnedData.timeframe*1000) >= round(start*1000),1);
    stop  = find(round(binnedData.timeframe*1000) <= round(stop *1000),1,'last');    
    if isempty(start) || isempty(stop)
        error('data_segment: time out of range');
    end
else
    if start> length(binnedData.timeframe) || stop >length(binnedData.timeframe)
        error('data_segment: bin index out of range');
    end
end

start_time = binnedData.timeframe(start);
stop_time  = binnedData.timeframe(stop);

%% Timeframe
    binnedData.timeframe = binnedData.timeframe(start:stop);
%% EMGs
    binnedData.emgdatabin = binnedData.emgdatabin(start:stop,:);
%% Spikes
    binnedData.spikeratedata = binnedData.spikeratedata(start:stop,:);
%% Force
    binnedData.forcedatabin = binnedData.forcedatabin(start:stop,:);
%% Pos
    binnedData.cursorposbin = binnedData.cursorposbin(start:stop,:);
%% Vel
    binnedData.velocbin = binnedData.velocbin(start:stop,:);
%% States
%% Trialtable
    binnedData.trialtable = binnedData.trialtable(binnedData.trialtable(:,1)<=stop_time & binnedData.trialtable(:,1)>=start_time,:);

%% Words
    binnedData.words = binnedData.words(binnedData.words(:,1)<=stop_time & binnedData.words(:,1)>=start_time,:);
%% Targets
   binnedData.targets.corners = binnedData.targets.corners(binnedData.targets.corners(:,1)<=stop_time & binnedData.targets(:,1).corners(:,1)>=start_time,:);
   binnedData.targets.rotation = binnedData.targets.rotation(binnedData.targets.rotation(:,1)<=stop_time & binnedData.targets(:,1).rotation(:,1)>=start_time,:);
%% Stim
end
