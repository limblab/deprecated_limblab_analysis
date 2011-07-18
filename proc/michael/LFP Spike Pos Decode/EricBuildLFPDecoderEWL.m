function [saveList] = BuildLFPDecoderEWL(predModifier, fileDir, fileList, saveDir, UseThresh, nfeat, binsize, lambda, Poly,varargin)
%  function [saveList] = BuildLFPDecoderEWL(predModifier, fileDir, fileList, saveDir, useThresh, nFeat, binSize, lambda, poly)
%
%  Takes in an input fileDirectory, an arbitrary number of files, and a save fileDirectory
%  creates the same number of LFP signal decoders in the save fileDirectory.  Returns
%  a list with the filenames of the saved files.

%useThresh=0;
%nFeat=100;
%binSize=0.1;
%lambda=1;
% load_paths;
saveList = cell(length(fileList), 1);
if ~isempty(varargin)
    bdf=varargin{1};
end
% Go throught the listed files one by one.
for i=1:length(fileList)
	fName=fileList{i}

	fNameAndDir=[fileDir,fName];
	sName=[saveDir,fName];
	if ~exist([fNameAndDir,'.plx'],'file')
		error(['Cant find file:', fNameAndDir])
	end
	
	disp(strcat('Building decoder for: ', fName));
    if ~exist('bdf','var')
        disp('converting to mat format')
        bdf= get_plexon_data(strcat(fNameAndDir,'.plx'));
        save([sName,'.mat'],'bdf')
    end
	adfreq=bdf.raw.analog.adfreq(1);
	fp = cell2mat(bdf.raw.analog.data)';
%     fp=single(fp(33:end,:));
	fs = adfreq;
	if ~exist('fs','var')
		fs=1/(bdf.vel(2,1)-bdf.vel(1,1));
    end
    
    start_time = bdf.raw.enc(1,1);
        last_analog_time = min(cellfun('length',bdf.raw.analog.data) / fs);
        if isfield(bdf.raw,'enc') && ~isempty(bdf.raw.enc)
            last_enc_time = bdf.raw.enc(end,1);
            stop_time = floor( min( [last_enc_time last_analog_time] ) ) - 1;
        else
            stop_time = floor(last_analog_time)-1; %need -1 when using get_plexon_data
        end
%         analog_time_base = start_time:1/fs:stop_time;
        analog_time_base=bdf.pos(:,1);
        t2= (1:length(fp))/fs;
        
         fpadj=interp1(t2,fp',analog_time_base);
    fp=fpadj';
    clear fpadj
    

	
	words=bdf.words;
    lambda=1;
    sfeat=0;
	clear fparr fpind varargin
   
	if (~isempty(findstr(predModifier, 'pos')))
		[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y,featMat,ytnew,xtnew,predtbase] = predictionsfromfp5all(bdf.pos,...
			'pos',size(fp,1),binsize,10,10,1,fs,fp,analog_time_base,analog_time_base,fNameAndDir,256,nfeat,Poly,UseThresh,words,[],lambda,sfeat);
		saveNamePos = [sName,'tik pospred ',num2str(nfeat),' feats lambda',num2str(lambda),'Poly',num2str(Poly),'.mat']
        saveList{i} = saveNamePos;
		save( saveNamePos,'v*','y*','x*','r*','best*','H','featMat','Poly','Use*','binsize');
	end;
	if (~isempty(findstr(predModifier, 'vel')))
		[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y,featMat,ytnew,xtnew,predtbase] = predictionsfromfp5all(bdf.vel,...
			'vel', size(fp,1),binsize,10,10,1,fs,fp,analog_time_base,analog_time_base,fNameAndDir,256,nfeat,Poly,UseThresh,words,[],lambda,sfeat);
		saveNameVel = [sName,'tik velpred ',num2str(nfeat),' feats lambda',num2str(lambda),'Poly',num2str(Poly),'.mat']
		saveList{i} = saveNameVel;
		save(saveNameVel,'v*','y*','x*','r*','best*','H','featMat','Poly','Use*','binsize');
	end;

	
	
    
	clear fp bdf v* y* x* r* emg*
	close all
end
