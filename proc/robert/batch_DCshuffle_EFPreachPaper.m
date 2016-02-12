function CmatAll=batch_DCshuffle_EFPreachPaper(PathName)

% syntax CmatAll=batch_DCshuffle_EFPreachPaper(PathName);
%
% PathName may be omitted, a dialog will be presented.


% get the list of files in a folder
if ~nargin
    PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\',...
        'select folder with data files');
    if exist(PathName,'dir')~=7
        disp('folder not valid.  aborting...')
        return
    end
end
disp(PathName)
cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};

REstr='(Chewie|Mini)(SpikeL|E)FPL*[0-9]{3} discreteclass2nr4 anova lda analysis 7bins -0.2-0.5sec.mat';
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,REstr))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.\n')
    disp('quitting...')
    return
end

for n=1:length(MATfiles)
    % reset the seed on the random generator only once perfile, 
    % else all runs will be identical.
    k=1;
    CmatAll{n,k}=DCshuffle_EFPreachPaper(MATfiles{n},1);
    for k=2:100
        CmatAll{n,k}=DCshuffle_EFPreachPaper(MATfiles{n},0);
    end
    close
    fprintf(1,'\n\n\n\n%s done.\n\n\n\n',MATfiles{n})
    pause(30)
end

