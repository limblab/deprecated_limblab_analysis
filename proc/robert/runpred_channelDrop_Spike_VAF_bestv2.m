function runpred_channelDrop_Spike_VAF_bestv2(PathName)

% is actually a batch file.

% create a folder for the outputs.  Create them with trailing numbers that
% will increment so that no folder is ever overwritten.
cd(PathName)
folderStr='channel_dropping_Spike_bestv2_1';
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
        skipAhead=1;
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
    % bdf.emg.data should just be an array, not cells or anything.  
    currBadChans=[];
    
    signal='emg';
    
    numsides=1;
    Use_Thresh=0; lambda=1;    
    folds=10;
    numlags=10;
    PolynomialOrder=2;
    binsize=0.05;
    if exist('fnam','var')~=1
        fnam='';
    end
        
    unitChansOn=cat(1,bdf.units.id);

    % load in best channels information from decoder file.
    outputsDir=dir(fullfile(pwd,'outputs'));
    load(fullfile(pwd,'outputs',outputsDir(cellfun(@isempty,regexp({outputsDir.name}, ...
        [fnam,'spikes.*']))==0).name),'rmat')
    
    cells=unitChansOn;
    cells(cells(:,2)==0,:)=[];
    % WON'T ALWAYS BE 9.  but for the moment this suffices in
    % place of something more complicated.
    rmat=rmat(:,9);
    % average across channels with >1 neuron
    uniqueCells=unique(cells(:,1));
    for n=1:length(uniqueCells)
        % replace each entry with the average of all entries.
        rmat(cells(:,1)==uniqueCells(n))=mean(abs(rmat(cells(:,1)==uniqueCells(n))));
    end
    [~,bestR,~]=unique(rmat);
    % add from best to worst.  Comment to go the other way around.
    bestR=flipud(bestR);
    bestc=cells(bestR,1);

    EMGVAFmallSpike=nan(length(bestc),size(EMGchanNames,2));
    EMGVAFsdallSpike=nan(length(bestc),size(EMGchanNames,2));
    EMGVAFspikeFolds=cell(size(bestc));

    for n=1:length(bestc)        
        % trim the spike channels.
        disp(['Spike: ',num2str(n),' channels'])
        
        bdfUse=bdf;
        bdfUse.units(unitChansOn(:,2)==0)=[];
        bdfUse.units=bdfUse.units(ismember(cells(:,1),bestc(1:n)));
        
        bdfUse.emg.data=double(bdfUse.emg.data);
        if exist('currBadChans','var')==1 && ~isempty(currBadChans)
            bdfUse.emg.emgnames(currBadChans)=[];
            bdfUse.emg.data(:,[1 currBadChans+1])=[];
        end
        if size(bdfUse.emg.data,2)==(length(bdfUse.emg.emgnames)+1) && all(diff(bdfUse.emg.data(:,1)) > 0)
            bdfUse.emg.data(:,1)=[];
        end
        [vaf,vmean,vsd,~,~,~,~,~,~,~,~,~,~,~,~] = predictions_mwstikpolyMOD(bdfUse,signal, ...
            [],binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
        EMGVAFmallSpike(n,:)=vmean;
        EMGVAFsdallSpike(n,:)=vsd;
        vmean
        EMGVAFspikeFolds{n}=vaf;
    end
    
    save(fullfile(PathName,folderNew,[fnam,' chan_drop.mat']), ...
        'EMGVAFmallSpike','EMGVAFsdallSpike','EMGchanNames','EMGVAFspikeFolds')
end
