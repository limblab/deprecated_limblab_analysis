% Generate 3-pannel statespace

%monkey = 'M';

units = unit_list(bdf);
mis = zeros(size(units,1), 4);

tic;

xs = bdf.vel(:,2:3);
pos_mean = mean(xs);
xs = xs - repmat(pos_mean, size(xs,1), 1);
[pos_prior, x, y] = vel_pdf(xs);

for i = 32:length(units)
    chan = units(i,1);
    unit = units(i,2);
    
    disp(sprintf('%d of %d\t%d-%d\tET: %f', i, length(units), chan, unit, toc));

    %
    % Emperical fitting method
    %

    s = get_unit(bdf, chan, unit);

    %end_mi = floor(s(end));

    b = train2bins(s, .001); % 1ms bins
    b = b(1000:end); % drop points before begin mi
    %v = [interp1(data.pos(1:end-1,1),dx,1:.001:end_mi)'
    %interp1(data.pos(1:end-1,1),dy,1:.001:end_mi)'];
    pos = bdf.vel(:,2:3);
    pos_mean = mean(pos);
    pos = pos - repmat(pos_mean, size(pos,1), 1);

    if (length(b) > length(pos))
        b = b(1:size(pos));
    else
        pos = pos(1:length(b),:);
    end

    d = tmi(b, pos, -1000:10:1000);

    t = -1000:10:1000;
    t = t.*0.001;

    bls = zeros(1,10);
    for j = 1:10
        test_spikes = rand_spikes(length(b), sum(b));
        bls(j) = mi(test_spikes', pos);
    end
    d = d - mean(bls);
    
    % MI peak analysis
    [mi_peak peak_width good_cell peakness peak_height] = peak_analysis(d,t);
    if good_cell ~= 1
        mis(i,:) = [chan unit NaN NaN];
        continue;
    end    
    
    mis(i,:) = [chan unit mi_peak peak_height];
    
    %
    % ML fitting method
    %
%    [L, alpha, success] = fit_model(bdf, chan, unit, mi_peak);
%    m_ml = alpha(1);
%    x_ml = alpha(2);
%    y_ml = alpha(3);

%    if success == 1
%        warn = '';
%    else
%        warn = ' (DNC)';
%    end
    
    %
    % Actual data
    %
    s = train2bins(get_unit(bdf, chan, unit) - mi_peak, bdf.vel(:,1));
    xs = bdf.vel(s>0,2:3);
    xs = xs - repmat(pos_mean, size(xs,1), 1);
    [p_xs, x, y] = vel_pdf(xs);
    p_sx = p_xs ./ pos_prior;

    %figure;pcolor(theta, rho, mini_psv_37_1.*1000)

    peak_fr = max(max(p_sx)) .* 1000;
    peak_fr = 5 * ceil(peak_fr/5);
    caxis_setting = [0 peak_fr];
    
    %
    % Plot
    %
    close all;
    figure;
%    subplot(1,2,1), h=pcolor(x, y, p_sx .* 1000);
    h=pcolor(x, y, p_sx .* 1000);
    axis square;
    title('Actual');
    xlabel('X Velocity (cm/s)');
    ylabel('Y Velocity (cm/s)');
    set(h, 'EdgeColor', 'none');
    caxis(caxis_setting);

%    p_ml = m_ml + x.*x_ml + y.*y_ml;
%    subplot(1,2,2), h=pcolor(x, y, p_ml );
%    axis square;
%    title('Maximum Likelihood');
%    xlabel('X Position (cm)');
%    ylabel('Y Position (cm)');
%    set(h, 'EdgeColor', 'none');
%    caxis(caxis_setting);

    suptitle(sprintf('Velocity Tuning: %s-%d-%d', monkey, chan, unit));    
    saveas(gcf, sprintf('cart_vel/%s-%d-%d', monkey, chan, unit), 'fig');
end
