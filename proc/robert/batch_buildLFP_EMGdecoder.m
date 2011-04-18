% this script operates on a folder that contains 1 or more .nev/.ns3
% file pairs.

%% folder/file info
PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
if exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
diary('r2results.txt')
Files(1:2)=[];
FileNames={Files.name};
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'[^EMGonly]\.mat'))==0);
if isempty(MATfiles)
    disp('no MAT files found.  quitting...')
    return
end

for n=1:length(MATfiles)
    FileName=MATfiles{n};
    load(FileName)
    fnam=FileName(1:end-4);
    
    %% assign EMG
    if isfield(bdf,'emg')
        try
            emgsamplerate=bdf.emg.emgfreq;
        catch
            emgsamplerate=bdf.emg.freq;
        end
        sig=bdf.emg.data;
    else
        emgsamplerate=bdf.raw.analog.adfreq(1);
        emgchans=find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'ainp[0-9]'))==0);
        if ~isempty(emgchans)
            sig=cat(2,bdf.raw.analog.data{emgchans});
        else
            disp('No EMG channels found!  Stopping...')
            return
        end
    end
    analog_times=1/emgsamplerate:1/emgsamplerate:size(sig,1)/emgsamplerate;
    signal='emg';
    
    %% assign fp, static input parameters
    disp('assigning static parameters')
    disJoint=find(diff(cellfun(@length,bdf.raw.analog.data)));
    if ~isempty(disJoint)
        disp('error, mismatched lengths in bdf.raw.analog.data.  quitting...')
        return
    end
    % possible solution for the disJoint problem.
    % for n=disJoint+1:length(bdf.raw.analog.data)
    %     bdf.raw.analog.data{n}(end)=[];
    % end
    
    % Even after EMG channels are successfully extracted, there might still
    % remain force channels or something else.  So, be smart about what gets
    % included in fp.
    fpchans=find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'elec[0-9]'))==0);
    fp=cat(2,bdf.raw.analog.data{fpchans})';
    samprate=bdf.raw.analog.adfreq(fpchans(1));
    numfp=length(fpchans);
    numsides=1;
    fptimes=1/samprate:1/samprate:size(bdf.raw.analog.data{1},1)/samprate;
    Use_Thresh=0; words=[]; lambda=1;

    disp('assigning tunable parameters and building the decoder...')
    folds=10;
    numlags=10;
    wsz=256;
    nfeat=150;
    PolynomialOrder=3;
    smoothfeats=0;
    binsize=0.05;
    if exist('fnam','var')~=1
        fnam='';
    end
    
    [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H] = ...
        predictionsfromfp5allMOD(sig,signal,numfp,binsize,folds,numlags, ...
        numsides,samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
        Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
    close
    fprintf(1,'\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n')
    
    EMGchanNames={'BI','Tri','Adelt','Pdelt'};
    if exist('FileName','var')==1
        disp(FileName)
    end
    fprintf(1,'folds=%d\n',folds)
    fprintf(1,'numlags=%d\n',numlags)
    fprintf(1,'wsz=%d\n',wsz)
    fprintf(1,'nfeat=%d\n',nfeat)
    fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
    fprintf(1,'smoothfeats=%d\n',smoothfeats)
    fprintf(1,'binsize=%.2f\n',binsize)
    fprintf(1,'emgsamplerate=%d\n',emgsamplerate)
    
    r2
    
    fprintf(1,'EMG r2 mean across folds: %.4f   %.4f   %.4f   %.4f\n',mean(r2,1))
    fprintf(1,'overall mean r2 %.4f\n',mean(r2(:)))
    
    clear FileName fnam bdf emgsamplerate sig emgchans analog_times signal disJoint fpchans fp samprate numfp numsides fptimes
    clear folds numlags wsz nfeat PolynomialOrder smoothfeats binsize vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr bestf bestc
    clear H EMGchanNames
end
diary off
clear