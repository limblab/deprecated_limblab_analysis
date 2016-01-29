% save path (make empty if you don't want to save)
save_dir = []; %'C:\Users\Matt Perich\Dropbox\lab\embc\Poster\figures\';
% has option to exclude files
excludeFiles = [];

%%
% This one is slightly different because for now I override the master file
fileInds = strcmpi(allFiles(:,1),'Mihili') & strcmpi(allFiles(:,4),'CO');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
metric = 'angle_error';

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'b','r','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'flipcw',flipClockwisePerts);

fileInds = strcmpi(allFiles(:,1),'Chewie') & strcmpi(allFiles(:,4),'CO');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'r','b','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'savepath',save_dir,'flipcw',flipClockwisePerts);

fileInds = strcmpi(allFiles(:,1),'Mihili') & strcmpi(allFiles(:,4),'RT');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);
metric = 'curvature';

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'b','r','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'flipcw',flipClockwisePerts);

fileInds = strcmpi(allFiles(:,1),'Chewie') & strcmpi(allFiles(:,4),'RT');
fileInds(excludeFiles) = 0;
doFiles = allFiles(fileInds,:);

fh=plotAdaptationOverTime('dir',root_dir,'dates',doFiles,'metric',metric,'colors',{'r','b','g','m','k','c','y','b','r','g','m','k','c','y','b','r','g','m','k','c','y'},'filter',false,'savepath',save_dir,'flipcw',flipClockwisePerts);
