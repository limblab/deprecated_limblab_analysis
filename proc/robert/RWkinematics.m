function RWkinematics(PathName,onlyTT)

if ~nargin
	PathName=pwd;
	onlyTT=0;
elseif nargin==1
	onlyTT=0;
end

cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<!poly.*)\.mat'))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  quitting...\n.')
    return
end

for n=1:length(MATfiles)
	fprintf(1,'loading %s\n',MATfiles{n})
	load(MATfiles{n})
	if onlyTT
		fprintf(1,'calculating time-to-target\n')
		TT=timeToTarget_unNormalized(out_struct_kinonly);
		assignin('base',sprintf('TT_%s_HCorBC',regexp(MATfiles{n},'[0-9]*','match','once')),TT)
	else
		fprintf(1,'calculating path length and time-to-target\n')
		BRfile=FileNames(strcmp(FileNames,regexprep(MATfiles{n},'\.mat','.txt')));
		if ~isempty(BRfile)
			% Brain Control
			BRarray=readBrainReaderFile_function(BRfile{1});
			[PL,TT]=kinematicsBrainControl(out_struct_kinonly,BRarray, ...
				input(sprintf('enter the start time for %s: ',BRfile{1})));
			assignin('base',sprintf('PL_%s_BC',regexp(MATfiles{n},'[0-9]*','match','once')),PL)
			assignin('base',sprintf('TT_%s_BC',regexp(MATfiles{n},'[0-9]*','match','once')),TT)
		else
			% hand control
			[PL,TT]=kinematicsHandControl(out_struct_kinonly);
			assignin('base',sprintf('PL_%s_HC',regexp(MATfiles{n},'[0-9]*','match','once')),PL)
			assignin('base',sprintf('TT_%s_HC',regexp(MATfiles{n},'[0-9]*','match','once')),TT)
		end
	end
end