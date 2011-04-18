%% file info
[FileName,PathName,~] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.nev file','*.nev');
cd(PathName)
fnam=FileName(1:end-4);

%% preview the EMGs to make sure the file is worth messing with.
temp=EMGpreview_cerebus(FileName);
figure
try
    for n=1:4
        subplot(4,1,n)
        plot(temp.emg.data(:,1),temp.emg.data(:,1+n))
        ylabel(temp.emg.emgnames{n})
    end
    subplot(4,1,1), title(fnam)
    clear n
catch
    close
    disp('failed')
end

%% load the file (cerebus)
% for lab 3, must put in lab2!!  if you put in lab3, it will actually hit
% the default in calc_from_raw (line 122), which is lab1.
clear temp
bdf=get_cerebus_data(FileName,1);

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
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
folds=10; 
numlags=10; 
wsz=512;
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

%% examine r2
EMGchanNames={'BI','Adelt','Pdelt'};
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
