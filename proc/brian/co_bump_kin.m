function all_kin = co_bump_kin(bdf)
% The output of this can be fed into co_bump_kin_pred

% Constants
time_before = -1;
time_after = 1;
kin_length = (time_after-time_before)*1000; % lenth of the kinematics vector
time = (1:kin_length).*.001 + time_before;

% Get the delay-bump trials that were successfully completed.
tt = co_trial_table(bdf);
dbtrials = tt( tt(:,3) == double('D') & tt(:,10) == double('R'), :);

%target = 2;
%bump = 1;

colors = {'r-','g-','k-','b-'};
all_kin = cell(4,4);

for bump = 1:4
    figure; hold on;
    for target = 1:4
        % Find the velocities for this target and bump direction
        go_times = dbtrials(dbtrials(:,2)==bump-1 & dbtrials(:,5)==target-1, 7);
        x = zeros(length(go_times), kin_length);
        y = zeros(length(go_times), kin_length);

        for i = 1:length(go_times)
            start = find(bdf.vel(:,1) < go_times(i)+time_before, 1, 'last');
            stop = start + kin_length - 1;
            try 
                x(i,:) = bdf.pos(start:stop, 2);
                y(i,:) = bdf.pos(start:stop, 3);
                dx(i,:) = bdf.vel(start:stop, 2);
                dy(i,:) = bdf.vel(start:stop, 3);
            catch
                warning('bdf:incomplete_trial','one of trials may have overrun the data file')
            end
            subplot(2,1,1), hold on, plot(time,x(i,:),colors{target});
            subplot(2,1,2), hold on, plot(time,y(i,:),colors{target});
        end
        all_kin{bump,target} = struct('x',x,'y',y,'dx',dx,'dy',dy);
    end % target
    suptitle(sprintf('bump = %d',bump));
end %bump

    

