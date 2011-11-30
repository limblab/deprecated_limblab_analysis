function [vaf_L,vaf_S]=optimal_lag(PathName)

if ~nargin
    PathName=pwd;
end
cd(PathName)
% cd('/Volumes/limblab/user_folders/Robert/data/monkey/outputs/Spike_LFP_EMG/outputs_1lag')
D=dir(pwd);

LFPfiles=find(cellfun(@isempty,regexp({D.name},'feats'))==0);
spikeFiles=find(cellfun(@isempty,regexp({D.name},'spikes'))==0);

LFPfiles=LFPfiles(sortCustomRegex({D(LFPfiles).name},{'Chewie','Mini','Jaco','Thor'}));
spikeFiles=spikeFiles(sortCustomRegex({D(spikeFiles).name},{'Chewie','Mini','Jaco','Thor'}));

vaf_L=[];
% LFP files
for n=1:length(LFPfiles)
	recordingName=regexp(D(LFPfiles(n)).name,['.*(?=',regexpi(D(LFPfiles(n)).name, ...
		'sortedtik|tik','match','once'),')'],'match','once')
    disp('LFPs')
    x_L{n}=load(D(LFPfiles(n)).name,'x');
    x_L{n}=x_L{n}.x;
    y_L{n}=load(D(LFPfiles(n)).name,'y');
    y_L{n}=y_L{n}.y;
	allEMGnamesL{n}=load(D(LFPfiles(n)).name,'EMGchanNames');	
	allEMGnamesL{n}=allEMGnamesL{n}.EMGchanNames;

    % it is a mistake to take out bad EMG days  from this function, because
    % it takes a while to run it would be better to include all days, then
    % exclude anything that requires exclusion only at the plotting level.
    for k=1:length(allEMGnamesL{n})
        [startInd,endInd]=regexp(allEMGnamesL{n}{k},'EMG_');
        allEMGnamesL{n}{k}(startInd:endInd)='';
    end
    
    for k=10:-1:1                          % [1 5 10 15 20]
        shiftedY=circshift(y_L{n},k);
        [~,vaf_L{n,k},~,~,~,~,y_pred,~,ytnew]=predonlyxy_nofeatselect(x_L{n}(k+1:end,:), ...
            shiftedY(k+1:end,:),3,0,1,1,1,1,10,0);
    end
end
vaf_L(:,sum(cellfun(@isempty,vaf_L),1)>0)=[];

vaf_S=[];
% spike files
for n=1:length(spikeFiles)
    % leave as LFPfiles in recordingName, for the sake of identifying the
    % badChannels
	recordingName=regexp(D(LFPfiles(n)).name,['.*(?=',regexpi(D(LFPfiles(n)).name, ...
		'sortedtik|tik','match','once'),')'],'match','once')
    disp('spikes')
    x_S{n}=load(D(spikeFiles(n)).name,'x');
    x_S{n}=x_S{n}.x;
    y_S{n}=load(D(spikeFiles(n)).name,'y');
    y_S{n}=y_S{n}.y;
	allEMGnamesS{n}=load(D(spikeFiles(n)).name,'EMGchanNames');	
	allEMGnamesS{n}=allEMGnamesS{n}.EMGchanNames;
    
    for k=1:length(allEMGnamesS{n})
        [startInd,endInd]=regexp(allEMGnamesS{n}{k},'EMG_');
        allEMGnamesS{n}{k}(startInd:endInd)='';
    end
    
    for k=10:-1:1                          % [1 5 10 15 20]
        shiftedY=circshift(y_S{n},k);
        [~,vaf_S{n,k},~,~,~,~,y_pred,~,ytnew]=predonlyxy_nofeatselect(x_S{n}(k+1:end,:), ...
            shiftedY(k+1:end,:),3,0,1,1,1,1,10,0);
    end
end
vaf_S(:,sum(cellfun(@isempty,vaf_S),1)>0)=[];




