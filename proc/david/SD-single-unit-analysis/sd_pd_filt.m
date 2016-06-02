function out_struct = sd_pd_filt(binnedData)
% Filters files by preferred direction for state-dependent analysis
% INPUT: 'binnedData' struct post-classifier
% OUTPUT: same structure as 'spike_window_histograms' but with movement in
% non-prefered directions filtered out
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
ts  = binnedData.timeframe;
pos = binnedData.cursorposbin;
vel = binnedData.velocbin;


%% Pre-filter processing
%-GET PD'S
disp('Calculating PDs...')
[pds, errs, moddepth] = glm_pds(binnedData);

%-CALC SPIKERATES FOR WINDOWS PRECEDING KINEMATICS
disp('Compiling windowed spiking data...');
spike_struct = pre_kin_windows(binnedData);

%-pull out struct fields
%states  = spike_struct.states;
%spikes1 = spike_struct.spike_wins1;
spikes = spike_struct.spike_wins;
%spikes3 = spike_struct.spike_wins3;

%% Discard non-PD-related movement

%   1) for each unit, compare preferred direction to veloc direction for
%   each bin
%   2)create logical array denoting when cursor is moving in PD of given
%   unit
%   3) ".*" logical array with that unit's column of 'spikes'
%   4) ...and that should be it!

%-CALC VELOCITY ANGLES
disp('Filtering spiking data by PD...');
vdir = cart2pol(vel(:,1),vel(:,2));

num_units = size(spikes,2);
thresh = pi/12; %range of angles to count as close enough to PD (i.e. THRESHold)
rates = zeros(size(spikes));
for unit = 1:num_units
    
    pd  =  pds(unit);
    err = errs(unit);
    if err < thresh/2
        pd_min = pd - thresh/2;
        pd_max = pd + thresh/2;
        
        % if movement is in a direction captured by the PD window...
        in_PD = in_window(pd_min, pd_max, vdir);
        % if movement is not in a direction captured by the PD window...
        no_PD = miss_window(pd_min, pd_max, vdir);
        % copy over appropriate spike rates...
        rates(in_PD,unit) = spikes(in_PD,unit);
        % set all non-PD-movement spiking values to -1
        rates(no_PD,unit) = rates(no_PD,unit) - 1;
    else
        str = strcat('unit ',binnedData.spikeguide(unit,:),' is out of bounds.');
        disp(str);
    end
end
disp('Done.');
out_struct = spike_struct;
out_struct.spikerates = rates;
%% Eventual output?
% spike_struct = 
% 
%          states: [24120x5 logical]
%      spikeguide: [94x6 char]
%     spike_means: [94x6 double]
%     spike_wins1: [24120x94 double]
%     spike_wins2: [24120x94 double]
%     spike_wins3: [24120x94 double]
%             pds: [94x1 double]
%            errs: [94x1 double]
%        moddepth: [94x1 double]
%

%% Internal functions

function in_PD = in_window(pd_min,pd_max,vdir)
% grab indices for spiking rates that occur while movement is along the PD
in_PD = zeros(length(vdir),1);
in_PD((vdir<=pd_max)&(vdir>=pd_min)) = in_PD((vdir<=pd_max)&(vdir>=pd_min))+1;

in_PD = logical(in_PD);



function no_PD = miss_window(pd_min,pd_max,vdir)
% grab indices for spiking rates that occur while movement is not along PD
no_PD = zeros(length(vdir),1);
no_PD((vdir>pd_max)|(vdir<pd_min)) = no_PD((vdir>pd_max)|(vdir<pd_min))+1;

no_PD = logical(no_PD);





