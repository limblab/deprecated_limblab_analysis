%% 3) Show tuning curves of individual neurons in each of three epochs
useDate = '2013-08-23';
elec = 20;
unit = 2;

load(fullfile(baseDir, useDate,['CO_FF_tuning_' useDate '.mat']));

sg = tuning.BL.PMd.nonparametric.peak.unit_guide;
utheta = tuning.BL.PMd.nonparametric.peak.utheta;
mFR = tuning.BL.PMd.nonparametric.peak.mfr;
sFR_l = tuning.BL.PMd.nonparametric.peak.cil;
sFR_h = tuning.BL.PMd.nonparametric.peak.cih;

useUnit = sg(:,1)==elec & sg(:,2)==unit;

% we went +pi to be the highest index, so if -pi is used...
if abs(utheta(1)) > utheta(end)
    utheta = [utheta; abs(utheta(1))];
    utheta(1) = [];
    
    mFR = [mFR mFR(:,1)];
    sFR_l = [sFR_l sFR_l(:,1)];
    sFR_h = [sFR_h sFR_h(:,1)];
    
    mFR(:,1) = [];
    sFR_l(:,1) = [];
    sFR_h(:,1) = [];
    
end

fh = figure('Position', [200, 200, 800, 600]);
hold all;
h = area(utheta.*(180/pi),[sFR_l(useUnit,:)' sFR_h(useUnit,:)']);
set(h(1),'FaceColor',[1 1 1]);
set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
plot(utheta.*(180/pi),mFR(useUnit,:),'b--','LineWidth',3);
axis('tight');

V = axis;
axis([min(utheta)*180/pi max(utheta)*180/pi 0 V(4)]);

% now fit a cosine and plot it
fr = tuning.BL.PMd.regression.peak.fr(:,useUnit);
theta = tuning.BL.PMd.regression.peak.theta;

st = sin(theta);
ct = cos(theta);
X = [ones(size(theta)) st ct];

B = regress(fr,X);

theta = -pi:0.1:2*pi;
plot(theta.*180/pi,B(1)+B(2)*sin(theta)+B(3)*cos(theta),'r','LineWidth',3);

% find the PD and put a line
pd = atan2(B(2),B(3));
plot([pd pd].*180/pi,[0 V(4)],'k--','LineWidth',3);

% make a legend
plot([60 100],[45 45],'--','Color','b','LineWidth',3);
plot([60 100],[42 42],'Color','r','LineWidth',3);
text(105,45,'Mean Activity','FontSize',16);
text(105,42,'Cosine Fit','FontSize',16);

xlabel('Direction of Movement (Deg)','FontSize',18);
ylabel('Firing Rate (Hz)','FontSize',18);
set(gca,'FontSize',16);
