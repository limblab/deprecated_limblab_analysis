%% Identify the file for loading
[FileName,PathName,FilterIndex] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.plx file','*.*');
cd(PathName)
diary([PathName,'decoderOutput.txt'])
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
disp(sprintf('\n\n\n\n\n=====================\nFILE LOADED\n===================='))
%% input parameters - Do not Change, just run.
disp('assigning static parameters')
fnam=FileName(1:end-4);

% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% FP
disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)),1);
if ~isempty(disJoint)
    disp('error, mismatched lengths in out_struct.raw.analog.data.  attempting to correct...')
	setLength=min(unique(cellfun(@length,out_struct.raw.analog.data)));
	for n=1:length(out_struct.raw.analog.data)
		out_struct.raw.analog.data{n}=out_struct.raw.analog.data{n}(1:setLength);
	end
end
disJoint=find(diff(cellfun(@length,out_struct.raw.analog.data)));
if ~isempty(disJoint)
    disp('still mismatched lengths in out_struct.raw.analog.data.  quitting...')
end

fpchans=find(cellfun(@isempty,regexp(out_struct.raw.analog.channels,'FP[0-9]+'))==0);
fp=double(cat(2,out_struct.raw.analog.data{fpchans}))';
samprate=out_struct.raw.analog.adfreq(fpchans(1));

% are all ts values the same for all channels?  Could be different on
% different preamps.
fptimes=out_struct.raw.analog.ts{1}(1):1/samprate: ...
    (size(out_struct.raw.analog.data{1},1)/samprate+out_struct.raw.analog.ts{1}(1));
if length(fptimes)==(size(fp,2)+1), fptimes(end)=[]; end
%%
% 1st (and last?) second of data gets eliminated by calc_from_raw for the encoder
% timestampe (see out_struct.raw.analog.pos or .vel, so is inappropriate to
% include them in the fp signals.
fp(:,fptimes<1 | fptimes>analog_times(end))=[];
fptimes(fptimes<1 | fptimes>analog_times(end))=[];

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
% to build a decoder:
% for n=1:3
%     fp=fp.*10;
%     
    [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
        featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
        buildModel_fp(sig,signal,numfp,binsize,numlags,numsides, ...
        samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
        Use_Thresh,words,emgsamplerate,lambda,smoothfeats);
    
    disp(sprintf('\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n'))
    
    % examine vaf
    fprintf(1,'file %s\n',fnam)
    fprintf(1,'decoding %s\n',signal)
    fprintf(1,'numlags=%d\n',numlags)
    fprintf(1,'wsz=%d\n',wsz)
    fprintf(1,'nfeat=%d\n',nfeat)
    fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
    fprintf(1,'smoothfeats=%d\n',smoothfeats)
    fprintf(1,'binsize=%.2f\n',binsize)
    fprintf(1,'gain factor=%d\n',10^n)
    
    vaf
    
    formatstr='vaf mean across folds: ';
    for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
    formatstr=[formatstr, '\n'];
    
    fprintf(1,formatstr,mean(vaf,1))
    fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))
    
    [range(H(:)), mean(abs(H))]
    close
    fprintf(1,'\n\n\n')
% end
%%
% transpose P?
P=P';
chanIDs = unique(bestc');
samplingFreq = samprate;
fillen=numlags*binsize;
neuronIDs='';
freq_bands =  [0,0;0,4;7,20;70,115;130,200;200,300];
featmat = [bestc', bestf']; 
f_bands = cell(numfp,1);

for i=1:numfp
    f_bands{i} = sortrows(freq_bands(featmat(featmat(:,1)==i,2),:),2);
end

% sort the H matrix so that it can be indexed by channel (present ordering
% is determined by degree of correlation to sig, not order).
cH = cell(nfeat,3);
for i=1:nfeat
    cH{i, 1} = bestc(i);
    cH{i, 2} = bestf(i);
    cHfirstr = numlags*(i-1)+1;
    cHlastr  = numlags*i;
    a = H(cHfirstr:cHlastr,:);
    cH{i, 3} = a;
end

[~, is] = sortrows(cell2mat(cH(:,1)),1);
cH = cH(is,:,:);
% do a secondary sort based on bestf
for i=1:numfp
    f = find([cH{:,1}]==i);
    if(~isempty(f))
        [~, is] = sortrows(cell2mat(cH(f,2)),1);
        cH(f,:) = cH(((min(f)-1)+is), :);
    end
end
H_sorted = cell2mat(cH(:,3));

% the appropriate one to save is H_sorted
H=H_sorted;

% H must be sorted, because the H matrix comes out of
% something that's ordered on the features, and the order of the features
% is caused by correlation to pos/vel, NOT channel order.
nameToSave=[fnam,'poly',num2str(PolynomialOrder),'_',num2str(nfeat)];
if smoothfeats
    nameToSave=[nameToSave,'smoothFeats'];
else
    nameToSave=[nameToSave,'feats'];
end
nameToSave=[nameToSave,signal,'-decoder.mat'];
save(fullfile(PathName,nameToSave),'H','P','neuronIDs','fillen','binsize', ...
	'chanIDs','samplingFreq','f_bands')
disp(sprintf('decoder saved in %s',PathName))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
folds=10;
[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
    featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
    predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats);


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

%% TODO: save decoder on citadel.
% % remoteDriveLetter='Y';    % appropriate for offline sorting machine
% remoteDriveLetter='Z';      % appropriate for GOB
% pathBank={[remoteDriveLetter,':\Miller\Chewie_8I2\Filter files'], ...
%     [remoteDriveLetter,':\Miller\Mini_7H1\FilterFiles']};
% 
% % 
% animal=regexp(FileName,'Chewie|Mini','match','once');
% chosenPath=pathBank{cellfun(@isempty,regexpi(pathBank,animal))==0};
% D=dir(PathName);
% copyfile([regexp(D(find(cellfun(@isempty,regexp({D.name},'[A-Za-z]+(?=[0-9]+\.mat)'))==0,1,'first')).name, ...
%     '[A-Za-z]+(?=[0-9]+\.mat)','match','once'),'*.mat'],remoteFolder)
% copyfile('LFP_EMGdecoder_results.txt',remoteFolder)

diary off