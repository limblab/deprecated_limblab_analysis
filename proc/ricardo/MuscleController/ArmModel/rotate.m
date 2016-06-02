function [M] = rotate(a, x, y, z, three_dim)
% rotate
% =========
% Generates a 4x4 rotation matrix for Post-Multiplication 
% of a transformation matrix (OpenGL format)
% 
% Dan Moran
% The Neurosciences Institute
% 7-13-1999
% *********************************************************  

if nargin == 4
    three_dim = 0;
end

%  Build 3x3 rotation matrix

v = [x; y; z];
u = v/norm(v);
I = eye(3);

S = [ 0   -u(3) u(2);
     u(3)   0  -u(1); 
    -u(2)  u(1)  0];

M = u*u' + cos(a)*(I-u*u') + sin(a)*S;

if ~three_dim
    % Convert M from 3x3 to 4x4
    
    M(:,4) = 0.0;
    M(4,:) = 0.0;
    M(4,4) = 1.0;
    
end