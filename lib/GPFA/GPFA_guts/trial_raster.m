function[trial_raster,dat] = trial_raster(units,trial_table,t1_pm,t2_pm)
% [trial_raster,dat] = trial_raster(units,trial_table,t1_pm,t2_pm) is a
% function that creates a raster (trial_raster) in cell array form. In
% addition, the second output 'dat' is a struct containing trial number 
% and spike information for use with the GPFA library from Byron Yu
% (users.ece.cmu.edu/~byronyu/software.shtml)
% INPUTS
%   units: This is a cell array in which each cell contains the spike times
%          for a single neuron
%   trial_table: Trial table, in which at least one column contains
%          timestamps of an event on which you want to align the raster
%   t1_pm: this is a vector with size 1x2. First element is the column for
%          which you want to align the start of the raster. The second
%          element is an offset (in milliseconds) from that column.
%              example: t1_pm = [5 200] means start the raster 200 
%                       milliseconds after the time in column 5. 
%   t2_pm: Same as t2_pm but for the raster end time. 
%   
%   NOTE: the raster for each trial does NOT need to be of constant length.
%         (i.e. trial_table(i,t2_pm(1)) - trial_table(i,t1_pm(1)) can be
%         different for every trial i)
%   

align1 = t1_pm(1); pm1 = t1_pm(2); % Break out the aligment values for clarity
align2 = t2_pm(1); pm2 = t2_pm(2);

% Create a cell array in which each cell contains information from one trial
trial_raster = cell(size(trial_table,1),1); 
dat = struct;

% Loop through trials
for i = 1:size(trial_table,1);
    
    t1 = trial_table(i,align1)+(pm1./1000); %start time
    t2 = trial_table(i,align2)+(pm2./1000); %end time
    
    % Initialize raster (NxT) where N is number of neurons and T is time
    raster = zeros(length(units),round(1000*(t2-t1))); 

    for neur = 1:length(units)
        % Align spikes to start and get rid of those not in region
        aligned_ts = round(1000*(units{neur}(2:end) - t1));
        aligned_ts(aligned_ts<=0 | aligned_ts>=((t2-t1)*1000)) = [];

        % Fill out rasters
        raster(neur,aligned_ts) = 1;
    end

    trial_raster{i} = raster; 
    
    dat(i).trialId = i;
    dat(i).spikes = raster;
    
    clc; fprintf('trial: %d/%d\n',i,size(trial_table,1));
end
clc; fprintf('Done\n'); 

