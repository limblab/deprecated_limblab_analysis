function runpredfp_featdropVAF(directoryIn)

mkdir('feature_dropping')

if ~nargin
	% dialog
else
	D=dir(directoryIn);
	LFPfiles=find(cellfun(@isempty,regexp({D.name},'feats'))==0);
	
end

% these parameters should be loaded in with the file (it's an error if they're not):
% featMat
% y
% PolynomialOrder
% Use_Thresh
% binsize

% need to be assigned:
lambda=1;
numlags=10;
numsides=1;
folds=10;
nfeat=[2:2:50,54:4:150,154:10:500];

for i=1:length(LFPfiles)
    EMGVAFmall=[];
    EMGVAFsdall=[];
    EMGVmall=[];
    EMGVsdall=[];
    EMGVtrall=[];
    parindex=[];
	
	recordingName=char(regexpi(D(LFPfiles(i)).name,'[a-z_]+[0-9-_]+(?=\w+)','match'));
	fprintf(1,'file: %s\n',recordingName)
	
	load(D(LFPfiles(i)).name,'featMat','y','PolynomialOrder','Use_Thresh','binsize','EMGchanNames')
	if ~isempty(find(cellfun(@isempty,regexp(badEMGdays,recordingName))==0, 1))
		[~,badChannels]=badEMGdays;
		currBadChans=badChannels{find(cellfun(@isempty,regexp(badEMGdays,recordingName))==0,1)};
		EMGchanNames(currBadChans)=[];
		y(:,currBadChans)=[];
	end
	
	binsamprate=1/binsize;

	for n=1:length(nfeat)		
		fprintf(1,'%d features. ',nfeat(n))
		featind=randperm(max(nfeat));
		[vmean,vaf,vaftr,r2m,r2sd,r2,y_pred,y_test,ytnew,xtnew,H,P,keptFeatInd,vsd] = ...
			predonlyxy_newVAF(featMat,y,PolynomialOrder,Use_Thresh,lambda,numlags,numsides, ...
			binsamprate,folds,nfeat(n),featind(1:nfeat(n)));
		EMGVmall=[EMGVmall;vmean];
		EMGVsdall=[EMGVsdall; vsd];
% 		parindex=[parindex;[i lambda]];
	end
	
% 	if ~isempty(EMGR2mall)
% 		xvect=repmat(nfeat',1,size(EMGVmall,2));
% 		errorbar(xvect,EMGVmall,EMGVsdall/2)
% 		xlabel('nfeat')
% 		ylabel('VAF')
% 		fignam=[recordingName,' emgpred featdrop poly2lam1'];
% 		title(fignam)
% % 		saveas(gcf,[fignam,'.fig'])
% 	end

	save(fullfile(directoryIn,'feature_dropping',[recordingName,' featdrop.mat']), ...
		'EMGVmall','EMGVsdall','EMGchanNames')
	
	clear feat* v* y* x* r* emg* EMGchanNames H* P* k* curr* recordingName
end


