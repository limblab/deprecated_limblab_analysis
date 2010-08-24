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
        case 3
            s1_analysis_path = 'D:\Ricardo\MATLAB\s1_analysis';
            data_path = 'D:\Ricardo\MATLAB\Data';
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
            if (bdf(iFile).words(i,2)==49 && bdf(iFile).words(i+1,2)==32)
                no_bump_count = no_bump_count + 1;
                no_bump(iFile).trial_start(no_bump_count) = bdf(iFile).words(i-1,1);
                no_bump(iFile).trial_end(no_bump_count) = bdf(iFile).words(i+1,1);
                no_bump(iFile).trial_start_index(no_bump_count) = find(bdf(iFile).pos(:,1) > no_bump(iFile).trial_start(no_bump_count)-.002 &...
                        bdf(iFile).pos(:,1) < no_bump(iFile).trial_start(no_bump_count)+.002,1);
                no_bump(iFile).trial_end_index(no_bump_count) = find(bdf(iFile).pos(:,1) > no_bump(iFile).trial_end(no_bump_count)-.002 &...
                        bdf(iFile).pos(:,1) < no_bump(iFile).trial_end(no_bump_count)+.002,1);                 
%                 if bdf(iFile).words(i+1,2)==48
%                     no_bump(iFile).succ(no_bump_count) = 1;
%                 else
%                     no_bump(iFile).succ(no_bump_count) = 0;
%                 end
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
        
        for i = 1:length(no_bump(iFile).trial_start)            
            no_bump(iFile).force{i} = bdf(iFile).force(no_bump(iFile).trial_start_index(i):no_bump(iFile).trial_end_index(i),:);
            no_bump(iFile).pos{i} = bdf(iFile).pos(no_bump(iFile).trial_start_index(i):no_bump(iFile).trial_end_index(i),:);
            no_bump(iFile).pos{i}(:,2) = no_bump(iFile).pos{i}(:,2)+6;
            no_bump(iFile).pos{i}(:,3) = no_bump(iFile).pos{i}(:,3)+31;
            if no_bump(iFile).pos{i}(1,2) < -4
                no_bump(iFile).dir{i} = 'right';
            elseif no_bump(iFile).pos{i}(1,2) > 6
                no_bump(iFile).dir{i} = 'left'; 
            elseif no_bump(iFile).pos{i}(1,3) > 6
                no_bump(iFile).dir{i} = 'down';
            else
                no_bump(iFile).dir{i} = 'up';
            end
        end

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
        bump_matrix{iFile} = zeros(length(bump(iFile).time) , length(crop_time));
        for i = 1:length(bump(iFile).time)
            if strcmp(bump(iFile).dir{i},'right') && strcmp(bump(iFile).bump_dir{i},BumpDir{iBumpDir})
                bump_counter = bump_counter+1;
                bump_start = find(bump(iFile).pos{i}(:,2)>-.1 & bump(iFile).pos{i}(:,2)<.1);
                bump_start = round(mean(bump_start));
                time = bump(iFile).pos{i}(:,1)-bump(iFile).pos{i}(bump_start,1);
                
                crop_time = find(time < -.299 & time > -.301,1):find(time > .299 & time < .301,1);
                
                if length(crop_time)<size(bump_matrix{iFile},2)
                    crop_time = [crop_time crop_time(end)+1];
                elseif length(crop_time)>size(bump_matrix{iFile},2)
                    crop_time = crop_time(1:end-1);
                end
                
                time_vector = time(crop_time);
%                 bump_matrix{iFile}(bump_counter,:) = bump(iFile).pos{i}(crop_time,3)'-mean(bump(iFile).pos{i}(1:end/4,3));               
                bump_matrix{iFile}(bump_counter,:) = bump(iFile).pos{i}(crop_time,3)';               
                
            end            
        end        
        bump_matrix{iFile} = bump_matrix{iFile}(1:bump_counter,:);
       
        no_bump_counter = 0;
        no_bump_start = find(no_bump(iFile).pos{1}(:,2)>-.1 & no_bump(iFile).pos{1}(:,2)<.1);
        no_bump_start = round(mean(no_bump_start));
        time = no_bump(iFile).pos{1}(:,1)-no_bump(iFile).pos{1}(no_bump_start,1);
        crop_time = find(time < -.299 & time > -.301,1):find(time > .299 & time < .301,1);
        no_bump_matrix{iFile} = zeros(length(no_bump(iFile).pos), length(crop_time));
        for i = 1:length(no_bump(iFile).pos)
            if strcmp(no_bump(iFile).dir{i},'right')
                no_bump_counter = no_bump_counter+1;
                no_bump_start = find(no_bump(iFile).pos{i}(:,2)>-.1 & no_bump(iFile).pos{i}(:,2)<.1);
                no_bump_start = round(mean(no_bump_start));
                time = no_bump(iFile).pos{i}(:,1)-no_bump(iFile).pos{i}(no_bump_start,1);
                
                crop_time = find(time < -.299 & time > -.301,1):find(time > .299 & time < .301,1);
                
                if length(crop_time)<size(no_bump_matrix{iFile},2)
                    crop_time = [crop_time crop_time(end)+1];
                elseif length(crop_time)>size(no_bump_matrix{iFile},2)
                    crop_time = crop_time(1:end-1);
                end
                
                time_vector_no_bump = time(crop_time);
%                 no_bump_matrix{iFile}(no_bump_counter,:) = no_bump(iFile).pos{i}(crop_time,3)'-mean(no_bump(iFile).pos{i}(1:end/4,3));               
                no_bump_matrix{iFile}(no_bump_counter,:) = no_bump(iFile).pos{i}(crop_time,3)';               
                
            end            
        end
        no_bump_matrix{iFile} = no_bump_matrix{iFile}(1:no_bump_counter,:);
        
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

        subplot(2,1,1);
        if ~area_flag
            plot(-.5,0,'r')
            hold on
            plot(-.5,0,'b')
            plot(-.5,0,'g')
            legend('10%','90%','no bump')
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
            plot(time_vector_no_bump,mean(no_bump_matrix{iFile}),'g','LineWidth',1)
            plot(time_vector_no_bump,mean(no_bump_matrix{iFile})+std(no_bump_matrix{iFile}),'Color','g','LineWidth',1,'LineStyle','--')
            plot(time_vector_no_bump,mean(no_bump_matrix{iFile})-std(no_bump_matrix{iFile}),'Color','g','LineWidth',1,'LineStyle','--')
        end
        [h{iBumpDir},p{iBumpDir},ci{iBumpDir},stats{iBumpDir}] = ttest2(no_bump_matrix{iFile},bump_matrix{iFile});
%                 plot(time,bump(iFile).pos{i}(:,3)-mean(bump(iFile).pos{i}(:,3)),iColor{iFile})
        plot(time_vector,mean(bump_matrix{iFile}),iColor{iFile},'LineWidth',1)
        plot(time_vector,mean(bump_matrix{iFile})+std(bump_matrix{iFile}),'Color',iColor{iFile},'LineWidth',1,'LineStyle','--')
        plot(time_vector,mean(bump_matrix{iFile})-std(bump_matrix{iFile}),'Color',iColor{iFile},'LineWidth',1,'LineStyle','--')
        
         
        ylabel('y (cm)')
        ylim([-4 4])
        xlim([-.3 .3])
        area_flag = 1;
        
        [maxp pind] = max(abs(stats{iBumpDir}.tstat));
                
        subplot(2,1,2)
        plot([-.3 .3],sign(stats{iBumpDir}.tstat(pind))*[stats{iBumpDir}.tstat(find(p{iBumpDir}<.05,1)) stats{iBumpDir}.tstat(find(p{iBumpDir}<.05,1))],...
            'Color',iColor{iFile},'LineWidth',1,'LineStyle','--');
        hold on
        plot(time_vector,stats{iBumpDir}.tstat(pind)*stats{iBumpDir}.tstat,iColor{iFile},'LineWidth',1)
        xlim([-.3 .3])
        xlabel('t (s)')
        ylabel('p')
    end
end

[h_2,p_2,ci_2,stats_2] = ttest2(bump_matrix{1},bump_matrix{2});
[maxp pind] = max(abs(stats_2.tstat));
figure(3)
% plot([-.3 .3],sign(stats{iBumpDir}.tstat(pind))*[stats_2.tstat(find(p_2<.05,1)) stats_2.tstat(find(p_2<.05,1))],...
%             'Color',iColor{iFile},'LineWidth',1,'LineStyle','--');
subplot(211)
plot(time_vector,stats_2.tstat(pind)*stats_2.tstat,iColor{iFile},'LineWidth',1)
xlim([-.3 .3])
ylabel('t stat')
subplot(212)
plot(time_vector,p_2)
xlim([-.3 .3])
xlabel('t (s)')
ylabel('p')
ylim([0 1])