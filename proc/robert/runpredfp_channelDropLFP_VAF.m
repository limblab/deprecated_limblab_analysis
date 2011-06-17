function runpredfp_channelDropLFP_VAF(PathName)

% is actually a batch file.

% create a folder for the outputs
mkdir('channel_dropping_LFP')

% for channel dropping there's no way around it; we're going to have to
% load in each BDF file, trim down the number of LFP channels, then run
% predictionsfromfp5all.m as if that were all the LFP channels we have.  We
% can NOT run predictionsfp_xyonly or whatever, because that utilizes a
% pre-arranged featMat, which is in some order that we can't know unless we
% have bestc, which isn't going to include all the channels so our analysis
% will run out at something like 85 out of 92 channels.

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
    end
end


for i=1:length(MATfiles)
    EMGVAFmall=[];
    EMGVAFsdall=[];
    EMGVmall=[];
    EMGVsdall=[];
    EMGVtrall=[];
    parindex=[];
	
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
    sig=bdf.emg.data(:,2:end);
    analog_times=bdf.emg.data(:,1);
    
    if ~isempty(find(cellfun(@isempty,regexp(fnam,badEMGdays))==0, 1))
        [~,badChannels]=badEMGdays;
        currBadChans=badChannels{find(cellfun(@isempty,regexp(fnam,badEMGdays))==0,1)};
        EMGchanNames(currBadChans)=[];
        sig(:,currBadChans)=[];
    end
    
    temg=analog_times;
    signal='emg';

    % Even after EMG channels are successfully extracted, there might still
    % remain force channels or something else.  So, be smart about what gets
    % included in fp.
    fpchans=find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'elec[0-9]'))==0);
    fp=cat(2,bdf.raw.analog.data{fpchans})';
    samprate=bdf.raw.analog.adfreq(fpchans(1));

    numsides=1;
    fptimes=1/samprate:1/samprate:size(bdf.raw.analog.data{1},1)/samprate;
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
    
    fpchansRandInd=randperm(length(fpchans));
    
    for numChans=2:length(fpchans)
        % trim the LFP channels.  Use random sample, since nothing is
        % ranked at this point.
        fpCut=fp(fpchansRandInd(1:numChans),:);
        numfp=size(fpCut,1);
        if numfp*6 < 150
            nfeat=numfp*6;
        else
            nfeat=150;
        end
        
        [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
            featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
            predictionsfromfp5allMOD(sig,signal,numfp,binsize,folds,numlags,numsides, ...
            samprate,fpCut,fptimes,temg,fnam,wsz,nfeat,PolynomialOrder, ...
            Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
        close
        EMGVmall=[EMGVmall;vmean];
        EMGVsdall=[EMGVsdall; vsd];
    end
	
	save(fullfile(PathName,'channel_dropping_LFP',[fnam,' chan_drop.mat']), ...
		'EMGVmall','EMGVsdall','EMGchanNames')
    
    
    
end


