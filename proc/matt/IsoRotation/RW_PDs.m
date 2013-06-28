function out = RW_PDs(bdf)

units = unit_list(bdf);
clear out;

out = struct('chan',{},'unit',{},'glmb',{},'glmstats',{},'glmpd',{},'glmdm',{});

for i = 1:size(units, 1)
    disp(['GLM fitting unit: ' num2str(i) ' of ' num2str(length(units))])
    chan = units(i,1);
    unit = units(i,2);
    
    mi_peak = 0;
    
    % GLM Fitting Method
    [b, dev, stats] = glm_kin(bdf, chan, unit, mi_peak,'vel');    
    s = train2bins(get_unit(bdf, chan, unit) - mi_peak, bdf.vel(:,1));
    vs = bdf.vel(s>0,2:3);
    [p_vs, theta, rho] = vel_pdf_polar(vs);
    
    % GLM evaluation
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(b, state, 'log').*20;
        end
    end
    
    tuning = mean(p_glm' .* 1000);
    tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    tt = sum(tt');    
    pd2 = atan2(tt(2), tt(1));
    
    dm = max(max(p_glm'))/mean(max(p_glm'));
    
    out(i) = struct('chan', chan, 'unit', unit, 'glmb', b, 'glmstats', stats, ...       
        'glmpd', pd2,'glmdm',dm);
end
