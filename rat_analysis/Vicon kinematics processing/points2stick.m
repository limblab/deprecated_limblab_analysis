function [xleg, yleg, zleg] = points2stick(points)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

npoints = length(points);
nsamples = size(points{1},1);

for jj = 1:nsamples
    for kk = 1:npoints
        xleg(jj,kk) = points{kk}(jj,1);
        yleg(jj,kk) = points{kk}(jj,2);
        zleg(jj,kk) = points{kk}(jj,3);
    end
end

