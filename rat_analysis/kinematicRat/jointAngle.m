clear all; close all; 

[folder, name, ext] = fileparts(mfilename('fullpath'));
cd(folder);
fig_folder = '../../../../figures/';
%% Define files to load

filedate = '160614';
ratName = 'two_spineMJ';
sample_freq = 100; %give this value in Hz 
pathName = ['../../../../data/kinematics/' filedate '_files/'];
filenum = [13];
make_graphs = 0;
saving = false;
animate = true;

for fileind=1:length(filenum) %so I can do batches- all files for a given day
    path     = [pathName filedate num2str(filenum(fileind), '%02d') '.csv'];
    tdmName = '';
    ratMks  = {'spine_top','spine_bottom',...
        'hip_top','hip_bottom', ...
        'hip_middle', 'knee', ...
        'heel', 'foot_mid', 'toe'};
    tdmMks  = {};
    
    [events,rat,treadmill] = ...
        importViconData(path,ratName,tdmName,ratMks,tdmMks);
    
    rat.angles.limb = computeAngle(rat.hip_top, rat.hip_middle, rat.foot_mid);
        rat.angles.hip  = computeAngle(rat.hip_top, rat.hip_middle, rat.knee);
        rat.angles.knee = computeAngle(rat.hip_middle, rat.knee, rat.heel);
        rat.angles.ankle = computeAngle(rat.knee, rat.heel, rat.foot_mid);
    
    %% 1. XY positions vs time
    track_marker = rat.foot_mid; 
    
    if ismember(1, make_graphs)
        figure(1);
        subplot(2, 1, 1);
        plot(track_marker(:, 1))
        ylabel('change in x - length');
        xlabel('Time');
        subplot(2, 1, 2);
        plot(track_marker(:, 2))
        ylabel('change in y - height');
        
    end
    %% 2. Joint angles vs time
    if ismember(2, make_graphs)
        %plot these
        lbls = fieldnames(rat.angles);
        figure(2);
        for i=1:length(lbls)
            subplot(4, 1, i);
            plot(rat.angles.(lbls{i}));
            ylabel([lbls(i) '(degrees)']);
        end
        xlabel('Time (s)');
    end
    %% finding location of split: there'll be a down spike first
    %TODO: this is probably excessively complicated but...
    %NOTE: if movement is strange (smaller down spike, for example), change the
    %cutoff value
    
    cutoff = 4;
    interval = 10;
    swing_times = find_swing_times(cutoff, interval, rat.angles.ankle);
    
    %the plot thickens
    %figure; plot(rat.angles.ankle);
    if length(swing_times)>0
        for i= intersect(make_graphs, 1:2) %for first two graphs
            figure(i); hold on;
            num_sub = length(findall(gcf,'type','axes'));
            for j=1:num_sub
                subplot(num_sub, 1, j);
                ax = gca;
                ax.XLim = [round(swing_times{1}(1)-100, -2) swing_times{end}(2)+400];
                h = get(ax,'xtick');
                set(ax,'xticklabel',(h-ax.XLim(1))/sample_freq); %convert Vicon (100 Hz sample rate) to seconds
                for i=1:length(swing_times)
                    x = [swing_times{i}(1) swing_times{i}(2) swing_times{i}(2) swing_times{i}(1)];
                    y = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
                    z = -.01*ones(1, 4);
                    patch(x, y, z, [.9 .9 .9], 'EdgeColor', 'none')
                end
            end
        end
    end
    %% 3. plot x vs y; color code stance/swing
    if ismember(3, make_graphs)
        plot3 = figure(3); 
        set(plot3, 'Position', [100 100 750 550]); hold on;
        if length(swing_times)>0
            clear('x_val', 'y_val');
            x_val = rat.foot_mid(:, 1);
            y_val = rat.foot_mid(:, 2);
            for i=1:length(swing_times)
                h1 = plot(x_val(swing_times{i}(1):swing_times{i}(2)), y_val(swing_times{i}(1):swing_times{i}(2)), 'r');
                x_val(swing_times{i}(1):swing_times{i}(2)) = NaN;
                y_val(swing_times{i}(1):swing_times{i}(2)) = NaN;
            end
            h2 = plot(x_val, y_val, 'b');
            legend([h1 h2], {'swing', 'stance'});
            xlabel('x');
            ylabel('y');
            
        else
            clear('x_val', 'y_val');
            x_val = rat.foot_mid(:, 1);
            y_val = rat.foot_mid(:, 2);
            
            h2 = plot(x_val, y_val); %not separating into swing and stance so...
            xlabel('x');
            ylabel('y');
        end
    end
    


%% 4. Overlay XY vs time
track_marker = rat.foot_mid; 

if ismember(4, make_graphs)
%split the array according to beginning of every swing phase
        lbls = {'Change in x - length', 'Change in y - height'};
        plot4 = figure(4); 
        set(plot4, 'Position', [50 500 1000 400]);
        for i=1:length(lbls)
            subplot(2, 1, i);
            hold on; 
            len_sw = zeros(1, length(swing_times)); 
            a = track_marker(:, i);
            for j=1:length(swing_times)-1
                plot(a(swing_times{j}(1):swing_times{j+1}(1)));
                len_sw(j) = swing_times{i}(2)-swing_times{i}(1); %get the length of each swing phase
            end
            
            %add the gray box to show swing/stance
            ax = gca;
            x = [0 mean(len_sw) mean(len_sw) 0];
            y = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z = -.01*ones(1, 4);
            patch(x, y, z, [.9 .9 .9], 'EdgeColor', 'none')
            ylabel([lbls(i) '(what are these units??)']);
            xlabel('Time (s)');
        end
end

%% %. Average XY vs time
if ismember(5, make_graphs)
%split the array according to beginning of every swing phase
        lbls = {'Change in x - length', 'Change in y - height'};
        plot5 = figure(5); 
        set(plot5, 'Position', [50 500 1000 400]); 
        for i=1:length(lbls)
            subplot(1, 2, i);
            hold on; 
            len_sw = zeros(1, length(swing_times)); 
            all_sw = cell(1, length(swing_times)-1); 
            a = track_marker(:, i);
            for j=1:length(swing_times)-1
                all_sw{j} = a(swing_times{j}(1):swing_times{j+1}(1));
                len_sw(j) = swing_times{i}(2)-swing_times{i}(1); 
            end
            %interpolate so they're all the same length
            ds = dnsamp(all_sw);
            xvals = 1/sample_freq:1/sample_freq:size(ds, 2)/sample_freq; 
            yvals = mean(ds, 'omitnan'); 
            first_y = yvals(1); 
            plot(xvals, yvals-first_y, 'linewidth', 2); %average together each step
            ax = gca;
            x = [0 mean(len_sw)/sample_freq mean(len_sw)/sample_freq 0];
            y = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z = -.01*ones(1, 4);
            patch(x, y, z, [.9 .9 .9], 'EdgeColor', 'none')
            ylabel([lbls(i) '(what units??)']);
            xlabel('Time (s)');
        end
end

%% 6. Overlay joint angles vs. time

if ismember(6, make_graphs)
%split the array according to beginning of every swing phase
        lbls = fieldnames(rat.angles);
        plot6 = figure(6); 
        set(plot6, 'Position', [500 150 1000 800]);
        for i=1:length(lbls)
            subplot(2, 2, i);
            hold on; 
            len_sw = zeros(1, length(swing_times)); 
            for j=1:length(swing_times)-1
                plot(rat.angles.(lbls{i})(swing_times{j}(1):swing_times{j+1}(1)));
                len_sw(j) = swing_times{i}(2)-swing_times{i}(1); 
            end
            ax = gca;
            x = [0 mean(len_sw) mean(len_sw) 0];
            y = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z = -.01*ones(1, 4);
            patch(x, y, z, [.9 .9 .9], 'EdgeColor', 'none')
            ylabel([lbls(i) '(degrees)']);
        end
        xlabel('Time (s)');
end

%% 7. Average joint angles vs time
if ismember(7, make_graphs)
%split the array according to beginning of every swing phase
        lbls = fieldnames(rat.angles);
        plot7 = figure(7); 
        set(plot7, 'Position', [500 150 1000 800]);
        for i=1:length(lbls)
            subplot(2, 2, i);
            hold on; 
            len_sw = zeros(1, length(swing_times)); 
            all_sw = cell(1, length(swing_times)-1); 
            for j=1:length(swing_times)-1
                all_sw{j} = rat.angles.(lbls{i})(swing_times{j}(1):swing_times{j+1}(1));
                len_sw(j) = swing_times{i}(2)-swing_times{i}(1); 
            end

            ds = dnsamp(all_sw);
            xvals = 1/sample_freq:1/sample_freq:size(ds, 2)/sample_freq; 
            
            plot(xvals, mean(ds, 'omitnan'), 'linewidth', 2);
            ax = gca;
            x = [0 mean(len_sw)/sample_freq mean(len_sw)/sample_freq 0];
            y = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z = -.01*ones(1, 4);
            patch(x, y, z, [.9 .9 .9], 'EdgeColor', 'none')
            ylabel([lbls(i) '(degrees)']);
            xlabel('Time (s)');
        end
end

%% 8. Filter X vs Y

%     figure;
%
%     goodinds1 = unique([find(~isnan(x_val)) find(~isnan(y_val))]);
%     jumps = find(diff(x_val)==0);
%     goodinds = setdiff(goodinds1,jumps+1);
%
%     inds = goodinds;
%     xval2 = interp1(x_val(inds),inds, 1:inds(end), 'pchip');
%     yval2 = interp1(y_val(inds), inds, 1:inds(end), 'pchip');
%     plot(x_val, y_val); hold on;
%     plot(xval2, yval2);
end
%% Animation
%
if animate
    figure(make_graphs(end)+1);
    %title('fast');
    rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.knee       ...
        rat.heel       ...
        rat.foot_mid ...
        rat.toe };
    
    xMin = cell2mat(cellfun(@(x)min(x(:,1)),rat_mat,'UniformOutput', false));
    xMin = min(xMin);
    
    xMax = cell2mat(cellfun(@(x)max(x(:,1)),rat_mat,'UniformOutput', false));
    xMax = max(xMax);
    
    yMin = cell2mat(cellfun(@(x)min(x(:,2)),rat_mat,'UniformOutput', false));
    yMin = min(yMin);
    
    yMax = cell2mat(cellfun(@(x)max(x(:,2)),rat_mat,'UniformOutput', false));
    yMax = max(yMax);
    
    axis([xMin xMax yMin yMax])
    grid on
    hold on
    
    [footstrike, footoff] = saveGaitMovie(rat_mat, rat.f, 'test.avi', false);
end
%
% pathName = '../../../vicondata/';
% filename = '16060310';
% path     = [pathName filename '.csv'];
%
% ratName = 'two_spineMJ';
% tdmName = '';
% ratMks  = {'spine_top','spine_bottom',...
%             'hip_top','hip_bottom', ...
%             'hip_middle', 'knee', ...
%             'heel', 'foot_mid', 'toe'};
% tdmMks  = {};
%
% [events,rat,treadmill] = ...
%             importViconData(path,ratName,tdmName,ratMks,tdmMks);
%
%
%
% figure(2);
% title('slow');
% rat_mat = {rat.hip_top    ...
%              rat.hip_bottom ...
%              rat.hip_middle ...
%              rat.knee       ...
%              rat.heel       ...
%              rat.foot_mid ...
%              rat.toe };
%
% xMin = cell2mat(cellfun(@(x)min(x(:,1)),rat_mat,'UniformOutput', false));
% xMin = min(xMin);
%
% xMax = cell2mat(cellfun(@(x)max(x(:,1)),rat_mat,'UniformOutput', false));
% xMax = max(xMax);
%
% yMin = cell2mat(cellfun(@(x)min(x(:,2)),rat_mat,'UniformOutput', false));
% yMin = min(yMin);
%
% yMax = cell2mat(cellfun(@(x)max(x(:,2)),rat_mat,'UniformOutput', false));
% yMax = max(yMax);
%
% axis([xMin xMax yMin yMax])
% grid on
% hold on

% saveGaitMovie( rat_mat , rat.f);


%% Saving

if saving
    %define the saving directory
    plotnames = {'xyt_', 'ja_', 'xy_', 'xyt_overlay_', 'xyt_avg_', 'ja_overlay_', 'ja_avg_'}
    for i=make_graphs
        figure(i);
        saveas(gcf,[fig_folder plotname{i} filedate num2str(filenum(fileind), '%02d') '.png']);
    end
    close all; %close all the figures so I don't write over them on the next round
    %TODO: consider adding a
end

