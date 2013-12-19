function [allUnitList,badChansGuess_lfp]=badChansFromMasterList(animalList)

for k=1:size(animalList,1)
    try
        load(findBDFonCitadel(animalList{k,1}))
        fprintf(1,'%s\n',findBDFonCitadel(animalList{k,1}))
        allUnitList{k}=unit_list(out_struct);                                               %#ok<*AGROW>
        
        fpAssignScript
        badChansGuess_lfp{k}=find(range(fp(1:32,:),2) >= ...
            (median(range(fp(1:32,:),2))+2*iqr(range(fp(1:32,:),2))));                      %#ok<*NODEF>
        badChansGuess_lfp{k}=[badChansGuess_lfp{k}; find(range(fp(1:32,:),2) <= ...
            (median(range(fp(1:32,:),2))-2*iqr(range(fp(1:32,:),2))))];
        
        badChansGuess_lfp{k}=[badChansGuess_lfp{k}; find(range(fp(33:64,:),2) >= ...
            (median(range(fp(33:64,:),2))+2*iqr(range(fp(33:64,:),2))))+32];
        badChansGuess_lfp{k}=[badChansGuess_lfp{k}; find(range(fp(33:64,:),2) <= ...
            (median(range(fp(33:64,:),2))-2*iqr(range(fp(33:64,:),2))))+32];
        
        badChansGuess_lfp{k}=[badChansGuess_lfp{k}; find(range(fp(65:96,:),2) >= ...
            (median(range(fp(65:96,:),2))+2*iqr(range(fp(65:96,:),2))))+64];
        badChansGuess_lfp{k}=[badChansGuess_lfp{k}; find(range(fp(65:96,:),2) <= ...
            (median(range(fp(65:96,:),2))-2*iqr(range(fp(65:96,:),2))))+64];
        
        % attempt to reconcile within the function?  probably not.
        clear out_struct fp fpchans fptimes samprate
    catch ME                                                                                %#ok<NASGU>
        assignin('base','allUnitList',allUnitList)
        assignin('base','badChansGuess_lfp',badChansGuess_lfp)
        continue
    end
end


return

%%  Chewie baseline LFPs
% some code that was used for plotting once the two return variables from
% this function were in hand
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'allChewieNames')                                                                       %#ok<*UNRCH>
channels=ones(96,length(allChewieNames));
% the "before" picture
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Chewie_badChansGuess_lfp')
for n=1:length(Chewie_badChansGuess_lfp)
    channels(Chewie_badChansGuess_lfp{n},n)=0; 
end, clear n
fig1=figure; imagesc(channels), colormap(gray)


%% Chewie baseline MSPs
units=zeros(96,length(allChewieNames));
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Chewie_allUnitList')
for n=1:length(Chewie_allUnitList)
    units(Chewie_allUnitList{n},n)=1; 
end, clear n
unitsFPsort=units([65:96 1:64],:);
fig2=figure; imagesc(unitsFPsort), colormap(gray)

%% Chewie LFPs, MSPs with bad channels & bad days removed
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Chewie_badChans_LFPandMSPauto')
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Chewie_badChans_assigned')
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Chewie_badDays')
figure(fig1)
imagesc(channels(setdiff(1:96,unique([Chewie_badChans_LFPandMSPauto; Chewie_badChans_assigned])), ...
    ~ismember(datenum(regexp(allChewieNames,'[0-9]{8}(?=[0-9]{3})','match','once'),'mmddyyyy'), ...
    datenum(Chewie_badDays))))
figure(fig2)
imagesc(unitsFPsort(setdiff(1:96,unique([Chewie_badChans_LFPandMSPauto; Chewie_badChans_assigned])), ...
    ~ismember(datenum(regexp(allChewieNames,'[0-9]{8}(?=[0-9]{3})','match','once'),'mmddyyyy'), ...
    datenum(Chewie_badDays))))


%%  Mini baseline LFPs
% some code that was used for plotting once the two return variables from
% this function were in hand
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'allMiniNames')                                                                       %#ok<*UNRCH>
channels=ones(96,length(allMiniNames));
% the "before" picture
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Mini_badChansGuess_lfp')
for n=1:length(Mini_badChansGuess_lfp)
    channels(Mini_badChansGuess_lfp{n},n)=0; 
end, clear n
fig1=figure; imagesc(channels), colormap(gray)


%% Mini baseline MSPs
units=zeros(96,length(allMiniNames));
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Mini_allUnitList')
for n=1:length(Mini_allUnitList)
    units(Mini_allUnitList{n},n)=1; 
end, clear n
unitsFPsort=units([65:96 1:64],:);
fig2=figure; imagesc(unitsFPsort), colormap(gray)


%% Mini LFPs, MSPs with bad channels removed.  No bad days identified yet (12-03-2013)
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Mini_badChans_LFPandMSPauto')
load('E:\personnel\RobertF\monkey_analyzed\LFP MSP stability\masterFileList.mat', ...
    'Mini_badChans_assigned')
figure(fig1)
imagesc(channels(setdiff(1:96,unique([Mini_badChans_LFPandMSPauto; Mini_badChans_assigned])),:))
figure(fig2)
imagesc(unitsFPsort(setdiff(1:96,unique([Mini_badChans_LFPandMSPauto; Mini_badChans_assigned])),:))
