%% Identify the files for loading - a data file, and a decoder file.
% if being called by something else, use the PathName that already exists.
% Assume FileName also exists.
if exist('PathName','var')~=1
	[FileName,PathName,FilterIndex] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.plx file','*.*');
	cd(PathName)
end
FileName
if isequal(get(0,'Diary'),'off')
    diary(fullfile(PathName,'decoderOutput.txt'))
end
%% load the file 
%  (skip this cell entirely if you've just loaded in a .mat file instead of
%  the .plx)
switch FileName(end-3:end)
    case '.mat'
        disp(['loading BDF structure from ',FileName])
        load(fullfile(PathName,FileName))
    case '.plx'
        out_struct=get_plexon_data(FileName);
        save([regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'],'out_struct')
end
fnam=FileName(1:end-4);
disp(sprintf('\n\n\n\n\n=====================\nFILE LOADED\n===================='))
%% input parameters - Do not Change, just run.
disp('assigning static variables')

% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% assign FPs, offloaded to script so it can be used in other places.
fpAssignScript
% look for something called CumulativeBadChannels and load it, then use it
% to cut down the fp array.
clear badChannels % in case this is being run as part of a batch loop
% if there is a remoteFolder2, load CumulativeBadChannels.mat from that.
% If not, try the current directory.
if exist('remoteFolder2','var')==1
    [remoteParentDir,~,~,~]=fileparts(remoteFolder2);
    FilesInfo=dir(remoteParentDir);
else
    disp('in order to exclude bad channels from CumulativeBadChans.mat')
    disp('you must copy it to the local directory (when building from a .mat file)')
    remoteParentDir='';
    FilesInfo=dir(PathName);
end
badChannelsFileInd=find(cellfun(@isempty,regexp({FilesInfo.name},'CumulativeBadChannels'))==0);
if ~isempty(badChannelsFileInd)
    fprintf(1,'loading bad channel info from %s',FilesInfo(badChannelsFileInd).name)
    load(fullfile(remoteParentDir,FilesInfo(badChannelsFileInd).name))
end
if exist('badChannels','var')==1
    disp('zeroing bad channels...')
    badChannels
    fp(badChannels,:)=zeros(length(badChannels),size(fp,2));
end
disp('static variables assigned')
%%
% 1st (and last?) second of data gets eliminated by calc_from_raw for the encoder
% timestampe (see out_struct.raw.analog.pos or .vel, so is inappropriate to
% include them in the fp signals.
if 0
    fp(:,fptimes<1 | fptimes>analog_times(end))=[];
    fptimes(fptimes<1 | fptimes>analog_times(end))=[];
end
%%
% downsample, so the delta band isn't empty at wsz=256; this is a current
% limitation of BrainReader.
if 0%samprate > 1000
    % want final fs to be 1000
    disp('downsampling to 1 kHz')
    samp_fact=samprate/1000;
    downsampledTimeVector=linspace(fptimes(1),fptimes(end),length(fptimes)/samp_fact);
    fp=interp1(fptimes,fp',downsampledTimeVector)';
    fptimes=downsampledTimeVector;
    downsampledTimeVector=linspace(analog_times(1),analog_times(end),length(analog_times)/samp_fact);
    downSampledBehaviorSignal=interp1(analog_times,sig(:,2:3),downsampledTimeVector);
    analog_times=downsampledTimeVector; clear downsampledTimeVector
    sig=[rowBoat(analog_times),downSampledBehaviorSignal];
    samprate=1000;
end

numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
numlags=10; 
wsz=256; 
nfeat=150;
PolynomialOrder=3; 
smoothfeats=0;
binsize=0.05;

%%
% DecoderPath is the entire path to the file, including the file name and
% the extension.
disp('loading decoder file')
if exist('DecoderPath','var')~=1
	[FileNameDecoder,PathNameDecoder,~] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a decoder file','*.*');
    DecoderPath=fullfile(PathNameDecoder,FileNameDecoder);
end
load(DecoderPath,'H','bestc','bestf')
fprintf(1,'%s loaded',DecoderPath)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
folds=10;
Hcell=cell(1,folds);
[Hcell{1:folds}]=deal(H);
[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
    featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
    predictionsfromfp6_inputDecoder(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Hcell,words,emgsamplerate,lambda,smoothfeats,[bestc bestf]);


% examine vaf
fprintf(1,'file %s\n',fnam)
fprintf(1,'decoding %s\n',signal)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d\n',nfeat)
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)

vaf

formatstr='vaf mean across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];

fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

diary off