%% file info
[FileName,PathName,FilterIndex] = uigetfile([humanDataFolder,'/*.dat'],'select a *.dat file');
cd(PathName)
fnam=FileName(1:end-4);
%% load the file (BCI2000)
if ~isempty(regexpi(PathName,'force'))
	[fpAll,~]=bci2fparrMOD(fnam,'force',1000,2000);
else
	[fpAll,~]=bci2fparrMOD(fnam,'',1000,2000);
end
close
%% input parameters - Do not Change, just run.
fprange=input(sprintf('enter the range of signals to include in the analysis (%d total): ',size(fpAll,1)));
emgrange=input(sprintf('enter the range of emgs to include (out of %d): ',size(emgAll,2)));
disp('assigning static parameters')
fp=fpAll(fprange,:);
emg=emgAll(:,emgrange);
sig=double(emg);
signal='emg';
numfp=size(fp,1);
numsides=1;
fptimes=ttlTDT_time_vector;
Use_Thresh=0; words=[]; lambda=1;
analog_times=ttlTDT_time_vector;
emgsamplerate=1000;
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
folds=10; 
numlags=10; 
wsz=256;
% with 16 channels nfeat must be <= 96
nfeat=70;
PolynomialOrder=2;
smoothfeats=1;
binsize=0.1;

[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H] = ...
    predictionsfromfp5allMOD(sig,signal,numfp,binsize,folds,numlags, ...
    numsides,samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
close

disp(sprintf('\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n'))

%% examine r2
r2
% disp(FileName)
disp(sprintf('overall mean r2 %.4f',mean(r2(:))))
% junk=r2(:,4:6);
% disp(sprintf('mean r2 over %s, %s, and %s: %.4f',EMGchanList{4},EMGchanList{5}, ...
% 	EMGchanList{6},mean(junk(:))))
[val,ind]=max(mean(r2,2));
disp(sprintf('fold %d had highest mean over all EMGs: mean %.4f',ind,val))
[val,ind]=max(sum(r2,2));
disp(sprintf('fold %d had highest sum over all EMGs: sum %.4f',ind,val))
[val,ind]=max(r2(:));
[r,c]=ind2sub(size(r2),ind);
disp(sprintf('fold %d had the highest individual r2, in %s: %.4f', ...
    r,EMGchanList{emgrange(c)},r2(r,c)))
[~,c]=max(mean(r2));
disp(sprintf('the best muscle was %s, with mean %.4f across folds', ...
	EMGchanList{emgrange(c)},mean(r2(:,c))))
