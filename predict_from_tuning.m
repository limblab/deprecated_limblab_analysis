function [vel_hat, b] = predict_from_tuning(bdf, tuning)

% $Id$

% Extract velocity and speed
v = bdf.vel(:,2:3);
s = sqrt( v(:,1).^2 + v(:,2).^2 );

% build firing rate matrix
good_cells = find(~isnan(tuning(:,3)));
b = zeros(size(v,1), length(good_cells));
cell_number = 1;
tic
for cell = good_cells'
    ts = bdf.units(cell).ts - 1 - tuning(cell,3);
    ts = ts(ts > 0);
    bins = train2bins(ts, .001);
    if (length(bins) < length(b))
        bins = [bins zeros(1, length(b) - length(bins))]; %#ok<AGROW>
    else
        bins = bins(1:length(b));
    end
    b(:,cell_number) = gauss_rate(bins, 100).*1000;
    cell_number = cell_number+1
    toc
end

b = downsample(b,20);
v = downsample(v,20);
s = downsample(s,20);

num_directions = 32;
dirs = (1:num_directions)' * 2*pi/num_directions;

cell = good_cells(1);
rates = b(:,1)' - tuning(cell,4);
slopes = tuning(cell,6) * cos(dirs - tuning(cell,5)) + tuning(cell,7);
mu = slopes*rates;
sig = repmat(1./slopes, 1, length(mu)).*repmat( rates, num_directions, 1 );

for i = 2:length(good_cells)
    cell = good_cells(i);
    
    rates = b(:,i)' - tuning(cell,4);
    slopes = tuning(cell,6) * cos(dirs - tuning(cell,5)) + tuning(cell,7);
    mu_i = slopes*rates;
    sig_i = repmat(1./slopes, 1, length(mu)).*repmat( rates, num_directions, 1 );

    new_mu = (mu.*sig_i + mu_i.*sig) ./ (sig + sig_i);
    new_sig = (sig.*sig_i) ./ (sig + sig_i);
    
    mu = new_mu;
    sig = new_sig;
end

minvar = sig == repmat(min(sig), size(sig,1), 1);
theta_hat = minvar'*dirs;
s_hat = mu(minvar);

vel_hat = [theta_hat s_hat];



