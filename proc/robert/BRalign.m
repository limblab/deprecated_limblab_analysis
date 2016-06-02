%%
clear, close
%% open files
if exist('PathName','var')~=1 || (isnumeric(PathName) && PathName==0)
    [FileName,PathName,FilterIndex] = uigetfile('Y:\*.txt','select a *.txt file');
else % PathName exists, and consists of an actual path
    % check for FileName.  If it exists, just run without a dialog,
    % assuming fullfile(PathName,FileName) is the file we want (a re-run).
    % If FileName does not exist, then we're just trying to re-use the path
    % in order to avoid dialog calesthenics
    if exist('FileName','var')~=1
        [FileName,PathName,FilterIndex]=uigetfile([PathName,'*.txt'],'select a *.txt file');
    end
end
% if cancelled
if isnumeric(PathName) && PathName==0, return, end
disp('reading online array...')
onlineArray=readBrainReaderFile_function(fullfile(PathName,FileName));
disp('reading psuedo-online array...')
oldPathName=PathName;
PathName(regexp(PathName,'online'):end)='';
% difference in path to pseudoOnline array is that all the pseudoOnlines
% live in the top level directory under pseudoOnline; there is no
% sub-hierarchy for date.
PathName=[PathName,'pseudoOnline'];
D=dir(PathName);
psoArray=readBrainReaderFile_function(fullfile(PathName,D(cellfun(@isempty,regexp({D.name}, ...
    regexp(FileName,'.*(?=\.txt)','match','once')))==0).name));
disp('data read')
% reset to original, in case want to re-do without dialog.
PathName=oldPathName; clear oldPathName
%% get rid of any lead-in data
tmp=size(onlineArray,1);
onlineArray(onlineArray(:,7)==0,:)=[];
fprintf(1,'deleted %d lines from online array\n',tmp-size(onlineArray,1))
tmp=size(psoArray,1);
psoArray(psoArray(:,7)==0,:)=[];
fprintf(1,'deleted %d lines from pseudo-online array\n',tmp-size(psoArray,1))

% scale time vector
original_OLA_time=onlineArray(:,7);
onlineArray(:,7)=onlineArray(:,7)/1e9;
onlineArray(:,7)=onlineArray(:,7)-onlineArray(1,7);
psoArray(:,7)=psoArray(:,7)/1e9;
psoArray(:,7)=psoArray(:,7)-psoArray(1,7);

%% plot
figure, set(gcf,'Position',[8         270        1005         420])
set(gca,'Position',[0.0269    0.1100    0.9592    0.8150])

plot(onlineArray(:,7),onlineArray(:,5)); hold on, h=plot(psoArray(:,7),psoArray(:,5),'r');
draggable(h,'h')

disp('visually line up the two arrays, and execute the last cell when finished.')

%% find point in .plx file where BR file starts.  
if min(get(h,'xdata')) > 0
    fprintf(1,['\nexclude the first %.2f seconds of data from the BR file\n', ...
        'to align with the .plx data.\n'],min(get(h,'xdata')))
    [val,loc]=min(abs(onlineArray(:,7)-min(get(h,'xdata'))));
    fprintf(1,'Plexon recording startup\n')
    int64(original_OLA_time(loc))
end

%% 
clear D Fi* ans loc o* p* t* v* h