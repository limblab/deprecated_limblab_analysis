%percept:
percept=[0 1];
%bumps:
angles=(0:20:360)*3.1415/180;
bumps=[sin(angles)',cos(angles)'];
%combined percept (assumes vector summation)
joint_percept=bsxfun(@plus,bumps,percept);

%joint percept angles
percept_angle=atan2(joint_percept(:,2),joint_percept(:,1));

%sigmoid describing choice rate:
%     minimum=params(1);
%     maximum=params(2);
%     center=params(3);
%     steepness=params(4);
stepsize=10*pi/180;
runto=pi;

for i=0:length(angles)
    sig=[0,1,i*stepsize,5];
    relative_angle=angles-i*stepsize;
    relative_joint_angle=joint_percept-i*stepsize;
    figure
    plot(relative_angle, sigmoid(sig,relative_angle),'b');
    hold on
    plot(relative_angle, sigmoid(sig,relative_joint_angle),'r');
    
end

