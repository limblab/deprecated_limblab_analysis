function runpred_neurondropVAF(directoryIn)

mkdir('neuron_dropping')

if ~nargin
	% dialog
else
	D=dir(directoryIn);
	D(1:2)=[];
	FileNames={D.name};
	MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'[^EMGonly]\.mat'))==0);
end

% need to be assigned:
lambda=1;
numlags=10;
numsides=1;
folds=10;
PolynomialOrder=2;
Use_Thresh=0;
binsize=0.05;
cells=[];

for i=1:length(MATfiles)
    EMGVmall=[];
    EMGVsdall=[];

	load(MATfiles{i},'bdf')
	
	% make sure the bdf has a .emg field
    bdf=createEMGfield(bdf);
	EMGchanNames=bdf.emg.emgnames;    
	if ~isempty(find(cellfun(@isempty,regexp(badEMGdays, ...
            regexp(MATfiles{i},'.*(?=sorted\.mat)','match','once')))==0, 1))
		[~,badChannels]=badEMGdays;
		currBadChans=badChannels{find(cellfun(@isempty,regexp(badEMGdays, ...
            regexp(MATfiles{i},'.*(?=sorted\.mat)','match','once')))==0,1)};
		EMGchanNames(currBadChans)=[];
        bdf.emg.data=bdf.emg.data(:,setdiff(2:size(bdf.emg.data,2),currBadChans));
	end
    signal='emg';

	% take only the sorted cells
	uList=unit_list(bdf);
    bdf.units(uList(:,2)==0)=[];
    
    nNeurons=[2:2:50,54:4:length(bdf.units)];
    
	for n=1:length(nNeurons)		
		bdfTemp=bdf;
		fprintf(1,'%d neurons, ',nNeurons(n))
		neuronind=randperm(max(nNeurons));
		bdfTemp.units=bdfTemp.units(neuronind(1:nNeurons(n)));
		
		[~,vmean,vsd,~,~,~,~,~,~,~,~,~,~,~,~] = predictions_mwstikpoly(bdfTemp,signal, ...
			cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
		
		EMGVmall=[EMGVmall;vmean];
		EMGVsdall=[EMGVsdall; vsd];
	end

	save(fullfile(directoryIn,'neuron_dropping',[MATfiles{i},' neurondrop.mat']), ...
		'EMGVmall','EMGVsdall','EMGchanNames','nNeurons')
	
	clear curr* uList bdfT* EMG* nNeurons
end


