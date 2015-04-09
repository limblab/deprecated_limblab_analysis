function plotBin(datastructname)
    %datastructname: string of name of the mat file or a binnedData structure
    %already in the matlab workspace

%% Loading the Data Structure

    if isstruct(datastructname)
        datastruct = datastructname;
    else
        datastruct = LoadDataStruct(datastructname);
    end
    
    if isempty(datastruct)
       disp(sprintf('Could not load structure %s',datastructname));
       return
    end

    %default values:
    if (nargin~=1)
        disp('Please provide the name of a preloaded structure');
        disp('OR the name of a .mat file');
        disp('usage:');
        disp('plotBin''mystruct'')            % plot data from ''mystruct'' in the ''base'' workspace');
        disp('plotBin(''myfile'')              % plot data from datastruct in ''myfile''');
        return
    end
    
    %Global Variables
    EMGs_to_plot = [];
    Force_to_plot = [];
    Words_to_plot = [];
    plot_Targets = 0;
    Pos_to_plot = [];
    LPfreq = 10.0;
    ploth1 = [];
    ploth2 = [];
    ForceNames = [];
    EMGNames   = [];
    PosNames   = [];
    
%% Creating UI

    UI = figure;
    set(UI,'Name','BinnedData Plotting Tool');
    set(UI,'NumberTitle','off');
    
    EMGpanel = uipanel('Parent',UI,'Title','EMGs','Position',[.05 .15 .3 .8]);
    Forcepanel = uipanel('Parent',UI,'Title','Force','Position',[.35 .15 .3 .8]);
%    KEvents_panel = uipanel('Parent',UI,'Title','Keyboard Events','Position',[.35 .15 .3 .4]);
    Pospanel = uipanel('Parent',UI,'Title','Cursor Position','Position',[.35 .15 .3 .4]);
    Wordspanel = uipanel('Parent',UI,'Title','Words','Position',[.65 .15 .3 .8]);
    
%% EMG Panel
if ~isempty(datastruct.emgdatabin)
    
    EMGnames = datastruct.emgguide;
    numEMGs=length(EMGnames);

    EMG_cb=zeros(1,numEMGs);

    for i=1:numEMGs
        ctrlBottom = .9-(i-1)*.8/numEMGs;  %distribute EMG chkboxes from top to bottom of panel
        position = [.1 ctrlBottom .9 .05]; %
        EMG_cb(i)=uicontrol('Parent',EMGpanel,'Style','checkbox','String',EMGnames{i},...
                            'Units','normalized','Position',position,'Callback',{@EMG_chbx_Callback,i});
    end

%     EMG_lpfilt_tb = uicontrol('Parent',EMGpanel,'Style','popupmenu', 'String', '10|Raw|5|15|20',...
%                                 'Min', 1, 'Max',1, 'Units', 'normalized', 'Position', [.1 .05 .3 .05],...
%                                 'BackgroundColor','w','Callback',@LPfreq_callback);
%     % Filter popup menu label                        
%     uicontrol('Parent',EMGpanel,'Style','text','String','LP Filter (Hz)','Units',...
%                'normalized','Position',[.1 .1 .5 .05],'HorizontalAlignment','left');
end
           
%% Force Panel
if isfield(datastruct,'forcedatabin')
if ~isempty(datastruct.forcedatabin)

    ForceNames = datastruct.forcelabels;
    
    Force_x_cb = uicontrol('Parent',Forcepanel,'Style','checkbox','String',ForceNames{1},...
                                 'Units','normalized','Position',[.1 .8 .9 .1],'Callback',{@Force_chbx_Callback,1});

    if size(datastruct.forcedatabin,2)>1
        Force_y_cb = uicontrol('Parent',Forcepanel,'Style','checkbox','String',ForceNames{2},...
                                     'Units','normalized','Position',[.1 .6 .9 .1],'Callback',{@Force_chbx_Callback,2});
    end
end
end
%% Words Panel
if isfield(datastruct,'words')
        
    WordsValue = zeros(30,1);
    numWords = 0;
    WordsNames = {};
    for i = 1:size(datastruct.words,1)
        if ~any(WordsValue==datastruct.words(i,2))
            numWords = numWords+1;
            WordsValue(numWords,:)=datastruct.words(i,2);
            WordsNames{numWords} = getWordStr(datastruct.words(i,2));
        end
    end
    WordsValue = nonzeros(WordsValue);
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
        
end

%% Position Panel
if isfield(datastruct,'cursorposbin')
if ~isempty(datastruct.cursorposbin)

    PosNames = datastruct.cursorposlabels;
    
    Pos_x_cb = uicontrol('Parent',Pospanel,'Style','checkbox','String',PosNames{1},...
                                 'Units','normalized','Position',[.1 .8 .9 .1],'Callback',{@Pos_chbx_Callback,1});
    Pos_y_cb = uicontrol('Parent',Pospanel,'Style','checkbox','String',PosNames{2},...
                                 'Units','normalized','Position',[.1 .6 .9 .1],'Callback',{@Pos_chbx_Callback,2});
    
end
end
%% Keyboard Panel
% if isfield(datastruct,'keyboard_events')
% 
%     KEventsNames = {'Start' 'Stop' 'Pause'};
%     KEventsValues =[   1   ;  2   ;   9   ];
%     
%     numKEvents = length(KEventsNames);
%     KEvents_cb=zeros(1,numKEvents);
%     
%     KEvents_ts = GetKEvents_ts;
%     
%     for i=1:numKEvents
%         if isempty(nonzeros(KEvents_ts(:,i)))
%             enable = 'off';
%         else
%             enable = 'on';
%         end
%         ctrlBottom = .8-(i-1)*.4/numKEvents;
%         position = [.1 ctrlBottom .9 .1];
%         KEvents_cb(i) = uicontrol('Parent', KEvents_panel,'Style','checkbox','String',KEventsNames(i),...
%                                     'Units','normalized','Position',position,...
%                                     'Callback',{@KEvents_chbx_Callback,i},'Enable',enable);
%     end
% end
    
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

    %Cursor Pos Checkboxes
    function Pos_chbx_Callback(hObject,eventdata,index)
        if (get(hObject,'Value') == get(hObject,'Max'))
        % Checkbox is checked-take approriate action
            Pos_to_plot(length(Pos_to_plot)+1)=index;
            Pos_to_plot = sort(nonzeros(Pos_to_plot));
        else
        % Checkbox is unchecked-take approriate action
            Pos_to_plot(Pos_to_plot==index)=0;
            Pos_to_plot = nonzeros(Pos_to_plot);
        end
    end  

%% Button Callback
    function Plot_Button_Callback(obj,event)
        legh = []; outh =[]; outm =[]; %handles holders
        scale = []; % to save x axis values when re-ploting
        
        usr_plotWords  = ~isempty(Words_to_plot);
        usr_plotEMGs   = ~isempty(EMGs_to_plot);
        usr_plotForce  = ~isempty(Force_to_plot);
%         usr_plotKEvents= ~isempty(KEvents_to_plot);  
        usr_plotPos    = ~isempty(Pos_to_plot);
        
        if ishandle(ploth1) %overwrite on existing figure
            figure(ploth1);
            if ~isempty(get(ploth1,'Children'))%if an axes exist, save horizontal view and clear it 
                scale = axis; %save the axis values
                clf(ploth1); %clear figure
            end
        else
            ploth1 = figure('Units','normalized','Position',[.125 0.3 .75 .5]);
        end
        
        if (usr_plotEMGs && (usr_plotForce || usr_plotPos)) %plot EMG and Force on two different Y axis
            hold off; axis auto;
            force_pos = [];
            if usr_plotForce
                force_pos = datastruct.forcedatabin(:,Force_to_plot);
            end
            if usr_plotPos
                force_pos = [force_pos datastruct.cursorposbin(:,Pos_to_plot)];
            end
            [AX,H1,H2]=plotyy(datastruct.timeframe, datastruct.emgdatabin(:,EMGs_to_plot),...
                              datastruct.timeframe, force_pos );
            [leghe,objhe,outhe,outme]=legend(AX(1),EMGnames{EMGs_to_plot},'Location','NorthWest');
            [leghf,objhf,outhf,outmf]=legend(AX(2),{ForceNames{Force_to_plot}; PosNames{Pos_to_plot}},'Location','NorthEast');
            legh = [leghe; leghf];
            outm = outme; outh = outhe;
            emg_handles = H1;
            force_handles = H2;
            
        elseif (usr_plotEMGs) %plot EMGs but not Force
            hold off; axis auto;
            emg_handles = plot(datastruct.timeframe,datastruct.emgdatabin(:,EMGs_to_plot));
            [legh,objh,outh,outm]=legend(EMGnames{EMGs_to_plot},'Location','NorthWest');
            
        elseif (usr_plotForce || usr_plotPos) %plot Force but no EMG
            hold off; axis auto;            
            force_handles = plot(datastruct.timeframe, [datastruct.forcedatabin(:,Force_to_plot) datastruct.cursorposbin(:,Pos_to_plot)] );
            [legh,objh,outh,outm]=legend(force_handles, {ForceNames{Force_to_plot};PosNames{Pos_to_plot}},'Location','NorthEast');
        end
       
 
         if (usr_plotWords) % Plot the words
  
            marker=[-2000 2000];
            colors= { 'b:' 'g:' 'r:' 'c:' 'm:' 'k:' 'b--' 'g--' 'r--' 'c--' 'm--' 'k--' 'b-.' 'g-.' 'r-.' 'c-.' 'm-.' 'k-.'};
            
            hold on;
            if (usr_plotEMGs || usr_plotForce || usr_plotPos)
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
%                 words_handles(1:size(tmpWords_ts,1),i)=plot(tmpWords_ts', tmpmarker');
            end
            outh = [outh; words_handles(1,1:length(Words_to_plot))'];
            outm = [outm WordsNames(Words_to_plot)];
            [leghw,objh,outh,outm]=legend(outh,outm,'Location','Northwest');
            legh(1) = leghw;
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
        usr_plotPos  = ~isempty(Pos_to_plot);

        PWTH_h = figure('Units','normalized','Position',[.125 0.3 .75 .5]);
        
        [timeBefore, timeAfter]=PWTH_GUI();
        
        if (usr_plotEMGs && usr_plotForce) %plot EMG and Force on two different Y axis
            EMGs_PWTH = PWTH([datastruct.timeframe datastruct.emgdatabin(:,EMGs_to_plot)],datastruct.words,...
                                WordsValue(Words_to_plot), timeBefore, timeAfter);            
            Force_PWTH = PWTH([datastruct.timeframe datastruct.forcedatabin(:,Force_to_plot)],datastruct.words,...
                                WordsValue(Words_to_plot), timeBefore, timeAfter);                
                            
            hold off; axis auto;
            [AX,H1,H2]=plotyy(EMGs_PWTH(:,1),EMGs_PWTH(:,2:end),Force_PWTH(:,1),Force_PWTH(:,2:end));
            [leghe,objhe,outhe,outme]=legend(AX(1),EMGnames{EMGs_to_plot},'Location','NorthWest');
            [leghf,objhf,outhf,outmf]=legend(AX(2),ForceNames{Force_to_plot},'Location','NorthEast');
            legh = [leghe; leghf];
            outm = outme; outh = outhe;
            emg_handles = H1;
            force_handles = H2;
            
        elseif (usr_plotEMGs) %plot EMGs but not Force
            hold off; axis auto;
            EMGs_PWTH = PWTH([datastruct.timeframe datastruct.emgdatabin(:,EMGs_to_plot)],datastruct.words,...
                                WordsValue(Words_to_plot), timeBefore, timeAfter);
            emg_handles = plot(EMGs_PWTH(:,1),EMGs_PWTH(:,2:end));
            [legh,objh,outh,outm]=legend(EMGnames{EMGs_to_plot},'Location','NorthWest');
            
        elseif (usr_plotForce || usr_plotPos) %plot Force but no EMG
            hold off; axis auto;
            Force_PWTH = PWTH([datastruct.timeframe [datastruct.forcedatabin(:,Force_to_plot) datastruct.cursorposbin(:,Pos_to_plot)]],datastruct.words,...
                                WordsValue(Words_to_plot), timeBefore, timeAfter);
            force_handles = plot(Force_PWTH(:,1),Force_PWTH(:,2:end));
            [legh,objh,outh,outm]=legend(force_handles, ForceNames{Force_to_plot},'Location','NorthEast');
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

%% 'Get' Subroutines
    function Words_ts = GetWords_ts()
        Words_ts = zeros(length(datastruct.words),numWords);
        
        for i=1:numWords
            templen=length(datastruct.words(datastruct.words(:,2)==WordsValue(i)));
            Words_ts(1:templen,i) = datastruct.words(datastruct.words(:,2)==WordsValue(i),1);
        end
    end
%     
%     function KEvents_ts = GetKEvents_ts()
%         KEvents_ts = zeros(length(datastruct.keyboard_events),numKEvents);
%         
%         for i=1:numKEvents
%             templen=length(datastruct.keyboard_events(datastruct.keyboard_events(:,2)==KEventsValues(i)));
%             KEvents_ts(1:templen,i) = datastruct.keyboard_events(datastruct.keyboard_events(:,2)==KEventsValues(i),1);
%         end
%     end
        
end