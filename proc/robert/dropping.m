LFPchansOn=str2num(char(regexp(bdf.raw.analog.channels,'(?<=elec)[0-9]+','match','once')));

unitChansOn=cat(1,bdf.units.id);
% unitChansOn(unitChansOn(:,2)==0,:)=[];
% unitChansOn=unique(unitChansOn);

fp=rand(length(LFPchansOn),10000);

randomInds=randperm(96);

EMGVmallLFP=[];
EMGVmallSpike=[];

% not quite right.  need to subtract from index for fp so that we don't
% exceed the size of fp.
for n=2:96
	if ~isempty(intersect(randomInds(n),LFPchansOn))
		% run predictionsfromfp5all.m
		fpUse=fp(ismember(LFPchansOn,randomInds(1:n)),:);
		vaf=n*rand(1,1)/96;
		EMGVmallLFP=[EMGVmallLFP; vaf];
	else
		EMGVmallLFP=[EMGVmallLFP; NaN];
	end
	
	
	if ~isempty(intersect(randomInds(n),unitChansOn(:,1)))
		bdfUse=bdf;
		bdfUse.units=bdfUse.units(ismember(unitChansOn(:,1),randomInds(1:n)) & unitChansOn(:,2)~=0);
		% run predictions_mwstikpoly
		vaf=n*rand(1,1)/96;
		EMGVmallSpike=[EMGVmallSpike; vaf];
	else
		EMGVmallSpike=[EMGVmallSpike; NaN];
	end
end
