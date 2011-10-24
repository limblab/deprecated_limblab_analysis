%function co_power_plot(bdf, tt)

vars = whos;
for i = 1:length(vars)
    if (~strcmp(vars(i).name,'bdf') && ~strcmp(vars(i).name,'tt'))
        clear(vars(i).name);
    end
end
clear i vars

% initial setup
nTargets = max(tt(:,5)) + 1;
v = bdf.vel(:,[2 3]);
f = [bdf.force(:,2)-mean(bdf.force(:,2)) bdf.force(:,3)-mean(bdf.force(:,3))];

%for dir = 1:nTargets
    %bumptrials = tt( tt(:,3) == double('H') & tt(:,2)==dir-1, 4 );
    %reachtrials = tt( tt(:,2) == -1 & tt(:,10) == double('R') & tt(:,5)==dir-1, 8 );
    bumptrials = tt( tt(:,3) == double('H'), 4 );
    reachtrials = tt( tt(:,2) == -1 & tt(:,10) == double('R'), 8 );

    % check for force in the bdf
    if ~isfield(bdf, 'force')
        error('No force data in bdf');
    end

    t = bdf.force(:,1);

    bump_power = zeros(length(bumptrials), 2501);
    for trial = 1:length(bumptrials)
        start = find(t > bumptrials(trial)-1, 1, 'first');
        stop  = find(t > bumptrials(trial)+1.5  , 1, 'first');

        bump_power(trial,:) = sum(f(start:stop,:)' .* v(start:stop,:)') / 100;
    end

    reach_power = zeros(length(reachtrials), 2501);
    for trial = 1:length(reachtrials)
        start = find(t > reachtrials(trial)-1, 1, 'first');
        stop  = find(t > reachtrials(trial)+1.5  , 1, 'first');

        reach_power(trial,:) = sum(f(start:stop,:)' .* v(start:stop,:)') / 100;    
    end

    t = -1:.001:1.5;
    figure; hold on;
    plot(t, mean(reach_power), 'k-');
    plot(t, mean(bump_power), 'r-');
    %title(dir);
    %figure;
    %shadedplot(t, mean(reach_power)-sqrt(var(reach_power)), ...
    %    mean(reach_power)+sqrt(var(reach_power)), [.5 .5 .5], [0 0 0]);
    %figure;
    %shadedplot(t, mean(bump_power)-sqrt(var(bump_power)), ...
    %    mean(bump_power)+sqrt(var(bump_power)), [1 .5 .5], [1 0 0]);
%end 


