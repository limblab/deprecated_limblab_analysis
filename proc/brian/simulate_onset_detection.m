% simulate_onset_detection.m
%
% Simulates poisson step functions to determine "onset"

% Setup
low_fs = 5:5:25;
step_fs = 5:5:50;

t = -.5:0.005:1;
tt = -.5:.0001:1;

output_m = zeros(length(step_fs), length(low_fs));
output_v = zeros(length(step_fs), length(low_fs));

for l = 1%:length(low_fs)
    for h = 4%1:length(step_fs)
        low_f = low_fs(l);
        high_f = low_fs(l) + step_fs(h);

        prise = zeros(1,10);
        for rep = 1:1%00
            % Generate spikes
            %p = low_f*(tt<0)*.0001 + high_f*(tt>=0 & tt<.1)*.0001 + low_f*(tt>=0.1)*.0001;
            p = low_f*(tt<0)*.0001 + high_f*(tt>=0)*.0001;
            s = [];
            for i = 1:20
                s = [s tt(rand(size(p)) < p)];
            end
            s = sort(s);

            % Plot raster
            figure;
            subplot(2,1,1),plot(s, rand(size(s)), 'k.')

            % Calc firing rate
            ps = zeros(size(t));
            for spike = s
                ps = ps + exp( - (t-spike).^2 / (2*.03.^2) );
            end

            % Plot firing rate
            subplot(2,1,2),plot(t,ps);

            % Calculate onset
            thr = (max(ps) - mean(ps(40:60)))/2 + mean(ps(40:60));
            prise(rep) = t(find(ps<thr & t<t(ps==max(ps)),1,'last')+1);
        end

        output_m(h,l) = mean(prise);
        output_v(h,l) = var(prise);

    end
end


