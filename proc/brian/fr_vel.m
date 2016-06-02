% Generate 3-pannel statespace

%units = unit_list(bdf);
monkey = 'P';
%units = [3 1];
units = [96 1; 43 1];

clear out;

tic;
for i = 1:size(units, 1)
    chan = units(i,1);
    unit = units(i,2);
    
    et = toc;
    disp(sprintf('%d of %d\t%d-%d\tET: %f', i, size(units, 1), chan, unit, et));
    
    %
    % Emperical fitting method
    %
%    out = rand_walk_new(bdf, chan, unit);
%    if(isnan(out(3)))
%        continue
%    end

    % l(v) = m + k ||v|| cos(th - th_p) + b ||v||
%    m_bl = out(5);
%    k_bl = out(7);
%    th_bl = out(6);
%    b_bl = out(8);

%    mi_peak = out(3);
    mi_peak = 0;
    
    %
    % GLM Fitting Method
    %
    [b, dev, stats] = glm_kin(bdf, chan, unit, mi_peak);
    %m_glm = glm_val(b, [0 0 0], 'log').*20;
    %glm_x = glm_val(b, [1 0 1], 'log').*20 - m_glm;
    %glm_y = glm_val(b, [1 0 1], 'log').*20 - m_glm;
    %k_glm = sqrt(glm_x.^2 + glm_y.^2);
    %th_glm = atan2(glm_y, glm_x);
    
    
    %
    % ML fitting method
    %
    %[L, alpha, success] = fit_model(bdf, chan, unit, mi_peak);
    %m_ml = alpha(1);
    %k_ml = sqrt(alpha(2).^2 + alpha(3).^2);
    %th_ml = atan2(alpha(3), alpha(2));
    %b_ml = alpha(4);

    %if success ~= 1
    %    warn = ' (DNC)';
    %else 
    %    warn = '';
    %end
    
    %
    % Actual data
    %
    %s = train2bins(get_unit(bdf, chan, unit) - mi_peak, bdf.vel(:,1));
    s = train2bins(get_unit(bdf, chan, unit), bdf.vel(:,1));
    vs = bdf.vel(s>0,2:3);
    [p_vs, theta, rho] = vel_pdf_polar(vs);
    %p_sv = p_vs ./ arthur_v_prior;
    %p_sv = p_vs ./ tiki_vel_prior;

    %figure;pcolor(theta, rho, mini_psv_37_1.*1000)

    %
    % Plot
    %
    %close all;
    figure;
    %subplot(1,3,1), h=pcolor(theta, rho, p_sv .* 1000 );
    %axis square;
    %title('Actual');
    %xlabel('Direction');
    %ylabel('Speed (cm/s)');
    %set(gca,'XTick',0:pi:2*pi)
    %set(gca,'XTickLabel',{'0','pi','2*pi'})
    %set(h, 'EdgeColor', 'none');
    %caxis([0 m_bl*3]);
    
    % Emperical
% 
%     p_bl = m_bl + k_bl .* rho .* cos(theta-th_bl) + b_bl .* rho;
%     subplot(1,2,2), h=pcolor(theta, rho, p_bl );
%     axis square;
%     title('Emperical');
%     xlabel('Direction');
%     ylabel('Speed (cm/s)');
%     set(gca,'XTick',0:pi:2*pi)
%     set(gca,'XTickLabel',{'0','pi','2*pi'})
%     set(h, 'EdgeColor', 'none');
%     caxis([0 m_bl*3]);
%     

    % ML fit
    %p_ml = m_ml + k_ml .* rho .* cos(theta-th_ml) + b_ml .* rho;
    %subplot(1,3,2), h=pcolor(theta, rho, p_ml );
    %axis square;
    %title('Maximum Likelihood');
    %xlabel('Direction');
    %ylabel('Speed (cm/s)');
    %set(gca,'XTick',0:pi:2*pi)
    %set(gca,'XTickLabel',{'0','pi','2*pi'})
    %set(h, 'EdgeColor', 'none');
    %caxis([0 b_ml*3]);
    
    % GLM fit
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(b, state, 'log').*20;
        end
    end
    subplot(1,3,3), h=pcolor(theta, rho, p_glm );
    axis square;
    title('GLM Likelihood');
    xlabel('Direction');
    ylabel('Speed (cm/s)');
    set(gca,'XTick',0:pi:2*pi)
    set(gca,'XTickLabel',{'0','pi','2*pi'})
    set(h, 'EdgeColor', 'none');
    %caxis([0 b_ml*3]);

    warn = '';
    suptitle(sprintf('Velocity Tuning: %s-%d-%d%s', monkey, chan, unit, warn));
    
    %saveas(gcf, sprintf('tmp2/%d-%d', chan, unit), 'fig');
    
    
    %tuning = mean(p_sv' .* 1000);
    %tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    %tt = sum(tt');    
    %pd = atan2(tt(2), tt(1));
    
    tuning = mean(p_glm' .* 1000);
    tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    tt = sum(tt');    
    pd2 = atan2(tt(2), tt(1))
    
    %out(i) = struct('chan', chan, 'unit', unit, 'glmb', b, 'glmstats', stats, ...
    %    'ml', struct('m',m_ml,'k',k_ml,'th',th_ml,'b',b_ml), ...
    %    'actual', p_sv, 'apd', pd, 'glmpd', pd2);
end


