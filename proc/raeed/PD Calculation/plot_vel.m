%% plot velocity vectors
t = bdf.vel(1,1):50/1000:bdf.vel(end,1);

vel = interp1(bdf.vel(:,1),bdf.vel(:,[2 3]),t);


vel_mag = vel(:,1).^2+vel(:,2).^2;
vel_dir = atan2(vel(:,2),vel(:,1));

figure
subplot(2,1,1)
hist(vel_mag,100)
subplot(2,1,2)
rose(vel_dir,100)

%%

ul = unit_list(bdf,1);

for j = 43
    spike_times = get_unit(bdf,ul(j,1),ul(j,2));
    spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
    s = train2bins(spike_times, t);

    % tuning curve
    mat = [vel_dir s'];
    mat = sortrows(mat);

    mat(:,1) = 0.08*floor(mat(:,1)/0.08);

    [vel_dir_unique,idx,idx_back] = unique(mat(:,1));
    s_proc = mat(:,2);
    s_mean = zeros(size(vel_dir_unique));

    for i = 1:idx_back(end)
        s_mean(i) = mean(s_proc(idx_back==i));
    end
    
    % GLM for this channel
    glmx = interp1(bdf.pos(:,1), bdf.pos(:,2:3), t);
    glmv = interp1(bdf.vel(:,1), bdf.vel(:,2:3), t);
    glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
    
    [b, dev, stats] = glmfit(glm_input, s, 'poisson');
    bv = [b(4) b(5)];
    moddepth = norm(bv,2);
    pds = atan2(bv(2), bv(1));
    
    figure
    polar(pds,moddepth,'o')

    figure
    subplot(2,1,1)
    polar(vel_dir_unique,s_mean)
    subplot(2,1,2)
    plot(vel_dir_unique,s_mean)
end

%% test bootstrapped glm
result = bootstrap(glm_func,[s glminput],10