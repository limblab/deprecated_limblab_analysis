% load in data files and get force/vel data for all movement periods

% plot average velocity profile in BL, AD, WO for each monkey for each CO

% plot PD over windows of movement

clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
save_file = 'f-v-t_results.mat';

allFiles = {'Mihili','2014-01-14','VR','RT'; ...    %1  S(M-P)
    'Mihili','2014-01-15','VR','RT'; ...    %2  S(M-P)
    'Mihili','2014-01-16','VR','RT'; ...    %3  S(M-P)
    'Mihili','2014-02-03','FF','CO'; ...    %4  S(M-P)
    'Mihili','2014-02-14','FF','RT'; ...    %5  S(M-P)
    'Mihili','2014-02-17','FF','CO'; ...    %6  S(M-P)
    'Mihili','2014-02-18','FF','CO'; ...    %7  S(M-P) - Did both perturbations
    'Mihili','2014-02-18-VR','VR','CO'; ... %8  S(M-P) - Did both perturbations
    'Mihili','2014-02-21','FF','RT'; ...    %9  S(M-P)
    'Mihili','2014-02-24','FF','RT'; ...    %10 S(M-P) - Did both perturbations
    'Mihili','2014-02-24-VR','VR','RT'; ... %11 S(M-P) - Did both perturbations
    'Mihili','2014-03-03','VR','CO'; ...    %12 S(M-P)
    'Mihili','2014-03-04','VR','CO'; ...    %13 S(M-P)
    'Mihili','2014-03-06','VR','CO'; ...    %14 S(M-P)
    'Mihili','2014-03-07','FF','CO'; ...    % 15
    'Chewie','2013-10-03','VR','CO'; ... %16  S ?
    'Chewie','2013-10-09','VR','RT'; ... %17  S x
    'Chewie','2013-10-10','VR','RT'; ... %18  S ?
    'Chewie','2013-10-11','VR','RT'; ... %19  S x
    'Chewie','2013-10-22','FF','CO'; ... %20  S ?
    'Chewie','2013-10-23','FF','CO'; ... %21  S ?
    'Chewie','2013-10-28','FF','RT'; ... %22  S x
    'Chewie','2013-10-29','FF','RT'; ... %23  S x
    'Chewie','2013-10-31','FF','CO'; ... %24  S ?
    'Chewie','2013-11-01','FF','CO'; ... %25 S ?
    'Chewie','2013-12-03','FF','CO'; ... %26 S
    'Chewie','2013-12-04','FF','CO'; ... %27 S
    'Chewie','2013-12-09','FF','RT'; ... %28 S
    'Chewie','2013-12-10','FF','RT'; ... %29 S
    'Chewie','2013-12-12','VR','RT'; ... %30 S
    'Chewie','2013-12-13','VR','RT'; ... %31 S
    'Chewie','2013-12-17','FF','RT'; ... %32 S
    'Chewie','2013-12-18','FF','RT'; ... %33 S
    'Chewie','2013-12-19','VR','CO'; ... %34 S
    'Chewie','2013-12-20','VR','CO'};    %35 S


doFiles = allFiles(strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO'),:);

epochs = {'BL','AD','WO'};
colors = {'b','r','g'};
monkeys = {'Chewie','Mihili'};

holdTime = 0.5;

timeDelay = 0;
useWins = [0 0.3; ...
    0.1 0.4;...
    0.2 0.5;...
    0.3 0.6;...
    0.4 0.7;...
    0.5 0.8;...
    0.6 0.9;...
    0.7 1.0];

% useWins = [0 0.3; ...
%     0.05 0.35;...
%     0.1 0.4;...
%     0.15 0.45;...
%     0.2 0.5;...
%      0.25 0.55;
%     0.3 0.6;...
%      0.35 0.65;
%     0.4 0.7;...
%      0.45 0.75;
%     0.5 0.8;...
%      0.55 0.85;
%     0.6 0.9;...
%      0.65 0.95;
%     0.7 1.0];

%%
%load(fullfile(root_dir,save_file));

%%
for iFile = 1:size(doFiles,1)
    
    if strcmpi(doFiles{iFile,1},'Chewie')
        ind = 2;
    else
        ind = 3;
    end
    
    ind = 4;
    
    fn = fullfile(root_dir,doFiles{iFile,1},doFiles{iFile,2},[doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{2} '_' doFiles{iFile,2} '.mat']);
    data = load(fn);
    c = data.cont;
    
    [mt,~] = filterMovementTable(data,'movement',true,3,false);
    
    allT = [];
    allV = [];
    allF = [];
    
    winF = zeros(size(mt,1),size(useWins,1));
    winV = zeros(size(mt,1),size(useWins,1));
    for iMove = 1:size(mt,1)
        % get velocity between target presentation and trial end
        idx = c.t > mt(iMove,ind)-timeDelay & c.t < mt(iMove,6)-holdTime+timeDelay;
        
        t = c.t(idx);
        tmax = max(t);
        
        f = c.vel(idx,:);
        
        idx = find(idx) - 15;
        v = c.vel(idx,:);
        
        allT = [allT; t];
        allV = [allV; v];
        allF = [allF; f];
        
        
        for iWin = 1:size(useWins,1);
            tmin = t(1);
            tmax = t(end);
            
            tdiff = tmax-tmin;
            
            idx = t >= (tmin + useWins(iWin,1)*tdiff) & t <= (tmin + useWins(iWin,2)*tdiff);
            winF(iMove,iWin) = hypot(rms(f(idx,1)),rms(f(idx,2)));
            winV(iMove,iWin) = hypot(rms(v(idx,1)),rms(v(idx,2)));
        end
    end
    
    allMoves(iFile).t = allT;
    allMoves(iFile).v = allV;
    allMoves(iFile).f = allF;
    allMoves(iFile).mt = mt;
    allMoves(iFile).winV = winV;
    allMoves(iFile).winF = winF;
end


clear getMoves iFile iEpoch iMove v idx mt c data fn ind

%%
save(fullfile(root_dir,save_file));

%%
% % stitch together all files
% close all;
% allF = [];
% allV = [];
% for iFile = 1:size(doFiles,1)
%     allV = [allV; allMoves(iFile).v];
%     allF = [allF; allMoves(iFile).f];
% end
% 
% v = sqrt(allV(:,1).^2 + allV(:,2).^2);
% f = sqrt(allF(:,1).^2 + allF(:,2).^2);
% 
% [b,~,~,~,s] = regress(f,[ones(size(v)) v]);
% 
% figure;
% hold all;
% box off;
% plot(v,f);
% plot(v,b(1)+b(2)*v,'k','LineWidth',3);
% 
% figure;
% box off;
% [a,l]=xcorr(v,f,1000);
% [~,idx] = max(a);
% l(idx)
% plot(l,a);

%%
figure;

allF = [];
allV = [];
for iFile = 1:size(doFiles,1)
    allV = [allV; mean(allMoves(iFile).winV,1)];
    allF = [allF; mean(allMoves(iFile).winF,1)];
end

[ax,h1,h2] = plotyy(1:size(useWins,1),mean(allV,1),1:size(useWins,1),mean(allF,1));
set(ax(1),'TickDir','out','FontSize',14,'Box','off');
set(ax(2),'TickDir','out','FontSize',14,'Box','off');
xlabel(ax(1),'Movement Bins','FontSize',14);
ylabel(ax(1),'Velocity','FontSize',14);
ylabel(ax(2),'Force','FontSize',14);
title(ax(1),'~15 msec Velocity Shift','FontSize',16);

set(h1,'LineWidth',2);
set(h2,'LineWidth',2);