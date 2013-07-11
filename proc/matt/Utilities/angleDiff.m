function adiff = angleDiff(angle1,angle2,useRad)
% ANGLEDIFF finds absolute value of difference in angle
%
% INPUTS:
%   angle1: an angle or vector of angles
%   angle2: another angle or vector of angles. Same size as angle1
%   useRad: (boolean) if true, inputs are in radians
%
% OUTPUTS:
%   adiff: element-wise difference between the angles
%
%%%%%%
% written by Matt Perich; last updated July 2013
%%%%%

if nargin < 3 %default to degrees
    useRad = false;
end

if useRad
    a = pi;
else
    a = 180;
end

% Find the difference
adiff = abs(angle2 - angle1);

% If greater than 180, subtract from 360 to get magnitude
for i = 1:length(adiff)
    if adiff(i) > a
        adiff(i) = abs(2*a-adiff(i));
    end
end