function plot_vel_map(vel_map,spikeguide,units)
% Plots output from 'create_vel_spikemaps' (plots unit no. 'unit')
% 'unit' can be a single number or a 1-D array listing which unit numbers
% to plot

for i = 1:length(units)
    
    figure
    surf(vel_map{units(i)});
    title(spikeguide(units(i),:));
    xlabel('x-velocity');
    ylabel('y-velocity');
    
end