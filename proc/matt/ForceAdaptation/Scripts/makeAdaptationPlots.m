clear
clc
close all;

% load each file and get cell classifications
root_dir = 'C:\Users\Matt Perich\Desktop\lab\data\';
save_dir = []; %'C:\Users\Matt Perich\Dropbox\lab\embc\Poster\figures\';

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

excludeFiles = [];

%%
fileInds = strcmpi(allFiles(:,1),'Mihili') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
metric = 'angle_error';

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'b','r','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false);

fileInds = strcmpi(allFiles(:,1),'Chewie') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'r','b','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'savepath',save_dir);

fileInds = strcmpi(allFiles(:,1),'Mihili') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'RT');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
metric = 'curvature';

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'b','r','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false);

fileInds = strcmpi(allFiles(:,1),'Chewie') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'RT');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'r','b','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'savepath',save_dir);

%% do angle error for CO
fileInds = strcmpi(allFiles(:,1),'Mihili') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
metric = 'angle_error';

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'b','r','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false);

fileInds = strcmpi(allFiles(:,1),'Chewie') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'CO');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);

fh=plotAdaptationOverTime('handle',fh,'dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'r','b','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'savepath',save_dir);

%% do curvature for RT
clear fh;
fileInds = strcmpi(allFiles(:,1),'Mihili') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'RT');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
metric = 'curvature';

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'b','r','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false);

fileInds = strcmpi(allFiles(:,1),'Chewie') & strcmpi(allFiles(:,3),'FF') & strcmpi(allFiles(:,4),'RT');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
fh=plotAdaptationOverTime('handle',fh,'dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'r','b','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'savepath',save_dir);

