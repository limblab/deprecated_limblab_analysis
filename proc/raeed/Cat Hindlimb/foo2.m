% foo2

global activity_unc;
global activity_con;
global cosdtheta asg rsg;

% First, set up our neurons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rand('state', 692006);
randn('state', 692006);
neurons = random('Normal', 0, 1, 100, 5);

%Test whether biarticular muscles are important (ablate inputs from
%biarticulars)
% neurons(:,[2,4])=0;

%%%%%%
% Get endpoint positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mtp = mp(:,17);

[a,r]=cart2pol(mtp(1), mtp(2));

% get polar points
rs = [-2 -1 0 1 2] + r;
%rs = r;
as = pi/16 * [-2 -1 0 1 2] + a;
%as = a;

[rsg, asg] = meshgrid(rs, as);
polpoints = [reshape(rsg,[1,25]); reshape(asg,[1,25])];

[x, y] = pol2cart(polpoints(2,:), polpoints(1,:));
endpoint_positions = [x;y];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, find angles coresponding to each endpoint position in normal case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
options = optimset('MaxFunEvals', 5000);
x0 = base_angles;

muscle_lengths = [];
joint_angles = [];

for i = 1:length(endpoint_positions)
    my_ep = endpoint_positions(:,i);
    [angles,val,flag] = fminsearch(@mycost, x0, options);
    joint_angles = [joint_angles; angles];
    get_mp;
    
    % These were commented out
    draw_bones;
    plot(my_ep(1), my_ep(2), 'ro');
    
    get_lengths;
    muscle_lengths = [muscle_lengths; lengths];
end
axis square
axis([-10 15 -20 5])
title 'Unconstrained'

scaled_lengths = muscle_lengths - repmat(min(muscle_lengths),25,1);
scaled_lengths = scaled_lengths ./ repmat(max(scaled_lengths),25,1);

activity_unc = neurons*scaled_lengths';

joint_angles_unc = joint_angles;







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, find angles coresponding to each endpoint position in constrained case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options = optimset('MaxFunEvals', 5000);
%x0 = [pi/4 pi/4];
x0 = base_angles;

muscle_lengths = [];
joint_angles = [];

figure;
for i = 1:length(endpoint_positions)
    my_ep = endpoint_positions(:,i);
    [x,val,flag] = fminsearch(@mycostcon, x0, options);
    angles = x; % [x(1) x(2) x(2)+pi/2];
    joint_angles = [joint_angles; angles];
    get_mp;
    
    % These were commented out
    draw_bones;
    if (flag == 1)
        plot(my_ep(1), my_ep(2), 'ro');
    else
        plot(my_ep(1), my_ep(2), 'bo');
    end
    
    get_lengths;
    muscle_lengths = [muscle_lengths; lengths];
end
axis square
axis([-10 15 -20 5])
title 'Constrained'

joint_angles_con = joint_angles;

scaled_lengths = muscle_lengths - repmat(min(muscle_lengths),25,1);
scaled_lengths = scaled_lengths ./ repmat(max(scaled_lengths),25,1);

activity_con = neurons*scaled_lengths';


%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate change in mean firing rates
%%%%%%%%%%%%%%%%%%%%%%%%%

%[r,p] = 
cc = [];
uu = [];

yc = [];
yu = [];

residuals_con = [];
residuals_unc = [];

VAF_con = [];
VAF_unc = [];

zerod_ep = endpoint_positions' - repmat(mean(endpoint_positions'),length(endpoint_positions'),1);

Y = [ones(length(zerod_ep),1) zerod_ep];

for i=1:length(neurons)
    ac = activity_con(i,:)';
    au = activity_unc(i,:)';
    
    x1 = reshape(rsg, 1, 25);
    x2 = reshape(asg, 1, 25);
    X = [ones(size(x1'))  x1'  x2'];
    
    c = X\ac;
    u = X\au;
    cc = [cc c];
    uu = [uu u];
    
    temp_c = Y\ac;
    temp_u = Y\au;
    yc = [yc temp_c];
    yu = [yu temp_u];
    
    % calculate SSE
    res_con_temp = (ac-X*c)'*(ac-X*c);
    res_unc_temp = (au-X*u)'*(au-X*u);
    
    residuals_con = [residuals_con res_con_temp];
    residuals_unc = [residuals_unc res_unc_temp];
    
    % find variance accounted for
    mean_ac = mean(ac);
    mean_au = mean(au);
    % find sum of squared deviations from mean
    ss_tot_con = (ac-mean_ac)'*(ac-mean_ac);
    ss_tot_unc = (au-mean_au)'*(au-mean_au);
    
    r2_con = 1-res_con_temp/ss_tot_con;
    r2_unc = 1-res_unc_temp/ss_tot_unc;
    
    VAF_con = [VAF_con r2_con];
    VAF_unc = [VAF_unc r2_unc];
    
end

% Get t-stat
sterr = std([ac;au]);
%usterr = std(au)./sqrt(100);
t_stat = max( abs(cc-uu)/sterr );

%paired t-test



% Get prefered directions
ccpd = atan2(cc(2,:), cc(3,:));
uupd = atan2(uu(2,:), uu(3,:));

cosdtheta = cos(ccpd-uupd);

% get real preferred directions
ycpd = atan2(yc(3,:),yc(2,:));
yupd = atan2(yu(3,:),yu(3,:));

cosdthetay = cos(ycpd-yupd);


%%%%%%%%%%%%% Draw plots of leg positions in joint space
figure
plot3(joint_angles_unc(:,1)', -joint_angles_unc(:,2)', joint_angles_unc(:,3)', 'bo');
axis square; grid on;
axis([0 1.5 0 1.5 0 1]);
%axis([-1.5 1.5 -1.5 1.5 0 3]);
view([-60 40]);
xlabel('leg');
ylabel('shank');
zlabel('foot');
title('Unconstrained')

figure
plot3(joint_angles_con(:,1)', -joint_angles_con(:,2)', joint_angles_con(:,3)', 'bo');
axis square; grid on;
axis([0 1.5 0 1.5 0 1]);
%axis([-1.5 1.5 -1.5 1.5 0 3]);
view([-60 40]);
xlabel('leg');
ylabel('shank');
zlabel('foot');
title('Constrained')

disp('unc corrcoef')
corrcoef(joint_angles_unc)

disp('con corrcoef')
corrcoef(joint_angles_con)


%%%%%%%%%%%%%%% Joint angle plots (rather than segment angles) %%%%%%%%%
disp('---------------- joint angles ------------------');

figure
x = joint_angles_unc(:,1)';
y = joint_angles_unc(:,1)' + joint_angles_unc(:,2)';
z = -joint_angles_unc(:,2)' - joint_angles_unc(:,3)';
plot3(x,y,z, 'bo');
axis square; grid on;
axis([0 1.5 0 1.5 0 1]);
%axis([-1.5 1.5 -1.5 1.5 0 3]);
view([-60 40]);
xlabel('hip');
ylabel('knee');
zlabel('ankle');
title('Unconstrained')

figure
x = joint_angles_unc(:,1)';
y = joint_angles_unc(:,1)' + joint_angles_unc(:,2)';
z = -joint_angles_unc(:,2)' - joint_angles_unc(:,3)';
plot3(x,y,z, 'bo');axis square; grid on;
axis([0 1.5 0 1.5 0 1]);
%axis([-1.5 1.5 -1.5 1.5 0 3]);
view([-60 40]);
xlabel('hip');
ylabel('knee');
zlabel('ankle');
title('Constrained')

disp('unc corrcoef')
corrcoef(joint_angles_unc)

disp('con corrcoef')
corrcoef(joint_angles_con)

% display R^2 and preferred direcction shift plot
figure
plot3(VAF_unc,VAF_con, cosdthetay, '.')
grid on
xlabel('unconstrained')
ylabel 'constrained'
zlabel 'cosdthetay'