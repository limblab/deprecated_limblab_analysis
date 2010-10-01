% Generate 3-pannel statespace

units = unit_list(bdf);
%monkey = 'P';
%units = [4 1];

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
        [b, junk1, junk2, l, l0] = glm_kin(bdf, chan, unit, t(i), 'pos');
        L(i) = -l;
        L0(i) = -l0;
    end

    out(j,:) = L./L0;
    
    plot(t,L./L0,'k-');
    title(sprintf('%s-%d-%d%s', monkey, chan, unit));
    xlabel('Lag (s)');
    ylabel('Log Likelihood Ratio');
    
    %saveas(gcf, sprintf('llfits/%d-%d', chan, unit), 'fig');
end


