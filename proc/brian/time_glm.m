% Generate 3-pannel statespace

%units = unit_list(bdf);
monkey = 'P';
units = [33 1];

clear out;
t = -5:.005:5;
out = zeros(size(units,1), length(t));

tic;
for j = 1:size(units, 1)
    chan = units(j,1);
    unit = units(j,2);
    
    et = toc;
    disp(sprintf('%d of %d\t%d-%d\tET: %f', j, size(units, 1), chan, unit, et));
    
    %
    % GLM Fitting Method
    %
    L = zeros(size(t));
    Lp = zeros(size(t));
    Lv = zeros(size(t));
    L0 = zeros(size(t));
    
    %unit_data = get_unit(bdf,chan,unit);
    %shf_unit_data = rand(size(unit_data))*(max(unit_data) - min(unit_data)) + min(unit_data);
    
    vx = bdf.vel(:,2);
    v = ([vx(101:end); vx(1:100)]);% + [vx(151:end); vx(1:150)] + [vx(51:end); vx(1:50)])/3;
    lambda = (v + 10) / 1000;
    s = rand(size(lambda));
    ts = bdf.vel(s<lambda,1);
    
    for i = 1:length(t)
        %disp(i);
                
        %[b, junk1, junk2, l, l0] = glm_kin(bdf, chan, unit, t(i), 'posvel', shf_unit_data);
        [b, junk1, junk2, l, l0] = glm_kin(bdf, chan, unit, t(i), 'posvel');
        L(i) = -l;
        L0(i) = -l0;

        %[b, junk1, junk2, l] = glm_kin(bdf, chan, unit, t(i), 'pos');
        %Lp(i) = -l;
        %[b, junk1, junk2, l] = glm_kin(bdf, chan, unit, t(i), 'vel');
        %Lv(i) = -l;
    end
    
    %tuning = mean(p_glm' .* 1000);
    %tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    %tt = sum(tt');    
    %pd2 = atan2(tt(2), tt(1));
    %
    %out(i) = struct('chan', chan, 'unit', unit, 'glmb', b, 'glmstats', stats, ...
    %    'ml', struct('m',m_ml,'k',k_ml,'th',th_ml,'b',b_ml), ...
    %    'actual', p_sv, 'apd', pd, 'glmpd', pd2);
    
    %close all;
    %plot(t,L./L0,'k-',t,Lp./L0,'r-',t,Lv./L0,'b-');
    
    out(j,:) = L./L0;
    
    plot(t,L./L0,'k-');
    title(sprintf('%s-%d-%d%s', monkey, chan, unit));
    xlabel('Lag (s)');
    ylabel('Log Likelihood Ratio');
    
    saveas(gcf, sprintf('llfits/%d-%d', chan, unit), 'fig');
end


