%uncertainty1D_calibrate_optotrak

























% optotrak('OptotrakDeActivateMarkers')
% %Shutdown the transputer message passing system.
% optotrak('TransputerShutdownSystem')

%% activate optotrak
% setting the path for the optotrak toolbox
path (path, 'C:\Documents and Settings\Konrad\My Documents\MATLAB\pwanda\OptotrakToolbox-2007-Dec-21');

% Just to be on the safe side, reset all Matlab functions:
% clear functions

%Settings:
coll.marker_num      =1;   % the marker to use for the position information
coll.NumMarkers      =2;   %Number of markers in the collection.
coll.FrameFrequency  =100; %Frequency to collect data frames at.
coll.MarkerFrequency =2500;%Marker frequency for marker maximum on-time.
oll.Threshold        =30;  %Dynamic or Static Threshold value to use.
coll.MinimumGain     =160; %Minimum gain code amplification to use.
coll.StreamData      =0;   %Stream mode for the data buffers.
coll.DutyCycle       =0.35;%Marker Duty Cycle to use.
coll.Voltage         =7;   %Voltage to use when turning on markers.
coll.CollectionTime  =1;   %Number of seconds of data to collect.
coll.PreTriggerTime  =0;   %Number of seconds to pre-trigger data by.
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
%Wait one second to let the camera adjust.
% pause(1);
%Activate the markers.
optotrak('OptotrakActivateMarkers')


uncertainty1D_loadparams;
%% open figure
clear targetH cursorH aH
aH=figure (1);
clf
global keyPressed
keyPressed=0;
set(aH,'KeyPressFcn',@keycall);
set(aH,'Color',[0 0 0]);
set(aH,'ToolBar','No');
set(aH,'MenuBar','No');
hold on
fillscreen;

%% Plot target positions
calibTargetPos=[0.75 0; 0 0; 0 -0.75];

for i=1:size(calibTargetPos,1)
    targetH{i}=plot(calibTargetPos(i,1),calibTargetPos(i,2),'o','Color',[0 0 0]);  %red target
    set(targetH{i},'MarkerEdgeColor',[1 1 1]);
    set(targetH{i},'MarkerSize',10);
    set(targetH{i},'visible','off');
    hold on
end
textH = text(-1.0,0.5,'');

% The origin in screen coordinates
x0y0 = calibTargetPos(2,:);
% Scaling from device distance to screen distances
% scr2cm  = [calibTargetPos(1,1)-calibTargetPos(2,1) calibTargetPos(3,2)-calibTargetPos(2,2)];

hold off
axis([-1.25 1.25 -1.25 1.25]);
c=gca;
axis square
axis off
set(c,'XLimMode','manual')

set(c,'YLimMode','manual')
hold on
%% Plot cursor markers
cursorH=plot(0,0,'o');
set(cursorH,'MarkerFaceColor',[1 1 1]);
set(cursorH,'MarkerSize',5);
set(cursorH,'visible','on');

fillscreen(aH)

% global fob_pos

% Read from the polhemus
try
    % Pick three workspace points
    clear pos
    for i=1:size(calibTargetPos,1)
        pos(i,1:2)=NaN;
        while isnan(pos(i,1))
            set(textH,'String',['Press any key when you are on target ' num2str(i) '...'],'Color' ,[1 1 1],'FontSize',8);
            set(targetH{i},'visible','on')
            keyPressed=0;

            while(keyPressed==0)
                data=optotrak('DataGetLatest3D',coll.NumMarkers);
                
                % X Y in optotrak coordinates
                currentPosOpt = [-data.Markers{coll.marker_num}(3),data.Markers{coll.marker_num}(2)];
                
                % Store the current 3D position
                Store{i}=data.Markers{coll.marker_num};
                %             posO=data.Markers{coll.marker_num};
                
                set(cursorH,'XData',currentPosOpt(1),'YData',currentPosOpt(2));
                drawnow
            end
            set(targetH{i},'visible','off');
            pos(i,:) = currentPosOpt;
        end
    end

    vx=Store{1}-Store{2};
    vy=Store{3}-Store{2};
    A=[vx vy]';

    for i=1:size(calibTargetPos,1)
        pos(i,:)=A*(Store{i}-Store{2});
    end
    bias=pos(2,:);
    
    % Scaling from screen distances to signal distances
    scr2sig = [calibTargetPos(1,1)-calibTargetPos(2,1) calibTargetPos(3,2)-calibTargetPos(2,2)]./[norm(pos(1,:)) norm(pos(3,:))];
    
    % Scaling from cm to signal distances
    scale = scr2sig;

    set(cursorH,'visible','on');
    T = 1000;
    tic
    for i=1:T
        set(textH,'String',['Test out the mapping... ' num2str(i/T*100) '%'],'Color' ,[1 1 1]);
        data=optotrak('DataGetLatest3D',coll.NumMarkers);
        posShow(i,:) = A*(data.Markers{coll.marker_num}-Store{2});
        screenPos=(posShow(i,:)).*scale+x0y0;
        set(cursorH,'XData',screenPos(1),'YData',screenPos(2),'Color',[1 1 1]);
        drawnow
    end
    testTime = toc;
    fprintf('Rate: %fHz\n',T/testTime)
    close(gcf)
    %     save(['calibration_' getDateFname],'bias','Matrix','convertCoordinates','x0y0');
    save([current_subject_ID '_calibration_' getDateFname],'bias','scale','scr2sig','x0y0','Store','A');
catch
    y=lasterror;
    y.stack
    rethrow(lasterror);
end

%-------------  shutdown --------------------------------
%De-activate the markers.
optotrak('OptotrakDeActivateMarkers')
%Shutdown the transputer message passing system.
optotrak('TransputerShutdownSystem')