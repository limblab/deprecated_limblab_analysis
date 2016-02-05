function [vaf_L,vaf_S,lagsUsed]=optimal_lag(PathName,processFlag,lagsToUse)

% processFlag is 1 for LFP only, 2 for spikes only.  3 is both, or just
% leave the input off altogether, the default is to do both.

if ~nargin
    PathName=pwd;
    processFlag=3;
    lagsToUse=10:-1:-5;
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
if processFlag~=2
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
        
        for k=1:length(lagsToUse)                          %10:-1:-5;   [1 5 10 15 20]
            shiftedY=circshift(y_L{n},-lagsToUse(k));
            x=x_L{n};
            if lagsToUse(k) > 0
                % must eliminate last rows of y because they no longer make
                % sense.
                shiftedY(end-lagsToUse(k):end,:)=[];
                % x technically unchanged, but x and y must be the same
                % size.
                x(end-lagsToUse(k):end,:)=[];
            elseif lagsToUse(k) < 0
                % must eliminate FIRST rows of y because they no longer
                % make sense.
                shiftedY(1:abs(lagsToUse(k)),:)=[];
                % x must match y in size.
                x(1:abs(lagsToUse(k)),:)=[];
            end % if lagsToUse(k)==0, there's no need to eliminate anything.
            [~,vaf_L{n,k},~,~,~,~,y_pred,~,ytnew]=predonlyxy_nofeatselect(x,shiftedY,2,0,1,1,1,1,10,0);
        end
    end
    vaf_L(:,sum(cellfun(@isempty,vaf_L),1)>0)=[];
end

vaf_S=[];
% spike files
if processFlag > 1
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
        
        for k=1:length(lagsToUse)                          %10:-1:-5;  [1 5 10 15 20]
            shiftedY=circshift(y_S{n},-lagsToUse(k));
            x=x_S{n};
            if lagsToUse(k) > 0
                % must eliminate last rows of y because they no longer make
                % sense.
                shiftedY(end-lagsToUse(k):end,:)=[];
                % x technically unchanged, but x and y must be the same
                % size.
                x(end-lagsToUse(k):end,:)=[];
            elseif lagsToUse(k) < 0
                % must eliminate FIRST rows of y because they no longer
                % make sense.
                shiftedY(1:abs(lagsToUse(k)),:)=[];
                % x must match y in size.
                x(1:abs(lagsToUse(k)),:)=[];
            end % if lagsToUse(k)==0, there's no need to eliminate anything.
            [~,vaf_S{n,k},~,~,~,~,y_pred,~,ytnew]=predonlyxy_nofeatselect(x,shiftedY,2,0,1,1,1,1,10,0);
        end
    end
    vaf_S(:,sum(cellfun(@isempty,vaf_S),1)>0)=[];
end

lagsUsed=lagsToUse;


