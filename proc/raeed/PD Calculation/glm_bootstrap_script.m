%% setup
t = bdf.vel(1,1):50/1000:bdf.vel(end,1);

glmx = interp1(bdf.pos(:,1), bdf.pos(:,2:3), t);
glmv = interp1(bdf.vel(:,1), bdf.vel(:,2:3), t);
glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];

ul = unit_list(bdf,1);

reps = 100;
num_samp = 1000;

moddepth = zeros(reps,length(ul));
pds = zeros(reps,length(ul));

moddepth_full = zeros(length(ul),1);
mean_moddepth = moddepth_full;
pds_full = zeros(length(ul),1);
mean_pds = pds_full;
errs = zeros(length(ul),1);
moderrs = errs;

bs = zeros(size(glm_input,2)+1,length(ul));
s_save = zeros(length(ul),length(t));

%% run glm bootstrap
for j=1:length(ul)
    
    spike_times = get_unit(bdf,ul(j,1),ul(j,2));
    spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
    s = train2bins(spike_times, t);

    % bootstrap
    avg_b = [0 0];
    for i=1:reps
        % grab test set indices
        idx = uint32(1+(length(glmx)-1)*rand(num_samp,1));

        b = glmfit(glm_input(idx,:),s(idx),'poisson');
        moddepth(i,j) = norm([b(4) b(5)]);
        pds(i,j) = atan2(b(5),b(4));
        
        avg_b = avg_b+[b(4) b(5)]*1.0/reps;
    end

    mean_moddepth(j) = norm(avg_b);
    mean_pds(j) = atan2(avg_b(2),avg_b(1));
    
    [b, dev, stats] = glmfit(glm_input,s,'poisson');
    moddepth_full(j) = norm([b(4) b(5)]);
    pds_full(j) = atan2(b(5),b(4));
    
    covb = stats.covb(4:5,4:5);
    bv = b(4:5);
    
    %Jacobian of cartesian to polar
    J = [bv(1)/sqrt(bv(1)^2+bv(2)^2) bv(2)/sqrt(bv(1)^2+bv(2)^2);...
        -bv(2)/(bv(1)^2+bv(2)^2)     bv(1)/(bv(1)^2+bv(2)^2)];
    
    % propagation of covariance (first order approximation)
    cov_polar = J*covb*J';
    
    %errors given by glm
    errs(j) = sqrt(cov_polar(2,2));
    moderrs(j) = sqrt(cov_polar(1,1));
    
    bs(:,j) = b;
    s_save(j,:) = s;
    
end

%% Figure out standard errors
stddev_pd = std(pds);
std_pd_err = stddev_pd/sqrt(reps);

std_mod_err = std(moddepth)/sqrt(reps);

figure
plot(std_pd_err./errs', std_mod_err./moderrs','o')


%% plot data

figure

for plotnum = 1:25
    subplot(5,5,plotnum)
    polar(pi,1)
    hold on
    polar(pds(:,plotnum),moddepth(:,plotnum)/max(moddepth(:)),'b.')
    h1 = polar(pds_full(plotnum),moddepth_full(plotnum)/max(moddepth(:)),'rx');
    h2 = polar(mean_pds(plotnum),mean_moddepth(plotnum)/max(moddepth(:)),'go');
    set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
            '-or','String','150','-or','String','210','-or','String','240',...
            '-or','String','300','-or','String','330','-or','String','  0.2',...
            '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
            '-or','String','  0.1','-or','String','  1') ,'String', ' ');
    set(h1,'linewidth',5)
    
    title(['Chan' num2str(ul(plotnum,1))])
end

%% Check estimations
s_est = zeros(length(t),length(ul));
for j=1:length(ul)
    s_est(:,j) = glmval(bs(:,j),glm_input,'log');
end

s_est = s_est';

%% Throw out top and bottom 2.5 percent of samples for each channel (according to PD)

% Build vector of distances from mean for each channel
ang_dist = pds-mean_pds(:,ones(reps,1))';
ang_dist(ang_dist>pi) = ang_dist(ang_dist>pi)-2*pi;
ang_dist(ang_dist<-pi) = ang_dist(ang_dist<-pi)+2*pi;

% sort vectors along angle distance for each unit
[ang_dist_sort,ang_index] = sort(ang_dist,1);

% calculate index range for 2.5 to 97.5 percent
ang_ind_low = ceil(reps*0.025);
ang_ind_high = floor(reps*0.975);

% get indices of array to keep
ang_index_keep = ang_index(ang_ind_low:ang_ind_high,:);

% Calculate confidence bounds (vector, each element corresponds to a
% channel)
conf_low = (ang_dist_sort(ang_ind_low,:))' + mean_pds;
conf_high = (ang_dist_sort(ang_ind_high,:))' + mean_pds;

%% Plot PDs

figure(65432)
for iPD = 1:48
    subplot(6,8,iPD)
    r = 0.0001:0.0001:mean_moddepth(iPD)/max(mean_moddepth);
    angle = repmat(mean_pds(iPD),1,length(r));
    err_up = repmat(conf_high(iPD),1,length(r));
    err_down = repmat(conf_low(iPD),1,length(r));
    
    h0 = polar(pi,1); % place point at max length so all polar plots are scaled the same.
    hold on
    h2 = polar(err_up,r);
    h3 = polar(err_down,r);
    set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
        '-or','String','150','-or','String','210','-or','String','240',...
        '-or','String','300','-or','String','330','-or','String','  0.2',...
        '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
        '-or','String','  0.1','-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential
    h1 = polar(angle,r,'r');
    set(h1,'linewidth',2);
    
    [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
    [x2,y2]=pol2cart(err_up,r);
    [x3,y3]=pol2cart(err_down,r);

    %     jbfill(x1,y1,y2,'b','b',1,0.5);
    x_fill = [x2(end), x1(end), x3(end), 0];
    y_fill = [y2(end), y1(end), y3(end), 0];

    % fill(x_fill,y_fill,'r');
    patch(x_fill,y_fill,'b','facealpha',0.3);
end

figure(654321)
for iPD = 49:96
    subplot(6,8,iPD-48)
    r = 0.0001:0.0001:mean_moddepth(iPD)/max(mean_moddepth);
    angle = repmat(mean_pds(iPD),1,length(r));
    err_up = repmat(conf_high(iPD),1,length(r));
    err_down = repmat(conf_low(iPD),1,length(r));
    
    h0 = polar(pi,1); % place point at max length so all polar plots are scaled the same.
    hold on
    h2 = polar(err_up,r);
    h3 = polar(err_down,r);
    set(findall(gcf, 'String', '30', '-or','String','60','-or','String','120',...
        '-or','String','150','-or','String','210','-or','String','240',...
        '-or','String','300','-or','String','330','-or','String','  0.2',...
        '-or','String','  0.1','-or','String','  0.5','-or','String','  0.25',...
        '-or','String','  0.1','-or','String','  1') ,'String', ' '); % remove a bunch of labels from the polar plot; radial and tangential
    h1 = polar(angle,r,'r');
    set(h1,'linewidth',2);
    
    [x1,y1]=pol2cart(angle,r); % needed to fill up the space between the two CI
    [x2,y2]=pol2cart(err_up,r);
    [x3,y3]=pol2cart(err_down,r);

    %     jbfill(x1,y1,y2,'b','b',1,0.5);
    x_fill = [x2(end), x1(end), x3(end), 0];
    y_fill = [y2(end), y1(end), y3(end), 0];

    % fill(x_fill,y_fill,'r');
    patch(x_fill,y_fill,'b','facealpha',0.3);
end
