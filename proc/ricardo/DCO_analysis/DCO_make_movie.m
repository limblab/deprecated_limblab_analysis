% function params = DCO_make_movie(data_struct,params)
%     DCO = data_struct.DCO;
%     bdf = data_struct.bdf;
%     
%     load('D:\Data\Mini_7H1\Mini_2014-05-21_DCO_EMG\Output_Data\DCO.mat')
%     load('D:\Data\Mini_7H1\Mini_2014-05-21_DCO_EMG\Output_Data\bdf.mat')    
%     DCO_emg = DCO;
%     bdf_emg = bdf;
%     clear bdf DCO
%     
%     load('D:\Data\Mini_7H1\Mini_2014-05-21_DCO_EMG\Mini_2014-05-21_DCO_EMG_001_params.mat')
%     BMI_data = load('D:\Data\Mini_7H1\Mini_2014-05-21_DCO_EMG\Mini_2014-05-21_DCO_EMG_001_data.txt');
%     BMI_data = BMI_data(find(diff(BMI_data(:,1))<0,1,'last')+1:end,:);
%     
%     load('D:\Data\Mini_7H1\Mini_2014-05-21_DCO_HC\Output_Data\bdf')
%     load('D:\Data\Mini_7H1\Mini_2014-05-21_DCO_HC\Output_Data\DCO')
%     DCO_hc = DCO;
%     bdf_hc = bdf;
%     clear bdf DCO

    idx_start_emg = find(BMI_data(:,strcmp(headers,'t_bin_start'))>=params.movie_range(1),1,'first');
    idx_end_emg = find(BMI_data(:,strcmp(headers,'t_bin_start'))<=params.movie_range(2),1,'last');
    
    idx_start_hc = find(bdf_hc.pos(:,1)>=params.movie_range(1),1,'first');
    
    ct_radius = 1.5;

    ot_inner_radius_emg = DCO_emg.trial_table(1,DCO_emg.table_columns.outer_target_radius)-.5*DCO_emg.trial_table(1,DCO_emg.table_columns.outer_target_thickness);
    ot_outer_radius_emg = DCO_emg.trial_table(1,DCO_emg.table_columns.outer_target_radius)+.5*DCO_emg.trial_table(1,DCO_emg.table_columns.outer_target_thickness);
    ot_span_emg = DCO_emg.trial_table(1,DCO_emg.table_columns.outer_target_span);
    
    ot_inner_radius_hc = DCO_hc.trial_table(1,DCO_hc.table_columns.outer_target_radius)-.5*DCO_hc.trial_table(1,DCO_hc.table_columns.outer_target_thickness);
    ot_outer_radius_hc = DCO_hc.trial_table(1,DCO_hc.table_columns.outer_target_radius)+.5*DCO_hc.trial_table(1,DCO_hc.table_columns.outer_target_thickness);
    ot_span_hc = DCO_hc.trial_table(1,DCO_hc.table_columns.outer_target_span);
    
    figure
    subplot(121)
    title('EMG control')
    hold on
    axis square   
    xlim([-20 20])
    ylim([-20 20])
    h_center_target_emg = area(ct_radius*cos([0:.1:2*pi]),ct_radius*sin([0:.1:2*pi]),'LineStyle','none','FaceColor','r','Visible','off');
    h_outer_target_emg = fill([ot_inner_radius_emg*cos([0:.1:ot_span_emg]) ot_outer_radius_emg*cos([ot_span_emg:-.1:0])],...
        [ot_inner_radius_emg*sin([0:.1:ot_span_emg]) ot_outer_radius_emg*sin([ot_span_emg:-.1:0])],'r','Visible','off');    
    h_upper_arm_emg = plot([BMI_data(idx_start_emg,strcmp(headers,'sh_x')) BMI_data(idx_start_emg,strcmp(headers,'el_x'))],...
        [BMI_data(idx_start_emg,strcmp(headers,'sh_y')) BMI_data(idx_start_emg,strcmp(headers,'el_y'))],'-k','LineWidth',2);
    h_lower_arm_emg = plot([BMI_data(idx_start_emg,strcmp(headers,'el_x')) BMI_data(idx_start_emg,strcmp(headers,'pred_x'))],...
        [BMI_data(idx_start_emg,strcmp(headers,'el_y')) BMI_data(idx_start_emg,strcmp(headers,'pred_y'))],'-k','LineWidth',2);  
    h_hand_emg = plot(BMI_data(idx_start_emg,strcmp(headers,'pred_x')),BMI_data(idx_start_emg,strcmp(headers,'pred_y')),'.b',...
        'MarkerSize',15); 
    h_text_emg = text(-10,-10,'');
    
    subplot(122)
    title('Hand control')
    hold on
    axis square   
    xlim([-20 20])
    ylim([-20 20])
    h_center_target_hc = area(ct_radius*cos([0:.1:2*pi]),ct_radius*sin([0:.1:2*pi]),'LineStyle','none','FaceColor','r','Visible','off');
    h_outer_target_hc = fill([ot_inner_radius_hc*cos([0:.1:ot_span_hc]) ot_outer_radius_hc*cos([ot_span_hc:-.1:0])],...
        [ot_inner_radius_hc*sin([0:.1:ot_span_hc]) ot_outer_radius_hc*sin([ot_span_hc:-.1:0])],'r','Visible','off');    
    h_hand_hc = plot(bdf_hc.pos(idx_start_hc,2),bdf_hc.pos(idx_start_hc,3),'.b',...
        'MarkerSize',15); 
    h_text_hc = text(-10,-10,'');
    
    for iFrame = 1:(idx_end_emg-idx_start_emg)    
        
        set(h_hand_emg,'XData',BMI_data(idx_start_emg+iFrame,strcmp(headers,'pred_x')))
        set(h_hand_emg,'YData',BMI_data(idx_start_emg+iFrame,strcmp(headers,'pred_y')))
        set(h_upper_arm_emg,'XData',[BMI_data(idx_start_emg+iFrame,strcmp(headers,'sh_x')) BMI_data(idx_start_emg+iFrame,strcmp(headers,'el_x'))])
        set(h_upper_arm_emg,'YData',[BMI_data(idx_start_emg+iFrame,strcmp(headers,'sh_y')) BMI_data(idx_start_emg+iFrame,strcmp(headers,'el_y'))])
        set(h_lower_arm_emg,'XData',[BMI_data(idx_start_emg+iFrame,strcmp(headers,'el_x')) BMI_data(idx_start_emg+iFrame,strcmp(headers,'pred_x'))])
        set(h_lower_arm_emg,'YData',[BMI_data(idx_start_emg+iFrame,strcmp(headers,'el_y')) BMI_data(idx_start_emg+iFrame,strcmp(headers,'pred_y'))])        
        
        last_word_emg = bdf_emg.words(find(bdf_emg.words(:,1)<BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start')),1,'last'),2);
        set(h_text_emg,'String',{num2str(last_word_emg);[num2str(BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start'))) ' s']})
        trial_table_idx_emg = find(DCO_emg.trial_table(:,DCO_emg.table_columns.t_ct_hold_on)<=BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start')),1,'last');
        ot_angle = DCO_emg.trial_table(trial_table_idx_emg,DCO_emg.table_columns.outer_target_direction);
        
        if (last_word_emg == 48 || last_word_emg == 160) %% CT on or CT hold
            set(h_center_target_emg,'Visible','on')
        elseif last_word_emg == 64   %% OT on
            ot_angles = ot_angle+[0:.1:ot_span_emg]-ot_span_emg/2;
            set(h_outer_target_emg,'XData',[ot_inner_radius_emg*cos(ot_angles) ot_outer_radius_emg*cos(ot_angles(end:-1:1))])
            set(h_outer_target_emg,'YData',[ot_inner_radius_emg*sin(ot_angles) ot_outer_radius_emg*sin(ot_angles(end:-1:1))])
            set(h_outer_target_emg,'Visible','on')
            set(h_center_target_emg,'Visible','on')
        elseif (last_word_emg == 128 || last_word_emg == 161)  %% Movement onset
            set(h_outer_target_emg,'Visible','on')
            set(h_center_target_emg,'Visible','off')
        elseif (last_word_emg >= 32 && last_word_emg <=35)  %% Trial end
            set(h_center_target_emg,'Visible','on')
            set(h_outer_target_emg,'Visible','off')
        else
            set(h_center_target_emg,'Visible','off')
            set(h_outer_target_emg,'Visible','off')
        end
        
        hc_idx = find(bdf_hc.pos(:,1)>=BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start')),1,'first');
        set(h_hand_hc,'XData',bdf_hc.pos(hc_idx,2)+DCO_hc.trial_table(1,DCO_hc.table_columns.x_offset))
        set(h_hand_hc,'YData',bdf_hc.pos(hc_idx,3)+DCO_hc.trial_table(1,DCO_hc.table_columns.y_offset))
        
        last_word_hc = bdf_hc.words(find(bdf_hc.words(:,1)<BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start')),1,'last'),2);
        set(h_text_hc,'String',{num2str(last_word_hc);[num2str(BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start'))) ' s']})
        trial_table_idx_hc = find(DCO_hc.trial_table(:,DCO_hc.table_columns.t_ct_hold_on)<=BMI_data(idx_start_emg+iFrame,strcmp(headers,'t_bin_start')),1,'last');
        ot_angle = DCO_hc.trial_table(trial_table_idx_hc,DCO_hc.table_columns.outer_target_direction);
        
        if (last_word_hc == 48 || last_word_hc == 160) %% CT on or CT hold
            set(h_center_target_hc,'Visible','on')
        elseif last_word_hc == 64   %% OT on
            ot_angles = ot_angle+[0:.1:ot_span_hc]-ot_span_hc/2;
            set(h_outer_target_hc,'XData',[ot_inner_radius_hc*cos(ot_angles) ot_outer_radius_hc*cos(ot_angles(end:-1:1))])
            set(h_outer_target_hc,'YData',[ot_inner_radius_hc*sin(ot_angles) ot_outer_radius_hc*sin(ot_angles(end:-1:1))])
            set(h_outer_target_hc,'Visible','on')
            set(h_center_target_hc,'Visible','on')
        elseif (last_word_hc == 128 || last_word_hc == 161)  %% Movement onset
            set(h_outer_target_hc,'Visible','on')
            set(h_center_target_hc,'Visible','off')
        elseif (last_word_hc >= 32 && last_word_hc <=35)  %% Trial end
            set(h_center_target_hc,'Visible','on')
            set(h_outer_target_hc,'Visible','off')
        else
            set(h_center_target_hc,'Visible','off')
            set(h_outer_target_hc,'Visible','off')
        end
        
        drawnow
        pause(diff(BMI_data(idx_start_emg+iFrame+[0 1],strcmp(headers,'t_bin_start'))))
    end
    