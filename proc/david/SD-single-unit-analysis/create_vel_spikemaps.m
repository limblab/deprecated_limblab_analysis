function [spike_struct, vel_maps] = create_vel_spikemaps(binnedData,bin_size)
% Creates a heat plot with binned x- and y-velocities on the x- and y-axes
% with mean binned firing rate for the z-axis/color using classified,
% binned data as the input for state-dependent kinematics decoding.
%
% NOTE: If 'bin_size' argument and 'vmax' constant (below) are changed,
% 'axis' property of vel heat map should be changed in 'plot_states.m'
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

%ts = binnedData.timeframe;
 vel = binnedData.velocbin(:,1:2);
%spd = binnedData.velocbin(:,3);
 chans = binnedData.spikeguide;
%spike_bins = binnedData.spikeratedata;

% Cell array to store heat map values for each unit
vel_maps = cell(size(chans,1),1);

%% Divide into spiking windows (larger bins preceding kinematic timepoint)
% spike_struct = 
% 
%          states: [24120x5 logical]
%      spikeguide: [94x6 char]
%     spike_means: [94x2 double]
%      spike_wins: [24120x94 double]

spike_struct = pre_kin_windows(binnedData);
spike_wins = spike_struct.spike_wins;

%% "Bin" velocity 
% Quantize velocity, effectively to smooth the heat map.

vx   = vel(:,1);
vy   = vel(:,2);
vmax = 40; % cm/s extreme value (based on one of Chewie's files: never beyond +/- 55cm/s)
%bin_size = 1; %cm/s

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
vx = bin_size*round(vx/bin_size);
vy = bin_size*round(vy/bin_size);
%   Account for offset that occurs if 'vmax' is not a multiple of 'bin_size'
%   For some reason this doesn't seem to be doing its job
offset = vmax - bin_size*round(vmax/bin_size);
vx = vx - offset;
vy = vy - offset;

%% Create mean spike rate values for each unit

E = 1;
verbose = 1;
num_units = size(spike_wins,2);
num_bins  = floor( (2*vmax + 1)/bin_size );
xidcs  = zeros(size(vx)); % arrays to store indices of relevant velocities
yidcs  = zeros(size(vy));
zz_vel = zeros(size(vx)); % assumes vx and vy are same size
disp('Calculating mean firing rates based on velocity for...');
for unit = 1:num_units
    
    if verbose
        disp(strcat([sprintf('...unit %i of %i: ',unit,num_units) chans(unit,:)]));
    end
    heat_map = zeros(num_bins); % square matrix to store mean spike rates
    spikes   = spike_wins(:,unit);
    
    % ugly nested loops, but let's do this
    for xx = 1:num_bins
        
        xidcs = xidcs & zz_vel; % reset xidcs to zero
        X = (xx-1)*bin_size - vmax; % convert to velocity bin
        if (X==0)
            xidcs(vx==X) = 1;
        else
            xidcs(vx==X) = vx(vx==X);
        end
        xidcs = logical(xidcs);
        for yy = 1:num_bins
            
            yidcs = yidcs & zz_vel; % reset yidcs to zero
            Y = (yy-1)*bin_size - vmax; % convert to velocity bin
            if (Y==0)
                yidcs(vy==Y) = 1;
            else
                yidcs(vy==Y) = vy(vy==Y);
            end
            yidcs = logical(yidcs);
            idcs = xidcs & yidcs;
            if ~isempty(find(idcs,1))
                heat_map(xx,yy) = mean(spikes(idcs));
            else % so we don't return NaN if no spikes are found
                heat_map(xx,yy) = 0;
                if E
                    disp(sprintf('idcs is empty. vx = %i, vy = %i.',X,Y));
                    E = 0;
                end
            end
            
        end
    end
    
    vel_maps{unit} = heat_map;
    
end






