function [out, time] = co_bump_kin_pred(all_kin)


time_before = -1;
time_after = 1;
kin_length = (time_after-time_before)*1000; % lenth of the kinematics vector
time = (1:kin_length).*.001 + time_before;

t_class = -1:.05:1;
tid_class = [1 50:50:2000];

% First by bump
x = cell(1,4);
y = cell(1,4);

%for target = 1:4
%    for bump = 1:4
%        x{target} = [x{target}; all_kin{bump, target}.x];
%        y{target} = [y{target}; all_kin{bump, target}.y];
%    end
%end
out = zeros(5,length(tid_class));

for t_idx = 1:length(tid_class)
    % Classify points and evaluate pct. correct.
    t = tid_class(t_idx);

    all_points = [];
    for target = 1:4
        for bump = 1:4
            for reach = 1:size(all_kin{bump,target}.x,1)
                all_points = [all_points; target all_kin{bump,target}.x(reach,t) all_kin{bump,target}.y(reach,t) ...
                    all_kin{bump,target}.dx(reach,t) all_kin{bump,target}.dy(reach,t)];
            end
        end
    end

    for rep = 1:5
        r = rand(length(all_points), 1);

        train_set = all_points(r>.2, :);
        test_set = all_points(r<.2, :);

        train_points = train_set(:,2:5);
        train_class = train_set(:,1);
        test_points = test_set(:,2:5);
        test_class = test_set(:,1);

        pred_class = classify(test_points, train_points, train_class, 'linear');

        out(rep,t_idx) = sum(pred_class == test_class) / length(test_class);
    end

end

errorbar(t_class, mean(out), sqrt(var(out)), 'k-')



