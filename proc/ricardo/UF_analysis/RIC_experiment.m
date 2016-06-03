datapath = 'D:\Data\RIC\BumpsDavid\';
filename = 'Ricardo.mat';

if ~exist('Target','var')
    load([datapath filename])
%     dataNE = dataNE/100;

    EMG_names = {'Bi','TriLat','TriLong','AD','MD','PD','PC','TM'};
    posture_names = {'Sagittal','Horizontal'};
    t_idx = find(Time(1,:)>=-.05 & Time(1,:)<=.1501);
    t_axis = Time(1,t_idx);

    Target = reshape(Target,[],1);

    bias_force_dir = zeros(size(Target));
    bias_force_dir([1:100 141:180]) = pi;
    bias_force_dir([101:140 181:260]) = 0;
    bias_force_dir(261:300) = 1.75*pi;
    bias_force_dir(301:end) = .75*pi;

    bias_force_mag = 3*ones(size(Target));

    posture = zeros(size(Target));
    posture(1:220) = 1;
    posture(221:end) = 2;

    screen_orientation = zeros(size(Target));
    screen_orientation(1:260) = 0;
    screen_orientation(261:end) = pi/4;

    block_num = zeros(size(Target));
    block_num(1:20) = 1;
    block_num(21:40) = 2;
    block_num(41:60) = 3;
    block_num(61:100) = 4;
    block_num(101:140) = 5;
    block_num(141:180) = 6;
    block_num(181:220) = 7;
    block_num(221:260) = 8;
    block_num(261:300) = 9;
    block_num(301:340) = 10;
    block_num(341:380) = 11;

    bump_speed = zeros(size(Target));
    bump_speed(1:20) = 10;
    bump_speed(21:40) = 20;
    bump_speed(41:end) = 30;

    target_direction = zeros(size(Target));
    bump_direction = zeros(size(Target));
    for iBlock = 1:length(unique(block_num))
        idx = block_num==iBlock & Target==1;
        target_direction(idx) = 1.5*pi + screen_orientation(idx);
        bump_direction(idx) = .5*pi + screen_orientation(idx);
        idx = block_num==iBlock & Target==2;
        target_direction(idx) = 0 + screen_orientation(idx);
        bump_direction(idx) = pi + screen_orientation(idx);
        idx = block_num==iBlock & Target==3;
        target_direction(idx) = .5*pi + screen_orientation(idx);
        bump_direction(idx) = 1.5*pi + screen_orientation(idx);
        idx = block_num==iBlock & Target==4;
        target_direction(idx) = pi + screen_orientation(idx);
        bump_direction(idx) = 0 + screen_orientation(idx);    
    end

    idx = 1;
    table_columns.target_number = idx; idx = idx+1;
    table_columns.target_direction = idx; idx = idx+1;
    table_columns.bump_direction = idx; idx = idx+1;
    table_columns.bias_force_dir = idx; idx = idx+1;
    table_columns.bias_force_mag = idx; idx = idx+1;
    table_columns.posture = idx; idx = idx+1;
    table_columns.screen_orientation = idx; idx = idx+1;
    table_columns.block_num = idx; idx = idx+1;
    table_columns.bump_speed = idx; idx = idx+1;

    trial_table(:,table_columns.target_number) = Target;
    trial_table(:,table_columns.target_direction) = target_direction;
    trial_table(:,table_columns.bump_direction) = bump_direction;
    trial_table(:,table_columns.bias_force_dir) = bias_force_dir;
    trial_table(:,table_columns.bias_force_mag) = bias_force_mag;
    trial_table(:,table_columns.posture) = posture;
    trial_table(:,table_columns.screen_orientation) = screen_orientation;
    trial_table(:,table_columns.block_num) = block_num;
    trial_table(:,table_columns.bump_speed) = bump_speed;
    clear Target target_direction bump_direction bias_force_dir bias_force_mag
    clear posture screen_orientation block_num bump_speed
    trial_table(trial_table(:,table_columns.target_number) == 0,:) = [];

    bump_directions = unique(trial_table(:,table_columns.bump_direction));
    for iBump = 1:length(bump_directions)
        bump_dir_idx{iBump} = find(trial_table(:,table_columns.bump_direction)==bump_directions(iBump));
    end
    bump_colors = lines(length(bump_directions));

    postures = unique(trial_table(:,table_columns.posture));
    for iPosture = 1:length(postures)
        posture_idx{iPosture} = find(trial_table(:,table_columns.posture)==postures(iPosture));
    end

    bump_speeds = unique(trial_table(:,table_columns.bump_speed));
    for iSpeed = 1:length(bump_speeds)
        bump_speed_idx{iSpeed} = find(trial_table(:,table_columns.bump_speed)==bump_speeds(iSpeed));
    end

    bias_directions = unique(trial_table(:,table_columns.bias_force_dir));
    for iBias = 1:length(bias_directions)
        bias_dir_idx{iBias} = find(trial_table(:,table_columns.bias_force_dir)==bias_directions(iBias));
    end

    screen_orientations = unique(trial_table(:,table_columns.screen_orientation));
    for iScreen = 1:length(screen_orientations);
        screen_idx{iScreen} = find(trial_table(:,table_columns.screen_orientation)==screen_orientations(iScreen));
    end  

end
fidx = 1;

%% All postures, fast bumps
for iPosture = 1:length(postures)
    posture = postures(iPosture);
    for iScreen = 1:length(screen_orientations)
        for iBias = 1:length(bias_directions)
            bias_direction = bias_directions(iBias);        
            table_idx = intersect(posture_idx{posture},bump_speed_idx{bump_speeds == 30});
            table_idx = intersect(table_idx,screen_idx{iScreen});
            table_idx = intersect(table_idx,bias_dir_idx{bias_directions == bias_direction});

            if ~isempty(table_idx)
                fEMG(fidx) = figure; fidx = fidx+1;
                for iEMG = 1:length(EMG_names)    
                    subplot(2,4,iEMG)
                    axis square
                    title(['EMG: ' EMG_names{iEMG}])
                    hold on
                    max_y = 0;
                    n_trials = [];
                    for iBump = 1:length(bump_directions)
                        trial_idx = intersect(table_idx,bump_dir_idx{bump_directions == bump_directions(iBump)});
                        if ~isempty(trial_idx)
                            n_trials(iBump) = length(trial_idx);
                            emg_temp = squeeze(dataNE(t_idx,iEMG,trial_idx))';
                            plot(t_axis,mean(emg_temp),'Color',bump_colors(iBump,:))
                            errorarea(t_axis,mean(emg_temp),1.96*std(emg_temp)/sqrt(length(trial_idx)),...
                                min([1 1 1],.7+bump_colors(iBump,:)));
                            max_y = max(max_y,max(mean(emg_temp)));
                            ylabel('EMG (%MVC)')
                            xlabel('t (s)')
                        end
                    end
                    y_range = [0 1.4*max_y];
                    x_range = [t_axis(1) t_axis(end)];
                    ylim(y_range)
                    xlim(x_range)
                    y_scale = diff(y_range)/diff(x_range);
                    y_text = .95;
                    for iBump = 1:length(bump_directions)
                        trial_idx = intersect(table_idx,bump_dir_idx{bump_directions == bump_directions(iBump)});
                        if ~isempty(trial_idx)
                            plot(x_range(1)+.25*diff(x_range)+.1*diff(x_range)*[0 cos(bump_directions(iBump))],...
                                y_range(1)+.85*diff(y_range)+.1*diff(y_range)*[0 sin(bump_directions(iBump))],...
                                'Color',bump_colors(iBump,:),'LineWidth',2)
                            text(x_range(1)+.02*diff(x_range),y_range(1)+y_text*diff(y_range),...
                                num2str(n_trials(iBump)),'Color',bump_colors(iBump,:))
                            y_text = y_text - .1;
                        end
                    end
                    plot(x_range(1)+.25*diff(x_range)+[0 .1*diff(x_range)*cos(bias_direction)],...
                        y_range(1)+.6*diff(y_range)+[0 .1*diff(y_range)*sin(bias_direction)],...          
                        'Color','k','LineWidth',1,'LineStyle','-')
                    plot(x_range(1)+.25*diff(x_range)+.1*diff(x_range)*cos(bias_direction)+[0 .05*diff(x_range)*(cos(bias_direction+.75*pi))],...
                        y_range(1)+.6*diff(y_range)+.1*diff(y_range)*sin(bias_direction)+[0 .05*diff(y_range)*(sin(bias_direction+.75*pi))],...          
                        'Color','k','LineWidth',1,'LineStyle','-')
                    plot(x_range(1)+.25*diff(x_range)+.1*diff(x_range)*cos(bias_direction)+[0 .05*diff(x_range)*(cos(bias_direction-.75*pi))],...
                        y_range(1)+.6*diff(y_range)+.1*diff(y_range)*sin(bias_direction)+[0 .05*diff(y_range)*(sin(bias_direction-.75*pi))],...          
                        'Color','k','LineWidth',1,'LineStyle','-')
                end
                set(gcf,'NextPlot','add');
                gca2 = axes;
                h = title(['RIC experiment - ' posture_names{iPosture} ' plane'],'Interpreter','none');
                set(gca2,'Visible','off');
                set(h,'Visible','on');   
            end
        end
    end
end


%%
save_figures(fEMG,'Ricardo',datapath,'EMG')
