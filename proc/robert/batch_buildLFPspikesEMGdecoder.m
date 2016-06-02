% this script operates on a folder that contains 1 or more .mat
% files containing FP and EMG data

%% folder/file info
PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
if exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
% diary is preferable to fopen if we want to include a simple command like
% echoing r2 to the standard output and having it show up in the log.  On
% the other hand, standard output messages will also show up.
% diary('LFP_EMGdecoder_results.txt');
Files(1:2)=[];
FileNames={Files.name};
% should exclude EMG files and output files (which usually end in
% 'polyN.mat')
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'[^EMGonly]\.mat'))==0);
% & ...    cellfun(@isempty,regexp(FileNames,'[^poly][^0-9]\.mat')));
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
    disp('quitting...')
    return
end

% master containment for r2 aggregate data
% r2LFP=cell(length(MATfiles),4);

for n=1:length(MATfiles)
    FileName=MATfiles{n};
    % only load the variable you want.  loading all loads in index n, which
    % is used by batch_get_cerebus_data, and saved.  Rather than
    % constricting the save, which destroys information, constrict the
    % load.
    load(FileName,'bdf')
    fnam=FileName(1:end-4);

    str=regexp(bdf.meta.datetime,' ','split');
    % r2LFP{n,1}=datestr(str{1},'mm-dd-yyyy');
    % r2LFP{n,2}=fnam;

    % make sure the bdf has a .emg field
    bdf=createEMGfield(bdf);
    % the default for the creation of a bdf with a .emg field is for
    % bdf.emg.data to have N+1 columns for N emgs, where the first column
    % is a time vector and the rest are the EMG data.  Therefore, bdf after
    % passing through createEMGfield will have this as well.

    try
        emgsamplerate=bdf.emg.emgfreq;
    catch
        emgsamplerate=bdf.emg.freq;
    end
    % bdf.emg.data should just be an array, not cells or anything.
    sig=double(bdf.emg.data(:,2:end));
    analog_times=bdf.emg.data(:,1);
%     analog_times=1/emgsamplerate:1/emgsamplerate:size(sig,1)/emgsamplerate;
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
    numfp=length(fpchans);
    fptimes=1/samprate:1/samprate:size(fp,2)/samprate;
    numsides=1;
    fse=emgsamplerate;
%     temg=(1/fse):(1/fse):(t2(end)+1/fse);
    temg=analog_times;

    Use_Thresh=0; words=[]; lambda=1;

    disp('assigning tunable parameters and building the decoder...')
    folds=10;
    numlags=10;
    wsz=256;
    nfeat=150;
%     nfeat=90; % for individual-powerband analysis only.
    PolynomialOrder=2;
    smoothfeats=0;
    binsize=0.05;
    if exist('fnam','var')~=1
        fnam='';
    end
    
    % in runpredfp_emgonly.m, temg takes the place of analog_times and so
    % it is substituted in its place in the input list below.
    [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
        featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
        predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
        samprate,fp,fptimes,temg,fnam,wsz,nfeat,PolynomialOrder, ...
        Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
    close
    fprintf(1,'\n\n\n\n\n=====================\nLFP predictions DONE\n====================\n\n\n\n')
    
    EMGchanNames=bdf.emg.emgnames; % {'BI','Tri','Adelt','Pdelt'};
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
    
    vaf
    
    formatstr='EMG vaf mean across folds: ';
    for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
    formatstr=[formatstr, '\n'];
    
    fprintf(1,formatstr,mean(vaf,1))
    fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

	% columns of r2matrix are: 
	% date	file	LFP_r2	good_EMGs	spike_r2	H
    % r2LFP{n,3}=r2;
	
    % consider creating a new folder, and saving this file AND THE SPIKES
    % FILE in it; that way if the thing has to be run > 1X because of an
    % error somewhere the loader won't choke on the new .mat files that
    % were added.
    if exist('outputs','dir')==0, mkdir('outputs'), end
    % comment the next clear statement to do in-depth troubleshooting
    clear PA PB Pmat
    save(['outputs\',fnam,'tik emgpred ',num2str(nfeat),' feats lambda',num2str(lambda),' poly',num2str(PolynomialOrder),'.mat'], ...
        'v*','y*','x*','r*','best*','H','feat*','P*','Use*','fse','temg','binsize','sr','smoothfeats','EMGchanNames');

    % clear all the outputs of the LFP predictions analysis, so there's no
    % confussion when things are re-generated for the spike prediction
    % analysis.
    clear vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr bestf bestc H bestfeat x y featMat ytnew xtnew predtbase P featind sr
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % now do spikes                                                                                                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    %% the units - take only sorted units
    uList=unit_list(bdf);
    bdf.units(uList(:,2)==0)=[];
    cells=[];
    
    % the version of predictions_mwstikpoly.m in the
    % s1_analysis/.../proc/marc folder is set to use the whole bdf.emg.data
    % field, so cut out the leading column if it's just times.
    if size(bdf.emg.data,2) > max(size(bdf.emg.emgnames)) && all(diff(bdf.emg.data(:,1)) > 0)
        bdf.emg.data(:,1)=[]; 
    end
    
    [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P] = ...
        predictions_mwstikpolyMOD(bdf,signal,cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
    close

    fprintf(1,'\n\n\n\n\n=====================\nspike predictions DONE\n====================\n\n\n\n')
    
    if exist('FileName','var')==1
        disp(FileName)
    end
    fprintf(1,'folds=%d\n',folds)
    fprintf(1,'numlags=%d\n',numlags)
    fprintf(1,'\n')
    fprintf(1,'\n')
    fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
    fprintf(1,'\n')
    fprintf(1,'binsize=%.2f\n',binsize)
    fprintf(1,'emgsamplerate=%d\n',emgsamplerate)
    
    vaf

    formatstr='EMG vaf mean across folds: ';
    for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
    formatstr=[formatstr, '\n'];
    fprintf(1,formatstr,mean(vaf,1))
    fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

    r2m=r2mean;
    save(['outputs\',fnam,'spikes tik emgpred ',num2str(binsize*1000),'ms bins lambda',num2str(lambda), ...
        ' poly',num2str(PolynomialOrder),'.mat'],'v*','y*','r*','x*','H','P','EMGchanNames','uList','rmat');
    
    clear FileName fnam bdf emgsamplerate sig emgchans analog_times signal disJoint fpchans fp samprate numfp numsides fptimes
    clear folds numlags wsz nfeat PolynomialOrder smoothfeats binsize vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr bestf bestc
    clear H EMGchanNames Use_Thresh formatstr k lambda str words fse temg P cells uList x* y*
    
end
clear n k ans r2* 
% diary off
% save([date,'r2results.mat'],r2LFP)

copyfile('outputs','\\165.124.111.234\limblab\user_folders\Robert\data\monkey\outputs')