function optimal_lag(PathName)

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

% LFP files
for n=1:length(LFPfiles)
	recordingName=regexp(D(LFPfiles(n)).name,['.*(?=',regexpi(D(LFPfiles(n)).name, ...
		'sortedtik|tik','match','once'),')'],'match','once');
    x_L{n}=load(D(LFPfiles(n)).name,'x');
    x_L{n}=x_L{n}.x;
    y_L{n}=load(D(LFPfiles(n)).name,'y');
    y_L{n}=y_L{n}.y;
	allEMGnamesL{n}=load(D(LFPfiles(n)).name,'EMGchanNames');	
	allEMGnamesL{n}=allEMGnamesL{n}.EMGchanNames;
        
	if ~isempty(find(cellfun(@isempty,regexp(badEMGdays,recordingName))==0, 1))
		[~,badChannels]=badEMGdays;
		currBadChans=badChannels{find(cellfun(@isempty,regexp(badEMGdays,recordingName))==0,1)};
		y_L{n}(:,currBadChans)=[];
		allEMGnamesL{n}(currBadChans)=[];
	end
	for k=1:length(allEMGnamesL{n})
		[startInd,endInd]=regexp(allEMGnamesL{n}{k},'EMG_');
		allEMGnamesL{n}{k}(startInd:endInd)='';
% 		allEMGnamesL{n}{k}=[char(regexp(recordingName,'[A-Z]','match','once')), ...
% 			'_',allEMGnamesL{n}{k}];
    end
    
    for k=[1 5 10 15 20]
        shiftedY=circshift(y_L{n},k);
        [~,vaf_L{n,k},~,~,~,~,y_pred,~,ytnew]=predonlyxy_nofeatselect(x_L{n}(k+1:end,:), ...
            shiftedY(k+1:end,:),3,0,1,1,1,1,10,0);
    end
end

% spike files
for n=1:length(spikeFiles)
	recordingName=regexp(D(LFPfiles(n)).name,['.*(?=',regexpi(D(LFPfiles(n)).name, ...
		'sortedtik|tik','match','once'),')'],'match','once');
    x_S{n}=load(D(LFPfiles(n)).name,'x');
    x_S{n}=x_S{n}.x;
    y_S{n}=load(D(LFPfiles(n)).name,'y');
    y_S{n}=y_S{n}.y;
	allEMGnamesS{n}=load(D(spikeFiles(n)).name,'EMGchanNames');	
	allEMGnamesS{n}=allEMGnamesS{n}.EMGchanNames;
    
	if ~isempty(find(cellfun(@isempty,regexp(badEMGdays,recordingName))==0, 1))
		[~,badChannels]=badEMGdays;
		currBadChans=badChannels{find(cellfun(@isempty,regexp(badEMGdays,recordingName))==0,1)};
		y_S{n}(:,currBadChans)=[];
		allEMGnamesS{n}(currBadChans)=[];
	end
	for k=1:length(allEMGnamesS{n})
		[startInd,endInd]=regexp(allEMGnamesS{n}{k},'EMG_');
		allEMGnamesS{n}{k}(startInd:endInd)='';
% 		allEMGnamesS{n}{k}=[char(regexp(recordingName,'[A-Z]','match','once')), ...
% 			'_',allEMGnamesS{n}{k}];
    end
    
    for k=[1 5 10 15 20]
        shiftedY=circshift(y_S{n},k);
        [~,vaf_S{n,k},~,~,~,~,y_pred,~,ytnew]=predonlyxy_nofeatselect(x_S{n}(k+1:end,:), ...
            shiftedY(k+1:end,:),3,0,1,1,1,1,10,0);
    end
end





