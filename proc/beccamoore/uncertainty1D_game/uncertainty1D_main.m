






























%%
%
% Uncertainty Task Script: 1D Task with Optotrak or Mouse Input
%
%   Contains functionality for both the "target uncertainty" task
%       and "cursor feedback uncertainty" (Nature 2004) task
%
%   Author: Paul Wanda  pwanda@northwestern.edu
%       Last Updated: 11/15/2012
%
%   task-specific parameters must be edited here: uncertainty1D_taskparams.m
%   optotrak calibration routine here:            uncertainty1D_calibrate_optotrak.m
%
%
clc; clear all; close all;


%% Load task parameters
uncertainty1D_taskparams;

%% Calibration
global keyPressed
if useMouse 
    % Run Mouse Input calibration
    % Setup Workspace
    screenDim = get(0,'ScreenSize');
    screenH   = figure(1);
    clf;
    set(screenH,'ToolBar','No');
    set(screenH,'MenuBar','No');
    set(screenH,'Color',params.bg_color);
    c = gca;
    set(c,'XLimMode','manual');
    set(c,'YLimMode','manual');
    hold on
    set(screenH,'Position',[1 1 screenDim(3) screenDim(4)]);
    axis([-1.25 1.25 -1.25 1.25]);
    axis square;
    axis off;
    
    % Hide the Mouse Cursor
    P = ones(16,16)*NaN;
    set(gcf,'Pointer','custom','PointerShapeCData',P);
    set(gcf,'Renderer','painters')
    
    calFile = 'MOUSE_CALIBRATION';
    
    % Create a calibration target at the matlab origin
    calH = plot(0,0,'s');
    set(calH,'MarkerEdgeColor','w');
    set(calH,'MarkerFaceColor','w');
    set(calH,'MarkerSize',cal.cal_size*cal.m2marker);
    set(calH,'visible','on');
    % Returns position of click in matlab coordinates
    mlb_cal_pos(1,:) = ginput(1); 
    % Returns screen position of mouse
    scr_cal_pos(1,:) = get(0,'PointerLocation'); 
    
    % Repeat calibration along the x-axis
    set(calH,'XData',1,'YData',0);
    mlb_cal_pos(2,:) = ginput(1);
    scr_cal_pos(2,:) = get(0,'PointerLocation');
    
    % Repeat Calibration along the y-axis
    set(calH,'XData',0,'YData',1);
    mlb_cal_pos(3,:) = ginput(1);
    scr_cal_pos(3,:) = get(0,'PointerLocation');
    set(calH,'visible','off');
    
    % Set the screen origin is the location of the first click
    cal.scr_origin = scr_cal_pos(1,:);
    cal.mlb_origin = mlb_cal_pos(1,:);
    
    % Conversions for Matlab Coordinates to Screen Coordinates 
    mlb2scr(1)=(scr_cal_pos(2,1)-scr_cal_pos(1,1))/(mlb_cal_pos(2,1)-mlb_cal_pos(1,1));
    mlb2scr(2)=(scr_cal_pos(3,2)-scr_cal_pos(1,2))/(mlb_cal_pos(3,2)-mlb_cal_pos(1,2));
    scr2mlb = 1./mlb2scr;

    cal.mlb2scr = mlb2scr;
    cal.scr2mlb = 1./mlb2scr;
    
    %
    % PHYSICALLY MEASURE OPTOTRAK
    %
    % Measured to be X m = 1.0 matlab units
    %     mlb2m(1) = 0.1445;    % along the x-axis
    %     mlb2m(2) = 0.1480;    % along the y-axis
    mlb2m(1) = 0.1390;    % along the x-axis
    mlb2m(2) = 0.1460;    % along the y-axis
    m2mlb    = 1./mlb2m;
    
    cal.m2mlb   = m2mlb;
    cal.mlb2m   = 1./m2mlb;
    
    % Calibration Cursor
    calH = plot(0,0,'o');
    set(calH,'MarkerEdgeColor',params.cursor_color);
    set(calH,'MarkerFaceColor',params.cursor_color);
    set(calH,'MarkerSize',params.cursor_size*cal.m2marker);
    set(calH,'visible','on');
    
    % Test Calibration
    cal_time_start = clock;
    cal_timer = clock;
    while (etime(cal_timer,cal_time_start) < cal.caltest_time)
        cp = get(0,'PointerLocation')-cal.scr_origin;
        set(calH,'XData',cp(1)*scr2mlb(1),'YData',cp(2)*scr2mlb(2));
        drawnow
        cal_timer = clock;
    end
    set(calH,'visible','off');
    % optotrack settings
else
    % Set the path for the optotrak toolbox
    path (path,'C:\Documents and Settings\Konrad\My Documents\MATLAB\pwanda\OptotrakToolbox-2007-Dec-21');
    
    %Settings:
    coll.marker_num      = 1;   %the marker to use for the position information
    coll.NumMarkers      = 2;   %Number of markers in the collection.
    coll.FrameFrequency  = 100; %Frequency to collect data frames at.
    coll.MarkerFrequency = 2500;%Marker frequency for marker maximum on-time.
    coll.Threshold       = 30;  %Dynamic or Static Threshold value to use.
    coll.MinimumGain     = 160; %Minimum gain code amplification to use.
    coll.StreamData      = 0;   %Stream state for the data buffers.
    coll.DutyCycle       = 0.35;%Marker Duty Cycle to use.
    coll.Voltage         = 7;   %Voltage to use when turning on markers.
    coll.CollectionTime  = 1;   %Number of seconds of data to collect.
    coll.PreTriggerTime  = 0;   %Number of seconds to pre-trigger data by.
    coll.Flags={'OPTOTRAK_BUFFER_RAW_FLAG';'OPTOTRAK_GET_NEXT_FRAME_FLAG'};
    
    %--------------- SETUP ----------------------------------
    %Load the system of transputers.
    optotrak('TransputerLoadSystem','system');
    %Wait one second to let the system finish loading.
    pause(1);
    %Initialize the transputer system.
    optotrak('TransputerInitializeSystem',{'OPTO_LOG_ERRORS_FLAG'});
    %Set optional processing flags (this overides the settings in OPTOTRAK.INI).
    optotrak('OptotrakSetProcessingFlags',...
        {'OPTO_LIB_POLL_REAL_DATA';
        'OPTO_CONVERT_ON_HOST';
        'OPTO_RIGID_ON_HOST'});
    %Load the standard camera parameters.
    optotrak('OptotrakLoadCameraParameters','standard');
    %Set up a collection for the OPTOTRAK.
    optotrak('OptotrakSetupCollection',coll);
    %Activate the markers.
    optotrak('OptotrakActivateMarkers')
    
    % Load Optotrak Calibration
    filename_prefix = getDateFname(5);
    calFile = [current_subject_ID '_calibration_' getDateFname '.mat'];
    if ~isempty(dir(calFile))
        load(calFile);  %load calibration parameters
    else
        fprintf('ERR: Missing calibration file...')
        return;
    end
    
    opt2mlb = scale;
    mlb2opt = 1./opt2mlb;
    cal.opt2mlb = opt2mlb;
    cal.mlb2opt = mlb2opt;
    
    
    %
    % PHYSICALLY MEASURE OPTOTRAK
    %
    % Measured to be X m = 1.0 matlab units
    %     mlb2m(1) = 0.1445;    % along the x-axis
    %     mlb2m(2) = 0.1480;    % along the y-axis
    mlb2m(1) = 0.1390;    % along the x-axis
    mlb2m(2) = 0.1460;    % along the y-axis
    m2mlb = 1./mlb2m;
    cal.mlb2m = mlb2m;
    cal.m2mlb = m2mlb;
    
    cal.mlb_origin = [0 0];
end


%% Task Setup Processing
% Trial Blocks
num_blocks = size(blocks,2);

% These vectors contain the trial-by-trial task information for all trials
% (every block concatenated)
trials.target_sequence       = [];
trials.pert_sequence         = [];
trials.cursor_onoff          = [];
trials.outer_onoff           = [];
trials.slice_onoff           = [];
trials.slice_sequence        = [];
trials.block_size            = [];
trials.type                  = [];
trials.cloud_onoff           = [];
trials.cloud_sequence        = [];

% Build trial data for each block
for bi=1:num_blocks
    blk = blocks{bi};
    type = blk.type;
    
    % Block Type 0 is baseline
    %
    % All Targets in Same Location
    % Target Feedback can be on or off for all trials
    % Cursor Feedback can be on or off
    % Slices are always off
    % Clouds are always off
    % Perturbation (shift) is always off
    %
    %
    %
    if type == 0
        % if multiple directions,multiply the Nmain*other dirs
        block_size = blk.num_trials;
        
        % generate target sequence
        target_sequence = params.target_location*ones(1,block_size);
        
        % which trials to display target feedback
        outer_onoff = blk.target_vis*ones(1,block_size);
        
        % which trials to display cursor feedback
        cursor_onoff = blk.cursor_vis*ones(1,block_size);
        
        % which trials to display slice feedback
        slice_onoff = zeros(1,block_size);
        
        cloud_onoff = zeros(1,block_size);
        
        % baseline has no perturbations,no clouds
        pert_sequence =  zeros(1,block_size);
        slice_sequence = zeros(1,block_size);        
        cloud_sequence = zeros(1,block_size);
    % Block Type 1 is Timed Target Feedback Task
    %
    % All Targets in Same Location
    % Target Feedback can be on or off for all trials
    % Cursor Feedback can be on or off
    % Slices are always on
    % Clouds are always off
    % Perturbation (shift) is generated
    %
    %
    %
    elseif type == 1
        % if multiple directions,multiply the Nmain*other dirs
        block_size = blk.num_trials;
        
        % generate target sequence
        target_sequence = params.target_location*ones(1,block_size);
        
        % which trials to display target feedback
        outer_onoff =  blk.target_vis*ones(1,block_size);
        
        % which trials to display cursor feedback
        cursor_onoff = blk.cursor_vis*ones(1,block_size);
        
        % which trials to display slice feedback
        slice_onoff =  ones(1,block_size);
        cloud_onoff =  zeros(1,block_size);
        
        % baseline has no perturbations,no clouds
        pert_sequence = blk.pert_mean+blk.pert_std*randn(1,block_size);
        
        % Spawn feedback slices
        slice_stds = [];
        for sli=1:params.slice_num_types
            clear temp;temp = repmat(params.slice_std(sli),1,params.slice_ratio(sli));
            slice_stds = [slice_stds temp];
        end
        slice_sequence = slice_stds(ceil(sum(params.slice_ratio).*rand(block_size,1)));
        cloud_sequence = zeros(1,block_size);
    % Block Type 2 is Timed Cloud Feedback Task (Nature 2004)
    %
    % All Targets in Same Location
    % Target Feedback can be on or off for all trials
    % Cursor Feedback can be on or off
    % Slices are always off
    % Clouds are always on
    % Perturbation (shift) is generated
    %
    %
    %
    elseif type == 2
        % if multiple directions,multiply the Nmain*other dirs
        block_size = blk.num_trials;
        
        % generate target sequence
        target_sequence = params.target_location*ones(1,block_size);
        
        % which trials to display target feedback
        outer_onoff =  ones(1,block_size);
        
        % which trials to display cursor feedback
        cursor_onoff = blk.cursor_vis*ones(1,block_size);
        
        % which trials to display slice feedback
        cloud_onoff =  ones(1,block_size);
        slice_onoff = zeros(1,block_size);
        
        % distribute the perturbations normally
        pert_sequence = blk.pert_mean+blk.pert_std*randn(1,block_size);
        
        % Spawn clouds slices
        cloud_stds = [];
        for sli=1:params.cloud_num_types
            clear temp;temp = repmat(params.cloud_std(sli),1,params.cloud_ratio(sli));
            cloud_stds = [cloud_stds temp];
        end
        cloud_sequence = cloud_stds(ceil(sum(params.cloud_ratio).*rand(block_size,1)));
        slice_sequence = zeros(1,block_size);
     % Block Type 2 is Continuous Cloud Feedback Task
    %
    % All Targets in Same Location
    % Target Feedback can be on or off for all trials
    % Cursor Feedback can be on or off
    % Slices are always off
    % Clouds are always on
    % Perturbation (shift) is generated
    %
    %
    %       
 elseif type == 3
        % if multiple directions,multiply the Nmain*other dirs
        block_size = blk.num_trials;
        
        % generate target sequence
        target_sequence = params.target_location*ones(1,block_size);
        
        % which trials to display target feedback
        outer_onoff =  ones(1,block_size);
        
        % which trials to display cursor feedback
        cursor_onoff = blk.cursor_vis*ones(1,block_size);
        
        % which trials to display slice feedback
        cloud_onoff = ones(1,block_size);
        slice_onoff = zeros(1,block_size);
        
        % distribute the perturbations normally
        pert_sequence = blk.pert_mean+blk.pert_std*randn(1,block_size);
        
        % Spawn clouds 
        cloud_stds = [];
        for sli=1:params.cloud_num_types
            clear temp;temp = repmat(params.cloud_std(sli),1,params.cloud_ratio(sli));
            cloud_stds = [cloud_stds temp];
        end
        cloud_sequence = cloud_stds(ceil(sum(params.cloud_ratio).*rand(block_size,1)));
        slice_sequence = zeros(1,block_size);
    end
    
    % Save information for this block
    trials.target_sequence       = [trials.target_sequence target_sequence];
    trials.pert_sequence         = [trials.pert_sequence   pert_sequence];
    trials.cursor_onoff          = [trials.cursor_onoff    cursor_onoff];
    trials.outer_onoff           = [trials.outer_onoff     outer_onoff];
    trials.cloud_onoff           = [trials.cloud_onoff     cloud_onoff];
    trials.cloud_sequence        = [trials.cloud_sequence  cloud_sequence];
    trials.slice_onoff           = [trials.slice_onoff     slice_onoff];
    trials.slice_sequence        = [trials.slice_sequence  slice_sequence];
    trials.block_size            = [trials.block_size      block_size];
    trials.type                  = [trials.type            type];
end

% Total number of trials
trials.total_num_trials = length(trials.target_sequence);

%% Preallocate Outputs
outputs.hand                    = cell(1,trials.total_num_trials);
outputs.cursor                  = cell(1,trials.total_num_trials);
outputs.task_timer              = cell(1,trials.total_num_trials);
outputs.state                   = cell(1,trials.total_num_trials);
outputs.slices                  = cell(1,trials.total_num_trials);
outputs.raw_slices              = cell(1,trials.total_num_trials);
outputs.clouds                  = cell(1,trials.total_num_trials);
outputs.raw_clouds              = cell(1,trials.total_num_trials);
outputs.reward                  = cell(1,trials.total_num_trials);
outputs.endpoint                = cell(1,trials.total_num_trials);


%% Setup Workspace For Task
close all;
% Create Workspace
screenDim = get(0,'ScreenSize');
screenH = figure(1);
clf;
set(screenH,'ToolBar','No');
set(screenH,'MenuBar','No');
set(screenH,'Color',params.bg_color); % black
c = gca;
set(c,'XLimMode','manual');
set(c,'YLimMode','manual');
hold on
set(screenH,'Position',[1 1 screenDim(3) screenDim(4)]);
axis([-params.axis_x params.axis_x -params.axis_y params.axis_y]);
axis square;
axis off;
%
% fillscreen(screenH);

% Hide Mouse Cursor
P = ones(16,16)*NaN;
set(gcf,'Pointer','custom','PointerShapeCData',P);

% Renderer
set(gcf,'Renderer','painters')

target.positions_mlb(:,1) = params.target_radius*cal.m2mlb(1)*cos(trials.target_sequence)';
target.positions_mlb(:,2) = params.target_radius*cal.m2mlb(2)*sin(trials.target_sequence)';

% Initialize Target Bar
targetBarH = rectangle('Position',[0,0,params.axis_x*2,params.target_size*cal.m2mlb(2)],...
                       'EdgeColor',params.targetbar_color,'FaceColor',params.targetbar_color);
set(targetBarH,'visible','off');

% Initialize Outer Target
outerTargetH = rectangle('Position',[0,0,params.target_size*cal.m2mlb(1),params.target_size*cal.m2mlb(2)],'EdgeColor',params.target_color,'FaceColor',params.target_color);
set(outerTargetH,'visible','off');

% Initialize Center Target
centerTargetH = rectangle('Position',[0-params.center_size*cal.m2mlb(1)/2,0-params.center_size*cal.m2mlb(2)/2,params.center_size*cal.m2mlb(1),params.center_size*cal.m2mlb(2)],'EdgeColor',params.center_color,'FaceColor',params.center_color);
set(centerTargetH,'visible','on');

% Initialize Hand
handH=plot(0,0,'o');
set(handH,'MarkerEdgeColor',params.cursor_color);
set(handH,'MarkerFaceColor',params.cursor_color);
set(handH,'MarkerSize',params.cursor_size*cal.m2marker);
set(handH,'visible','off');

% Initialize Cursor
cursorH=plot(0,0,'o');
set(cursorH,'MarkerEdgeColor',params.cursor_color);
set(cursorH,'MarkerFaceColor',params.cursor_color);
set(cursorH,'MarkerSize',params.cursor_size*cal.m2marker);
set(cursorH,'visible','off');

% Initialize Endpoint Marker
cursorEndpointH=plot(0,0,'o');
set(cursorEndpointH,'MarkerEdgeColor',params.cursor_color);
set(cursorEndpointH,'MarkerFaceColor',params.cursor_color);
set(cursorEndpointH,'MarkerSize',params.cursor_size*cal.m2marker);
set(cursorEndpointH,'visible','off');

cloudH=zeros(1,1:params.cloud_num);
% Initialize Cursor Cloud
for cloud_i=1:params.cloud_num
    cloudH(cloud_i)=plot(0,0,'o');
    set(cloudH(cloud_i),'MarkerEdgeColor',params.cloud_color);
    set(cloudH(cloud_i),'MarkerFaceColor',params.cloud_color);
    set(cloudH(cloud_i),'MarkerSize',params.cloud_size*cal.m2marker);
    set(cloudH(cloud_i),'visible','off');
end

sliceH=zeros(1,1:params.slice_num);
% Initialize Target Slices
for sli=1:params.slice_num
    sliceH(sli)= rectangle('Position',[0,0,1,1],'EdgeColor',...
                        params.slice_color,'FaceColor',params.slice_color);
    set(sliceH(sli),'visible','off');
end


% Text Feedback
textF = text(0,0,'');
set(textF,'Color',[1 1 1]);
set(textF,'FontSize',10);

% Text Warnings
textW = text(0,0,'');
set(textW,'Color',[1 1 1]);
set(textW,'FontSize',10);

% Text Score
textS = text(0,1.25,'');
set(textS,'Color',[1 1 1]);
set(textS,'FontSize',10);

%% General Initialization and Defaults
%
set(centerTargetH,'visible','off');
set(outerTargetH,'visible','off');
set(handH,'visible','off');
set(cursorH,'visible','off');
for sli=1:params.slice_num
    set(sliceH(sli),'visible','off');
end
for cloud_i=1:params.cloud_num
    set(cloudH(cloud_i),'visible','off');
end

% Set First Target
current_target_pos_mlb = target.positions_mlb(1,:);

set(outerTargetH,'Position',...
    [current_target_pos_mlb(1)-params.target_size*cal.m2mlb(1)/2,...
     current_target_pos_mlb(2)-params.target_size*cal.m2mlb(2)/2,...
     params.target_size*cal.m2mlb(1),...
     params.target_size*cal.m2mlb(2)]);
set(outerTargetH,'visible','off');

% Initialize Target Bar
barwidth =2*params.axis_x*abs(sin(trials.target_sequence(1)))+...
      params.target_size*cal.m2mlb(1)*abs(cos(trials.target_sequence(1)));
barheight=2*params.axis_y*abs(cos(trials.target_sequence(1)))+...
      params.target_size*cal.m2mlb(2)*abs(sin(trials.target_sequence(1)));

set(targetBarH,'Position',[current_target_pos_mlb(1)-barwidth/2,...
                           current_target_pos_mlb(2)-barheight/2,...
                           barwidth,...
                           barheight]);
set(targetBarH,'visible','off');

% Other Defaults
state = gamemode.PRETRIAL;
modeChanged   = false;
trial_counter = 1;
current_shift = 0;
current_shift_mlb = current_shift.*cal.m2mlb;

%% Main Task Loop over the trials

% gamemode.PRETRIAL     = 100;
% gamemode.CENTER_DRAW  = 200;
% gamemode.CENTER_HOLD  = 300;
% gamemode.CENTER_DELAY = 400;
% gamemode.MOVEMENT     = 500;
% gamemode.TARGET_HOLD  = 600;
% gamemode.REWARD       = 700;
% gamemode.FAIL         = 701;
% gamemode.ABORT        = 702;
% gamemode.INCOMPLETE   = 703;

% Initialize Trial Outputs
saved_hand            = [];%
saved_cursor          = [];%
saved_state           = [];%
saved_task_timer      = [];%
saved_outcome         = [];%
saved_endpoint        = [];%
saved_clouds          = [];
saved_rawclouds       = [];
saved_slices          = [];%
saved_rawslices       = [];%

%% Set Up Timers

task_timer_start    = clock;
task_timer          = task_timer_start;
state_timer         = task_timer_start;
state_timer_start   = task_timer_start;

running_total_rewards = 0;
block_num             = 1;
block_breaks          = cumsum(trials.block_size);

% Update Position Initial
if useMouse
    % From MOUSE
    current_hand_pos_raw = get(0,'PointerLocation')-cal.scr_origin;
    current_hand_pos_mlb = current_hand_pos_raw.*cal.scr2mlb;
else
    % FROM OPTOTRAK
    data = optotrak('DataGetLatest3D',coll.NumMarkers);
    current_pos_raw = data.Markers{coll.marker_num};
    if ~isempty(current_pos_raw)
        posShow = (A*(current_pos_raw-Store{2}))';
        current_hand_pos_mlb=(posShow.*cal.opt2mlb+cal.mlb_origin);
    end
end
current_cursor_pos_mlb = current_hand_pos_mlb;

% Main Task Loop
while trial_counter <= trials.total_num_trials
    %Update Clocks
    current_clock   = clock;
    state_timer     = current_clock;
	task_timer      = current_clock;

    previous_hand_pos_mlb = current_hand_pos_mlb;
    previous_cursor_pos_mlb = current_cursor_pos_mlb;
    
    % Update Positions
    if useMouse
        % From MOUSE
        current_hand_pos_raw = get(0,'PointerLocation')-cal.scr_origin;
        current_hand_pos_mlb = current_hand_pos_raw.*cal.scr2mlb;
    else
        % FROM OPTOTRAK
        data = optotrak('DataGetLatest3D',coll.NumMarkers);
        current_pos_raw = data.Markers{coll.marker_num};
        if ~isempty(current_pos_raw)
            posShow = (A*(current_pos_raw-Store{2}))';
            current_hand_pos_mlb=(posShow.*cal.opt2mlb+cal.mlb_origin);
        end
    end
    
    % Set the true hand position
    set(handH,'XData',current_hand_pos_mlb(1),...
              'YData',current_hand_pos_mlb(2));
    % In metric
    current_hand_pos = current_hand_pos_mlb.*cal.mlb2m;
    
    % calculate metric extent of hand from center and along a line towards
    % the target
    hand_extent_from_center = norm(current_hand_pos);   
    hand_extent_towards_target = norm(current_hand_pos.* ...
        [cos(params.target_location) sin(params.target_location)]);
    
    % Calculate Current Cursor Position
    if (trials.cloud_onoff(trial_counter)==1)
        % Add perturbation to cursor if its a cloud trial
        current_cursor_pos_mlb = current_hand_pos_mlb+current_shift_mlb;
    else
        % Don't perturb cursor otherwise
        current_cursor_pos_mlb = current_hand_pos_mlb;
    end
    set(cursorH,'XData',current_cursor_pos_mlb(1),...
                'YData',current_cursor_pos_mlb(2));

    % Current Cursor in Metric
    current_cursor_pos = current_cursor_pos_mlb.*cal.mlb2m;
    
    % calculate metric extent of cursor from center and along a line towards
    % the target
    cursor_extent_from_center = norm(current_cursor_pos);
    cursor_extent_towards_target = norm(current_cursor_pos.*...
        [cos(params.target_location) sin(params.target_location)]);
    
    % save ====
    saved_hand       = [saved_hand   current_hand_pos'];
    saved_cursor     = [saved_cursor current_cursor_pos'];
    saved_state      = [saved_state  state];
    saved_task_timer = [saved_task_timer etime(task_timer,task_timer_start)];
    
    % PSEUDO-STATE MACHINE
    switch state
        case gamemode.PRETRIAL  % Set up the pretrial settings for trial_counter
            % Trial is not complete
            trial_complete      = false;
            
            % Initialize Trial Outputs
            saved_hand          = [];
            saved_cursor        = [];
            saved_state         = [];
            saved_task_timer	= [];
            saved_outcome       = [];
            saved_endpoint      = [];
            saved_slices        = [];
            saved_rawslices     = [];
            saved_clouds        = [];
            saved_rawclouds     = [];
            
            % Get the current shift
            current_shift = trials.pert_sequence(trial_counter)*...
                [sin(params.target_location) -cos(params.target_location)];
            current_shift_mlb = current_shift.*cal.m2mlb;
            
            % Get the new target in matlab coordinates for plotting
            current_target_pos_mlb = target.positions_mlb(trial_counter,:);
            
            % Draw the target bar
            barwidth=2*params.axis_x*...
                abs(sin(trials.target_sequence(trial_counter)))+...
                params.target_size*cal.m2mlb(1)*...
                abs(cos(trials.target_sequence(trial_counter)));
            barheight=2*params.axis_y*...
                abs(cos(trials.target_sequence(trial_counter)))+...
                params.target_size*cal.m2mlb(2)*...
                abs(sin(trials.target_sequence(trial_counter)));
            set(targetBarH,'Position',...
                [current_target_pos_mlb(1)-barwidth/2,...
                current_target_pos_mlb(2)-barheight/2,...
                barwidth,...
                barheight]);
            set(targetBarH,'visible','off');
            
            if(trials.slice_onoff(trial_counter)==1)
                % shift the target if a slice trial
                current_target_pos_mlb = current_target_pos_mlb+current_shift_mlb;
                if (params.target_location==pi/2 || params.target_location==3*pi/2)
                    current_slices = randn(params.slice_num,1)*...
                        trials.slice_sequence(trial_counter)*cal.m2mlb(1);
                    saved_rawslices = current_slices;
                    width = params.target_size*...
                        params.slice_size*cal.m2mlb(1);
                    height = params.target_size*cal.m2mlb(2);
                    % Initialize the slices
                    for sli=1:params.slice_num
                        set(sliceH(sli),'Position',...
                           [current_target_pos_mlb(1)+...
                            current_slices(sli)*sin(params.target_location)-...
                            width/2,...
                            current_target_pos_mlb(2)+...
                            current_slices(sli)*-cos(params.target_location)-...
                            height/2,...
                            width,height]);
                        set(sliceH(sli),'visible','off');
                    end
                elseif (params.target_location==0 || params.target_location==pi)
                    current_slices = randn(params.slice_num,1)*...
                        trials.slice_sequence(trial_counter)*cal.m2mlb(2);
                    saved_raw_slices = current_slices;
                    width = params.target_size*cal.m2mlb(1);
                    height = params.target_size*...
                             params.slice_size*cal.m2mlb(2);
                    for sli=1:params.slice_num
                        set(sliceH(sli),'Position',...
                           [current_target_pos_mlb(1)+...
                            current_slices(sli)*sin(params.target_location)-...
                            width/2,...
                            current_target_pos_mlb(2)+...
                            current_slices(sli)*-cos(params.target_location)-...
                            height/2,...
                            width,height]);
                        set(sliceH(sli),'visible','off');
                    end    
                end
            elseif (trials.cloud_onoff(trial_counter)==1)
                % don't shift the target
                % Generate the 1D feedback dots for this trial
                raw_dots(:,1) = randn(params.cloud_num,1)*...
                    trials.cloud_sequence(trial_counter)*cal.m2mlb(1)*...
                    abs(sin(params.target_location));
                raw_dots(:,2) = randn(params.cloud_num,1)*...
                    trials.cloud_sequence(trial_counter)*cal.m2mlb(2)*...
                    abs(cos(params.target_location));
                saved_rawclouds = raw_dots;
                
                % Initialize the feedback cloud
                for cloud_i=1:params.cloud_num
                    set(cloudH(cloud_i),'XData',raw_dots(cloud_i,1),...
                        'YData',raw_dots(cloud_i,2));
                    set(cloudH(cloud_i),'visible','off');
                end
            end
            % booleans used to track whether the feedback has been
            % displayed yet.  needed for timed feedback
            feedback_on       = false;
            feedback_complete = false;
            
            % Initialize Outer Target
            set(outerTargetH,'Position',...
               [current_target_pos_mlb(1)-params.target_size*cal.m2mlb(1)/2,...
                current_target_pos_mlb(2)-params.target_size*cal.m2mlb(2)/2,...
                params.target_size*cal.m2mlb(1),...
                params.target_size*cal.m2mlb(2)]);
            set(outerTargetH,'EdgeColor',params.target_color);
            set(outerTargetH,'FaceColor',params.target_color);
            set(outerTargetH,'visible','off');
            
            % Calculate the variable timeouts
            center_hold_timeout = params.center_hold_timeout_low+ ...
                (params.center_hold_timeout_high-params.center_hold_timeout_low)*rand(1);
            center_delay_timeout = params.center_delay_timeout_low+ ...
                (params.center_delay_timeout_high-params.center_delay_timeout_low)*rand(1);
            target_hold_timeout = params.target_hold_timeout_low+ ...
                (params.target_hold_timeout_high-params.target_hold_timeout_low)*rand(1);
            
            % Trial start time
            trial_start_time = current_clock;
            
            % Transition to the next gamemode
            modeChanged=true;
            state = gamemode.CENTER_DRAW;
        case gamemode.CENTER_DRAW % Draws the center target and waits for the cursor to overlap
            
            % If cursor is in center go to hold.
            if cursorInSquareTarget(handH,centerTargetH)
                modeChanged=true;
                state = gamemode.CENTER_HOLD;
            end

        case gamemode.CENTER_HOLD % Ensures the cursor stays on the target long enough
            % If cursor leaves the target abort (repeat the same trial)
            if ~cursorInSquareTarget(handH,centerTargetH)
                modeChanged=true;
                state = gamemode.ABORT;
                % if hold time exceeded,go to CENTER_DELAY
            elseif (etime(state_timer,state_timer_start) >= center_hold_timeout)
                modeChanged=true;
                state = gamemode.CENTER_DELAY;
            end
        case gamemode.CENTER_DELAY
            %set(outerTargetH,'visible','on');
            % if cursor isnt in target abort and go back to pretrial
            if ~cursorInSquareTarget(handH,centerTargetH)
                modeChanged=true;
                state = gamemode.ABORT;
                % if hold time met,go to CENTER_DELAY
            elseif (etime(state_timer,state_timer_start) >= center_delay_timeout)
                modeChanged=true;
                state = gamemode.MOVEMENT;
            end
        case gamemode.MOVEMENT
            % if movement time exceeded,go to INCOMPLETE
            if (etime(state_timer,state_timer_start) > params.movement_timeout)
                modeChanged=true;
                set(textW,'String','Move faster!');
                pause(params.warning_time);
                set(textW,'String','');
                state = gamemode.INCOMPLETE;
            end
            % if cursor is past target radius go to TARGET_HOLD
            %current_target_pos_mlb
            if cursor_extent_towards_target >= params.target_radius
                if (feedback_on && ~feedback_complete)
                    modeChanged=true;
                    set(textW,'String','Move slower!');
                    pause(params.warning_time);
                    set(textW,'String','');
                    state = gamemode.INCOMPLETE;
                else
                    if params.target_location==(pi/2) || params.target_location == (3/2*pi)
                        ep(1) = interp1([previous_cursor_pos_mlb(2) current_cursor_pos_mlb(2)],[previous_cursor_pos_mlb(1) current_cursor_pos_mlb(1)],sin(params.target_location)*params.target_radius*cal.m2mlb(2));
                        ep(2) = sin(params.target_location)*params.target_radius*cal.m2mlb(2);
                    else
                        ep(1) = cos(params.target_location)*params.target_radius*cal.m2mlb(1);
                        ep(2) = interp1([previous_cursor_pos_mlb(1) current_cursor_pos_mlb(1)],[previous_cursor_pos_mlb(2) current_cursor_pos_mlb(2)],cos(params.target_location)*params.target_radius*cal.m2mlb(1));
                    end
                    saved_endpoint = ep;
                    set(cursorEndpointH,'XData',ep(1),'YData',ep(2));
                    if cursorInSquareTarget(cursorEndpointH,outerTargetH)
                        modeChanged=true;
                        set(outerTargetH,'EdgeColor',params.target_color_reward);
                        set(outerTargetH,'FaceColor',params.target_color_reward);
                        state = gamemode.REWARD;
                        
                        % if cursor is at or past the target radius,GO TO FAIL
                    else
                        modeChanged=true;
                        set(outerTargetH,'EdgeColor',params.target_color_fail);
                        set(outerTargetH,'FaceColor',params.target_color_fail);
                        state = gamemode.FAIL;
                        
                    end
                end
            end
        case gamemode.TARGET_HOLD
            % if cursor is out of target,ABORT
            if (etime(state_timer,state_timer_start) >= target_hold_timeout) % if time limit is exceeded,go to REWARD
                modeChanged=true;
                state = gamemode.REWARD;
            elseif ~cursorInSquareTarget(cursorH,outerTargetH)
                modeChanged=true;
                state = gamemode.ABORT;
            end
        case gamemode.REWARD
            if (etime(state_timer,state_timer_start) >= params.intertrial_interval)
                modeChanged=true;
                saved_outcome = 1;
                running_total_rewards = running_total_rewards+1;
                trial_complete = true;
                state = gamemode.PRETRIAL;
            end
        case gamemode.ABORT
            if (etime(state_timer,state_timer_start) >= params.intertrial_interval)
                modeChanged=true;
                saved_outcome = 2;
                state = gamemode.PRETRIAL;
            end
        case gamemode.INCOMPLETE
            if (etime(state_timer,state_timer_start) >= params.intertrial_interval)
                modeChanged=true;
                saved_outcome = 3;
                state = gamemode.PRETRIAL;
            end
        case gamemode.FAIL
            if (etime(state_timer,state_timer_start) >= (params.intertrial_interval+params.failure_penalty))
                modeChanged=true;
                saved_outcome = 0;
                trial_complete = true;
                state = gamemode.PRETRIAL;
            end
        otherwise
            % Default action
            modeChanged=true;
            state = gamemode.PRETRIAL;
    end
    
    % If a state transition occurred,note the current time
    if modeChanged
        modeChanged=false;
        state_timer_start = current_clock;
    end
    
    %% Handle All Graphics/Drawing-Related Operations
    
    
    % Draw center target
    if ((state == gamemode.CENTER_DRAW) || (state == gamemode.CENTER_HOLD)...
            || (state == gamemode.CENTER_DELAY))
        set(centerTargetH,'visible','on');
    else
        set(centerTargetH,'visible','off');
    end
    
    % Draw target bar
    if ((state == gamemode.CENTER_HOLD)||(state == gamemode.CENTER_DELAY) || (state == gamemode.MOVEMENT) || (state == gamemode.REWARD) || (state == gamemode.FAIL))&& params.targetbar_onoff
        set(targetBarH,'visible','on');
   else
        set(targetBarH,'visible','off');
    end
    
    % Draw outer target
    if ((state == gamemode.CENTER_DELAY) || (state == gamemode.MOVEMENT))&& (trials.outer_onoff(trial_counter)==1)
        set(outerTargetH,'visible','on');
    elseif ((state == gamemode.REWARD) || (state == gamemode.FAIL))
        set(outerTargetH,'visible','on');
    else
        set(outerTargetH,'visible','off');
    end
    
    % Draw cloud (timed or continuous)
    if ((state == gamemode.MOVEMENT) && (trials.cloud_onoff(trial_counter)==1)) && (trials.type(block_num)==2)
        % If the feedback location was reached and the timer isn't running,start the timer,
        % and set the cloud position (once per movement)
        if ((hand_extent_towards_target >= params.cloud_trigger_location) && ~feedback_on)
            feedback_timer_start = current_clock;
            feedback_on=true;
            %update cloud position;
            current_dots(:,1) = raw_dots(:,1)+current_cursor_pos_mlb(1);
            current_dots(:,2) = raw_dots(:,2)+current_cursor_pos_mlb(2);
            for cloud_i=1:params.cloud_num
                set(cloudH(cloud_i),'XData',current_dots(cloud_i,1),'YData',current_dots(cloud_i,2));
            end
            saved_clouds = current_dots;
        end
        % If the timer is running and we haven't hit the feedback time limit yet,
        % draw the cloud
        if feedback_on
            if (etime(current_clock,feedback_timer_start)<=params.cloud_duration)
                %draw cloud
                for cloud_i=1:params.cloud_num
                    set(cloudH(cloud_i),'visible','on');
                end
            else
                % otherwise hide dots
                for cloud_i=1:params.cloud_num
                    set(cloudH(cloud_i),'visible','off');
                end
            end
            if ~feedback_complete && (etime(current_clock,feedback_timer_start)>params.cloud_duration)
                feedback_complete=true;
            end
        end
    elseif ((state == gamemode.MOVEMENT) && (trials.cloud_onoff(trial_counter)==1)) && (trials.type(block_num)==3)
        % If the feedback location was reached and the timer isn't running,start the timer,
        % and set the cloud position
        if (hand_extent_towards_target >= params.cloud_trigger_location)
            
            %update cloud position;
            current_dots(:,1) = raw_dots(:,1)+current_cursor_pos_mlb(1);
            current_dots(:,2) = raw_dots(:,2)+current_cursor_pos_mlb(2);
            for cloud_i=1:params.cloud_num
                set(cloudH(cloud_i),'XData',current_dots(cloud_i,1),'YData',current_dots(cloud_i,2));
            end
            if (~feedback_on)
                feedback_on=true;
                feedback_complete=true;
                saved_clouds = current_dots;
            end
            %draw cloud
            for cloud_i=1:params.cloud_num
                set(cloudH(cloud_i),'visible','on');
            end
        else
            % otherwise hide dots
            for cloud_i=1:params.cloud_num
                set(cloudH(cloud_i),'visible','off');
            end
        end
    else
        % hide the dots
        for cloud_i=1:params.cloud_num
            set(cloudH(cloud_i),'visible','off');
        end
    end
    
    
    % Draw slices
    if ((state == gamemode.MOVEMENT) && (trials.slice_onoff(trial_counter)==1))
        % If the feedback location was reached and the timer isn't running,start the timer,
        if ((hand_extent_towards_target >= params.slice_trigger_location) && ~feedback_on)
            feedback_timer_start = current_clock;
            feedback_on=true;
            for sli=1:params.slice_num
                set(sliceH(sli),'visible','on');
            end
            %             saved_dots = current_dots;
        end
        % If the timer is running and we haven't hit the feedback time limit yet,
        % draw the cloud
        if feedback_on
            if (etime(current_clock,feedback_timer_start)<=params.slice_duration)
                %draw cloud
                for sli=1:params.slice_num
                    set(sliceH(sli),'visible','on');
                end
            else
                % otherwise hide dots
                for sli=1:params.slice_num
                    set(sliceH(sli),'visible','off');
                end
            end
            if ~feedback_complete && (etime(current_clock,feedback_timer_start)>params.slice_duration)
                feedback_complete=true;
            end
        end
    else
        % hide the dots
        for sli=1:params.slice_num
            set(sliceH(sli),'visible','off');
        end
    end
    
    
    % DRAW CURSOR
    if ((state == gamemode.MOVEMENT) && (trials.cursor_onoff(trial_counter)==1))
        % show true position
        set(handH,'visible','on');
        set(cursorEndpointH,'visible','off');
    elseif ((state == gamemode.MOVEMENT) && ((hand_extent_from_center >= params.block_window_start) ...
            && (hand_extent_from_center <= params.block_window_end)))
        set(handH,'visible','off');
        set(cursorEndpointH,'visible','off');
    elseif (state == gamemode.TARGET_HOLD)
        % show real-time shifted cursor during outer hold
        set(handH,'visible','on');
        set(cursorEndpointH,'visible','off');
    elseif ((state == gamemode.REWARD) || (state == gamemode.FAIL))
        % if a completed trial,show the endpoint
        set(handH,'visible','off');
        set(cursorEndpointH,'visible','on');
        for cloud_i=1:params.cloud_num
            set(cloudH(cloud_i),'visible','off');
        end
    else
        set(cursorEndpointH,'visible','off');
        % block cursor if not within a certain area (important for return
        % movement)
        if ((hand_extent_from_center >= params.pretrial_block_window_start) ...
                && (hand_extent_from_center <= params.pretrial_block_window_end))
            set(handH,'visible','off');
        else
            set(handH,'visible','on');
        end
    end
    
    % DEBUGMODE
    % always show hand
    %     set(handH,'visible','on');
    if DEBUGMODE==0
        set(textS,'String',sprintf(['Current Trial: ' num2str(trial_counter) '    Next Break at ' num2str(block_breaks(block_num)) '\nScore: ' num2str(running_total_rewards)]));
    else
        set(textS,'String',sprintf(['Cloud: ' num2str(trials.slice_sequence(trial_counter))]));
    end
    % If trial completed
    if trial_complete
        %        set(textF,'String',sprintf(' Score: %03i + ? \n Trials: %03i',sum(payoff),trials.N-(numel(payoff)-1)));
        outputs.hand{trial_counter}        = saved_hand;
        outputs.cursor{trial_counter}        = saved_cursor;
        outputs.task_timer{trial_counter}  = saved_task_timer;
        outputs.state{trial_counter}        = saved_state;
        outputs.clouds{trial_counter}        = saved_clouds;
        outputs.raw_clouds{trial_counter}    = saved_rawclouds;
        outputs.slices{trial_counter}        = saved_slices;
        outputs.raw_slices{trial_counter}    = saved_rawslices;
        outputs.reward{trial_counter}      = saved_outcome;
        outputs.endpoint{trial_counter}    = saved_endpoint;
        
        if trial_counter == block_breaks(block_num)
            set(textF,'String',['Block ' num2str(block_num) ' of ' num2str(length(block_breaks)) ' Completed. Hit ' num2str(running_total_rewards) ' of ' num2str(block_breaks(block_num)) ' total targets.']);
            save(['outputs_' current_subject_ID '_' getDateFname '_block_' int2str(block_num)],'outputs','cal','calFile','trials','blk','blocks','params','target');
            block_num = block_num+1;
            pause;
            set(textF,'String','');
        end
        
        trial_counter        = trial_counter+1;
        trial_complete = false;
    end
    
    % Flush pending graphics actions
    drawnow;
    
end % trial_counter loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SAVE all outputs
%
save(['outputs_' current_subject_ID '_final_' getDateFname],'outputs','cal','calFile','trials','blk','blocks','params','target');
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% If in use, Shut Down Optotrak
if ~useMouse 
    %De-activate the markers.
    optotrak('OptotrakDeActivateMarkers')

    %Shutdown the transputer message passing system.
    optotrak('TransputerShutdownSystem')
end