function [  ] = readSelectivity( IOcurves )
%READSELECTIVITY Summary of this function goes here
%   Detailed explanation goes here

for i=1:size(IOcurves.plots,1)
    IOcurves.plots(i)
    IOcurves.electrode(IOcurves.plots(i)).selectivity
end

end

