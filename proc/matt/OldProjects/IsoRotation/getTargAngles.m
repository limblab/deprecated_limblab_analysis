function thetaTarg = getTargAngles(trialTable,type, force, angSize)

% type can be 'table' or 'move'
if nargin < 2
    type = 'table';
end

if strcmpi(type,'table')
% Get target data
% Get the target centers for each trial
targIDs = trialTable( :, 10);

targetCenters = [(trialTable(:,4)+trialTable(:,2))/2 (trialTable(:,5)+trialTable(:,3))/2];
% map targids to target centers
targIDList = sort(unique(targIDs));
targMap = zeros(length(targIDList),4);
% Get angles and positions to the target centers
for i = 1:length(targIDList)
    target = targetCenters(find(targIDs==targIDList(i),1),:);
    targMap(i,:) = [atan2(target(2),target(1)) targIDList(i) target(1) target(2)];
end

% get directions for each trial to use for Target PDs
thetaTarg = targMap(targIDs,1); % Get angles at each trial's target ID

else
   
        
    % Get the starting times of each trial and make a matrix of time
    % intervals for each trial
    ints = [trialTable(:,7), trialTable(:,8)];

    % Calculate movement direction in time window
    thetaTarg = getMoveAngles(force, ints, angSize);
    
end

thetaTarg = wrapAngle(thetaTarg,0); % make sure it goes from [-pi,pi)