% clear; close all;clc;

% pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Processed\';
% pathnameout='\\165.124.111.234\limblab\user_folders\Boubker\PDs\';
% % root=('Pedro_S1_040-s');
%  root=('Pedro_S1_042-s');
% bdf=LoadDataStruct([pathname,root,'.mat']);
% 
bdf=data;

dd=[];
dd=[dd bdf.units.id];
chan=dd(1:2:end-1);
units=dd(2:2:end);
chanunit(:,1)=dd(1:2:end-1)';
chanunit(:,2)=dd(2:2:end)';
cha_uni=chanunit;
cha_uni(find(cha_uni(:,2)==0),:)=[];

for i=1 : length(cha_uni)
    chan=cha_uni(i,1);unit=cha_uni(i,2);
[b, dev, stats, L, L0] = glm_kin(bdf, chan, unit, 0, 'posvel');


s = train2bins(get_unit(bdf, chan, unit), bdf.vel(:,1));
    vs = bdf.vel(s>0,2:3);
    [p_vs, theta, rho] = vel_pdf_polar(vs);
   

  
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(b, state, 'log').*20;
        end
    end
%     subplot(1,3,3),
%     h=pcolor(theta, rho, p_glm );
%     axis square;
%     title('GLM Likelihood');
%     xlabel('Direction');
%     ylabel('Speed (cm/s)');
%     set(gca,'XTick',0:pi:2*pi)
%     set(gca,'XTickLabel',{'0','pi','2*pi'})
%     set(h, 'EdgeColor', 'none');


    warn = '';
%     suptitle(sprintf('Velocity Tuning: %s-%d-%d%s', monkey, chan, unit, warn));
    tuning = mean(p_glm' .* 1000);
    tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    tt = sum(tt');    
    pd2(i,1) = atan2(tt(2), tt(1));
end
GLMPDs(:,1:2)=cha_uni;
GLMPDs(:,3)=pd2;
GLMPDs(GLMPDs(:,3)<0,3)=GLMPDs(GLMPDs(:,3)<0,3)+2*pi;
allPDs=[allPDs GLMPDs(:,3)];  