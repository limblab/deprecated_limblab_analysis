clear all; close all;

[folder, name, ext] = fileparts(mfilename('fullpath'));
cd(folder);
fig_folder = '../../../../figures/';
%% Define files to load

filedate = '160902';
%filename = '16-07-26'; 
%ratName = '16-09-02';
ratName = [filedate(1:2) '-' filedate(3:4) '-' filedate(5:6)];
sample_freq = 100; %give this value in Hz
pathName = ['../../../../data/kinematics/' filedate '_files/'];
filenum = 12; %can input an array if desired
make_graphs = [2];
saving = false;
animate = false;
recruit = false; 
hist = false;
hists = {};
gapfill = false; 

for fileind=1:length(filenum) %so I can do batches- all files for a given day
    %close all; 
    path     = [pathName filedate num2str(filenum(fileind), '%02d') '.csv'];
    %path     = [pathName filename num2str(filenum(fileind), '%02d') '.csv'];
    tdmName = '';
    tdmMks  = {};
    %ratMks = {'hip_top', 'hip_center' , 'hip_bottom', 'knee', 'heel', 'metatarsal', 'phalanx'}
%    ratMks = {'hip_center', 'hip_top', 'hip_bottom', 'knee', 'heel', 'toe'}
    ratMks  = {'spine_top','spine_bottom','hip_top','hip_bottom', ...
         'hip_middle', 'knee', 'heel', 'foot_mid', 'toe'};       
%      ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
%           'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe'};   
 
    [events,rat,treadmill] = ...
        importViconData(path,ratName,tdmName,ratMks,tdmMks);
    
    %convert to mm
    %cut section down, if desired
    startMk = 1; %round(length(rat.knee)/2);
    lastMk = round(length(rat.knee)*1); %length(rat.knee); 
    for i=1:length(ratMks)
        rat.(ratMks{i}) = rat.(ratMks{i})(startMk:lastMk, :); 
        rat.(ratMks{i}) = rat.(ratMks{i})/4.7243;
    end
   
    rat.angles.limb = computeAngle(rat.hip_top, rat.hip_middle, rat.foot_mid);
    rat.angles.hip  = computeAngle(rat.hip_top, rat.hip_middle, rat.knee);
    rat.angles.knee = computeAngle(rat.hip_middle, rat.knee, rat.heel);
    rat.angles.ankle = computeAngle(rat.knee, rat.heel, rat.foot_mid);
    
    track_marker = rat.toe; %which marker to plot (should generalize so I can plot multiple markers?)
    x_zero = mean(rat.hip_bottom(:, 1), 'omitnan'); 
    y_zero = mean(rat.hip_bottom(:, 2), 'omitnan'); 
    
    cutoff = 9;
    interval = 10;
    swing_times = find_swing_times(cutoff, interval, rat.angles.ankle);
    
    
    %% Fill gaps in data: interpolate x, y, z positions
    if gapfill
        %WHAT IS HAPPENING WITH SPINE TOP and bottom MARKER?? (back and forth 135/48)
        for i=5%length(ratMks)
            marker = rat.(ratMks{i}); 
            idx = ~isnan(marker); %finds indices of good values
            ind = 1:length(marker); 
            %TODO: check how many nans in a row: if >3, don't interp
            
            %check for doubled nans
            dbls = find(diff(idx)==0); 
            nval = find(diff(dbls)>1); 
            for n=1:length(nval)
                ran = (dbls(nval(n))+1):(dbls(nval(n)+1)-1); %get a range of mostly good values
                %interpolate that range
                %TODO: figure out what the issue is with 
                temp = interp1(ind(idx(ran, 1)), marker(idx(ran, 1)), ind(ran), 'linear');
            end
            
            temp = interp1(ind(idx(:, 1)), marker(idx(:, 1)), ind, 'linear'); %check if this does all the values! (x, y, z)
            plot(marker(:, 1), '.'); 
            hold on; 
            plot(temp); 
                
            end
    end
    
    %% 1. XY positions vs time
    
    if ismember(1, make_graphs)
        figure(1);
        subplot(2, 1, 1);
        plot(track_marker(:, 1))
        ylabel('change in x - length');
        xlabel('Time (s)');
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
            plot(rat.angles.(lbls{i}), '.');
            ylabel([lbls(i) '(degrees)']);
            %set(gca, 'XTick', [])
        end
        %xlabel('Time (s)');
    end
    %% finding location of split: there'll be a down spike first
    %TODO: this is probably excessively complicated but...
    %NOTE: if movement is strange (smaller down spike, for example), change the
    %cutoff value
    
    %the plot thickens
    %figure; plot(rat.angles.ankle);
    if length(swing_times)>0
        if length(intersect(make_graphs, 1:2))>0
        for i= intersect(make_graphs, 1:2) %for first two graphs
            figure(i); hold on;
            num_sub = length(findall(gcf,'type','axes'));
            for j=1:num_sub
                subplot(num_sub, 1, j);
                ax = gca;
                ax.XLim = [round(swing_times{1}(1)-100, -2) swing_times{end}(2)+400];
                h = get(ax,'xtick');
                %set(ax,'xticklabel',(h-ax.XLim(1))/sample_freq); %convert Vicon (100 Hz sample rate) to seconds
                for i=1:length(swing_times)
                    x_rect = [swing_times{i}(1) swing_times{i}(2) swing_times{i}(2) swing_times{i}(1)];
                    y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
                    z_rect = -.01*ones(1, 4);
                    patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
                end
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
            x_val = track_marker(:, 1);
            y_val = track_marker(:, 2);
            for i=1:length(swing_times)-1
                h1 = plot(x_val(swing_times{i}(1):swing_times{i}(2)), y_val(swing_times{i}(1):swing_times{i}(2)), 'r');
                h2 = plot(x_val(swing_times{i}(2):swing_times{i+1}(1)), y_val(swing_times{i}(2):swing_times{i+1}(1)), 'b');
                first_pts{i} = [x_val(swing_times{i}(1)), y_val(swing_times{i}(1))];
                plot(first_pts{i}(1), first_pts{i}(2), 'o', 'color', 'k', 'linewidth', 3);
                disp(swing_times{i}); 
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
            x_rect = [0 mean(len_sw) mean(len_sw) 0];
            y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z_rect = -.01*ones(1, 4);
            patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
            ylabel([lbls(i) '(what are these units??)']);
            xlabel('Time (s)');
        end
    end
    
    %% 5. Average XY vs time
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
            x_rect = [0 mean(len_sw)/sample_freq mean(len_sw)/sample_freq 0];
            y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z_rect = -.01*ones(1, 4);
            patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
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
            x_rect = [0 mean(len_sw) mean(len_sw) 0];
            y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z_rect = -.01*ones(1, 4);
            patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
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
            x_rect = [0 mean(len_sw)/sample_freq mean(len_sw)/sample_freq 0];
            y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z_rect = -.01*ones(1, 4);
            patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
            ylabel([lbls(i) '(degrees)']);
            xlabel('Time (s)');
        end
    end
    %% Avg X vs Y (trajectory)
    
    if ismember(8, make_graphs)
        %split the array according to beginning of every swing phase
        %plot8 = figure(8);
        figure(8); grid off;
        %set(plot8, 'Position', [50 500 1000 400]);
        b_ind = 2; 
        ind_end = length(swing_times)-1; 
        len_sw = zeros(1, ind_end-b_ind);
        x_step = cell(1, ind_end-b_ind);
        y_step = cell(1, ind_end-b_ind);
        xvals = track_marker(:, 1);
        yvals = track_marker(:, 2); 
        for j=b_ind:ind_end
            x_step{j-b_ind+1} = xvals(swing_times{j}(1):swing_times{j+1}(1)); %get full step x vals
            y_step{j-b_ind+1} = yvals(swing_times{j}(1):swing_times{j+1}(1)); %get full step y vals
            len_sw(j-b_ind+1) = swing_times{j}(2)-swing_times{j}(1);
        end
        %interpolate so they're all the same length
        dsx = dnsamp(x_step);
        dsy = dnsamp(y_step);
        xvals = mean(dsx, 'omitnan')-x_zero;
        yvals = mean(dsy, 'omitnan')-y_zero;
        mean_sw = round(mean(len_sw)*.85); 
        %first_y = yvals(1);
        hold on; 
        color1 = [11 131 25]/255; 
        %plot(xvals(1), yvals(1), 'o'); 
        h1 = plot(xvals(1:mean_sw), yvals(1:mean_sw), 'linewidth', 4, 'color', color1); %average together each step
        h2 = plot(xvals(mean_sw:end), yvals(mean_sw:end), 'linewidth', 4, 'color', color1); %average together each step
        
        axis equal;
        ax = gca; 
        %ax.XLim = [-5 30];
        %ax.YLim = [-75 -55];
        %TODO: set YLim
        ylabel('Y (mm)');
        xlabel('X (mm)');
        set(ax, 'fontsize', 24); 
        %legend([h1 h2], {'swing', 'stance'});
    end
    
    %% Animation
    %
    if animate
        figure(9); 
        %figure(make_graphs(end)+1);
        %title('fast');
        rat_mat = {rat.hip_top    ...
            rat.hip_bottom ...
            rat.hip_middle ...
            rat.knee       ...
            rat.heel       ...
            rat.foot_mid   ...
            rat.toe };

        %to select a smaller section:
        b_ind = swing_times{3}(1); 
        e_ind = swing_times{4}(1);
        t_interval = b_ind:2:e_ind; 
         %b_ind = 10876;
         %e_ind = b_ind; 
         %e_ind = find(rat.angles.hip==max(rat.angles.hip));
        %stepnum = 1;
        rat_mat = cellfun(@(array) array(t_interval, :), rat_mat, 'UniformOutput', false);
        %init_arr = cellfun(@(x) [x_zero*ones(size(x, 1), 1)
        %y_zero*ones(size(x, 1), 1)], rat_mat, 'UniformOutput', false); %make array to set origin to bottom of hip in first frame
        %rat_mat = cellfun(@(x)x(:,1:2)-init_arr{1},rat_mat,'UniformOutput', false); %set origin to bottom of hip in first frame
        rat_mat = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame

        annotate = false;
        hold_prev_frames = true;
        
        set(gca, 'fontsize', 24); 
        xlabel('X (mm)'); 
        ylabel('Y (mm)'); 
        
        [an, footstrike, footoff] = saveGaitMovie(rat_mat, rat.f, hold_prev_frames, 'step.avi', saving, annotate);
        ylim([-100 30])
        xlim([-60 70])
    end
    
    %% trajectory on top of animation
    
    if ismember(9, make_graphs)
        %split the array according to beginning of every swing phase
        figure(9);% grid on;
        %set(plot8, 'Position', [50 500 1000 400]);
%         b_ind = swing_times{8}(1); 
%         ind_end = swing_times{9}(1);
        %b_ind = swing_times{end-2}(1); 
        %e_ind = swing_times{end-1}(1); 
        xvals = track_marker(:, 1);
        yvals = track_marker(:, 2); 

        x_step = rat_mat{end}(:, 1); 
        y_step = rat_mat{end}(:, 2); 
        len_sw = length(t_interval);  
        %init_loc = rat.hip_bottom(b_ind:e_ind); 
        %x_step = xvals(b_ind:e_ind)-init_loc(:, 2); 
        %y_step = yvals(b_ind:e_ind)-init_loc(:, 3); 


        hold on; 
        color1 = [225 91 51]/255; %[11 131 25]/255;
        h1 = plot(x_step, y_step, 'linewidth', 3.5, 'color', color1); %average together each step
        %h2 = plot(x_step(len_sw:end), y_step(len_sw:end), 'linewidth', 3.5, 'color', color1); %average together each step
        
        uistack(h1, 'top'); %TODO: WHY DOESN'T THIS WORK DANG IT
        
        
%         ylabel('Y (mm)');
%         xlabel('X (mm)');
%         %legend([h1 h2], {'swing', 'stance'});
        %ylim([-75 25])
%         NumTicks = 3;
%         ax = gca; 
%         L = get(ax,'XLim');
%         set(ax,'XTick',linspace(L(1),L(2),NumTicks));
%         NumTicks = 5;
%         L = get(ax,'YLim');
%         set(ax,'YTick',linspace(L(1),L(2),NumTicks))
%         set(ax, 'fontsize', 20); 
    end
    

    
    %% Recruitment Curves
    if recruit
        color1 = [191 29 41]/255; 
        color2 = [.4 .4 .4]; 
        joint = rat.angles.ankle;
        datainv = 1.01*max(joint)-joint;
        %datainv = joint; 
        figure; hold on;
        baseline = datainv(1); 
        for i=1:length(datainv)-50
            if abs(datainv(i)-datainv(i+20))<0.1 
                if mean(datainv(i:i+20))-baseline>0.1 && mean(datainv(i:i+20))-baseline<1.5
                baseline = mean(datainv(i:i+20)); 
                %disp(i); 
                %plot(i, datainv(i)-baseline, 'o'); 
                end
            end
            
            datainv(i) = datainv(i)-baseline; 
        end
        datainv = datainv(1:end-50); 
        %hold on;
        plot(datainv, 'linewidth', 3, 'color', color1);  
        set(gca, 'fontsize', 18); 
        set(gca, 'XTick', []); 
        ylim([-1 35]); 
        ylabel('\Delta ankle angle (deg)'); 
        set(gca, 'fontsize', 18); 
        
        %make a trace of all locations of stimulation and corresponding
        %amplitudes
        xvals = .2:.2:1.0; 
        [pks, locs] = findpeaks(datainv, 'MinPeakDistance',800); 
%         xtrace = 1:length(datainv); 
%         ytrace = zeros(length(datainv)); 
%         for l=1:length(locs)
%             stim_width = (locs(l)-100):locs(l);  
%             ytrace(stim_width) = xvals(l); 
%         end
%         figure; 
%         plot(xtrace, ytrace, 'color', color2, 'linewidth', 3);
%         set(gca, 'XTickLabel', []); 
%         ylabel('current (mA)'); 
%         set(gca, 'fontsize', 20); 
% %         
%         figure;
%         
%         xvals = [0:.2:1.0]; 
%         pks = [0; pks].'
%         plot(xvals, pks, 'o', 'linewidth', 3, 'color', color1); 
%         ax = gca; 
%         ax.XLim(1) = 0; 
%         
%         hold on; 
%         fit = polyfit(xvals, pks, 5);
%         plot(xvals, polyval(fit, xvals), '--', 'linewidth', 3, 'color', color1); 
%         xlabel('Current (mA)'); 
%         ylabel('\Delta ankle angle (deg)');
%         set(ax, 'fontsize', 18); 
%         ylim([0 40]); 
    end
       
    
    %% Get data in swing phase above the starting point
    if hist
        all_pts = cell(1, length(swing_times)); 
        for i=1:length(swing_times)
            all_pts{i} = range(track_marker(swing_times{i}(1):swing_times{i}(2))) 
            for j=swing_times{i}(1):swing_times{i}(2)
                
                if track_marker(j, 2)>track_marker(swing_times{i}(1), 2) %compare each point to the first point in its step
                    %all_pts = all_pts+1; 
                    %all_pts{i}(j) = track_marker(j, 2)-track_marker(swing_times{i}(1), 2);
                    
                end
            end
        end
        hists{end+1} = all_pts; 
    end
    %% Saving
    
    if saving
        %define the saving directory
        plotnames = {'xyt_', 'ja_', 'xy_', 'xyt_overlay_', 'xyt_avg_', 'ja_overlay_', 'ja_avg_', 'xyavg_', 'animate_'};
        for i=[make_graphs 9]
            figure(i);
            saveas(gcf,[fig_folder plotnames{i} filedate num2str(filenum(fileind), '%02d') '.png']);
        end
        close all; %close all the figures so I don't write over them on the next round
        %TODO: consider adding a
    end
    
end

%% more cleanup of values to get summary stats
if hist
    means = [];
    stds = [];
    step_avg = {};
    b_inds = [2, 2, 3]; 
    e_inds = [4, 0, 0]; 
    for i=1:length(hists)
        %get the mean of each step taken for each set of parameters
        %step_avg{i} = cell2mat(cellfun(@(x) mean(x), hists{i}, 'UniformOutput', false));
        %means(i) = mean(step_avg{i}(2:end));
        vals = cell2mat(hists{i});
        means(i) = mean(vals(b_inds(i):end-e_inds(i)));
        stds(i) = std(vals(b_inds(i):end-e_inds(i)));
    end
    
    figure;
    hold on;
    %colors = [[30 55 120]/255; [41 78 166]/255; [82 124 227]/255];
    colors = [[120 54 0]/255; [171 78 0]/255; [227 104 0]/255];
    %b = bar(1,means, 0.8); 
    for i=1:3
        bar(i, means(i), 0.8, 'FaceColor', colors(i, :)); 
        %b(i).FaceColor = colors(i, :); 
    end
    errorbar(1:3,means,stds,'.', 'color','k', 'linewidth', 4)
    xlabel('Parameters')
    ylabel('Range of step length (mm)'); 
    set(gca, 'fontsize', 24); 
end
