% this script operates on a folder that contains 1 or more .mat
% files containing FP and position data

% folder/file info
if exist('PathName','var')~=1
    PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
end
% PathName=pwd;
if exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
% diary is preferable to fopen if we want to include a simple command like
% echoing r2 to the standard output and having it show up in the log.  On
% the other hand, standard output messages will also show up.
Files(1:2)=[];
FileNames={Files.name};
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'(?<!poly.*)\.mat'))==0);
MATfiles(cellfun(@isempty,regexp(MATfiles,'allFPsToPlot\.mat'))==0)=[];
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
    disp('quitting...')
    return
end

%%
for batchIndex=1:length(MATfiles)
	FileName=MATfiles{batchIndex};
	buildLFPpositionDecoderRDF
	% get rid of the plot generated by predictionsfromfp6.m
	close
    % save bestc, bestf for reference with allFPsToPlot
    load('allFPsToPlot.mat','cutfp')
    [~,nameNoExt,~,~]=fileparts(MATfiles{batchIndex});
    cutfp(cellfun(@isempty,regexp({cutfp.name},nameNoExt))==0).bestc=bestc;
    cutfp(cellfun(@isempty,regexp({cutfp.name},nameNoExt))==0).bestf=bestf;
    save('allFPsToPlot.mat','cutfp')    
end

% % save decoder on citadel.
% % remoteDriveLetter='Y';    % appropriate for offline sorting machine
% remoteDriveLetter='Z';      % appropriate for GOB
% pathBank={[remoteDriveLetter,':\Miller\Chewie_8I2\Filter files'], ...
%     [remoteDriveLetter,':\Miller\Mini_7H1\FilterFiles']};
% 
% animal=regexp(FileName,'Chewie|Mini','match','once');
% chosenPath=pathBank{cellfun(@isempty,regexpi(pathBank,animal))==0};
% D=dir(PathName);



