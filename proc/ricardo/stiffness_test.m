if ~exist('bdf','var')
%     addpath('C:\Documents and Settings\limblab\Desktop\s1_analysis\')
    cd('D:\Ricardo\MATLAB\s1_analysis')
    load_paths
    cd('D:\Ricardo\MATLAB\s1_analysis\proc\ricardo')

    dataFile = 'D:\Data\bump_stim_forces_test_005.plx';

    cd('D:\Ricardo\MATLAB\s1_analysis\bdf')
    bdf = get_plexon_data(dataFile);
    cd('D:\Ricardo\MATLAB\s1_analysis\proc\ricardo')
end

bump.time =  bdf.words(bdf.words(1:end-2,2)>=80,1);
bump.mag = bdf.words(bdf.words(1:end-2,2)>=80,2)-80;
bump_count = 0;
no_bump_count = 0;
for i = 1:length(bdf.words)-2
    if bdf.words(i,2)>=80
        bump_count = bump_count+1;  
        bump.trial_start(bump_count) = bdf.words(i-1,1);
        bump.trial_end(bump_count) = bdf.words(i+1,1);
        bump.trial_start_index(bump_count) = find(bdf.pos(:,1) > bump.trial_start(bump_count)-.002 &...
                bdf.pos(:,1) < bump.trial_start(bump_count)+.002,1);
        bump.trial_end_index(bump_count) = find(bdf.pos(:,1) > bump.trial_end(bump_count)-.002 &...
                bdf.pos(:,1) < bump.trial_end(bump_count)+.002,1); 
        if bdf.words(i+1,2)==32
            bump.succ(bump_count) = 1;
        else
            bump.succ(bump_count) = 0;
        end
    end
    if (bdf.words(i,2)==21 || bdf.words(i,2)==20) && bdf.words(i+1,2)<80
        no_bump_count = no_bump_count + 1;
        no_bump.trial_start(no_bump_count) = bdf.words(i-1,1);
        no_bump.trial_end(no_bump_count) = bdf.words(i+1,1);
        if bdf.words(i+1,2)==48
            no_bump.succ(no_bump_count) = 1;
        else
            no_bump.succ(no_bump_count) = 0;
        end
    end
end

for i = 1:length(bump.time)
    bump.force{i} = bdf.force(bump.trial_start_index(i):bump.trial_end_index(i),:);
    bump.pos{i} = bdf.pos(bump.trial_start_index(i):bump.trial_end_index(i),:);
    bump.pos{i}(:,2) = bump.pos{i}(:,2)+6;
    bump.pos{i}(:,3) = bump.pos{i}(:,3)+36;
    % offset x=6 y=31b
    if bump.pos{i}(1,2) < -4
        bump.dir{i} = 'right';
    elseif bump.pos{i}(1,2) > 6
        bump.dir{i} = 'left'; 
    elseif bump.pos{i}(1,3) > 6
        bump.dir{i} = 'down';
    else
        bump.dir{i} = 'up';
    end
end

figure;
for i = 1:length(bump.time)
    subplot(4,4,i)
    plot(bump.pos{i}(:,2),bump.pos{i}(:,3))
    xlim([-40 30])
    ylim([-70 0])
    hold on
end

% 1 2 3 10 12 13 14
figure;
bump_time = [-1 0 0 .125 .125 1];
bump_on = [-2 -2 -1 -1 -2 -2];
bump_area_x = [0 .125 .125 0 0];
bump_area_y = [30 30 -30 -30 30];
block_area_y = bump_area_y;
flag = ones(1,4);
counters = zeros(1,4);
for i = [5 6 7 8 9 11 15]
    switch bump.dir{i}
        case 'right'
            counters(1) = counters(1)+1;
            subplot(8,2,counters(1));
            bump_start = find(bump.pos{i}(:,2)>-.1 & bump.pos{i}(:,2)<.1);
            bump_start = round(mean(bump_start));
            time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
            block_start = find(bump.pos{i}(:,2)>-7.1 & bump.pos{i}(:,2)<-6.9);
            block_start = round(mean(block_start));
            block_end = find(bump.pos{i}(:,2)<7.1 & bump.pos{i}(:,2)>6.9);
            block_end = round(mean(block_end));
            tmp1 = bump.pos{i}(block_start,1)-bump.pos{i}(bump_start,1);
            tmp2 = bump.pos{i}(block_end,1)-bump.pos{i}(bump_start,1);
            block_area_x = [tmp1 tmp2 tmp2 tmp1 tmp1];
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
            
            plot(time,bump.pos{i}(:,2))
            ylim([-14 14])
            xlim([-.5 .5])
            title('left -> right')
            ylabel('x (cm)')
            subplot(8,2,2+counters(1));
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
            plot(time,bump.pos{i}(:,3))
            ylabel('y (cm)')
            ylim([-6 6])
            xlim([-.5 .5])
            text(.05,-5,num2str(bump.mag(i)))
            % i = 15 -> small bump
        case 'left'
            counters(2) = counters(2)+1;
            subplot(8,2,4+counters(2));
            bump_start = find(bump.pos{i}(:,2)>-.1 & bump.pos{i}(:,2)<.1);
            bump_start = round(mean(bump_start));
            time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
            block_end = find(bump.pos{i}(:,2)>-7.1 & bump.pos{i}(:,2)<-6.9);
            block_end = round(mean(block_end));
            block_start = find(bump.pos{i}(:,2)<7.1 & bump.pos{i}(:,2)>6.9);
            block_start = round(mean(block_start));
            tmp1 = bump.pos{i}(block_start,1)-bump.pos{i}(bump_start,1);
            tmp2 = bump.pos{i}(block_end,1)-bump.pos{i}(bump_start,1);
            block_area_x = [tmp1 tmp2 tmp2 tmp1 tmp1];
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
%             if flag(2)
                area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
%                 flag(2) = 0;
%             end
            hold on
            plot(time,bump.pos{i}(:,2))
            title('right -> left')
            ylim([-14 14])
            xlim([-.5 .5])
            ylabel('x (cm)')
            subplot(8,2,6+counters(2));
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
            plot(time,bump.pos{i}(:,3))
            ylabel('y (cm)')
            ylim([-6 6])
            xlim([-.5 .5])
            text(.05,-5,num2str(bump.mag(i)))
            % 8 -> big, 11 -> big
        case 'up'
            counters(3) = counters(3)+1;
            subplot(8,2,8+counters(3));
            bump_start = find(bump.pos{i}(:,3)>-.1 & bump.pos{i}(:,3)<.1);
            bump_start = round(mean(bump_start));
            time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
            block_end = find(bump.pos{i}(:,3)>-7.1 & bump.pos{i}(:,3)<-6.9);
            block_end = round(mean(block_end));
            block_start = find(bump.pos{i}(:,3)<7.1 & bump.pos{i}(:,3)>6.9);
            block_start = round(mean(block_start));
            tmp2 = bump.pos{i}(block_start,1)-bump.pos{i}(bump_start,1);
            tmp1 = bump.pos{i}(block_end,1)-bump.pos{i}(bump_start,1);
            block_area_x = [tmp1 tmp2 tmp2 tmp1 tmp1];
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
%             if flag(3)
                area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
%                 flag(3) = 0;
%             end
            hold on
            plot(time,bump.pos{i}(:,2))
            title('down -> up')
            ylim([-6 6])
            xlim([-.5 .5])
            text(.05,-5,num2str(bump.mag(i)))
            ylabel('x (cm)')
            subplot(8,2,10+counters(3));
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
            plot(time,bump.pos{i}(:,3))
            ylabel('y (cm)')
            ylim([-14 14])
            xlim([-.5 .5])
            % 6 -> big, 7 -> medium 
        case 'down'
            counters(4) = counters(4)+1;
            subplot(8,2,12+counters(4));
            bump_start = find(bump.pos{i}(:,3)>-.1 & bump.pos{i}(:,3)<.1);
            bump_start = round(mean(bump_start));
            time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
            block_start = find(bump.pos{i}(:,3)<7.1 & bump.pos{i}(:,3)>6.9);
            block_start = round(mean(block_start));
            block_end = find(bump.pos{i}(:,3)>-7.1 & bump.pos{i}(:,3)<-6.9);
            if isempty(block_end)
                block_end = length(time);
            end
            block_end = round(mean(block_end));
            tmp2 = bump.pos{i}(block_start,1)-bump.pos{i}(bump_start,1);
            tmp1 = bump.pos{i}(block_end,1)-bump.pos{i}(bump_start,1);
            block_area_x = [tmp1 tmp2 tmp2 tmp1 tmp1];
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
%             if flag(4)
                area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
%                 flag(4) = 0;
%             end
            hold on
            plot(time,bump.pos{i}(:,2))
            title('up -> down')
            ylim([-6 6])
            xlim([-.5 .5])
            text(.05,-5,num2str(bump.mag(i)))
            ylabel('x (cm)')
            xlabel('t (s)')
            subplot(8,2,14+counters(4));
            area(block_area_x,block_area_y,'LineStyle','none','FaceColor',[.9 .9 .9])
            hold on
            area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
            hold on
            plot(time,bump.pos{i}(:,3))
            ylabel('y (cm)')
            ylim([-14 14])
            xlim([-.5 .5])
            xlabel('t (s)')
            % 5 -> small, 9 -> medium 
    end
    hold on
end
        
figure;
bump_time = [-1 0 0 .125 .125 1];
bump_on = [-2 -2 -1 -1 -2 -2];
bump_area_x = [0 .125 .125 0 0];
bump_area_y = [6 6 -6 -6 6];
% flag = ones(1,4);

subplot(131)
i = 15;
bump_start = find(bump.pos{i}(:,2)>-.1 & bump.pos{i}(:,2)<.1);
bump_start = round(mean(bump_start));
time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
hold on
plot(time,bump.pos{i}(:,3),'k')
title('Small bump')
xlabel('time (s)')
ylabel('deviation (cm)')
box off
ylim([-5 5])
xlim([-.5 0.5])

subplot(132)
i = 9;
bump_start = find(bump.pos{i}(:,3)>-.1 & bump.pos{i}(:,3)<.1);
bump_start = round(mean(bump_start));
time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
hold on
plot(time,bump.pos{i}(:,2),'k')
title('Medium bump')
ylim([-5 5])
xlim([-.5 0.5])
box off
% 9 -> medium 

subplot(133)
i = 6;
bump_start = find(bump.pos{i}(:,3)>-.1 & bump.pos{i}(:,3)<.1);
bump_start = round(mean(bump_start));
time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
area(bump_area_x,bump_area_y,'LineStyle','none','FaceColor',[.8 .8 .8])
hold on
plot(time,bump.pos{i}(:,2),'k')
ylim([-5 5])
xlim([-.5 0.5])
title('Big bump')
box off

% i = 8;
% bump_start = find(bump.pos{i}(:,2)>-.1 & bump.pos{i}(:,2)<.1);
% bump_start = round(mean(bump_start));
% time = bump.pos{i}(:,1)-bump.pos{i}(bump_start,1);
% plot(time,bump.pos{i}(:,3))

