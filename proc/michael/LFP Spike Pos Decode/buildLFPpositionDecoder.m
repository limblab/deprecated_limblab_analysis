%% Identify the file for loading
[FileName,PathName,FilterIndex] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.plx file','*.plx');
cd(PathName)
%% load the file (skip if already loaded in .mat file)
bdf=get_plexon_dataNoUnits(FileName);
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
fp=cat(2,bdf.raw.analog.data{:})';
samprate=bdf.raw.analog.adfreq(1);
sig=bdf.pos;
signal='pos';
numfp=size(fp,1);
numsides=1;
fptimes=1/samprate:1/samprate:size(bdf.raw.analog.data{1},1)/samprate;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
analog_times=sig(:,1);
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
folds=10; 
numlags=10; 
wsz=256; 
nfeat=100; 
PolynomialOrder=2; 
smoothfeats=1;
binsize=0.1;

[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H] = ...
    predictionsfromfp5allMOD(sig,signal,numfp,binsize,folds,numlags, ...
    numsides,samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats);

disp(sprintf('\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n'))

% examine r2
r2
disp(sprintf('overall mean r2 %.4f',mean(r2(:))))
[val,ind]=max(mean(r2,2));
disp(sprintf('fold %d had highest mean over x and y: mean %.4f',ind,val))
[val,ind]=max(sum(r2,2));
disp(sprintf('fold %d had highest sum over x and y: sum %.4f',ind,val))
[val,ind]=max(r2(:));
[r,c]=ind2sub(size(r2),ind);
str='xy';
disp(sprintf('fold %d had the highest individual r2, in %s: %.4f', ...
    r,str(c),r2(r,c)))


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
if isequal(extension,'.plx')
    chanIDs=chanIDs+32;
end

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

save(fullfile(PathName,[fnam,'-decoder.mat']),'FOLDTOSAVE','H','H_sorted','Hall',...
    'PolynomialOrder','Use_Thresh','bestc','bestf','binsize','cH','chanIDs', ...
    'f_bands','featmat','fnam','folds','freq_bands','lambda','nChans','nFeats', ...
    'nfeat','numlags','numsides','r2','r2mean','r2sd','samplingFreq','samprate', ...
    'signal','smoothfeats','vaf','vaftr','vmean','vsd','wsz','y_pred','y_test','filterLength')

disp(sprintf('decoder saved in %s',PathName))