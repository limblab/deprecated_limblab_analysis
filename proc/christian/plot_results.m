function plot_results(res)

%% Mean
numpts = size(vertcat(res.R2f{:,1}),1);

R2fc = zeros(numpts, size(res.R2f{1,1},2),res.NumLoops);
R2ac = zeros(numpts, size(res.R2a{1,1},2),res.NumLoops);
R2ffc = zeros(numpts, size(res.R2ff{1,1},2),res.NumLoops);

for i = 1:res.NumLoops
    R2fc(:,:,i) = vertcat(res.R2f{:,i});
    R2ac(:,:,i) = vertcat(res.R2a{:,i});
    R2ffc(:,:,i) = vertcat(res.R2ff{:,i});
end

MR2f = mean(R2fc,3);
MR2a = mean(R2ac,3);
MR2ff= mean(R2ffc,3);

SR2f = std(R2fc,0,3);
SR2a = std(R2ac,0,3);
SR2ff= std(R2ffc,0,3);

Mf = mean(MR2f,2);
Ma = mean(MR2a,2);
Mff= mean(MR2ff,2);

SDf = sqrt(SR2f(:,1).^2+SR2f(:,2).^2)/2;
SDa = sqrt(SR2a(:,1).^2+SR2a(:,2).^2)/2;
SDff = sqrt(SR2ff(:,1).^2+SR2ff(:,2).^2)/2;

y_posf = MR2f(:,2);
y_posa = MR2a(:,2);
y_posff = MR2ff(:,2);

res.MR2a = MR2a;
res.MR2f = MR2f;
res.MR2ff= MR2ff;

%% Plots
figure;
hold on;
numpts = size(res.MR2f,1);

%calculate SD around mean curve
x = round([1:numpts numpts:-1:1]);
yft = Mf+SDf;
yfb = Mf-SDf;
yf  = [yft; yfb(end:-1:1)];

yat = Ma+SDa;
yab = Ma-SDa;
ya = [yat; yab(end:-1:1)];

yfft = Mff+SDff;
yffb = Mff-SDff;
yff  = [yfft; yffb(end:-1:1)];

pink = [255 182 193]./255;
gray = [112 128 144]./255;
light_blue = [208 255 255]./255;

area(x,yff,'FaceColor',gray,'LineStyle','none');
area(x,yf,'FaceColor',light_blue,'LineStyle','none');
area(x,ya,'FaceColor',pink,'LineStyle','none');
hf = plot(1:numpts,Mf,'b.-');
ha = plot(1:numpts,Ma,'r.-');
hff = plot(1:numpts,Mff,'k.-');
legend([hf,ha,hff],'fixed model','adaptive model','fixed no drop/perm');
title('Mean R^2');

% plot y_pos only
figure; hold on;
x = [1:numpts numpts:-1:1];
yft = y_posf+SR2f(:,2);
yfb = y_posf-SR2f(:,2);
yf  = [yft; yfb(end:-1:1)];
yat = y_posa+SR2a(:,2);
yab = y_posa-SR2a(:,2);
ya = [yat; yab(end:-1:1)];
yfft = y_posff+SR2ff(:,2);
yffb = y_posff-SR2ff(:,2);
yff  = [yfft; yffb(end:-1:1)];

area(x,yff,'FaceColor',gray,'LineStyle','none');
area(x,yf,'FaceColor',light_blue,'LineStyle','none');
area(x,ya,'FaceColor',pink,'LineStyle','none');
hf = plot(1:numpts,y_posf,'b.-');
ha = plot(1:numpts,y_posa,'r.-');
hff = plot(1:numpts,y_posff,'k.-');
legend([hf,ha,hff],'fixed model','adaptive model','fixed no drop/perm');
title('Y\_pos R^2');
