function runpred_channelDropLFP_Spike_VAF_best(PathName)

% is actually a batch file.

% create a folder for the outputs.  Create them with trailing numbers that
% will increment so that no folder is ever overwritten.
folderStr='channel_dropping_LFP_Spike1';
if exist(folderStr,'dir')~=0
    D=dir(PathName);
    folderStrNoNumbers=regexp(folderStr,'.*(?=[0-9])','match','once');
    folderNumbers=cellfun(@(x) str2num(x),regexp({D.name}, ...
        ['(?<=',folderStrNoNumbers,')[0-9]+'],'match','once'),'UniformOutput',0);
    folderNew=[folderStrNoNumbers, num2str(max(cat(2,folderNumbers{:}))+1)];
else
    folderNew=folderStr;
end
mkdir(folderNew)

% load in each BDF file, trim down the number of channels, then run
% predictionsfromfp5all.m as if that were all the LFP channels we have.
% Then run neuron dropping in a similar way.

if ~nargin
    % dialog
else
    cd(PathName)
    Files=dir(PathName);
    Files(1:2)=[];
    FileNames={Files.name};
    MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'[^EMGonly]\.mat'))==0 & ...
        cellfun(@isempty,regexp(FileNames,'[^poly][^0-9]\.mat'))==0);
    if isempty(MATfiles)
        fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
        disp('quitting...')
        return
    else
        %         contyes=input(sprintf('%d files found.  continue? (1 or 0): ',length(MATfiles)));
        %         if ~contyes, return, end
        %         skipAhead=input(sprintf('index to start (default 1): '));
        skipAhead=1; contyes=1;
    end
end


for i=skipAhead:length(MATfiles)
    FileName=MATfiles{i};
    load(FileName,'bdf')
    fnam=FileName(1:end-4);
    fprintf(1,'file: %s\n',fnam)
    
    % make sure the bdf has a .emg field
    bdf=createEMGfield(bdf);
    % the default for the creation of a bdf with a .emg field is for
    % bdf.emg.data to have N+1 columns for N emgs, where the first column
    % is a time vector and the rest are the EMG data.  Therefore, bdf after
    % passing through createEMGfield will have this as well.
    EMGchanNames=bdf.emg.emgnames;
    try
        emgsamplerate=bdf.emg.emgfreq;
    catch
        emgsamplerate=bdf.emg.freq;
    end
    % bdf.emg.data should just be an array, not cells or anything.
    sig=double(bdf.emg.data(:,2:end));
    analog_times=bdf.emg.data(:,1);
    
    if ~isempty(find(cellfun(@isempty,regexp(fnam,badEMGdays))==0, 1))
        [~,badChannels]=badEMGdays;
        currBadChans=badChannels{find(cellfun(@isempty,regexp(fnam,badEMGdays))==0,1)};
        EMGchanNames(currBadChans)=[];
        sig(:,currBadChans)=[];
    else
        currBadChans=[];
    end
    
    temg=analog_times;
    signal='emg';
    
    % Even after EMG channels are successfully extracted, there might still
    % remain force channels or something else.  So, be smart about what gets
    % included in fp.
    fpchans=find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'elec[0-9]'))==0);
    fp=double(cat(2,bdf.raw.analog.data{fpchans}))';
    samprate=bdf.raw.analog.adfreq(fpchans(1));
    % downsample fp
    if samprate > 1000
        % want final fs to be 1000
        disp('downsampling to 1 kHz')
        samp_fact=samprate/1000;
        downsampledTimeVector=linspace(analog_times(1),analog_times(end),length(analog_times)/samp_fact);
        fp=interp1(analog_times,fp',downsampledTimeVector)';
        samprate=1000;
    end
    
    numsides=1;
    fptimes=1/samprate:1/samprate:size(fp,2)/samprate;
    Use_Thresh=0; words=[]; lambda=1;
    
    disp('assigning tunable parameters and building the decoder...')
    folds=10;
    numlags=10;
    wsz=256;
    %     nfeat=150;
    PolynomialOrder=2;
    smoothfeats=0;
    binsize=0.05;
    if exist('fnam','var')~=1
        fnam='';
    end
    cells=[];
    
    % disabled channels for LFPs and spikes won't be the same, so include
    % every channel of 1:96, just substitute NaNs for whatever isn't
    % participating in the loop this time.
    LFPchansOn=str2num(char(regexp(bdf.raw.analog.channels,'(?<=elec)[0-9]+','match','once')));
    
    randomInds=randperm(96);
    EMGVAFmallLFP=nan(95,size(EMGchanNames,2));
    EMGVAFsdallLFP=nan(95,size(EMGchanNames,2));
    EMGVAFmallSpike=nan(95,size(EMGchanNames,2));
    EMGVAFsdallSpike=nan(95,size(EMGchanNames,2));
    
    numChansVector=[2:50, 52:2:96];
    for n=1:length(numChansVector)
        % trim the LFP channels.  Use random sample.  Make local copies for
        % each of LFP and spikes.
        disp(['LFP: ',num2str(numChansVector(n)),' channels'])
        if ~isempty(intersect(randomInds(numChansVector(n)),LFPchansOn))
            fpUse=fp(ismember(LFPchansOn,randomInds(1:numChansVector(n))),:);
            numfp=size(fpUse,1);
            if numfp*6 < 150
                nfeat=numfp*6;
            else
                nfeat=150;
            end
            
            [~,vmean,vsd,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = ...
                predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags, ...
                numsides,samprate,fpUse,fptimes,temg,fnam,wsz,nfeat,PolynomialOrder, ...
                Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
            close
            EMGVAFmallLFP(numChansVector(n)-1,:)=vmean;
            EMGVAFsdallLFP(numChansVector(n)-1,:)=vsd;
        end
        
        % trim the spike channels.  first, figure out what's there.
        disp(['Spike: ',num2str(numChansVector(n)),' channels'])
        unitChansOn=cat(1,bdf.units.id);
        
        if ~isempty(intersect(randomInds(numChansVector(n)),unitChansOn(:,1)))
            bdfUse=bdf;
            bdfUse.units=bdfUse.units(ismember(unitChansOn(:,1),randomInds(1:numChansVector(n))) & ...
                unitChansOn(:,2)~=0);
            bdfUse.emg.data=double(bdfUse.emg.data);
            if exist('currBadChans','var')==1 && ~isempty(currBadChans)
                bdfUse.emg.emgnames(currBadChans)=[];
                bdfUse.emg.data(:,[1 currBadChans+1])=[];
            end
            if size(bdfUse.emg.data,2)==(length(bdfUse.emg.emgnames)+1) && all(diff(bdfUse.emg.data(:,1)) > 0)
                bdfUse.emg.data(:,1)=[];
            end
            [~,vmean,vsd,~,~,~,~,~,~,~,~,~,~,~,~] = predictions_mwstikpolyMOD(bdfUse,signal, ...
                cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
            EMGVAFmallSpike(numChansVector(n)-1,:)=vmean;
            EMGVAFsdallSpike(numChansVector(n)-1,:)=vsd;
        end
        
    end
    
    save(fullfile(PathName,folderNew,[fnam,' chan_drop.mat']), ...
        'EMGVAFmallLFP','EMGVAFsdallLFP','EMGVAFmallSpike','EMGVAFsdallSpike','EMGchanNames')
end

copyfile(folderNew,['Y:\user_folders\Robert\data\monkey\outputs\',folderNew])
clock