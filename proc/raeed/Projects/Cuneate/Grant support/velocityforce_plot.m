function velocityforce_plot(bdf)
%% generate velocity direction vs force direction plot for bdf (straight from calc_from_raw.m)
% DEPRECATED

% first add trial table
if(~isfield(bdf,'TT') || ~isfield(bdf,'TT_hdr'))
    [bdf.TT bdf.TT_hdr] = rw_trial_table(bdf);
end

% add unit firing rates
if ~isfield(bdf.units,'FR')
    for i = 1:length(bdf.units)
        [s,t] = bin_spikes(bdf,50,bdf.units(i).id(1),bdf.units(i).id(2));
        bdf.units(i).FR = [t' s'];
    end
end

clear i
clear s
clear t

% get around the holes in parse_for_tuning (hack)
% bdf.dfdt = bdf.force;
% bdf.dfdtdt = bdf.force;
bdf.meta.task = 'RW';

% get arm data for peak velocity
behaviors = parse_for_tuning(bdf,'continuous');

%% calculate curvature
x_dot = behaviors.armdata{2}.data(:,1);
y_dot = behaviors.armdata{2}.data(:,2);

x_dotdot = behaviors.armdata{3}.data(:,1);
y_dotdot = behaviors.armdata{3}.data(:,2);

curv = (x_dot.*y_dotdot-y_dot.*x_dotdot)./((x_dot.^2+y_dot.^2).^(3/2));
speed = (x_dot.^2+y_dot.^2).^(1/2);
% curv(speed<1e-2) = NaN;

% plot curvature over time
figure
plot(curv)
%%

vel = behaviors.armdata{2}.data;
force = behaviors.armdata{4}.data;

vel_dir = atan2(vel(:,2),vel(:,1));
force_dir = atan2(force(:,2),force(:,1));

plot(force_dir,vel_dir,'o')