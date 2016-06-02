function pathToBDF=findBDFonGOB(nameIn,suppressDialog)

% syntax pathToBDF=findBDFonGOB(nameIn,suppressDialog)
%
% looks for a BDF-formatted file on GOB, making a few assumptions about
% where such things live.

if nargin < 2
    suppressDialog=0;
end

% if the file name as a .mat extension, keep it.
[~,~,ext]=fileparts(nameIn);

switch ext
    case '.plx'
        nameIn=regexprep(nameIn,'\.plx','\.mat');
    case '.txt'
         nameIn=regexprep(nameIn,'\.txt','\.mat');
    case '.mat'
%         nameIn=nameIn;
    otherwise
        nameIn=[nameIn, '.mat'];
end

animal=regexp(nameIn,'Chewie|Mini','match','once');

pathToGOBData=fullfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data',animal);
[status,result]=dos(['cd /d ',pathToGOBData,' && dir *',nameIn,'* /s /b']);
    
% evaluate, based on results of system commands to find file.
if status==0
    pathToBDF=result;
else
    % revert to dialog, we couldn't automagically locate the
    % BDF.
    if ~suppressDialog
        [FileName,PathName]=uigetfile('*.mat','select a bdf file');
        pathToBDF=fullfile(PathName,FileName);
    else
        error('file not found: %s\n',nameIn)
    end
end
