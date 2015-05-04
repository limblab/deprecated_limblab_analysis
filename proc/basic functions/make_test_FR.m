function fake_behaviors = make_test_FR(behaviors)
%returns a behaviors structure with made up firing rates

% strip firing rates from behaviors
fake_behaviors = behaviors;
fake_behaviors.FR = [];

% set up PDs
PD_gen = linspace(-pi,pi,100);

% find velocities and directions
armdata = behaviors.armdata;
vel = armdata(strcmp('vel',{armdata.name}).data;
dir = atan2(vel(:,2),vel(:,1));

% generate FR
for i=1:length(PD_gen)
    avg_FR = 
end