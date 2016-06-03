function kernels = kernel_glm(bdf, chan, unit)

% constants
num_random_samples = 60000;
window_width = 50; % number of samples on either side of t (total window width is double this)
kernel_length = 2*window_width+1;

% get signals
spike_times = get_unit(bdf,chan,unit);
t = bdf.pos(1,1):.01:bdf.pos(end,1);
[s, st] = train2bins(spike_times, t);
s(1) = 0; s(end) = 0; % blank the overflow buckets in spike bins

[c, kin_points, s_points] = intersect(bdf.pos(:,1), t);
s = s(s_points);
x = bdf.pos(kin_points,[2 3]) - repmat(mean(bdf.pos(:, [2 3])), length(kin_points), 1);
%kin_sigs = [x>0 bdf.vel(:,[2 3])>0];
%kin_sigs = kin_sigs*2 - 1;

kin_sigs = [x bdf.vel(kin_points,[2 3])];
%kin_sigs = bdf.vel(kin_points, [2 3]);
%kin_sigs = sqrt(bdf.vel(:,2).^2 + bdf.vel(:,3).^2);

% get random samples and build glm data set
idx = floor(rand(1,num_random_samples) * (length(s)-window_width*2)) + window_width+1;
%s_idx = find(s>0);
%s_idx = s_idx(100:end-100);
%idx = [idx s_idx];

glm_x = zeros(length(idx), size(kin_sigs,2)*kernel_length);
glm_y = zeros(length(idx), 1);

for i = 1:length(idx)
    glm_y(i) = s(idx(i));
    glm_x(i, :) = reshape(kin_sigs((idx(i)-window_width):(idx(i)+window_width), :), 1, []);
end

[b, dev, stats] = glmfit(glm_x, glm_y, 'poisson');


kernels = struct('b', b, 'dev', dev, 'stats', stats);

