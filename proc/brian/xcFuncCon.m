function [k, W] = xcFuncCon(bdf)
% xcFuncCon give the functional connectiveity of the dataset using the
%   cross correlation method
%
% [k, W] = xcFuncCon(bdf) gives the set of kernels (k) and the weights (W)
%   for all pairwise neurons pairs in the dataset (bdf).

ul = unit_list(bdf);

k = cell(length(ul), length(ul));

tic;
for preSynID = 1:length(ul)
    for postSynID = 1:length(ul)
        [table, all] = raster(bdf.units(preSynID).ts, bdf.units(postSynID).ts, -.05,0,-1);
        x = hist(all, -.05:.0005:0);
        x = x./x(2);
        k{preSynID,postSynID} = x;
        W(preSynID,postSynID) = mean(x);

        et = toc;
        disp(sprintf('%d of %d (%d) -- ET: %f.2 sec', preSynID, length(ul), postSynID, et));
    end
end


