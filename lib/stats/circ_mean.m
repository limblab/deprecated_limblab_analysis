function out = circ_mean( in )
%CIRC_MEAN circular mean

out = atan2(sum(sin(in)), sum(cos(in)));

