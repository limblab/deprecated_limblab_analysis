function filt_sig = low_pass_filter(time, raw_sig, cut_off_freq, deriv, resample_time);
% Phase-symmetric low-pass digital filter using Woltring's algorithm
% It can be used to fit smooth spline to discrete movement data and compute
% the derivatives. You can also use it to re-sample the movement data for
% different time instants.
% Usage: filter_signal = low_pass_filter(time_array(nx1), raw_signal(nxm), cut_off_freq, 
%           derivative, resample_time(nx1))
% Base on code from Dr. Dan Moran, NSI 11-16-1999
% 
% WW/BME/WU      01/31/2003
% Last Update   09/24/2003
%
% Revision history:
%
% Changed to check for Nan and check for -9999, which is how the
% markers appear when off the screen.

opt_mode = 1;
half_order = 3;
weight_x = ones(1,size(raw_sig,1));
weight_y = ones(1,size(raw_sig,2));
samp_freq = 1/(time(2) - time(1));
opt_val = samp_freq/(2.0*pi*cut_off_freq/((sqrt(2.0) - 1)^(0.5/half_order)))^(2.0*half_order);
orig_time = time;

% check for NaN and remove
a = isnan(raw_sig);
[r,c] = find(a == 1);
[r1, c1] = find (raw_sig == -9999);
r = [r, r1];
c = [c, c1];
r = sort(r);
%fprintf('\n Removing %d entries of data due to NaN values',size(r,1));
raw_sig(r,:) = [];
time(r) = [];

if (size(time,1) < 3*half_order | size(raw_sig,1) < 3*half_order)
   error('Error = 1; Too few points: Try transpose of time and/or signal matrices?');
end

[coef, work, err] = gcvspl(time, raw_sig, size(raw_sig,1), weight_x, weight_y, ...
   half_order, size(raw_sig,1), size(raw_sig,2), opt_mode, opt_val, size(raw_sig,1));

if (err == 2)
   error('Error = 2;  Knot sequence is not strictly increasing or some weight factor is not positive.');
elseif (err == 3)   
   disp('Error = 3;  Wrong mode parameter or value.');
end

if exist('resample_time')
    orig_time = resample_time;
end
for i=1:size(orig_time,1)
	for j=1:size(raw_sig,2)
      if (orig_time(i) >= time(1) & orig_time(i) <= time(end))
         filt_sig(i,j) = splder(deriv, half_order, size(raw_sig,1), orig_time(i), time, coef(:,j), i, work);
      else
         filt_sig(i,j) = NaN;    % Padding for NaN taken out in beginning/end of array.
      end
   end
end
