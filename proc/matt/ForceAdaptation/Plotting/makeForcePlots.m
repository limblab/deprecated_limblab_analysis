function makeForcePlots(data,saveFilePath,thresh)
close all;

if nargin < 3
    thresh = Inf;
    if nargin < 2
        saveFilePath = [];
    end
end

if isempty(thresh)
    thresh = Inf;
end

paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

force = data.cont.force;
vel = data.cont.vel;
pos = data.cont.pos;

epoch = data.meta.epoch;

thF = wrapAngle(atan2(force(:,2),force(:,1)),0);
thV = wrapAngle(atan2(vel(:,2),vel(:,1)),0);

fmag = hypot(force(:,1),force(:,2));
vmag = hypot(vel(:,1),vel(:,2));

badInds = vmag > thresh;
force(badInds,:) = [];
vel(badInds,:) = [];
pos(badInds,:) = [];
thF(badInds,:) = [];
thV(badInds,:) = [];
fmag(badInds,:) = [];
vmag(badInds,:) = [];

% % plot magnitude of force applied as a function of velocity direction
% figure;
% plot(thV,fmag,'.');
% title('force magnitude against movement direction','FontSize',14);
%
% plotScatterWithHist(thV,thF,'xlabel','movement direction (rad)','ylabel','force direction (rad)','xline',ph,'yline',ph,'nbins',40);

% H = plotScatterWithHist(vmag(goodinds),fmag(goodinds),'xlabel','velocity mag)','ylabel','force mag','xline',vthresh,'nbins',40);

%% make plots
figure;
subplot1(2,1);
subplot1(1);
hold all;
plot(thV,vmag,'b.');
ylabel('velocity mag','FontSize',fontSize);
axis('tight');

subplot1(2);
hold all;
plot(thV,fmag,'b.');
title('force magnitude against movement direction','FontSize',fontSize);
xlabel('velocity direction','FontSize',fontSize);
ylabel('force mag','FontSize',fontSize);
axis('tight');

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'force_vel.png');
    saveas(gcf,fn,'png');
end

figure;
hold all;
plot(vmag,fmag,'b.');
title('force magnitude against movement magnitude','FontSize',fontSize);
ylabel('force mag','FontSize',fontSize);
xlabel('velocity mag','FontSize',fontSize);
axis('tight');

% fit trendlines
[B1,~,~,~,temp] = regress(fmag,[ones(size(vmag)) vmag]);

% Plot the lines
plot(vmag,B1(1)+B1(2).*vmag,'kd','LineWidth',2);
legend({'',num2str(B1(2))});

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'force_line.png');
    saveas(gcf,fn,'png');
end

%% make surface plot of force magnitude as function of x/y velocity
xlin = linspace(min(vel(:,1)),max(vel(:,1)),1000);
ylin = linspace(min(vel(:,2)),max(vel(:,2)),1000);
[x,y] = meshgrid(xlin,ylin);

z = griddata(vel(:,1),vel(:,2),fmag,x,y,'cubic');
figure;
mesh(x,y,z);
colorbar;
view(gca,0,90);
xlabel('X-Velocity','FontSize',fontSize);
ylabel('Y-Velocity','FontSize',fontSize);
title('Magnitude of force applied','FontSize',fontSize);

if ~isempty(saveFilePath)
    fn = fullfile(saveFilePath,'force_mag.png');
    saveas(gcf,fn,'png');
end

% %% do the same for x/y position to make sure this doesn't change anything
% xlin = linspace(min(pos(:,1)),max(pos(:,1)),1000);
% ylin = linspace(min(pos(:,2)),max(pos(:,2)),1000);
% [x,y] = meshgrid(xlin,ylin);
%
% z = griddata(pos(:,1),pos(:,2),fmag,x,y,'cubic');
% figure;
% mesh(x,y,z);
% colorbar;
% view(gca,0,90);
% xlabel('X-Position','FontSize',14);
% ylabel('Y-Position','FontSize',14);
% title('Magnitude of force applied');
%


