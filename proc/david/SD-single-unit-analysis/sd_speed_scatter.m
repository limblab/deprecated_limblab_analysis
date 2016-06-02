function [scatter_cell, pds] = sd_speed_scatter(binnedData)
% Creates a cell array where each cell represents a unit, storing firing
% rate data for movements in the PD
%
% binnedData = 
% 
%           timeframe: [24120x1 single]
%                meta: [1x1 struct]
%            emgguide: []
%          emgdatabin: []
%         forcelabels: []
%        forcedatabin: []
%          spikeguide: [94x6 char]
%       spikeratedata: [24120x94 single]
%     cursorposlabels: [2x12 char]
%        cursorposbin: [24120x2 single]
%            velocbin: [24120x3 single]
%         veloclabels: [3x12 char]
%               words: [1683x2 double]
%             targets: [1x1 struct]
%          trialtable: []
%                stim: []
%               stimT: []
%              states: [24120x5 logical]
%        statemethods: [5x14 char]
%         classifiers: {[8]  []  []  {1x2 cell}  {1x2 cell}}
%

%% Initialize
%-Initialize
sg  = binnedData.spikeguide;
vel = binnedData.velocbin;
vx = vel(:,1);
vy = vel(:,2);
speed = vel(:,3);


%% Pre-filter processing
%-GET PD'S
disp('Calculating PDs...')
[pds, errs, moddepth] = SD_glm_pds(binnedData); %#ok<NASGU>

%-CALC SPIKERATES FOR WINDOWS PRECEDING KINEMATICS
disp('Compiling windowed spiking data...');
spike_struct = pre_kin_windows(binnedData);

%-pull out struct fields
spikes = spike_struct.spike_wins;

%% Discard non-PD-related movement

%   1) for each unit, compare preferred direction to veloc direction for
%   each bin
%   2)create logical array denoting when cursor is moving in PD of given
%   unit
%   3) use logical array to gather that unit's column of 'spikes'
%   4) ...and that should be it!

%-GET VELOCITY ANGLES
disp('Filtering spiking data by PD...');
vdir = cart2pol(vx,vy); % returns only theta, not rho

num_units = size(spikes,2);
thresh = pi/12; %range of angles to count as close enough to PD (i.e. THRESHold)
scatter_cell = cell(num_units,1);
for unit = 1:num_units
    
    pd  =  pds(unit);
    err = errs(unit);
    if err < thresh/2
        pd_min = pd - thresh/2;
        pd_max = pd + thresh/2;
        
        % if movement is in a direction captured by the PD window...
        in_PD = in_window(pd_min, pd_max, vdir);
        % create matrix for this unit
        unit_cell = [ speed(in_PD) spikes(in_PD,unit) ]; % cursor speed, firing rate for movements in PD
        binned_cell = bin_velocity(unit_cell);
        scatter_cell{unit} = binned_cell;
    else
        str = strcat(['unit ' sg(unit,:) ' is out of bounds.']);
        disp(str);
    end
end

% condense out_cell to remove empty cells
scatter_cell = condense_cell(scatter_cell);
disp('Done.');
% out_struct = spike_struct;
% out_struct.spikerates = rates;
%

%% Internal functions

function binned_cell = bin_velocity(unit_cell)
% unit_cell = [ speed(in_PD) spikes(in_PD,unit) ]
% Outputs 'unit_cell' but with binned, averaged speeds
% That is: mean firing rate for 0 cm/s, mean firing rate for 1 cm/s, mean
% firing rate for 2 cm/s, etc...
%
%-Initialize
speed  = unit_cell(:,1);
spikes = unit_cell(:,2);
%-binning parameters... probably have to be careful about these to make
%sure bins are proper multiples of the step sizes
bin1 = 10;
bin2 = 20;
bin3 = 50;
step1 = 1;
step2 = 2;
step3 = 5;

%-Set up speeds at which we want to bin
bins = [ 0:step1:bin1  bin1+step2:step2:bin2  bin2+step3:step3:bin3 ]';
spike_means = zeros(size(bins));
zout = zeros(size(speed));
curr_bin = zeros(size(speed));
%-Bin speeds
for i = 1:length(bins)
    
    % set size to which we are binning (dependent upon where we are in the
    % range)
    if     (bins(i)<=bin1)
        bin_size = step1;
    elseif (bins(i)<=bin2)
        bin_size = step2;
    elseif (bins(i)<=bin3)
        bin_size = step3;
    end
    
    % set range of speeds of current bin
    min_speed = bins(i) - bin_size/2;
    max_speed = bins(i) + bin_size/2;
    % get spike rates for speeds that fall within the current bin
    curr_bin((speed>=min_speed)&(speed<max_speed)) = spikes((speed>=min_speed)&(speed<max_speed));
    curr_bin = logical(curr_bin);
    spike_means(i) = mean(spikes(curr_bin));

    %reset curr_bin to zero
    curr_bin = curr_bin & zout;
    
end
% bins = speed bins, spike_means = mean spike rate for given speed bin
binned_cell = [ bins spike_means ];




function in_PD = in_window(pd_min,pd_max,vdir)
% grab indices for spiking rates that occur while movement is along the PD
in_PD = zeros(length(vdir),1);
in_PD((vdir<=pd_max)&(vdir>=pd_min)) = in_PD((vdir<=pd_max)&(vdir>=pd_min))+1;

in_PD = logical(in_PD);


function out_cell = condense_cell(in_cell)

% get appropriate size
filled = 0;
for i = 1:size(in_cell,1)
    if ~isempty(in_cell{i})
        filled = filled + 1;
    end
end

count = 0;
out_cell = cell(filled,2);
% populate out_cell
for i = 1:size(in_cell,1)
    if ~isempty(in_cell{i})
        count = count + 1;
        out_cell{count,1} = in_cell{i};
        out_cell{count,2} = i; % record which unit is being recorded
    end
end


