function pathToPLX=findPLXonCitadel(nameIn,suppressDialog)

% syntax pathToPLX=findPLXonCitadel(nameIn,suppressDialog)
%
% nameIn must include the .plx extension.

if nargin < 2
    suppressDialog=0;
end

[~,nameIn,~]=FileParts(nameIn);

animal=regexp(nameIn,'Chewie|Mini','match','once');

remoteDriveLetter='Z:';
switch animal
    case 'Chewie'
        spikeLFPfolder=fullfile(remoteDriveLetter,'Chewie_8I2','SpikeLFP');
    case 'Mini'
        spikeLFPfolder=fullfile(remoteDriveLetter,'Mini_7H1',...
            'Spikes and Local Field Potentials','MiniSpikeLFPL');
end
[status,result]=dos(['cd /d ',spikeLFPfolder,' && dir *',nameIn,'* /s /b']);

if status==0
    pathToPLX=result;
    pathToPLX(regexp(pathToPLX,sprintf('\n')))='';
else
    % revert to dialog, we couldn't automagically locate the
    % .plx file.
    if ~suppressDialog
        [FileName,PathName]=uigetfile('*.mat','select a bdf file');
        pathToPLX=fullfile(PathName,FileName);
    else
        error('file not found: %s\n',nameIn)
    end
end
pathToPLX(regexp(pathToPLX,sprintf('\n')))='';






