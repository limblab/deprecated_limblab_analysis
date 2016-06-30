%% bootstrap script
muscleplot = false;
%% First set up
base_leg = get_baseleg;

num_configs = 100;

rng('default')
neurons = random('Normal',0,1,10000,8);
% neurons = eye(8);

rng('shuffle')
hip_angles = rand(num_configs,1)*2*pi/3-pi/6;
knee_angles = rand(num_configs,1)*2*pi/3;
ankle_angles = rand(num_configs,1)*2*pi/3;

seg2joint_mat = [1 0 0;1 -1 0;0 -1 1]'; %assuming row vector of segment angle (postmultiply by matrix for xform)

leg_configs = [hip_angles knee_angles ankle_angles]/seg2joint_mat; %config is stored in segment angles

%% check what this looks like
% figure
% for i = 1:num_configs
%     draw_bones(base_leg,leg_configs(i,:));
%     hold on
% end

%% get muscle lengths and endpoints
muscle_lengths = zeros(num_configs,base_leg.num_muscles);
endpoint_positions = zeros(num_configs,2);
for i = 1:num_configs
    muscle_lengths(i,:) = get_musclelengths(base_leg,leg_configs(i,:));
    mp = get_legpts(base_leg,leg_configs(i,:));
    endpoint_positions(i,:) = mp(:,end)';
end

muscle_offset = min(muscle_lengths);
scaled_lengths = muscle_lengths - repmat(muscle_offset,num_configs,1);
muscle_scale = max(scaled_lengths);
scaled_lengths = scaled_lengths ./ repmat(muscle_scale,num_configs,1);

%% get neural activity
num_sec = 4;
activity = get_activity(neurons,scaled_lengths,num_sec);
% activity = neurons*scaled_lengths';

%% fit activity
zerod_ep = endpoint_positions - repmat(mean(endpoint_positions),num_configs,1);

[th,rad] = cart2pol(endpoint_positions(:,1),endpoint_positions(:,2));

cart_fit = cell(num_configs,1);
yc = [];

for i=1:length(neurons)
    act = activity(i,:)';
    
    cart_fit{i} = LinearModel.fit(zerod_ep,act);
    pol_fit{i} = LinearModel.fit([th rad],act);
    yc = [yc cart_fit{i}.Coefficients.Estimate];
end

ycpd = atan2(yc(3,:),yc(2,:));

%% plot stuff
if(muscleplot)
    moddepth = sqrt(yc(2,:).^2+yc(3,:).^2);
    
    figure
    h1 = polar(0,.05,'.');
    set(h1,'MarkerSize',0.1)
    colors = colormap;
    hold on
    for i = 1:length(neurons)
        handles(i) = polar([ycpd(i) ycpd(i)],[0 moddepth(i)]);
        h2 = polar(ycpd(i),moddepth(i),'o');
        
        set(handles(i),'Color',colors(8*i,:),'LineWidth',3)
        set(h2,'Color',colors(8*i,:),'LineWidth',3)

        hold on
    %     pause(.01)
    end
    % muscle order: BFA IP RF1 RF2 BFP VL MG SOL TA
    title 'Global pulling directions of muscles (Unc)'
    legend(handles,'BFA','IP','RF','BFP','VL','MG','SOL','TA')
else
    figure
    plot_PD_distr(ycpd,100);
end