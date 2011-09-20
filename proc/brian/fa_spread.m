% preload bdf and trial table;

% Arthur_S1_018.mat
% mini_bumps_005-6.mat
% tiki_rw_006.mat
% Tiki_S1_b_005.mat
% Pedro_S1_011

% Clear except bdf and tt
vars = whos;
for i = 1:length(vars)
    if (~strcmp(vars(i).name,'bdf') && ~strcmp(vars(i).name,'tt'))
        clear(vars(i).name);
    end
end
clear i vars

kernel_sigma = .05;%.035;
t = -.5:0.005:1;

ul = unit_list(bdf);

nTargets = max(tt(:,5)) + 1;
bumptrials = tt( tt(:,3) == double('H'), : );
reachtrials = tt( tt(:,2) == -1 & tt(:,10) == double('R'), : );
table = cell(1,nTargets);


onsets = [ reachtrials(:,7); bumptrials(:,4) ];
trial_types = [zeros(size(reachtrials,1),1); ones(size(bumptrials,1),1)];
trial_dirs = [reachtrials(:,5); bumptrials(:,2)];
ps = cell(length(ul), length(onsets));
    
for unitNumber = 1:length(ul)
    chan = ul(unitNumber, 1);
    unit = ul(unitNumber, 2);
    
    table = raster(get_unit(bdf, chan, unit), onsets, -1.5, 2, -1);
    
    for trial = 1:length(table)    
        ps{unitNumber, trial} = zeros(size(t));
        for spike = table{trial}'
            ps{unitNumber, trial} = ps{unitNumber, trial} + ...
                exp( - (t-spike).^2 / (2*kernel_sigma.^2) )./sqrt(2*pi*kernel_sigma^2);        
        end
    end
end

%%
baseline = zeros(1,length(ul));
for unitNumber = 1:length(ul)
    tmp = zeros(1,length(onsets));
    for trial = 1:length(onsets)
        tmp(trial) = ps{unitNumber,trial}(:,1);
    end
    baseline(unitNumber) = mean(tmp);
end

q = [];
for unitNumber = 1:length(ul)
    tmp = [];
    for trial = 1:length(onsets)
        if trial_types(trial)
            tmp = [tmp; ps{unitNumber,trial}(:,125)-baseline(unitNumber)];
        else 
            tmp = [tmp; ps{unitNumber,trial}(:,180)-baseline(unitNumber)];
        end
    end
    q = [q tmp];
end

lambda = factoran([q;q+0.1*randn(size(q))],4);

x = [];
y = [];
z = [];
zz = [];
for timeslice = 1:length(t)
    q = [];
    for unitNumber = 1:length(ul)
        tmp = [];
        for trial = 1:length(onsets)
            tmp = [tmp; ps{unitNumber,trial}(:,timeslice)-baseline(unitNumber)];
        end
        q = [q tmp];
    end

    proj = q * lambda;
    x = [x proj(:,1)];
    y = [y proj(:,2)];
    z = [z proj(:,3)];    
    zz = [zz proj(:,4)];
end

%% 3D Plots

types = trial_types*4 + trial_dirs + 1;
colors = [0 0 0; 1 0 0 ; 0 1 0; 0 0 1];
viewpoints = [288 -6; 172 -40; -85 42];

for plotid = 1:3
    figure; hold on;

    for curtype = 1:4
        f = types == curtype;
        plot3(x(f,180), y(f,180), zz(f,180), 'o', ...
            'MarkerEdgeColor', colors(curtype,:), ...
            'MarkerFaceColor', colors(curtype,:));
    end

    for curtype = 5:8
        f = types == curtype;
        plot3(x(f,116), y(f,116), zz(f,116), 'o', ...
            'MarkerEdgeColor', colors(curtype-4,:), ...
            'MarkerFaceColor', 'none');   
    end
    
    for trial = 1:length(trial_types)
        if trial_types(trial)
            stoppoint = 116;
        else 
            stoppoint = 180;
        end
        plot3(x(trial,71:stoppoint), y(trial,71:stoppoint), zz(trial,71:stoppoint), ...
            '-', 'Color', [.5 .5 .5]);    
    end

    xlabel('Factor 1');
    ylabel('Factor 2');
    zlabel('Factor 3');
    
    view(viewpoints(plotid,:));
end


%% Timecourse plot

x1 = [x(trial_types==1,116) y(trial_types==1,116) z(trial_types==1,116)];
x2 = [x(trial_types==0,180) y(trial_types==0,180) z(trial_types==0,180)];

mu1 = mean(x1);
mu2 = mean(x2);
si = inv(cov([x1;x2]));
%si = inv((cov(x1)+cov(x2))/2);

w = si*(mu1 - mu2)'; % multiply vectors by w to get v axis projection

v = zeros(size(x));
for trial = 1:length(trial_types)
    tmp = [x(trial,:)' y(trial,:)' z(trial,:)'];
    v(trial,:) = tmp * w;
end

bump_v = mean(v(trial_types==1,:));
bump_v_v = sqrt(var(v(trial_types==1,:)));
nbump = sum(trial_types==1);

reach_v = mean(v(trial_types==0,:));
reach_v_v = sqrt(var(v(trial_types==0,:)));
nreach = sum(trial_types==0);

figure;
shadedplot(t, bump_v-bump_v_v/sqrt(nbump), bump_v+bump_v_v/sqrt(nbump), [.5 .5 .5], [0 0 0]);
hold on;
plot(t, bump_v, 'k-');

shadedplot(t, reach_v-reach_v_v/sqrt(nreach), reach_v+reach_v_v/sqrt(nreach), [1 .5 .5], [1 0 0]);
hold on;
plot(t, reach_v, 'r-');

