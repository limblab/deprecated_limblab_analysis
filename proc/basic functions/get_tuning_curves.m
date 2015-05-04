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
vel = armdata(strcmp('vel',{armdata.name}).data;
dir = atan2(vel(:,2),vel(:,1));

% bin directions
dir_bins = round(dir/(pi/4))*(pi/4);

% average firing rates for directions
bins = -3*pi/4:pi/4:pi;
for i = 1:length(bins)
    binned_FR(i,:) = sum(behaviors.FR(dir_bins==bins(i),:))/sum(dir_bins==bins(i));
end

% plot tuning curves
figure_handles = zeros(size(binned_FR,2),1);
for i=1%:length(figure_handles)
    figure_handles(i) = figure('name',['Tuning Plot for Neuron ' num2str(i)]);
    
    polar(bins,binned_FR(:,i))
end

output_data.binned_FR = binned_FR;