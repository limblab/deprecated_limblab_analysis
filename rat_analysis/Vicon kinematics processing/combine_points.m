function data = combine_points(x,y,z,frames)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

npoints = size(x,2);
ncols = npoints*3+2;
data= zeros(length(frames),ncols);

data(:,1) = frames;
data(:,2) = 0*frames;
data(:,3:3:ncols) = x;
data(:,4:3:ncols) = y;
data(:,5:3:ncols) = z;


