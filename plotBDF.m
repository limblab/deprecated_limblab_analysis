function plotBDF(datastructname)
    %datastructname: string of name of the mat file or a bdf structure
    %already in the matlab workspace

%% Loading the Data Structure
    
    addpath ./BMI_analysis
    datastruct = LoadDataStruct(datastructname,'bdf');

    if isempty(datastruct)
       disp(sprintf('Could not load structure %s',datastructname));
       return
    end

    %default values:
    if (nargin~=1)
        disp('Please provide the name of a preloaded structure');
        disp('OR the name of a .mat file');
        disp('usage:');
        disp('plotForceEMG(''mystruct'')            % plot data from ''mystruct'' in the ''base'' workspace');
        disp('plotForceEMG(''myfile'')              % plot data from datastruct in ''myfile''');
        return
    end
    
    %Global Variables
    EMGs_to_plot = [];
    Force_to_plot = [];
    Words_to_plot = [];
    plot_Targets = 0;
    KEvents_to_plot = [];
    LPfreq = 10.0;
    ploth1 = [];
    ploth2 = [];
    
%% Creating UI

    UI = figure;
    set(UI,'Name','BDF Structure Plotting Tool');
    set(UI,'NumberTitle','off');
    
    EMGpanel = uipanel('Parent',UI,'Title','EMGs','Position',[.05 .15 .3 .8]);
    Forcepanel = uipanel('Parent',UI,'Title','Force','Position',[.35 .55 .3 .4]);
    KEvents_panel = uipanel('Parent',UI,'Title','Keyboard Events','Position',[.35 .15 .3 .4]);
    Wordspanel = uipanel('Parent',UI,'Title','Words','Position',[.65 .15 .3 .8]);
    
%% EMG Panel
if isfield(datastruct, 'emg')
    
    EMGnames = strrep(datastruct.emg.emgnames,'EMG_','');
    numEMGs=length(EMGnames);

    EMG_cb=zeros(1,numEMGs);

    for i=1:numEMGs
        ctrlBottom = .9-(i-1)*.8/numEMGs;  %distribute EMG chkboxes from top to bottom of panel
        position = [.1 ctrlBottom .9 .05]; %
        EMG_cb(i)=uicontrol('Parent',EMGpanel,'Style','checkbox','String',EMGnames(i),...
                            'Units','normalized','Position',position,'Callback',{@EMG_chbx_Callback,i});
    end

    EMG_lpfilt_tb = uicontrol('Parent',EMGpanel,'Style','popupmenu', 'String', '10|Raw|5|15|20',...
                                'Min', 1, 'Max',1, 'Units', 'normalized', 'Position', [.1 .05 .3 .05],...
                                'BackgroundColor','w','Callback',@LPfreq_callback);
    % Filter popup menu label                        
    uicontrol('Parent',EMGpanel,'Style','text','String','LP Filter (Hz)','Units',...
               'normalized','Position',[.1 .1 .5 .05],'HorizontalAlignment','left');
end
           
%% Force Panel
if isfield(datastruct,'force')

    ForceNames = datastruct.force.labels;

    Force_x_cb = uicontrol('Parent',Forcepanel,'Style','checkbox','String','Force x',...
                                 'Units','normalized','Position',[.1 .8 .9 .1],'Callback',{@Force_chbx_Callback,1});
    Force_y_cb = uicontrol('Parent',Forcepanel,'Style','checkbox','String','Force y',...
                                 'Units','normalized','Position',[.1 .6 .9 .1],'Callback',{@Force_chbx_Callback,2});
end
%% Words Panel
if isfield(datastruct,'words')

    wrist_flexion_task = 0;
    ball_drop_task = 0;
    multi_gadget_task = 0 ;
    
    %Find which behavior using start word:
    start_trial_words = datastruct.words( bitand(hex2dec('f0'),datastruct.words(:,2)) == hex2dec('10') ,2);
    if ~isempty(start_trial_words)
            start_trial_code = start_trial_words(1);
            if ~isempty(find(start_trial_words ~= start_trial_code, 1))
                close(h);
                error('plotBDF:inconsistentBehaviors','Not all trials are the same type');
            end

            if start_trial_code == hex2dec('17')
                wrist_flexion_task = 1;
            elseif start_trial_code == hex2dec('19')
                ball_drop_task = 1;
            elseif start_trial_code == hex2dec('16')
                multi_gadget_task = 1;
            else
                close(h);
                error('BDF:unkownTask','Unknown behavior task with start trial code 0x%X',start_trial_code);
            end

        end
    
    if wrist_flexion_task
        %Words used in the Wrist Flexion Task
        WordsNames = {'Start' 'Go Cue' 'Catch' 'Reward' 'Abort' 'Fail'};%'Targets'};
        WordsValues= [   23  ;   49   ;   50  ;   32   ;   33  ;  34  ];%   >240  ];
    elseif ball_drop_task
        %Words used in the Ball Drop Task
        WordsNames = { 'Start' 'Touch Pad' 'Go Cue' 'Catch' 'Pick up' 'Reward' 'Abort' 'Fail' 'Incomplete' 'Empty Rack'};
        WordsValues= [   25   ;     48    ;   49   ;   50  ;    144  ;   32   ;   33  ;  34  ;     35     ;     36      ];
    elseif multi_gadget_task
        WordsNames = { 'Start' 'Touch Pad' 'Gadget1 on' 'Catch' 'Reach1'  'Reach2' 'Reach3'  'Mvt_onset' 'Reward' 'Abort' 'Fail'};
        WordsValues= [   22   ;     48    ;   41       ;   50  ;    113  ;   114  ;    115 ;     128    ;    32  ;  33  ;   34  ];
    end

    numWords = length(WordsNames);
        
    Words_cb=zeros(1,numWords);
    
    Words_ts = GetWords_ts();
    
    for i=1:numWords
        if isempty(nonzeros(Words_ts(:,i)))
            enable = 'off';
        else
            enable = 'on';
        end
        ctrlBottom = .9-(i-1)*.8/numWords;  %distribute Word chkboxes from 5% to 80% of panel height, from top to bottom
        position = [.1 ctrlBottom .9 .05];
        Words_cb(i)=uicontrol('Parent',Wordspanel,'Style','checkbox','String',WordsNames(i),...
                            'Units','normalized','Position',position,...
                            'Callback',{@Words_chbx_Callback,i},'Enable',enable);
    end
    
    if isfield(datastruct,'databursts')
        Targets_cb = uicontrol('Parent',Wordspanel,'Style','checkbox','String','Targets (TODO?)',...
                            'Units','normalized','Position',[.1 .1 .9 .05],...
                            'Callback',@Targets_chbx_Callback,'Enable',enable);
    end        
        
end
%% Keyboard Panel
if isfield(datastruct,'keyboard_events')

    KEventsNames = {'Start' 'Stop' 'Pause'};
    KEventsValues =[   1   ;  2   ;   9   ];
    
    numKEvents = length(KEventsNames);
    KEvents_cb=zeros(1,numKEvents);
    
    KEvents_ts = GetKEvents_ts;
    
    for i=1:numKEvents
        if isempty(nonzeros(KEvents_ts(:,i)))
            enable = 'off';
        else
            enable = 'on';
        end
        ctrlBottom = .8-(i-1)*.4/numKEvents;
        position = [.1 ctrlBottom .9 .1];
        KEvents_cb(i) = uicontrol('Parent', KEvents_panel,'Style','checkbox','String',KEventsNames(i),...
                                    'Units','normalized','Position',position,...
                                    'Callback',{@KEvents_chbx_Callback,i},'Enable',enable);
    end
end
    
%% Buttons
    Plot_Button = uicontrol('Parent', UI, 'String', 'Plot','Units','normalized','Tag','Plot_Button',...
                            'Position', [.15 .0375 .2 .075],'Callback',@Plot_Button_Callback);

%     Predict_Button = uicontrol('Parent', UI, 'String', 'Predict EMG','Units','normalized','Tag','Predict_Button',...
%                             'Position', [.4 .0375 .2 .075],'Callback',@Predict_Button_Callback,'Enable','off');

    PWTH_Button = uicontrol('Parent',UI, 'String', 'PWTH', 'Units', 'normalized', 'Tag', 'PWTH_Button',...
                            'Position', [.4 0.0375 .2 .075],'Callback',@PWTH_Button_Callback);
                        
    Close_Button = uicontrol('Parent', UI, 'String', 'Close', 'Units', 'normalized', 'Tag','Close_Button',...
                            'Position', [.65 .0375 .2 .075],'Callback',@Close_Button_Callback);
    

%% CheckBoxes CallBacks

    %EMG Checkboxes
    function EMG_chbx_Callback(hObject,eventdata,index)
        if (get(hObject,'Value') == get(hObject,'Max'))
        % Checkbox is checked-take approriate action
            EMGs_to_plot(length(EMGs_to_plot)+1)=index;
            EMGs_to_plot = sort(nonzeros(EMGs_to_plot));
        else
        % Checkbox is unchecked-take approriate action
            EMGs_to_plot(EMGs_to_plot==index)=0;
            EMGs_to_plot = nonzeros(EMGs_to_plot);
        end
    end

    function LPfreq_callback(hObject,eventdata)
        val = get(hObject,'Value');
        switch val
            case 1
                LPfreq = 10.0;
            case 2
                LPfreq = 0;
            case 3
                LPfreq = 5.0;
            case 4
                LPfreq = 15.0;
            case 5
                LPfreq = 20.0;
            otherwise
                LPfreq = 2000;
        end
    end
                
    %Words Checkboxes
    function Words_chbx_Callback(hObject,eventdata,index)
        if (get(hObject,'Value') == get(hObject,'Max'))
        % Checkbox is checked-take approriate action
            Words_to_plot(length(Words_to_plot)+1)=index;
            Words_to_plot = sort(nonzeros(Words_to_plot));
        else
        % Checkbox is unchecked-take approriate action
            Words_to_plot(Words_to_plot==index)=0;
            Words_to_plot = nonzeros(Words_to_plot);
        end
    end

    function Targets_chbx_Callback(hObject,eventdata)
        if (get(hObject,'Value') == get(hObject,'Max'))
        % Checkbox is checked-take approriate action
            plot_Targets = 1;
        else
        % Checkbox is unchecked-take approriate action
            plot_Targets = 0;
        end
    end

    %Force Checkboxes
    function Force_chbx_Callback(hObject,eventdata,index)
        if (get(hObject,'Value') == get(hObject,'Max'))
        % Checkbox is checked-take approriate action
            Force_to_plot(length(Force_to_plot)+1)=index;
            Force_to_plot = sort(nonzeros(Force_to_plot));
        else
        % Checkbox is unchecked-take approriate action
            Force_to_plot(Force_to_plot==index)=0;
            Force_to_plot = nonzeros(Force_to_plot);
        end
    end       

    %Keyboard Events Checkboxes
    function KEvents_chbx_Callback(hObject,eventdata,index)
        if (get(hObject,'Value') == get(hObject,'Max'))
        % Checkbox is checked-take approriate action
            KEvents_to_plot(length(KEvents_to_plot)+1)=index;
            KEvents_to_plot = sort(nonzeros(KEvents_to_plot));
        else
        % Checkbox is unchecked-take approriate action
            KEvents_to_plot(KEvents_to_plot==index)=0;
            KEvents_to_plot = nonzeros(KEvents_to_plot);
        end
    end        
        
%% Button Callback
    function Plot_Button_Callback(obj,event)
        legh = []; outh =[]; outm =[]; %handles holders
        scale = []; % to save x axis values when re-ploting
        
        usr_plotWords = ~isempty(Words_to_plot);
        usr_plotEMGs = ~isempty(EMGs_to_plot);
        usr_plotForce= ~isempty(Force_to_plot);
        usr_plotKEvents=~isempty(KEvents_to_plot);        
        
        if ishandle(ploth1) %overwrite on existing figure
            figure(ploth1);
            if ~isempty(get(ploth1,'Children'))%if an axes exist, save horizontal view and clear it 
                scale = axis; %save the axis values
                clf(ploth1); %clear figure
            end
        else
            ploth1 = figure('Units','normalized','Position',[.125 0.3 .75 .5]);
        end
        
        if (usr_plotEMGs && usr_plotForce) %plot EMG and Force on two different Y axis
            hold off; axis auto;
            FilteredEMGs = FiltEMGs();
            FilteredForce= FiltForce();
            [AX,H1,H2]=plotyy(datastruct.emg.data(:,1),FilteredEMGs,datastruct.force.data(:,1),FilteredForce);
            [leghe,objhe,outhe,outme]=legend(AX(1),EMGnames(EMGs_to_plot),'Location','NorthWest');
            [leghf,objhf,outhf,outmf]=legend(AX(2),ForceNames(Force_to_plot),'Location','NorthEast');
            legh = [leghe; leghf];
            outm = outme; outh = outhe;
            emg_handles = H1;
            force_handles = H2;
            
        elseif (usr_plotEMGs) %plot EMGs but not Force
            hold off; axis auto;
            FilteredEMGs = FiltEMGs();
            emg_handles = plot(datastruct.emg.data(:,1),FilteredEMGs);
            [legh,objh,outh,outm]=legend(EMGnames(EMGs_to_plot),'Location','NorthWest');
            
        elseif (usr_plotForce) %plot Force but no EMG
            hold off; axis auto;            
            FilteredForce= FiltForce();
            force_handles = plot(datastruct.force.data(:,1),FilteredForce);
            [legh,objh,outh,outm]=legend(force_handles, ForceNames(Force_to_plot),'Location','NorthEast');
        end
       

        if (usr_plotWords) % Plot the words
 
            marker=[-2000 2000];
            if wrist_flexion_task
                colors={ 'b:' 'c:' 'm:' 'g:' 'r:' 'r:'};   %Colors for WF Task
            elseif ball_drop_task
                colors={ 'k:' 'c:' 'b:' 'm:' 'y:' 'g:' 'r:' 'r:' 'r:' 'y:'}; % Colors for BD Task
            else
                colors= { 'k:' 'c:' 'b:' 'm:' 'y:' 'g:' 'r:' 'r:' 'r:' 'y:'}; % Colors for BD Task
            end
            
            hold on;
            if (usr_plotEMGs || usr_plotForce)
                axis manual;
            else
                axis auto;
            end
                        
            for i=1:length(Words_to_plot)
                tmpWords_ts=[nonzeros(Words_ts(:,Words_to_plot(i))) nonzeros(Words_ts(:,Words_to_plot(i)))];
                tmpmarker=[];
                for j=1:size(tmpWords_ts,1)
                    tmpmarker(j,:)=marker;
                end
                    words_handles(1:size(tmpWords_ts,1),i)=plot(tmpWords_ts',tmpmarker',colors{Words_to_plot(i)});
            end
            outh = [outh; words_handles(1,1:length(Words_to_plot))'];
            outm = [outm WordsNames(Words_to_plot)];
            [leghw,objh,outh,outm]=legend(outh,outm,'Location','Northwest');
            legh(1) = leghw;
        end
        
        if (usr_plotKEvents) %Plot Keyboard Events

            marker=[-200 200];
            colors={'k--' 'k-.' 'k:'};
            hold on; axis manual;
            if (usr_plotEMGs || usr_plotForce)
                axis manual;
            else
                axis auto;
            end

            numEvents = 0;
            for i=1:length(KEvents_to_plot)
                    tmpKEvents_ts=[nonzeros(KEvents_ts(:,KEvents_to_plot(i))) nonzeros(KEvents_ts(:,KEvents_to_plot(i)))];
                    tmpmarker=[];
                    for j=1:size(tmpKEvents_ts,1)
                        tmpmarker(j,:)=marker;
                    end
                        KEvents_handles(1:size(tmpKEvents_ts,1),i)=plot(tmpKEvents_ts',tmpmarker',colors{KEvents_to_plot(i)});
            end

            outh = [outh; KEvents_handles(1,:)'];
            outm = [outm KEventsNames(KEvents_to_plot)];
            [leghk,objh,outh,outm]=legend(outh,outm,'Location','Northwest');
            legh(1) = leghk;
        end
        
%         if plot_Targets %TODO ??
%             num_Targets = size(datastruct.databursts,1)-1; % TODO : is the last databurst always empty? why?
%         end
            
         
        if ~isempty(scale) %Maintain the x axis if replotting
            for i=1:length(legh)
                axes(legh(i));
                scale_y(i,:) = axis;
                axis([scale(1:2) scale_y(i,3:4)]);
            end
        end
    end
        

    function PWTH_Button_Callback(obj,event)
        
        legh = []; outh =[]; outm =[]; %handles holders        

        if length(Words_to_plot) ~= 1
            disp('This action require that no more and no less than one word be selected');
            return;
        end
         
        usr_plotEMGs = ~isempty(EMGs_to_plot);
        usr_plotForce= ~isempty(Force_to_plot);   

        PWTH_h = figure('Units','normalized','Position',[.125 0.3 .75 .5]);
        
        [timeBefore, timeAfter]=PWTH_GUI();
        
        if (usr_plotEMGs && usr_plotForce) %plot EMG and Force on two different Y axis
            EMGs_PWTH = PWTH(datastruct.emg.data(:,[1; EMGs_to_plot+1]),datastruct.words,...
                                WordsValues(Words_to_plot), timeBefore, timeAfter);
                                      
            Force_PWTH = PWTH(datastruct.force.data(:,[1; Force_to_plot+1]),datastruct.words,...
                                WordsValues(Words_to_plot), timeBefore, timeAfter);
                            
            hold off; axis auto;
            FilteredEMGs = FiltEMGs(EMGs_PWTH(:,2:end));
            FilteredForce= FiltForce(Force_PWTH(:,2:end));
            [AX,H1,H2]=plotyy(EMGs_PWTH(:,1),FilteredEMGs,Force_PWTH(:,1),FilteredForce);
            [leghe,objhe,outhe,outme]=legend(AX(1),EMGnames(EMGs_to_plot),'Location','NorthWest');
            [leghf,objhf,outhf,outmf]=legend(AX(2),ForceNames(Force_to_plot),'Location','NorthEast');
            legh = [leghe; leghf];
            outm = outme; outh = outhe;
            emg_handles = H1;
            force_handles = H2;
             
        elseif (usr_plotEMGs) %plot EMGs but not Force
            hold off; axis auto;
            EMGs_PWTH = PWTH(datastruct.emg.data(:,[1; EMGs_to_plot+1]),datastruct.words,...
                                WordsValues(Words_to_plot), timeBefore, timeAfter);
            FilteredEMGs = FiltEMGs(EMGs_PWTH(:,2:end));
            emg_handles = plot(EMGs_PWTH(:,1),FilteredEMGs);
            [legh,objh,outh,outm]=legend(EMGnames(EMGs_to_plot),'Location','NorthWest');
            
        elseif (usr_plotForce) %plot Force but no EMG
            hold off; axis auto;
            Force_PWTH = PWTH(datastruct.force.data(:,[1; Force_to_plot+1]),datastruct.words,...
                                WordsValues(Words_to_plot), timeBefore, timeAfter);
            FilteredForce= FiltForce(Force_PWTH(:,2:end));
            force_handles = plot(Force_PWTH(:,1),FilteredForce);
            [legh,objh,outh,outm]=legend(force_handles, ForceNames(Force_to_plot),'Location','NorthEast');
        end

    end
        
    function Close_Button_Callback(obj,event)
        close(get(obj,'Parent'));
        if ishandle(ploth1)
            close(ploth1);
        end        
        if ishandle(ploth2)
            close(ploth2);
        end
    end

%     function Predict_Button_Callback(obj,event)
%         disp('not implemented yet');
%     end

%% Filtering

    function FilteredEMGs = FiltEMGs(varargin)
        
        if nargin
            tempEMGs = varargin{1};
        else
            tempEMGs = datastruct.emg.data(:,EMGs_to_plot+1);
        end
            
        if LPfreq % No filtering necessary if user selected 'Raw' (which sets LP to 0.0)
            highpassfreq = 50; %50Hz
            lowpassfreq = LPfreq; %5-20Hz
            emgfreq = datastruct.emg.emgfreq(1);

            [bh,ah] = butter(4, highpassfreq*2/emgfreq, 'high');
            [bl,al] = butter(4, lowpassfreq*2/emgfreq, 'low');

            tempEMGs = filtfilt(bh,ah,tempEMGs); %highpass at 50 Hz
            tempEMGs = abs(tempEMGs); %rectify
            tempEMGs = filtfilt(bl,al,tempEMGs); %lowpass at user selected freq
    %        tempEMGs = filter(bl,al,tempEMGs); 

    %         for i=1:length(EMGs_to_plot)
    %             tempEMGs(:,i)=tempEMGs(:,i)-min(tempEMGs(:,i)); %remove offset
    %         end
        end
    
        FilteredEMGs = tempEMGs;

        clear tempEMGs bh ah bl al;

    end
   
    function FilteredForce = FiltForce(varargin)

        if nargin
            tempForce = varargin{1}
        else
            tempForce = datastruct.force.data(:,Force_to_plot+1);
        end
        
        lowpassfreq = 20; %20Hz
        adfreq = datastruct.raw.analog.adfreq(1);

        [bl,al] = butter(4, lowpassfreq*2/adfreq, 'low');

        %LP filter @ 20Hz - necessary?
%        tempForce = filtfilt(bl,al,tempForce);

        FilteredForce = tempForce;
    end

%% 'Get' Subroutines
    function Words_ts = GetWords_ts()
        Words_ts = zeros(length(datastruct.words),numWords);
        
        for i=1:numWords
            templen=length(datastruct.words(datastruct.words(:,2)==WordsValues(i)));
            Words_ts(1:templen,i) = datastruct.words(datastruct.words(:,2)==WordsValues(i),1);
        end
    end
    
    function KEvents_ts = GetKEvents_ts()
        KEvents_ts = zeros(length(datastruct.keyboard_events),numKEvents);
        
        for i=1:numKEvents
            templen=length(datastruct.keyboard_events(datastruct.keyboard_events(:,2)==KEventsValues(i)));
            KEvents_ts(1:templen,i) = datastruct.keyboard_events(datastruct.keyboard_events(:,2)==KEventsValues(i),1);
        end
    end
        
end