% if ~exist('bdf','var')
if ~exist('already_ran','var')
    computer = input('Desktop (1), Lab 2 (2), Laptop (3): ');

    switch computer
        case 1
            s1_analysis_path = 'D:\Ricardo\MATLAB\s1_analysis';
            data_path = 'D:\Data';
        case 2 
            s1_analysis_path = 'C:\Documents and Settings\limblab\Desktop\s1_analysis\';
            data_path = 'E:\DataFiles\Tiki';
    end
    
    cd(s1_analysis_path)
    load_paths
    cd([s1_analysis_path '\bdf'])
    
    for i = 1:3
        dataFile = [data_path '\bump_stim_forces_test_00' num2str(i+4) '.plx'];
        bdf_temp = get_plexon_data(dataFile,2);
        bdf(i) = bdf_temp;
        clear bdf_temp
        clear ('get_plexon_data',...
            'get_units_plx',...
            'get_raw_plx',...
            'get_keyboard_plx',...
            'calc_from_raw',...
            'plx_info',...
            'plx_information',...
            'plx_adchan_names',...
            'plx_ad',...
            'plx_event_ts',...
            'get_encoder',...
            'get_words',...
            'extract_datablocks',...
            'get_analog_signal');
    end

    cd([s1_analysis_path '\proc\ricardo'])
    already_ran = 1;
end

iColor = {'r','b','k'};
BumpDir = {'up','down'};

for iBumpDir = 1:2
    area_flag = 0;
    try %#ok<TRYNC>
        close iBumpDir
    end
    for iFile = 1:2
        first_trial = find(bdf(iFile).words(:,2)==20 | bdf(iFile).words(:,2)==21,1);
        last_trial = find(bdf(iFile).words(:,2)>=32 & bdf(iFile).words(:,2)<=36,1,'last');

        temp_words = bdf(iFile).words(first_trial:last_trial,:);

        bump(iFile).time =  bdf(iFile).words(bdf(iFile).words(1:end-2,2)>=80,1);
        bump(iFile).mag = bdf(iFile).words(bdf(iFile).words(1:end-2,2)>=80,2)-80;
        bump_count = 0;
        no_bump_count = 0;
        for i = 1:length(bdf(iFile).words)-2
            if bdf(iFile).words(i,2)>=80
                bump_count = bump_count+1;  
                bump(iFile).trial_start(bump_count) = bdf(iFile).words(i-1,1);
                bump(iFile).trial_end(bump_count) = bdf(iFile).words(i+1,1);
                bump(iFile).trial_start_index(bump_count) = find(bdf(iFile).pos(:,1) > bump(iFile).trial_start(bump_count)-.002 &...
                        bdf(iFile).pos(:,1) < bump(iFile).trial_start(bump_count)+.002,1);
                bump(iFile).trial_end_index(bump_count) = find(bdf(iFile).pos(:,1) > bump(iFile).trial_end(bump_count)-.002 &...
                        bdf(iFile).pos(:,1) < bump(iFile).trial_end(bump_count)+.002,1); 
                if bdf(iFile).words(i+1,2)==32
                    bump(iFile).succ(bump_count) = 1;
                else
                    bump(iFile).succ(bump_count) = 0;
                end
            end
            if (bdf(iFile).words(i,2)==21 || bdf(iFile).words(i,2)==20) && bdf(iFile).words(i+1,2)<80
                no_bump_count = no_bump_count + 1;
                no_bump(iFile).trial_start(no_bump_count) = bdf(iFile).words(i-1,1);
                no_bump(iFile).trial_end(no_bump_count) = bdf(iFile).words(i+1,1);
                if bdf(iFile).words(i+1,2)==48
                    no_bump(iFile).succ(no_bump_count) = 1;
                else
                    no_bump(iFile).succ(no_bump_count) = 0;
                end
            end
        end

        for i = 1:length(bump(iFile).time)
            bump(iFile).force{i} = bdf(iFile).force(bump(iFile).trial_start_index(i):bump(iFile).trial_end_index(i),:);
            bump(iFile).pos{i} = bdf(iFile).pos(bump(iFile).trial_start_index(i):bump(iFile).trial_end_index(i),:);
            bump(iFile).pos{i}(:,2) = bump(iFile).pos{i}(:,2)+6;
            bump(iFile).pos{i}(:,3) = bump(iFile).pos{i}(:,3)+31;
            % offset x=6 y=31b
            if bump(iFile).pos{i}(1,2) < -4
                bump(iFile).dir{i} = 'right';
            elseif bump(iFile).pos{i}(1,2) > 6
                bump(iFile).dir{i} = 'left'; 
            elseif bump(iFile).pos{i}(1,3) > 6
                bump(iFile).dir{i} = 'down';
            else
                bump(iFile).dir{i} = 'up';
            end
        end
        
        for i = 1:length(no_bump(iFile).time)
            bump(iFile).force{i} = bdf(iFile).force(bump(iFile).trial_start_index(i):bump(iFile).trial_end_index(i),:);
            bump(iFile).pos{i} = bdf(iFile).pos(bump(iFile).trial_start_index(i):bump(iFile).trial_end_index(i),:);
            bump(iFile).pos{i}(:,2) = bump(iFile).pos{i}(:,2)+6;
            bump(iFile).pos{i}(:,3) = bump(iFile).pos{i}(:,3)+31;

        % figure;
        for i = 1:length(bump(iFile).force)
            [max_val index] = max(abs(bump(iFile).force{i}(:,3)-bump(iFile).force{i}(1,3)));
            if bump(iFile).force{i}(index,3) > 0
                bump(iFile).bump_dir{i} = 'up';
            else
                bump(iFile).bump_dir{i} = 'down';
            end
        end

        bump_time = [-1 0 0 .125 .125 1];
        bump_on = [-2 -2 -1 -1 -2 -2];
        bump_area_x = [0 .125 .125 0 0];
        bump_area_y = [30 30 -30 -30 30];

        figure(iBumpDir);
        bump_counter = 0;
        bump_start = find(bump(iFile).pos{1}(:,2)>-.1 & bump(iFile).pos{1}(:,2)<.1);
        bump_start = round(mean(bump_start));
        time = bump(iFile).pos{1}(:,1)-bump(iFile).pos{1}(bump_start,1);
        crop_time = find(time < -.299 & time > -.301,1):find(time > .299 & time < .301,1);
        bump_matrix = zeros(length(bump(iFile).time) , length(crop_time));
        for i = 1:length(bump(iFile).time)
            if strcmp(bump(iFile).dir{i},'right') && strcmp(bump(iFile).bump_dir{i},BumpDir{iBumpDir})
                bump_counter = bump_counter+1;
                bump_start = find(bump(iFile).pos{i}(:,2)>-.1 & bump(iFile).pos{i}(:,2)<.1);
                bump_start = round(mean(bump_start));
                time = bump(iFile).pos{i}(:,1)-bump(iFile).pos{i}(bump_start,1);
                
                crop_time = find(time < -.299 & time > -.301,1):find(time > .299 & time < .301,1);
                
                if length(crop_time)<size(bump_matrix,2)
                    crop_time = [crop_time crop_time(end)+1];
                elseif length(crop_time)>size(bump_matrix,2)
                    crop_time = crop_time(1:end-1);
                end
                
                time_vector = time(crop_time);
%                 bump_matrix(bump_counter,:) = bump(iFile).pos{i}(crop_time,3)'-mean(bump(iFile).pos{i}(1:end/4,3));               
                bump_matrix(bump_counter,:) = bump(iFile).pos{i}(crop_time,3)';               
                
            end            
        end
        bump_matrix = bump_matrix(1:bump_counter,:);
%         subplot(2,1,1);
%         if ~area_flag
%             area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
%             hold on        
%         end

%             plot(time_vector,bump(iFile).pos{i}(crop_time,2),iColor{iFile})
%             ylim([-14 14])
%             xlim([-.5 .5])
%             title('left -> right')
%             ylabel('x (cm)')

%         subplot(2,1,2);
        if ~area_flag
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
        end
%                 plot(time,bump(iFile).pos{i}(:,3)-mean(bump(iFile).pos{i}(:,3)),iColor{iFile})
        plot(time_vector,mean(bump_matrix),iColor{iFile},'LineWidth',1)
        plot(time_vector,mean(bump_matrix)+std(bump_matrix),'Color',iColor{iFile},'LineWidth',1,'LineStyle','--')
        plot(time_vector,mean(bump_matrix)-std(bump_matrix),'Color',iColor{iFile},'LineWidth',1,'LineStyle','--')
        ylabel('y (cm)')
        ylim([-4 4])
        xlim([-.5 .5])
        area_flag = 1;
    end
end
