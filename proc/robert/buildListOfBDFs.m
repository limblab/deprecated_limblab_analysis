function buildListOfBDFs(startFolder,varargin)

% syntax buildListOfBDFs(startFolder,'property1','value1',...)
%
% startFolder is the beginning folder in which to start the search.  Use
% its value to set the animal whose data you want to comb through.
%
%   INPUT PROPERTY KEYWORDS             POSSIBLE VALUE(S)
%                      
%           'file_type'                 {'plx','nev',['all']}
%           'duration'                  1x1 double - default 600 s.
%           'hold_time'                 1x1 double - default 0.2 s.
%           'control'                   {['hand'],'brain','spike','LFP'}
%           'order'                     {'first','last',['all']}
%
%   OUTPUT
%
%           a file will be saved to the directory that was current whenever
%           the function was run.
%
% Explanation of input property keywords:
%
%       duration - length of the recording in s.  600 for 10 min. file.
%       Will allow 10% tolerance error.  For 10 min file, that means 9 to
%       11 minute files will also be included in the list
% 
%       hold time - maximum allowable hold time.  The mean hold time 
%       (as calculated from bdf.words) must not be above this number.
%
%       control - hand control, brain control in general, or spike or LFP
%       control.
%
%       order - pick files that were the first of their kind in their
%       particular subfolder, or the last of their kind, or all applicable
%       files.

startingPath=pwd;

if ismac
    [status,result]=unix(['find ',startFolder,' -name "*.mat" -print']);
else
    [status,result]=dos(['cd /d ',startFolder,' && dir *.mat* /s /b']);
end

% don't bother opening a file if the result of the search was failure.
if status > 0
    error(result)
end

animal=regexp(startFolder,'Chewie|Mini','match','once');

if mod(length(varargin),2)~=0
    error('arguments beyond startFolder must occur in property/value pairs')
end
% determine file type.  
ftInputIndex=strcmpi(varargin,'file_type');
if ~isempty(ftInputIndex)
    ft=varargin{ftInputIndex+1};
else
    ft='all';
end
if strcmp(ft,'all'), ft='plx|nev'; end
% determine duration.  
durInputIndex=strcmpi(varargin,'duration');
if ~isempty(durInputIndex)
    duration=varargin{durInputIndex+1};
else
    duration=600;
end
% determine hold time.  
holdInputIndex=strcmpi(varargin,'hold_time');
if ~isempty(holdInputIndex)
    hold_time=varargin{holdInputIndex+1};
else
    hold_time=0.2;
end
% determine type of control.  
controlInputIndex=strcmpi(varargin,'control');
if ~isempty(controlInputIndex)
    control=varargin{controlInputIndex+1};
else
    control='hand';
end
% determine ordering.  
orderInputIndex=strcmpi(varargin,'order');
if ~isempty(orderInputIndex)
    order=varargin{orderInputIndex+1};
else
    order='all';
end
if strcmp(order,'all'), order='first|last'; end

% open the text file where we'll store our results.
% currentPath=pwd;
% cd(startingPath)
% fid=fopen(['BDFlist_',animal],'w');
% fprintf(fid,'');
% cd(currentPath)
fileIndex=0;

returns=[0 regexp(result,sprintf('\n'))];
for n=2:length(returns)
    candidatePath=result(returns(n-1)+1:returns(n)-1);
    if exist(candidatePath,'file')==2        
        S=load(candidatePath);
        fname=fieldnames(S); 
        fname(cellfun(@isempty,regexpi(fname,'bdf|out_struct')))=[];
        bdf=S.(fname{1}); clear S
        % file type
        if isempty(regexpi(bdf.meta.filename,ft))
            continue
        end
        % duration
        if (bdf.meta.duration < 0.9*duration || bdf.meta.duration > 1.1*duration)
            continue
        end
        % hold time
        reward_words=find(out_struct.words(:,2)==32);
        bdfMeanHold=mean(out_struct.words(reward_words,1)- ...
            out_struct.words(reward_words-1,1));
        if bdfMeanHold > hold_time
            continue
        end
        % order
        mean(bdf.vel(:)) >= 10
        % determine hand control by looking at bdf.pos and bdf.vel, both
        % range of values and size of arrays
        
    end
end


% write the whole path to the file
currentPath=pwd;
cd(startingPath)
fprintf(fid,'%s\n','');
cd(currentPath)














