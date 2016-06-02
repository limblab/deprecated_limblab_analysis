function [Chewie_kinStructAll_noFails,Chewie_kinStructAll_withFails,Mini_kinStructAll_noFails,Mini_kinStructAll_withFails]=earlyPerformanceStats

opts=struct('version',2,'includeFails',0);
dayList={'04-12-2012','04-13-2012','04-16-2012','04-17-2012', ...
    '04-18-2012','04-19-2012','04-20-2012','04-23-2012','04-24-2012', ...
    '04-25-2012','04-26-2012','04-27-2012','04-30-2012'};

for dayListInd=1:length(dayList)
    PathName=['E:\monkey data\Chewie\',dayList{dayListInd}];
    batch_get_cursor_kinematics
    save(fullfile(strrep(PathName,'E:\monkey data\Chewie', ...
        'Z:\Chewie_8I2\Filter files'),'kinStruct.mat'),'kinStruct')
end
Chewie_kinStructAll_noFails=[];
for dayListInd=1:length(dayList)
    load(['Z:\Chewie_8I2\Filter files\',dayList{dayListInd},'\kinStruct.mat'])
    Chewie_kinStructAll_noFails=[Chewie_kinStructAll_noFails, kinStruct];       %#ok<*AGROW>
    clear kinStruct
end

opts.includeFails=1;
for dayListInd=1:length(dayList)
    PathName=['E:\monkey data\Chewie\',dayList{dayListInd}];
    batch_get_cursor_kinematics
    save(fullfile(PathName,'kinStruct.mat'),'kinStruct')
end
Chewie_kinStructAll_withFails=[];
for dayListInd=1:length(dayList)
    load(['E:\monkey data\Chewie\',dayList{dayListInd},'\kinStruct.mat'])
    Chewie_kinStructAll_withFails=[Chewie_kinStructAll_withFails, kinStruct];
    clear kinStruct                        
end

%% if we want to re-run without doing all the processing above, can comment
%  everything down to here, or just put in a breakpoint around line 1, 
%  and skip directly to here.
if ~exist('Chewie_kinStructAll_noFails','var')
    Chewie_kinStructAll_noFails=evalin('base','Chewie_kinStructAll_noFails');
end
figure
plotPerformance(Chewie_kinStructAll_noFails, ...
    'LineStyle','none','Marker','o','MarkerEdgeColor','none', ...
    'MarkerFaceColor','r')
hold on
if ~exist('Chewie_kinStructAll_withFails','var')
    Chewie_kinStructAll_withFails=evalin('base','Chewie_kinStructAll_withFails');
end
plotPerformance(Chewie_kinStructAll_withFails, ...
    'LineStyle','none','Marker','o','MarkerEdgeColor','k', ...
    'MarkerFaceColor','none','LineWidth',2)


%%
opts.includeFails=0;
dayList={'04-13-2012','04-16-2012','04-17-2012', ...
    '04-18-2012','04-19-2012','04-20-2012','04-23-2012','04-24-2012', ...
    '04-25-2012','04-26-2012','04-27-2012','04-30-2012'};

for dayListInd=1:length(dayList)
    PathName=['E:\monkey data\Mini\',dayList{dayListInd}];
    batch_get_cursor_kinematics
    save(fullfile(strrep(PathName,'E:\monkey data\Mini', ...
        'Z:\Mini_7H1\FilterFiles'),'kinStruct.mat'),'kinStruct')
end
Mini_kinStructAll_noFails=[];
for dayListInd=1:length(dayList)
    load(['Z:\Mini_7H1\FilterFiles\',dayList{dayListInd},'\kinStruct.mat'])
    Mini_kinStructAll_noFails=[Mini_kinStructAll_noFails, kinStruct];
    clear kinStruct
end

opts.includeFails=1;                                                        %#ok<*STRNU>
for dayListInd=1:length(dayList)
    PathName=['E:\monkey data\Mini\',dayList{dayListInd}];
    batch_get_cursor_kinematics
    save(fullfile(PathName,'kinStruct.mat'),'kinStruct')
end
Mini_kinStructAll_withFails=[];
for dayListInd=1:length(dayList)
    load(['E:\monkey data\Mini\',dayList{dayListInd},'\kinStruct.mat'])
    Mini_kinStructAll_withFails=[Mini_kinStructAll_withFails, kinStruct];
    clear kinStruct                        
end

if ~exist('Mini_kinStructAll_noFails','var')
    Mini_kinStructAll_noFails=evalin('base','Mini_kinStructAll_noFails');
end
figure
plotPerformance(Mini_kinStructAll_noFails, ...
    'LineStyle','none','Marker','o','MarkerEdgeColor','none', ...
    'MarkerFaceColor','r')
hold on
if ~exist('Mini_kinStructAll_withFails','var')
    Mini_kinStructAll_withFails=evalin('base','Mini_kinStructAll_withFails');
end
plotPerformance(Mini_kinStructAll_withFails, ...
    'LineStyle','none','Marker','o','MarkerEdgeColor','k', ...
    'MarkerFaceColor','none','LineWidth',2)


function plotPerformance(kinStructAll,varargin)

BCdays=~isnan(cat(1,kinStructAll.decoder_age));
kinStructAll(~BCdays)=[];
wrongDecoders=cat(1,kinStructAll.decoder_age)>30;
kinStructAll(wrongDecoders)=[];
totDur=0;
for n=1:length(kinStructAll)
    totDur=totDur+kinStructAll(n).duration;
    subplot(2,1,2)
    plot(totDur-kinStructAll(n).duration+kinStructAll(n).trialTS(:,1), ...
        kinStructAll(n).TT,varargin{:})
    hold on
    plot(totDur+[1 1],get(gca,'Ylim'),'k--')
    set(gca,'Xlim',[min(get(gca,'Xlim')) totDur+1])
    subplot(2,1,1)
    plot(totDur-kinStructAll(n).duration+kinStructAll(n).slidingTime, ...
        kinStructAll(n).slidingAccuracy,varargin{:})
    hold on
    plot(totDur+[1 1],get(gca,'Ylim'),'k--')
    set(gca,'Xlim',[min(get(gca,'Xlim')) totDur+1])
end, clear n

