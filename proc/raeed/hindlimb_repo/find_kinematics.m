function [joint_angles, muscle_lengths, scaled_lengths] = find_kinematics(endpoint_positions, plotflag)

global my_ep
global segments
global base_angles
global offset_angles
global muscles;
global pelvic_points femoral_points tibial_points foot_points;

% matrix to transform hip-centric segment angles into joint angles (offset
% by pi for knee and ankle), assuming row vector of segment angles
joint_transform = [1 0 0; 1 -1 0; 0 -1 1]';
num_positions = length(endpoint_positions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, find angles coresponding to each endpoint position in normal case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(plotflag)
    figure
end
options = optimset('MaxFunEvals', 5000);
x0 = base_angles';

muscle_lengths_unc = [];
joint_angles_unc = [];
start_angles_con = [];

for i = 1:length(endpoint_positions)
    my_ep = endpoint_positions(:,i);
    [angles,val,flag] = fminsearch(@mycost, x0, options);
    start_angles_con = [start_angles_con angles];
    joint_angles_unc = [joint_angles_unc; angles'*joint_transform];
    get_mp;
    
    % These were commented out
    if(plotflag)
        draw_bones;
        if (isequal(my_ep,mp(:,segments(end,end))))
            plot(my_ep(1), my_ep(2), 'ro');
        else
            plot(my_ep(1), my_ep(2), 'bo');
        end
    end
    
    get_lengths;
    muscle_lengths_unc = [muscle_lengths_unc; lengths];
end
if(plotflag)
    axis square
    % axis([-10 15 -20 5])
    title 'Unconstrained'
end

muscle_offset = min(muscle_lengths_unc);

scaled_lengths_unc = muscle_lengths_unc - repmat(muscle_offset,num_positions,1);

muscle_scale = max(scaled_lengths_unc);

scaled_lengths_unc = scaled_lengths_unc ./ repmat(muscle_scale,num_positions,1);

% make sure joint angles are between -pi and pi
while(~isempty(find(joint_angles_unc<-pi | joint_angles_unc>pi, 1)))
    joint_angles_unc(joint_angles_unc<-pi) = joint_angles_unc(joint_angles_unc<-pi)+2*pi;
    joint_angles_unc(joint_angles_unc> pi) = joint_angles_unc(joint_angles_unc> pi)-2*pi;
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, find angles coresponding to each endpoint position in constrained case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options = optimset('MaxFunEvals', 5000, 'MaxIter', 1000, 'Display', 'off', 'Algorithm', 'active-set');
%x0 = [pi/4 pi/4];
x0 = base_angles';

muscle_lengths_con = [];
joint_angles_con = [];

if(plotflag)
    figure;
end

for i = 1:length(endpoint_positions)
    my_ep = endpoint_positions(:,i);
%     [x,val,flag] = fminsearch(@mycostcon, x0, options);
    [angles,val,flag] = fmincon(@mycost, start_angles_con(:,i) , [0 1 -1;0 -1 1], [-pi/15; pi], [1 -1 0], pi/2,[],[],[], options);
    joint_angles_con = [joint_angles_con; angles'*joint_transform];
    get_mp;
    
    % These were commented out
    if(plotflag)
        draw_bones;
        if (isequal(my_ep,mp(:,segments(end,end))))
            plot(my_ep(1), my_ep(2), 'ro');
        else
            plot(my_ep(1), my_ep(2), 'bo');
        end
    end
    
    get_lengths;
    muscle_lengths_con = [muscle_lengths_con; lengths];
end
if(plotflag)
    axis square
    % axis([-10 15 -20 5])
    title 'Constrained'
end

% scaled_lengths_con = muscle_lengths_con - repmat(min(muscle_lengths_con),num_positions,1);
% scaled_lengths_con = scaled_lengths_con ./ repmat(max(scaled_lengths_con),num_positions,1);

scaled_lengths_con = muscle_lengths_con - repmat(muscle_offset,num_positions,1);
scaled_lengths_con = scaled_lengths_con ./ repmat(muscle_scale,num_positions,1);

% make sure joint angles are between -pi and pi
while(~isempty(find(joint_angles_con<-pi | joint_angles_con>pi, 1)))
    joint_angles_con(joint_angles_con<-pi) = joint_angles_con(joint_angles_con<-pi)+2*pi;
    joint_angles_con(joint_angles_con> pi) = joint_angles_con(joint_angles_con> pi)-2*pi;
end

joint_angles = {joint_angles_unc; joint_angles_con};
muscle_lengths = {muscle_lengths_unc; muscle_lengths_con};
scaled_lengths = {scaled_lengths_unc; scaled_lengths_con};