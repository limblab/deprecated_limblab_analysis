function [figure_handles, output_data]=get_tuning_curves(folder,options)
% GET_TUNING_CURVES

% if behaviors is in options, use it
if(~isfield(options,'behaviors'))
    error('behaviors not in options; haven''t yet implemented parsing in function')
else
    behaviors = options.behaviors;
end

% find velocities and directions
armdata = behaviors.armdata;
vel = armdata([armdata.name=='vel']).data;
dir = atan2(vel(:,2),vel(:,1));

% bin directions
dir_bins = round(dir/(pi/4))*(pi/4);

% average firing rates for directions
bins = -135:45:180;
for i = 1:length(bins)
    binned_FR(i,:) = sum(behaviors.FR(dir_bins==bins(i),:));
end

% plot first  40 neurons
for i=1:length(behaviors.FR)
end