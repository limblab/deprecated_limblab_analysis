%% Identify the file for loading
[FileName,PathName,FilterIndex] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.plx file','*.plx');
cd(PathName)
%% load the file (skip if already loaded in .mat file)
bdf=get_plexon_data(FileName);
disp(sprintf('\n\n\n\n\n=====================\nFILE LOADED\n===================='))

%% input parameters - Do not Change, just run.
disp('assigning static parameters')

fnam=FileName(1:end-4);
disJoint=find(diff(cellfun(@length,bdf.raw.analog.data)));
if ~isempty(disJoint)
    disp('error, mismatched lengths in bdf.raw.analog.data.  quitting...')
    return
end
% possible solution for the disJoint problem.  
% for n=disJoint+1:length(bdf.raw.analog.data)
%     bdf.raw.analog.data{n}(end)=[];
% end
% different possible solution
% for n=1:disJoint
%     bdf.raw.analog.data{n}(end)=[];
% end
fpchans=find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'FP[0-9]+'))==0);
fp=double(cat(2,bdf.raw.analog.data{fpchans}))';
samprate=bdf.raw.analog.adfreq(fpchans(1));

sig=bdf.vel;
signal='vel';
numfp=size(fp,1);
numsides=1;
fptimes=1/samprate:1/samprate:size(bdf.raw.analog.data{1},1)/samprate;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
analog_times=sig(:,1);
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
folds=2; 
numlags=10; 
wsz=256; 
nfeat=100;
PolynomialOrder=2; 
smoothfeats=0;
binsize=0.05;

[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
    featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
    predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats);

disp(sprintf('\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n'))

% examine r2

vaf

formatstr='vaf mean across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];

fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))


%% pick a fold, and save (from EWL Convert2ReachDecoder)
FOLDTOSAVE=ind; % defaults to highest sum.  Can of course modify in any way.
if(~exist('Hall', 'var'))
	Hall = H;
end
H = Hall{FOLDTOSAVE};
nChans = numfp;

chanIDs = unique(bestc');
% detect when the recording was done; shift appropriately if earlier .plx.
% don't shift at all if .nev.  If later .plx, shift everything so that
% BrainReader doesn't have to.
% for i = 1:size(chanIDs,1);
% 	if(chanIDs(i) > 32)
% 		chanIDs(i) = chanIDs(i) + 32;
% 	end
% end
[~,~,extension,~]=fileparts(FileName);
% if isequal(extension,'.plx')
%     chanIDs=chanIDs+32;
% end

samplingFreq = samprate;
freq_bands =  [0,0;0,4;7,20;70,115;130,200;200,300];

featmat = [bestc', bestf']; 
nFeats = size(featmat,1);
f_bands = cell(nChans,1);

for i=1:nChans
    f_bands{i} = sortrows(freq_bands(featmat(featmat(:,1)==i,2),:),2);
end

cH = cell(nFeats,3);

for i=1:nFeats
    cH{i, 1} = bestc(i);
    cH{i, 2} = bestf(i);
    cHfirstr = numlags*(i-1)+1;
    cHlastr  = numlags*i;
    a = H(cHfirstr:cHlastr,:);
  %  a = flipdim(a,1);
    cH{i, 3} = a;
 %   cH{i, 3} = H(cHfirstr:cHlastr,:);
end

[trash, is] = sortrows(cell2mat(cH(:,1)),1);
cH = cH(is,:,:);
% do a secondary sort based on bestf
for i=1:nChans
    f = find([cH{:,1}]==i);
    if(~isempty(f))
        [trash, is] = sortrows(cell2mat(cH(f,2)),1);
        cH(f,:) = cH(((min(f)-1)+is), :);
    end
end

H_sorted = cell2mat(cH(:,3));
filterLength=numlags*binsize;

% I don't think the filter.xxxx are necessary.  Just the variables.
% H has to be from 1 fold.  NxM, with M the number of outputs
% P should be included
% must have neuronsIDs.  Can be empty if only going to do LFP decoding.
% fillen.
% chanIDs.  
% samplingFreq
% f_bands
%
% yes, H should probably be sorted, because the H matrix comes out of
% something that's ordered on the features, and the order of the features
% is caused by correlation to pos/vel, NOT channel order.
save(fullfile(PathName,[fnam,'-decoder.mat']))

% save(fullfile(PathName,[fnam,'-decoder.mat']),'FOLDTOSAVE','H','H_sorted','Hall',...
%     'PolynomialOrder','Use_Thresh','bestc','bestf','binsize','cH','chanIDs', ...
%     'f_bands','featmat','fnam','folds','freq_bands','lambda','nChans','nFeats', ...
%     'nfeat','numlags','numsides','r2','r2mean','r2sd','samplingFreq','samprate', ...
%     'signal','smoothfeats','vaf','vaftr','vmean','vsd','wsz','y_pred','y_test','filterLength')



disp(sprintf('decoder saved in %s',PathName))