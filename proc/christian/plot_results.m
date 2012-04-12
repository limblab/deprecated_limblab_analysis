function plot_results(res)

%% Mean
numpts  = size(vertcat(res.R2f{:,1}),1);
numpts  = max(numpts,size(vertcat(res.R2ff{:,1}),1));
numpts  = max(numpts,size(vertcat(res.R2a{:,1}),1));
numpts  = max(numpts,size(vertcat(res.R2af{:,1}),1));
numOuts = size(res.R2f{1,1},2); 
numOuts = max(numOuts,size(res.R2ff{1,1},2)); 
numOuts = max(numOuts,size(res.R2a{1,1},2));
numOuts = max(numOuts,size(res.R2af{1,1},2));

R2fc = zeros(numpts, numOuts, res.NumIter);  %R2 for fixed model with drops and permutation
R2ac = zeros(numpts, numOuts, res.NumIter);  %R2 for adaptive model with drops and permutation
R2ffc = zeros(numpts,numOuts, res.NumIter);  %R2 for fixed model no drop or perm
R2afc = zeros(numpts,numOuts, res.NumIter);  %R2 for adaptive model no drop or perm

%this extracts the cell R2 results into a (numpts x numOut x numLoops) array of double
for i = 1:res.NumIter
    if size(res.R2f{:,i})
        R2fc(:,:,i) = vertcat(res.R2f{:,i});
    end
    if size(res.R2a{:,i})
        R2ac(:,:,i) = vertcat(res.R2a{:,i});
    end
    if size(res.R2ff{:,i})
        R2ffc(:,:,i) = vertcat(res.R2ff{:,i});
    end
    if size(res.R2af{:,i})
        R2afc(:,:,i) = vertcat(res.R2af{:,i});
    end
end

%mean and std for each output accross iterations
MR2f = mean(R2fc,3);
MR2a = mean(R2ac,3);
MR2ff= mean(R2ffc,3);
MR2af= mean(R2afc,3);

SR2f = std(R2fc,0,3);
SR2a = std(R2ac,0,3);
SR2ff= std(R2ffc,0,3);
SR2af= std(R2afc,0,3);

%mean accross outputs and iterations
Mf = mean(MR2f,2);
Ma = mean(MR2a,2);
Mff= mean(MR2ff,2);
Maf= mean(MR2af,2);

SDf = sqrt(SR2f(:,1).^2+SR2f(:,2).^2)/2;
SDa = sqrt(SR2a(:,1).^2+SR2a(:,2).^2)/2;
SDff = sqrt(SR2ff(:,1).^2+SR2ff(:,2).^2)/2;
SDaf = sqrt(SR2af(:,1).^2+SR2af(:,2).^2)/2;

res.MR2a = MR2a;
res.MR2f = MR2f;
res.MR2ff= MR2ff;
res.Mr2af= MR2af;

%% Plots
figure;
hold on;
numpts = size(res.MR2f,1);

%calculate SD around mean curve
x = round([1:numpts numpts:-1:1]);

%fixed decoder, meanR2 +- SD (t = top, b = bottom)
yft = Mf+SDf; 
yfb = Mf-SDf; 
yf  = [yft; yfb(end:-1:1)];

%adapt decoder, meanR2 +- SD (t = top, b = bottom)
yat = Ma+SDa;
yab = Ma-SDa;
ya = [yat; yab(end:-1:1)];

%fixed decoder no drop/perm, meanR2 +- SD (t = top, b = bottom)
yfft = Mff+SDff;
yffb = Mff-SDff;
yff  = [yfft; yffb(end:-1:1)];

%adapt decoder no drop/perm, meanR2 +- SD (t = top, b = bottom)
yaft = Maf+SDaf;
yafb = Maf-SDaf;
yaf  = [yaft; yafb(end:-1:1)];

%plot means and SD for each
pink = [255 182 193]./255;
gray = [112 128 144]./255;
light_blue = [208 255 255]./255;
light_green= [0.5 1 0.5];

area(x,yff,'FaceColor',gray,'LineStyle','none');
area(x,yf,'FaceColor',light_blue,'LineStyle','none');
area(x,ya,'FaceColor',pink,'LineStyle','none');
area(x,yaf,'FaceColor',light_green,'LineStyle','none');

hf = plot(1:numpts,Mf,'b.-');
ha = plot(1:numpts,Ma,'r.-');
hff = plot(1:numpts,Mff,'k.-');
haf = plot(1:numpts,Maf,'g.-');
legend([hf,ha,hff,haf],'fixed model','adaptive model','fixed no drop/perm','adapt, no drop/perm');
title('Mean R^2');

% plot individual outputs
for i = 1:numOuts
    figure; hold on;

    %mean +-SD, then plot individual output mean on top of area
    x = [1:numpts numpts:-1:1];
    yft = MR2f(:,i)+SR2f(:,i);
    yfb = MR2f(:,i)-SR2f(:,i);
    yf  = [yft; yfb(end:-1:1)];
    yat = MR2a(:,i)+SR2a(:,i);
    yab = MR2a(:,i)-SR2a(:,i);
    ya = [yat; yab(end:-1:1)];
    yfft = MR2ff(:,i)+SR2ff(:,i);
    yffb = MR2ff(:,i)-SR2ff(:,i);
    yff  = [yfft; yffb(end:-1:1)];
    yaft = MR2ff(:,i)+SR2ff(:,i);
    yafb = MR2ff(:,i)-SR2ff(:,i);
    yaf  = [yaft; yafb(end:-1:1)];
    
    area(x,yff,'FaceColor',gray,'LineStyle','none');
    area(x,yf,'FaceColor',light_blue,'LineStyle','none');
    area(x,ya,'FaceColor',pink,'LineStyle','none');
    area(x,yaf,'FaceColor',light_green,'LineStyle','none');
    
    hf = plot(1:numpts,MR2f(:,i),'b.-');
    ha = plot(1:numpts,MR2a(:,i),'r.-');
    hff = plot(1:numpts,MR2ff(:,i),'k.-');
    haf = plot(1:numpts,MR2af(:,i),'g.-');
    
    legend([hf,ha,hff,haf],'fixed model','adaptive model','fixed no drop/perm','adapt, no drop/perm');
%     legend([hf,ha,hff],sprintf('fixed (R2 = %.2f)',mean(MR2f(:,i))),...
%         sprintf('adaptive (R2 = %.2f)',mean(MR2a(:,i))),...
%         sprintf('fixed no drop/perm (R2 = %.2f)',mean(MR2ff(:,i))));
    title(sprintf('%s',res.filter.outnames(i,:)));
end
