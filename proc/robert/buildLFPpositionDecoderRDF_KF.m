% Identify the file for loading
% if being called by something else, use the PathName that already exists.
% Assume FileName also exists.
if exist('PathName','var')~=1
	[FileName,PathName,~] = uigetfile('E:\monkey data\','select a *.mat file','*.*');
	cd(PathName)
end
FileName
if isequal(get(0,'Diary'),'off')
    diary(fullfile(PathName,'decoderOutput.txt'))
end
% load the file 
disp(['loading BDF structure from ',FileName])
load(fullfile(PathName,FileName))
fnam=FileName(1:end-4);
fprintf(1,'\n\n\n\n\n=====================\nFILE LOADED\n====================')
% input parameters - Do not Change, just run.
disp('assigning static variables')

% behavior
signal='vel';
% sig=out_struct.(signal);
sig=[out_struct.pos, out_struct.vel(:,2:3)];
analog_times=sig(:,1);

% assign FPs, offloaded to script so it can be used in other places.
fpAssignScript
% look for something called CumulativeBadChannels and load it, then use it
% to cut down the fp array.
clear badChannels % in case this is being run as part of a batch loop
% if there is a remoteFolder2, load CumulativeBadChannels.mat from that.
% If not, try the current directory.
disp('in order to exclude bad channels listed in a CumulativeBadChans.mat')
disp('you must copy it to the local directory (when building from a .mat file)')
remoteParentDir='';
FilesInfo=dir(PathName);
badChannelsFileInd=find(cellfun(@isempty,regexp({FilesInfo.name},'CumulativeBadChannels'))==0);
if ~isempty(badChannelsFileInd)
    fprintf(1,'loading bad channel info from %s',FilesInfo(badChannelsFileInd).name)
    try
        load(fullfile(remoteParentDir,FilesInfo(badChannelsFileInd).name))
    catch ME
    end
else
    disp('skipping bad channels assignment.  Must zero out in H matrix!')
end
if exist('badChannels','var')==1
    disp('zeroing bad channels...')
    badChannels
    fp(badChannels,:)=zeros(length(badChannels),size(fp,2));
end
disp('static variables assigned')

numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')
% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
numlags=10; 
wsz=256; 
nfeat=100;
% nfeat=6*size(fp,1);
PolynomialOrder=3; 
smoothfeats=0;
binsize=0.05;

[A,C,Q,R,bestf,bestc] = ...
    buildModel_fp_KF(sig,signal,numfp,binsize,[],[], ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats);

%%%%%%%%%%%%%%%%%%%INTERMEDIATE STEP: RE-TRAINING ON BC DATA%%%%%%%%%%%%%%

[FileName,PathName,FilterIndex] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.mat file','*.*');
cd(PathName)
disp(['loading BDF structure from ',FileName])
load(fullfile(PathName,FileName))
fpAssignScript
% sig=out_struct.(signal);
sig=[out_struct.pos, out_struct.vel(:,2:3)];
analog_times=sig(:,1);
clear badChannels % in case this is being run as part of a batch loop
remoteParentDir='';
FilesInfo=dir(PathName);
badChannelsFileInd=find(cellfun(@isempty,regexp({FilesInfo.name},'CumulativeBadChannels'))==0);
if ~isempty(badChannelsFileInd)
    fprintf(1,'loading bad channel info from %s',FilesInfo(badChannelsFileInd).name)
    try
        load(fullfile(remoteParentDir,FilesInfo(badChannelsFileInd).name))
    catch ME
    end
else
    disp('skipping bad channels assignment.  Must zero out in H matrix!')
end
if exist('badChannels','var')==1
    disp('zeroing bad channels...')
    badChannels
    fp(badChannels,:)=zeros(length(badChannels),size(fp,2));
end
[C,R,bestf,bestc] = ...
    adaptModel_fp_KF(sig,signal,numfp,binsize,[],[], ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,out_struct.words,emgsamplerate,lambda,smoothfeats,A,C,Q,R, ...
    bestc,bestf,out_struct.targets.centers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
% folds=10;

[FileName,PathName,FilterIndex] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.mat file','*.*');
cd(PathName)
disp(['loading BDF structure from ',FileName])
load(fullfile(PathName,FileName))
fpAssignScript
% sig=out_struct.(signal);
sig=[out_struct.pos, out_struct.vel(:,2:3)];
analog_times=sig(:,1);
clear badChannels % in case this is being run as part of a batch loop
remoteParentDir='';
FilesInfo=dir(PathName);
badChannelsFileInd=find(cellfun(@isempty,regexp({FilesInfo.name},'CumulativeBadChannels'))==0);
if ~isempty(badChannelsFileInd)
    fprintf(1,'loading bad channel info from %s',FilesInfo(badChannelsFileInd).name)
    try
        load(fullfile(remoteParentDir,FilesInfo(badChannelsFileInd).name))
    catch ME
    end
else
    disp('skipping bad channels assignment.  Must zero out in H matrix!')
end
if exist('badChannels','var')==1
    disp('zeroing bad channels...')
    badChannels
    fp(badChannels,:)=zeros(length(badChannels),size(fp,2));
end

% eliminate inputs, in order: {folds,numlags,PolynomialOrder}
[vaf,vmean,vsd,y_test,y_pred,~,~,~,~,bestf,bestc,~,~,x,y,featMat] = ...
    predictionsfromfp6_KF(sig,signal,numfp,binsize,[],[],numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,[], ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats,1:6,A,C,Q,R,bestc,bestf);
                                                      % this is bandsToUse,
                                                      % can be omitted.
% examine vaf
fprintf(1,'file %s\n',FileName)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d\n',nfeat)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)

vaf

diary off