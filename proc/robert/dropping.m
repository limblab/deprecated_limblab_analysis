LFPchansOn=str2num(char(regexp(bdf.raw.analog.channels,'(?<=elec)[0-9]+','match','once')));

unitChansOn=cat(1,bdf.units.id);
unitChansOn(unitChansOn(:,2)==0,:)=[];
unitChansOn=unique(unitChansOn);

fp=rand(length(LFPchansOn),10000);

randomInds=randperm(96);

EMGVmallLFP=[];
EMGVmallSpike=[];

% not quite right.  need to subtract from index for fp so that we don't
% exceed the size of fp.
for n=2:96
	if ~isempty(intersect(randomInds(n),LFPchansOn))
		% run predictionsfromfp5all.m
		fpUse=fp(randomInds(ismember(randomInds(1:n),LFPchansOn)),:);
		vaf=n*rand(1,1)/96;
		EMGVmallLFP=[EMGVmallLFP; vaf];
	else
		EMGVmallLFP=[EMGVmallLFP; NaN];
	end
end
