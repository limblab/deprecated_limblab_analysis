close all
clear all
boot_iter = 2000;
set(0,'DefaultTextInterpreter','none')
curr_dir = pwd;    
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd(curr_dir)

resultpath = 'D:\Ricardo\Miller Lab\Bump choice results\Newsome results\';
[datapath filelist] = BC_newsome_experiment_list();

bump_pse = zeros(boot_iter,length(filelist));
stim_pse = zeros(boot_iter,length(filelist));
bump_null_bias = zeros(boot_iter,length(filelist));
stim_null_bias = zeros(boot_iter,length(filelist));

for file_no = 1:length(filelist)
    disp(['File number: ' num2str(file_no) ' of ' num2str(length(filelist))])
    filename = filelist(file_no).name;
    stim_pd = filelist(file_no).pd;
    if ~exist([resultpath filename '_results'],'file')
        if ~exist([datapath filename '.mat'],'file')    
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
            bdf = get_plexon_data([datapath filename '.plx'],2);
            save([datapath filename],'bdf');
            cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\';
            trial_table = BC_build_trial_table([datapath filename]);    
            save([datapath filename],'trial_table','-append')
        end

        cd(curr_dir)
        load([datapath filename],'trial_table','bdf')

        trial_table = trial_table(trial_table(:,5)==0,:); % remove training trials
        bump_table = trial_table(trial_table(:,4)==1,:);
        stim_table = trial_table(trial_table(:,4)==2,:);
        
        bump_magnitudes = unique(bump_table(:,7));
        bump_directions = unique(bump_table(:,6));

        if bump_directions~=stim_pd
            error(['Stim PD (' num2str(stim_pd) ') does not match file bump directions ('...
                num2str(bump_directions(1)) ', ' num2str(bump_directions(2)) '), check BC_newsome_experiment_list.m']); %#ok<WNTAG>
        end

        bump_directions = [bump_directions(bump_directions==stim_pd) bump_directions(bump_directions~=stim_pd)];
        bumps_ordered = unique(2*[-bump_magnitudes(end:-1:1);bump_magnitudes]); %convert bumps to forces

        bump_table_summary = BC_table_summary(bump_table,bump_directions);
        stim_table_summary = BC_table_summary(stim_table,bump_directions);      

        if ~exist([resultpath filename '_results.mat'],'file')
            sigmoid_fit_bumps_params = sigmoid_fit_bootstrap(bump_table_summary,bumps_ordered,boot_iter);
            sigmoid_fit_stim_params = sigmoid_fit_bootstrap(stim_table_summary,bumps_ordered,boot_iter);

            [figure_sigmoid,...
                sigmoid_fit_bumps,...
                sigmoid_fit_stim]= BC_newsome_sigmoids_plot(bump_table_summary,stim_table_summary,...
                sigmoid_fit_bumps_params,sigmoid_fit_stim_params,bump_directions,bumps_ordered,filename);
            save([resultpath filename '_results'], 'sigmoid_fit_bumps',...
                'sigmoid_fit_stim',...
                'sigmoid_fit_bumps_params',...
                'sigmoid_fit_stim_params');
            
        else
            load([resultpath filename '_results.mat'])
            [figure_sigmoid,...
                sigmoid_fit_bumps,...
                sigmoid_fit_stim]= BC_newsome_sigmoids_plot(bump_table_summary,stim_table_summary,...
                sigmoid_fit_bumps_params,sigmoid_fit_stim_params,bump_directions,bumps_ordered,filename);
        end
        
        figure_null_bias = BC_newsome_null_bias_vs_time(bump_table,stim_table,stim_pd);
            
        hgsave(figure_sigmoid,[resultpath filename]);
        hgsave(figure_null_bias,[resultpath filename '_null_bias']);
        I = getframe(figure_sigmoid);
        imwrite(I.cdata, [resultpath filename '.png']);
        I = getframe(figure_null_bias);
        imwrite(I.cdata, [resultpath filename  '_null_bias.png']);
        close all
    end
end
%%
for file_no = 1:length(filelist)
    filename = filelist(file_no).name;
    load([resultpath filename '_results'], 'sigmoid_fit_bumps',...
                'sigmoid_fit_stim','sigmoid_fit_bumps_params',...
                'sigmoid_fit_stim_params')
                
    bump_null_bias(:,file_no) = sigmoid_fit_bumps_params(:,1)+sigmoid_fit_bumps_params(:,2)./...
        (1+exp(sigmoid_fit_bumps_params(:,4)));
    stim_null_bias(:,file_no) = sigmoid_fit_stim_params(:,1)+sigmoid_fit_stim_params(:,2)./...
        (1+exp(sigmoid_fit_stim_params(:,4)));        

    bump_pse(:,file_no) = sigmoid_fit_bumps_params(:,4)./sigmoid_fit_bumps_params(:,3);
    stim_pse(:,file_no) = sigmoid_fit_stim_params(:,4)./sigmoid_fit_stim_params(:,3);
        
    null_bias_stim(file_no) = sigmoid_fit_stim.a+sigmoid_fit_stim.b/(1+exp(sigmoid_fit_stim.d));
    null_bias_bump(file_no) = sigmoid_fit_bumps.a+sigmoid_fit_bumps.b/(1+exp(sigmoid_fit_bumps.d));
    pse_stim(file_no) = sigmoid_fit_stim.d/sigmoid_fit_stim.c;
    pse_bump(file_no) = sigmoid_fit_bumps.d/sigmoid_fit_bumps.c;
    
    [temp temp_bins] = hist(bump_null_bias(:,file_no)-stim_null_bias(:,file_no),1000);
    null_bias_diff_p(file_no) = sum(temp(1:find(temp_bins>0,1,'first')))./sum(temp);

    [temp temp_bins] = hist(bump_pse(:,file_no)-stim_pse(:,file_no),1000);
    pse_diff_p(file_no) = sum(temp(1:find(temp_bins>0,1,'first')))./sum(temp);
    
    num_electrodes(file_no) = length(filelist(file_no).electrodes);
    
end

results_table = [num_electrodes' pse_bump' pse_stim' pse_stim'-pse_bump' ...
    null_bias_bump' null_bias_stim' null_bias_stim'-null_bias_bump'...
    pse_diff_p' null_bias_diff_p'];

results_table = num2cell(results_table);
for i=1:length(filelist)
    fig_links{i} = ['[[Media:' filelist(i).name '.png | ' filelist(i).name ']]'];
end
results_table = [num2cell([1:length(filelist)])' fig_links' {filelist.date}' results_table];

results_table_headers = {'Experiment number','Filename','Date','Num electrodes','PSE bump','PSE stim','PSE stim - PSE bump',...
    'Null bias bump', 'Null bias stim', 'Null bias stim - null bias bump', 'PSE p(stim > bump)', 'Null bias p(stim > bump)'};

mat2wiki(results_table,results_table_headers)

figure; 
plot(null_bias_diff_p,0,'.');
set(gca,'YTick',[])
ylim([-3 .5])
hold on
text(0.2,.4,'Num electrodes','HorizontalAlignment','Left')
text(0.2,-2.5,'Electrode numbers','HorizontalAlignment','Left')
for file_no = 1:length(filelist)
    text(null_bias_diff_p(file_no),0.2*rand+.1,num2str(num_electrodes(file_no)),...
        'HorizontalAlignment','center')
    text(null_bias_diff_p(file_no),-(2*rand+.1),num2str([filelist(file_no).electrodes]'),...
        'HorizontalAlignment','center','VerticalAlignment','top')
end
xlabel('p')
title('P(stim null bias - bump null bias < 0)')

figure; 
plot(pse_diff_p,0,'.');
set(gca,'YTick',[])
ylim([-3 .5])
xlim([0 1])
hold on
text(0.2,.4,'Num electrodes','HorizontalAlignment','Left')
text(0.2,-2.5,'Electrode numbers','HorizontalAlignment','Left')
for file_no = 1:length(filelist)
    text(pse_diff_p(file_no),0.2*rand+.1,num2str(num_electrodes(file_no)),...
        'HorizontalAlignment','center')
    text(pse_diff_p(file_no),-(2*rand+.1),num2str([filelist(file_no).electrodes]'),...
        'HorizontalAlignment','center','VerticalAlignment','top')    
end
xlabel('p')
title('P(stim pse - bump pse < 0)')