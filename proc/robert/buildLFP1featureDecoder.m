function [vaf1feat,H,bestf1feat,bestc1feat]=buildLFP1featureDecoder(varargin)

% syntax buildLFPpositionDecoderRDF(PathName,skipBadChannelsAssignment,nfeat,featShift)
%
% inputs are optional, but must be supplied in order. i.e., in order to
% input featShift, must also input PathName, skipBadChannelsAssignment and nfeat.
% featShift is ZERO-BASED; i.e., to calculate feature 9, input 1,8 for
% nfeat & featShift because the first 8 features correspond to featShift 0 through 7.

numlags=10;
wsz=256;
nfeat=1; featShift=0;
PolynomialOrder=3;
smoothfeats=0;
binsize=0.05;
folds=10;
skipBadChannelsAssignment=1;
PathName='';

if nargin >= 1
    wholePath=varargin{1};
    [PathName,FileName,ext]=FileParts(wholePath);
    FileName=[FileName,ext];
end
if nargin >= 2
    skipBadChannelsAssignment=varargin{2};
end
if nargin >= 3
    nfeat=varargin{3};
    featShift=varargin{4};
end

%% Identify the file for loading
% if being called by something else, use the PathName that already exists.
% Assume FileName also exists.
if isempty(PathName)
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

if nfeat > size(fp,1)*6
    nfeat=6*size(fp,1);
end
disp('static variables assigned')

%%
numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%

[vaf1feat,~,~,~,y_pred,~,~,~,~,bestf1feat,bestc1feat,H,~,x,y,featMat,ytnew,~,~,~,featind,sr] = ...
    predictionsfromfp6_all1featDecoders(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats,1:6,featShift);
