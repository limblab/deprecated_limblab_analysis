function plot_curs_traj_wf(binnedData,varargin)
% plot cursor path during the isometric wf task
%
%   usage: fh = plot_curs_traj_wf(binnedData,word_start,time_wrt_start,word_stop,time_wrt_stop,fh);
%   
%       binnedData      :   binnedData file format
%       varargin :
%           word_start      :   either 'Start' or 'Go_Cue' (default)
%           time_wrt_start  :   time in seconds wrt word_start to start ploting
%                               cursor trajectory. Can be positive or negative. default = 0.0s
%           word_stop       :   either 'tgt_hit' or 'end' (default)
%                               'tgt_hit' -> time of first target contact, or end
%                                            of trial if failure.
%                               'end'     -> time of trial end (reward, failure)
%           time_wrt_stop   :   time in seconds wrt word_stop to stop ploting
%                               cursor trajectory. Can be positive or negative. default = 0.0s
%           succ_only       :   boolean, 1 to plot only successful trials (default), 0 to plot all

%% argument handling

%default parameters:
word_start      = 'go_cue';
time_wrt_start  = 0.0;
word_stop       = 'end';
time_wrt_stop   = 0.0;
succ_only       = true;

if nargin >1 word_start     = varargin{2}; end
if nargin >2 time_wrt_start = varargin{3}; end
if nargin >3 word_stop      = varargin{4}; end
if nargin >4 time_wrt_stop  = varargin{5}; end
if nargin >5 succ_only      = varargin{6}; end

%% find start and end times to plot trajectories for all trials

num_trials = size(binnedData.trialtable,1);
plot_data = nan(num_trials,3); % [time_start, time_stop, tgt_id]
w = Words;

% start times:
if strcmpi(word_start,'go_cue')
    tt_start = find(strcmp('go/catch',binnedData.trialtablelabels));
elseif strcmpi(word_start,'start')
    tt_start  = find(strcmp('trial start time',binnedData.trialtablelabels));
else
    error('invalid ''word_start'' argument to plot_curs_traj')
end
plot_data(:,1) = binnedData.trialtable(:,tt_start) + time_wrt_start;

%tgt_id
plot_data(:,3) = binnedData.trialtable(:,strcmp('tgt_id',binnedData.trialtablelabels));

% stop times:
if strcmpi(word_stop,'tgt_hit')
    for t = 1:num_trials
        plot_data(t,2) = binnedData.words(find(binnedData.words(:,1) > binnedData.trialtable(t,tt_start) & ...
                                                binnedData.words(:,2) == w.OT_Hold,1,'first') ,1);
    end
elseif strcmpi(word_stop,'end')
    plot_data(:,2) = binnedData.trialtable(:,strcmp('trial end time',binnedData.trialtablelabels)) + time_wrt_stop;
else
    error('invalid ''word_stop'' argument to plot_curs_traj')
end

if succ_only
    plot_data = plot_data( binnedData.trialtable(:,strncmpi('result',binnedData.trialtablelabels,6)) == double('R'),:);
end

[t_min, t_max] = deal(binnedData.timeframe(1),binnedData.timeframe(end));
plot_data = plot_data(plot_data(:,1) > t_min & plot_data(:,2) < t_max,:);

n_valid_trials = size(plot_data,1);

%% Plot paths

tgt_colors = {'blue','lime','maroon','silver','aqua','green','red','black'};

figure; hold on;
for t = 1:n_valid_trials
    
    curs_xy = binnedData.cursorposbin( binnedData.timeframe >= plot_data(t,1) & ...
                                       binnedData.timeframe <= plot_data(t,2), :);                                 
    plot(curs_xy(:,1),curs_xy(:,2), 'color', rgb(tgt_colors{plot_data(t,3)}));
end

%% Plot Tgts
tgt_list = sort(unique(binnedData.trialtable(:,strcmp('tgt_id',binnedData.trialtablelabels))));

for i = 1:length(tgt_list)
    idx = find(binnedData.trialtable(:,strcmp(binnedData.trialtablelabels,'tgt_id')) == tgt_list(i),1,'first');
    
    %[ULx,ULy,LRx,LRy] = binnedData.trialtable(idx,2:5)
    
    LLx = binnedData.trialtable(idx,2); %ULx
    LLy = binnedData.trialtable(idx,5); %LRy
    w   = binnedData.trialtable(idx,4)- binnedData.trialtable(idx,2); %LRx-ULx;
    h   = binnedData.trialtable(idx,3)- binnedData.trialtable(idx,5); %ULy-LRy;

    rectangle('Position',[LLx,LLy,w,h],'EdgeColor',rgb(tgt_colors{tgt_list(i)}),'LineWidth',2);
end

