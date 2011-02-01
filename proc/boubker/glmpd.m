chan=3;unit=1;
[b, dev, stats, L, L0] = glm_kin(bdf, chan, unit, 0, 'posvel');

s = train2bins(get_unit(bdf, chan, unit), bdf.vel(:,1));
    vs = bdf.vel(s>0,2:3);
    [p_vs, theta, rho] = vel_pdf_polar(vs);
   
    figure;
  
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(b, state, 'log').*20;
        end
    end
%     subplot(1,3,3),
    h=pcolor(theta, rho, p_glm );
    axis square;
    title('GLM Likelihood');
    xlabel('Direction');
    ylabel('Speed (cm/s)');
    set(gca,'XTick',0:pi:2*pi)
    set(gca,'XTickLabel',{'0','pi','2*pi'})
    set(h, 'EdgeColor', 'none');


    warn = '';
%     suptitle(sprintf('Velocity Tuning: %s-%d-%d%s', monkey, chan, unit, warn));
    tuning = mean(p_glm' .* 1000);
    tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    tt = sum(tt');    
    pd2 = atan2(tt(2), tt(1))
  