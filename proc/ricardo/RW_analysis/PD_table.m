function table = PD_table(bdf,offset)

    x_offset = -bytes2float(bdf.databursts{1,2}(7:10));
    y_offset = -bytes2float(bdf.databursts{1,2}(11:14));
    workspace_size = 15;
    min_speed = 0;
    max_speed = 10;
    idX = find(bdf.pos(:,2)>x_offset-workspace_size/2 & bdf.pos(:,2)<x_offset+workspace_size/2);
    idY = find(bdf.pos(:,3)>y_offset-workspace_size/2 & bdf.pos(:,3)<y_offset+workspace_size/2);
    spd = sqrt(bdf.vel(:,2).^2+bdf.vel(:,3).^2);
    idVel = find(spd<max_speed & spd>min_speed);
    in_workspace = intersect(idX,idY);
    in_workspace = intersect(in_workspace,idVel);
    
    th = 1:360;
    th = th*2*pi/360;
    vel_test = [10.*cos(th') 10.*sin(th')];
    speed = sqrt(vel_test(:,1).^2 + vel_test(:,2).^2);
    pos_test = zeros(length(vel_test),2);
    force_test = zeros(length(vel_test),2);
    test_params = [pos_test vel_test speed force_test];
            
    vel = bdf.vel;
    pos = bdf.pos;
    force = bdf.force;
    
    vel = vel(in_workspace,:);
    pos = pos(in_workspace,:);
    force = force(in_workspace,:);
    force(:,2) = force(:,2)-mean(force(:,2));
    force(:,3) = force(:,3)-mean(force(:,3));
    ts = 200; % new sampling frequency (Hz)
    vt = vel(:,1);
    t = vt(floor(vt*ts)==vt*ts);
    dt = diff(t);

    glmv = vel(floor(vt*ts)==vt*ts,2:3);
    glmx = pos(floor(vt*ts)==vt*ts,2:3);
    glmf = force(floor(vt*ts)==vt*ts,2:3);
    glmf(:,1) = glmf(:,1)-mean(glmf(:,1));
    glmf(:,2) = glmf(:,2)-mean(glmf(:,2));

    ul = unit_list(bdf);
    ul = ul(ul(:,2)~=255,:);
    
    ul = ul(ul(:,2)~=0,:);
    ul = double(ul);    

    num_pds = size(ul,1);
    pds = zeros(num_pds,1);
    dm_theta = zeros(num_pds,1);
    speed_comp = zeros(num_pds,1);
    confidence = zeros(num_pds,1);
    task_modulation = zeros(num_pds,1);
    num_spikes = zeros(num_pds,1);
    pds_f = zeros(num_pds,1);
    conf_f = zeros(num_pds,1);

    tic;
    for i = 1:num_pds       
        spike_times = get_unit(bdf,ul(i,1),ul(i,2));
        spike_times = spike_times(spike_times>t(1) & spike_times<t(end))-offset;
        s = train2bins(spike_times, t);
        s(find((dt>1/ts))+1) = 0;

        glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2) glmf];       
        [b, ~, stats] = glmfit(glm_input, s, 'poisson');
        db = stats.se;
        bv = [b(4); b(5)];
        dbv = [db(4); db(5)];
        pd = atan2(bv(2),bv(1));
        pds(i) = pd;
        
        bf = [b(7); b(8)];        
        dbf = [db(7); db(8)];        
        pd_f = atan2(bf(2),bf(1));
        pds_f(i) = pd_f;

        J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
        seTheta = dbv'*J;
        stdTheta = 1.96*seTheta; % 95% confidence  
        confidence(i) = abs(stdTheta);  
        
        J_f = [-bf(2)/(bf(1)^2+bf(2)^2); bf(1)/(bf(1)^2+bf(2)^2)];
        seTheta = dbf'*J_f;
        stdTheta = 1.96*seTheta; % 95% confidence  
        conf_f(i) = abs(stdTheta);  

        fr_10 = glmval(b, test_params, 'log');
        fr_0 = glmval(b, zeros(1,size(test_params,2)), 'log');
        speed_comp(i) = mean(fr_10)-fr_0;
        if abs(max(fr_10)-fr_0) > abs(min(fr_10)-fr_0)
            task_modulation(i) = max(fr_10)-fr_0;
        else
            task_modulation(i) = min(fr_10)-fr_0;
        end
        dm_theta(i) = max(fr_10)-min(fr_10);  
        num_spikes(i) = length(spike_times);
    end
    pds(pds<0)=pds(pds<0)+2*pi;
    pds_f(pds_f<0)=pds_f(pds_f<0)+2*pi;
    table = [ul pds confidence task_modulation dm_theta speed_comp num_spikes pds_f conf_f];
end
