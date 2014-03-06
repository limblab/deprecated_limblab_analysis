function constraint_forces = calc_constraint_forces(Q)
% Calculates the forces that are used to constrain the arm to a certain range of motion.
% 
% 1. Inputs: Joint angles 7x1 (Q-rad)
%
% 2. Uses two parameters, one that specifies the range of motion and one
% that specifies how steep the constraint curves are, to calculate a joint
% torques needed to keep the arm within physiological limits.
%
% 3. Outputs: Constraint Forces 7x1 (Nm/s)
%
% Created by Sherwin Chan
% Date: 2/25/2005
% Last modified :
%   2/25/2005 SSC
%
%

% Initialize constants
DEGtoRAD = pi/180;

% This array contains the constraint parameters.  The first column lists
% the beginning of the allowed arm angles and the last column lists the end
% of the allowed arm angles.
constraint_params = [-90 90; -80 90; -75 160; 20 140; -90 90; -75 90; -60 45];
constraint_params = constraint_params * DEGtoRAD;

% This determines the steepness of the constraint curves at the ends
mult_factor = [6.87 6.87; 6.87 6.87; 6.87 6.87; 6.87 6.87;...
               4 4; 4 4; 4 4];
%                2 2; 2 2; 2 2];

for i = 1:7
    if Q(i) < (constraint_params(i,1) + 20 * DEGtoRAD) 
        constraint_forces(i) = exp(mult_factor(i,1)*(-Q(i) + (constraint_params(i,1) + 20 * DEGtoRAD))) - 1;
    elseif Q(i) > (constraint_params(i,2) - 20 * DEGtoRAD)
        constraint_forces(i) = -exp(mult_factor(i,2)*(Q(i) - (constraint_params(i,2) - 20 * DEGtoRAD))) + 1;
%         disp(['Angle = ', num2str(Q(i)/DEGtoRAD), ' Constraint Force = ', num2str(constraint_forces(i))]);
    else
        constraint_forces(i) = 0;
    end
end
