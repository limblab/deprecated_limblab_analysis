function vel_heat_maps = vel_spikemap(binnedData)
% Creates a series of heat maps, each containing firing rates for a given
% unit spanning a specified bin (default: 50ms), showing firing rates for a
% range of binned x/y velocities.
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
%-pull out struct fields
binned_spikes = binnedData.spikeratedata;
chans = binnedData.spikeguide;
vel = binnedData.velocbin;
ts  = binnedData.timeframe;
%-animation parameters
mov_start = 0.5; %(seconds) time before kinematic timepoint at which the movie will start
mov_end   = 0.3; %(seconds) time after kinematic timepoint at which movie will end
bin_size  = ts(2)-ts(1); %(seconds) length of one bin
mov_pause = 0.3; %(seconds) determines framerate by pausing between each frame renewal
%-convert from seconds to bins
bin_start = round(mov_start/bin_size);
bin_end   = round(mov_end/bin_size);
num_bins  = bin_start + bin_end; %number of bins to run through
%-velocity binning parameters
vbin_size = 4; %(cm/s) velocity bin size
vmax = 40; %(cm/s) limit of range we'll bother to look at
vx = vel(:,1);
vy = vel(:,2);
%% Planned function structure
% *Bin velocity
% *Create cell array to hold array maps
%   -dim 1: unit
%   -dim 2: frame (stepping through 
%   -contents: matrix of size determined by 'vbin_size' and 'vmax' (currently
%   should be 20x20) with values to plot as heat maps

%% Bin velocity
% Copied directly from 'create_vel_spikemaps'

% Set values beyond 'vmax' to be equal to 'vmax'
%   -Initialize indexing arrays
pos_limX = zeros(size(vx));
neg_limX = zeros(size(vx));
pos_limY = zeros(size(vy));
neg_limY = zeros(size(vy));
%   -Find values outside of range
pos_limX(vx > vmax)  = vx(vx >  vmax);
neg_limX(vx < -vmax) = vx(vx < -vmax);
pos_limY(vy > vmax)  = vy(vy >  vmax);
neg_limY(vy < -vmax) = vy(vy < -vmax);
%   -Make logical
pos_limX = logical(pos_limX);
neg_limX = logical(neg_limX);
pos_limY = logical(pos_limY);
neg_limY = logical(neg_limY);
%   -Create arrays of the appropriate size to match out-of-bounds data
p_limX =  ones(size(find(pos_limX)))*vmax;
n_limX = -ones(size(find(neg_limX)))*vmax;
p_limY =  ones(size(find(pos_limY)))*vmax;
n_limY = -ones(size(find(neg_limY)))*vmax;
%   -Set out-of-bounds data equal to 'vmax'
vx(pos_limX) = p_limX;
vx(neg_limX) = n_limX;
vy(pos_limY) = p_limY;
vy(neg_limY) = n_limY;

% Quantize velocity
vx = vbin_size*round(vx/vbin_size);
vy = vbin_size*round(vy/vbin_size);
%   Account for offset that occurs if 'vmax' is not a multiple of 'bin_size'
%   ...For some reason this doesn't seem to be doing its job
offset = vmax - vbin_size*round(vmax/vbin_size);
vx = vx - offset;
vy = vy - offset;

%% Create velocity spike rate maps
%CHANGE THIS SO IT DOESN'T TAKE JUST MEAN OF ALL SPIKERATES ASSOCIATED WITH
%THAT VELOCITY, BUT GETS RATES FROM BINS WE WANT
num_units = size(binned_spikes,2);
num_vbins = floor( (2*vmax + 1)/vbin_size );

xidcs  = zeros(size(vx)); % arrays to store indices of relevant velocities
yidcs  = zeros(size(vy));
zz_vel = zeros(size(vx)); % assumes vx and vy are same size
disp('Calculating mean firing rates based on velocity for...');
for unit = 1:num_units
    
    if verbose
        disp(strcat([sprintf('...unit %i of %i: ',unit,num_units) chans(unit,:)]));
    end
    heat_map = zeros(num_vbins); % square matrix to store mean spike rates
    spikes   = binned_spikes(:,unit);
    
    % ugly nested loops, but let's do this
    % run through each velocity bin and find associated values
    for xx = 1:num_vbins
        
        xidcs = xidcs & zz_vel; % reset xidcs to zero
        X = (xx-1)*vbin_size - vmax; % convert to velocity bin
        if (X==0)
            xidcs(vx==X) = 1;
        else
            xidcs(vx==X) = vx(vx==X);
        end
        xidcs = logical(xidcs);
        for yy = 1:num_vbins
            
            yidcs = yidcs & zz_vel; % reset yidcs to zero
            Y = (yy-1)*vbin_size - vmax; % convert to velocity bin
            if (Y==0)
                yidcs(vy==Y) = 1;
            else
                yidcs(vy==Y) = vy(vy==Y);
            end
            yidcs = logical(yidcs);
            idcs = xidcs & yidcs;
            pre_idcs = get_binned_rate(spikes,bin,idcs);
            if ~isempty(find(pre_idcs,1))
                heat_map(xx,yy) = mean(spikes(pre_idcs));
            else % so we don't return NaN if no spikes are found
                heat_map(xx,yy) = 0;
                if E
                    disp(sprintf('idcs is empty. vx = %i, vy = %i.',X,Y));
                    E = 0;
                end
            end
            
        end
    end
    %CHANGE TO 2-D CELL ARRAY TO TAKE SERIES OF MAPS
    vel_heat_maps{unit} = heat_map;
    
end

%% Internal functions

function pre_idcs = get_binned_rate(binned_spikes,bin,idcs)
% Returns a set of indices corresponding to the appropriate bin relative to
% the given kinematic timepoint (defined by the velocity bin we're looking
% at)



%% 'pre_kin_windows' code

% function spike_struct = pre_kin_windows(binnedData)
% % Creates larger bins for spiking in windows preceding a kinematic
% % timepoint by 'win_lag' seconds
% 
% %-Initialize
% win_lag    = 0.25; % lag in sec (how far behind kinematics timepoint we will look at spiking activity)
% win_length = 0.15; % in sec
% states     = binnedData.states;
% spikerates = binnedData.spikeratedata;
% 
% bin_size   = binnedData.timeframe(2) - binnedData.timeframe(1);
% win_start  = round(win_lag/bin_size); % convert to bins
% win_bins   = round(win_length/bin_size); % convert to bins
% 
% binned_spikes = zeros(size(spikerates));
% %% To-Do
% % -interested also in width of distribution? (stddev/whatever)
% 
% 
% %% Count spikes in designated window for each channel
% 
% % CONVERT FREQUENCIES TO SPIKES PER BIN (was spikes/second)
% spikerates = spikerates*bin_size;
% 
% % SUM SPIKES INTO WINDOWS (i.e. BIGGER BINS)
% for x = win_start+1:length(binned_spikes)
%     init = x - win_start; % tmp variable for 'spikerates' sum start index
%     binned_spikes(x,:) = sum(spikerates(init:init+win_bins, :), 1);
% end
% 
% % CONVERT WINDOWED SPIKE COUNTS INTO Hz
% binned_spikes = binned_spikes/win_length;
% 
% %% compile spiking means for each channel
% 
% %MAYBE CALCULATE THIS ONLY IN 'plot_spike_windows'? OR WHERE? EITHER WAY,
% %IT HAS TO HAPPEN POST-PD-FILTERING
% spike_means = zeros(size(binned_spikes,2),2);
% for x=1:size(binned_spikes,2)
% 
%     mnM = mean(binned_spikes( states(:,1),x));
%     mnP = mean(binned_spikes(~states(:,1),x));
%     mnM = round(mnM);
%     mnP = round(mnP);
%     spike_means(x,:) = [ mnM mnP ]; %[ mean(movementState) mean(postureState) ]
% 
% end
% 
% spike_struct.states = states;
% spike_struct.spikeguide  = binnedData.spikeguide;
% spike_struct.spike_means = spike_means;
% spike_struct.binned_spikes  = round(binned_spikes);



