function [xlegpoints, ylegpoints, zlegpoints] = separate_points(data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

npoints = size(data,2)/3;
for ii = 1:npoints
    ind = (ii-1)*3 + 1;
    points{ii} = data(:,ind:(ind+2));
end

xlegpoints(:,:) = data(:,1:3:end);
ylegpoints(:,:) = data(:,2:3:end);
zlegpoints(:,:) = data(:,3:3:end);
    
