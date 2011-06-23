function runpred_channelDropLFP_Spike_VAF(PathName)

% is actually a batch file.

% create a folder for the outputs
if exist('channel_dropping_LFP_Spike','dir')==0
	mkdir('channel_dropping_LFP_Spike')
end

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
        contyes=input(sprintf('%d files found.  continue? (1 or 0): ',length(MATfiles)));
        if ~contyes, return, end
    end
end


for i=1:length(MATfiles)
    EMGVAFmallLFP=[];
    EMGVAFsdallLFP=[];
    EMGVAFmallSpike=[];
    EMGVAFsdallSpike=[];
	
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
    cells=[];
    
    % disabled channels for LFPs and spikes won't be the same, so include
    % every channel of 1:96, just substitute NaNs for whatever isn't
    % participating in the loop this time.
	LFPchansOn=str2num(char(regexp(bdf.raw.analog.channels,'(?<=elec)[0-9]+','match','once')));

	randomInds=randperm(96);
    
    for numChans=2:96
        % trim the LFP channels.  Use random sample.  Make local copies for
        % each of LFP and spikes.
        disp(['LFP: ',num2str(numChans),' channels'])
		if ~isempty(intersect(randomInds(numChans),LFPchansOn))
			fpUse=fp(ismember(LFPchansOn,randomInds(1:numChans)),:);
			numfp=size(fpUse,1);
			if numfp*6 < 150
				nfeat=numfp*6;
			else
				nfeat=150;
			end
			
			[~,vmean,vsd,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = ...
				predictionsfromfp5allMOD(sig,signal,numfp,binsize,folds,numlags, ...
				numsides,samprate,fpUse,fptimes,temg,fnam,wsz,nfeat,PolynomialOrder, ...
				Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
			close
			EMGVAFmallLFP=[EMGVAFmallLFP; vmean];
			EMGVAFsdallLFP=[EMGVAFsdallLFP; vsd];
		else
			EMGVAFmallLFP=[EMGVAFmallLFP; NaN*ones(size(EMGchanNames))];
			EMGVAFsdallLFP=[EMGVAFsdallLFP; NaN*ones(size(EMGchanNames))];
		end

        % trim the spike channels.  first, figure out what's there.
        disp(['Spike: ',num2str(numChans),' channels'])
		unitChansOn=cat(1,bdf.units.id);

		if ~isempty(intersect(randomInds(numChans),unitChansOn(:,1)))
			bdfUse=bdf;
			bdfUse.units=bdfUse.units(ismember(unitChansOn(:,1),randomInds(1:numChans)) & ...
				unitChansOn(:,2)~=0);
			bdfUse.emg.data=double(bdfUse.emg.data);
			if length(bdfUse.emg.emgnames)+1 == size(bdfUse.emg.data,2)
				bdfUse.emg.data(:,1)=[];
			end
			if size(bdfUse.emg.data,2) > length(bdfUse.emg.emgnames) && ...
					all(diff(bdfUse.emg.data(:,1)) > 0)
				bdfUse.emg.data(:,1)=[];
			end
            bdfUse.emg.emgnames(currBadChans)=[];
            bdfUse.emg.data(:,[1 currBadChans+1])=[];
			if length(bdfUse.emg.emgnames)+1 == size(bdfUse.emg.data,2)
				bdfUse.emg.data(:,1)=[];
			end
			[~,vmean,vsd,~,~,~,~,~,~,~,~,~,~,~,~] = predictions_mwstikpolyMOD(bdfUse,signal, ...
				cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
			EMGVAFmallSpike=[EMGVAFmallSpike; vmean];
			EMGVAFsdallSpike=[EMGVAFsdallSpike; vsd];
		else
			EMGVAFmallSpike=[EMGVAFmallSpike; NaN*ones(size(EMGchanNames))];
			EMGVAFsdallSpike=[EMGVAFsdallSpike; NaN*ones(size(EMGchanNames))];			
		end
		
    end
	
	save(fullfile(PathName,'channel_dropping_LFP_Spike',[fnam,' chan_drop.mat']), ...
		'EMGVAFmallLFP','EMGVAFsdallLFP','EMGVAFmallSpike','EMGVAFsdallSpike','EMGchanNames')   
end


