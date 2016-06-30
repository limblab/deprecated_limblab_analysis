%%
clear;
close all;
clc;

%% Pick session and parameters

% The following dates seem very weird:
%   '2014-01-15'
dataSummary;

monkeys = {'Mihili','Chewie','MrT'};
tasks = {'CO','RT'};
perts = {'FF','VR','GR'};
use_date_idx = ismember(sessionList(:,1),monkeys) & ismember(sessionList(:,3),perts) & ismember(sessionList(:,4),tasks);
use_dates = sessionList(use_date_idx,2);
epochs = {'BL','AD','WO'};

max_num_dims = 20;

do_split = false;

%%


% sum_dist = zeros(length(arrays),length(use_dates),2);

all_results = repmat(struct('M1',[],'PMd',[]),1,length(use_dates));
% loop along date
for idx_session = 1:length(use_dates)
    use_date = use_dates{idx_session};
    
    date_idx = strcmpi(sessionList(:,2),use_date);
    
    monkey = sessionList{date_idx,1};
    task = sessionList{date_idx,4};
    pert = sessionList{date_idx,3};
    
    y = use_date(1:4);
    m = use_date(6:7);
    d = use_date(9:10);
    
    switch lower(sessionList{date_idx,1})
        case 'mrt'
            arrays = {'PMd'};
        case 'chewie'
            arrays = {'M1'};
        case 'mihili'
            arrays = {'M1','PMd'};
    end
    
    for idx_array = 1:length(arrays)
        array = arrays{idx_array};
        
        filedir = ['F:\' monkey '\' array '\BDFStructs\' use_date];
        
        if (exist(['F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_notsplit.mat'],'file') && ~do_split) || (exist(['F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_split.mat'],'file') && do_split)
            if do_split
                disp(['Loading smoothed data... F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_split.mat']);
                load(['F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_split.mat']);
            else
                disp(['Loading smoothed data... F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_notsplit.mat']);
                load(['F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_notsplit.mat']);
            end
        else
            
            clear bdf;
            error_code = 0;
            sgs = cell(1,length(epochs));
            for i = 1:length(epochs)
                filename = [monkey '_' array '_' task '_' pert '_' epochs{i} '_' m d y '.mat'];
                
                if exist(fullfile(filedir,filename),'file') && ~error_code
                    load(fullfile(filedir,filename));
                    sg = cell2mat(cellfun(@(x) x',{out_struct.units.id},'UniformOutput',false))';
                    idx = sg(:,2) ~= 255 & sg(:,1) < 97;
                    out_struct.units = out_struct.units(idx);
                    
                    sgs{i} = sg(idx,:);
                    bdf(i) = out_struct;
                    clear out_struct;
                else
                    error_code = 1;
                    warning(['FILE NOT FOUND: ' filename]);
                end
            end
            
            if ~error_code
                if length(unique(cellfun(@length,{bdf.units}))) > 1
                    warning('Different unit counts...');
                    bad_units = checkUnitGuides(sgs);
                    master_sg = setdiff(sgs{1}, bad_units, 'rows');
                    
                    for i = 1:length(sgs)
                        [~,I] = intersect(sgs{i},master_sg,'rows');
                        bdf(i).units = bdf(i).units(I);
                        sgs{i} = sgs{i}(I,:);
                    end
                    clear bad_units master_sg i I;
                end
                
                
                disp('Beginning smoothing...');
                if do_split
                    [~, dim_red_FR, smoothed_FR ] = within_trial_comp_neural_spaces( bdf, 1:length(bdf(1).units), 3, epochs );
                    close all;
                    clear bdf idx sg1 sg2;
                    save(['F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_split.mat'],'dim_red_FR','smoothed_FR');
                else
                    [~, dim_red_FR, smoothed_FR ] = comp_neural_spaces( bdf, 1:length(bdf(1).units), 2, epochs);
                    close all;
                    %     [~, dim_red_FR, smoothed_FR ] = within_trial_comp_neural_spaces( bdf, 1:length(bdf(1).units), 3, epochs );
                    clear bdf idx sg1 sg2;
                    save(['F:\pca_results\' monkey '_' array '_' task '_' pert '_' use_date '_smoothed_notsplit.mat'],'dim_red_FR','smoothed_FR');
                end
            end
        end
        
        % get angles for some number of dimensions pre-sort
        
        epoch_angles = zeros(2,max_num_dims);
        for i = 1:max_num_dims
            [angles, ~, ~ ] = comp_neural_spaces( [], 1:size(smoothed_FR{1},2), i, epochs, smoothed_FR, dim_red_FR);
            epoch_angles(1,i) = angles.data(1,2);
            epoch_angles(2,i) = angles.data(1,3);
            close all;
        end
        
        all_results(idx_session).(array).epoch_angles = epoch_angles;
        
        % reorder based on similarity to baseline
        all_angles = cell(1,length(dim_red_FR)-1);
        all_dim_min_angles = cell(1,length(dim_red_FR)-1);
        for i = 2:length(dim_red_FR)
            [angle, dim_min_angle] = find_closest_hyperplane( dim_red_FR{1}.w, dim_red_FR{i}.w, 'all');
            dim_red_FR{i}.w = dim_red_FR{i}.w(:,dim_min_angle);
            dim_red_FR{i}.scores = dim_red_FR{i}.scores(:,dim_min_angle);
            dim_red_FR{i}.eigen = dim_red_FR{i}.eigen(dim_min_angle);
            
            all_angles{i-1} = angle;
            all_dim_min_angles{i-1} = dim_min_angle;
            
            %             sum_dist(idx_array,idx_session,i-1) = sum(abs((1:max_num_dims)-dim_min_angle(1:max_num_dims)));
            
        end
        
        all_results(idx_session).(array).reorder_angles = all_angles;
        all_results(idx_session).(array).dim_min_angle = all_dim_min_angles;
        
        % now get angles for reordered space
        epoch_angles = zeros(2,max_num_dims);
        for i = 1:max_num_dims
            [angles, ~, ~ ] = comp_neural_spaces( [], 1:size(smoothed_FR{1},2), i, epochs, smoothed_FR, dim_red_FR);
            epoch_angles(1,i) = angles.data(1,2);
            epoch_angles(2,i) = angles.data(1,3);
            close all;
        end
        
        all_results(idx_session).(array).epoch_angles_sort = epoch_angles;
        
        % now save some eigenvalue information
        eigen = zeros(size(dim_red_FR{1}.eigen,1),length(dim_red_FR));
%         w = zeros(size(dim_red_FR{1}.eigen,1),size(dim_red_FR{1}.eigen,1),length(dim_red_FR));
        for i = 1:length(dim_red_FR)
            eigen(:,i) = dim_red_FR{i}.eigen;
%             w(:,:,i) = dim_red_FR{i}.w;
        end
        all_results(idx_session).(array).eigen = eigen;
%         all_results(idx_session).(array).w = w;        
    end
end

save('F:\pca_results\all_results.mat','-v7.3','all_results','sessionList','use_date_idx');


%% Look at BL->AD space changes as a function of sessions
load( 'F:\pca_results\all_results.mat')
sessionList = sessionList(use_date_idx,:);

%%
perts = {'VR'};
tasks = {'CO','RT'};
monkeys = {'Mihili'};

max_num_dims = 20;
exclude_sessions = []; %[5,7,8,9,39,44,61,67];

idx = find( ismember(sessionList(:,1),monkeys) & ismember(sessionList(:,3),perts) & ismember(sessionList(:,4),tasks) );
idx(ismember(idx,exclude_sessions)) = [];

array = 'M1';
diff_sum_m1 = zeros(length(idx),max_num_dims);
for i = 1:length(idx)
    r = all_results(idx(i));
    if isfield(r,array)
        r = r.(array);
        for j = 1:max_num_dims
            diff_sum_m1(i,j) = sum( abs( (1:j) - r.dim_min_angle{1}(1:j) ) );
        end
    end
end

array = 'PMd';
diff_sum_pmd = zeros(length(idx),max_num_dims);
for i = 1:length(idx)
    r = all_results(idx(i));
    if isfield(r,array)
        r = r.(array);
        for j = 1:max_num_dims
            diff_sum_pmd(i,j) = sum( abs( (1:j) - r.dim_min_angle{1}(1:j) ) );
        end
    end
end

figure;
subplot(1,2,1);
imagesc(diff_sum_m1./repmat(diff_sum_m1(:,end),1,size(diff_sum_m1,2)));
subplot(1,2,2);
imagesc(diff_sum_pmd./repmat(diff_sum_pmd(:,end),1,size(diff_sum_pmd,2)));

figure;
imagesc(diff_sum_m1./repmat(diff_sum_m1(:,end),1,size(diff_sum_m1,2))-diff_sum_pmd./repmat(diff_sum_pmd(:,end),1,size(diff_sum_pmd,2))); colorbar;

        
%%
array = 'M1';
perts = {'VR','FF'};
tasks = {'CO','RT'};
monkeys = {'Mihili'};
which_plot = 2;
max_num_dims = 35;

exclude_sessions = []; %[5,7,8,9,39,44,61,67];

load( 'F:\pca_results\all_results.mat')
sessionList = sessionList(use_date_idx,:);
idx = find( ismember(sessionList(:,1),monkeys) & ismember(sessionList(:,3),perts) & ismember(sessionList(:,4),tasks) );

idx(ismember(idx,exclude_sessions)) = [];

switch which_plot
    case 1 % plot the angle between BL and AD/WO spaces for 1:20 dimensions  (pre and post sort)
        figure;
        all_data = zeros(length(idx),max_num_dims);
        all_data_sort = zeros(length(idx),max_num_dims);
        for i = 1:length(idx)
            r = all_results(idx(i));
            if isfield(r,array)
                r = r.(array);
                
                all_data(i,:) = r.epoch_angles(1,1:max_num_dims)*180/pi;
                all_data_sort(i,:) = r.epoch_angles_sort(1,1:max_num_dims)*180/pi;
                
                    subplot(1,2,1);
                    hold all;
                    plot(1:max_num_dims, r.epoch_angles(1,1:max_num_dims)*180/pi,'k','LineWidth',2);
                    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[1 max_num_dims],'YLim',[0 90]);
                    title('Ordered by Variance Explained','FontSize',14);
                    xlabel('Number of subspace dimensions','FontSize',14);
                    ylabel('Difference between BL and AD','FontSize',14);
                    
                    
                    subplot(1,2,2);
                    hold all;
                    plot(1:max_num_dims, r.epoch_angles_sort(1,1:max_num_dims)*180/pi,'k','LineWidth',2);
                    set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[1 max_num_dims],'YLim',[0 90]);
                    title('Sorted by Baseline Eigenvector Similarity','FontSize',14);
                    xlabel('Number of subspace dimensions','FontSize',14);
            end
        end
        
        
        
    case 2 % plot the sum distance of sort between BL and AD/WO for 1:20 dimensions
        figure;
        diff_sum = zeros(length(idx),max_num_dims);
        for i = 1:length(idx)
            r = all_results(idx(i));
            if isfield(r,array)
                r = r.(array);
                for j = 1:max_num_dims
                    diff_sum(i,j) = sum( abs( (1:j) - r.dim_min_angle{1}(1:j) ) );
                end
            end
        end
        
        imagesc(diff_sum,[0 50]); colorbar;
        
        diff_sum_ff = diff_sum;
        
        angle_diff = zeros(length(idx),max_num_dims);
        for i = 1:length(idx)
            r = all_results(idx(i));
            if isfield(r,array)
                r = r.(array);
                for j = 1:max_num_dims
                    angle_diff(i,j) = abs(j-r.dim_min_angle{1}(j));
                end
            end
        end
        angle_diff_mrt = angle_diff;
        
        
    case 3 % plot colormap show histograms of angle difference as function of dimensions
        for j = 1:2
            subplot(1,2,j);
            hold all;
            the_angles = zeros(length(idx),max_num_dims);
            for i = 1:length(idx)
                r = all_results(idx(i));
                if isfield(r,array)
                    r = r.(array);
                    the_angles(i,:) = r.epoch_angles(j,:)*180/pi;
                end
            end
            
            bins = 1:90;
            for i = 1:max_num_dims
                [n,x] = hist(the_angles(:,i),bins);
                hist_vec
            end
            
        end
        
    case 4 % show metrics averaged across sessions
        for i = 1:length(idx)
            r = all_results(idx(i));
            if isfield(r,array)
                r = r.(array);
                
                % get angle
                r.epoch_angles(j,:)*180/pi;
            end
        end
        
end

%%

figure;
        hold all;
        angle_diff = angle_diff_mihili;
        plot(1:size(angle_diff,2),mean(angle_diff,1),'b-','LineWidth',3);
        angle_diff = angle_diff_mrt;
        plot(1:size(angle_diff,2),mean(angle_diff,1),'k-','LineWidth',3);
        angle_diff = angle_diff_mihili;
        plot([1:size(angle_diff,2);1:size(angle_diff,2)]',[mean(angle_diff,1)-std(angle_diff,1)/sqrt(size(angle_diff,1));mean(angle_diff,1)+std(angle_diff,1)/sqrt(size(angle_diff,1))]','b--','LineWidth',2);
        angle_diff = angle_diff_mrt;
        plot([1:size(angle_diff,2);1:size(angle_diff,2)]',[mean(angle_diff,1)-std(angle_diff,1)/sqrt(size(angle_diff,1));mean(angle_diff,1)+std(angle_diff,1)/sqrt(size(angle_diff,1))]','k--','LineWidth',2);
        legend({'Mihili','MrT'},'FontSize',14);
        set(gca,'Box','off','FontSize',14,'TickDir','out');
        xlabel('Components','FontSize',14);
        ylabel('Difference of match','FontSize',14);
        axis('tight');
        title('PMd:CF+VR','FontSize',14);


%%
a = diff_sum_ff(:,end);
b = diff_sum_vr(:,end);
a(a > 70) = [];
b(b > 70) = [];
figure;
hist(a,0:5:70);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r');
hold all;
hist(b,0:5:70);
h = findobj(gca,'Type','patch');
set(h,'EdgeColor','w','FaceAlpha',0.7);

axis('tight');
legend({'FF','VR'});
title('PMd: All tasks, all monkeys','FontSize',14);
xlabel('Sum Difference','FontSize',14);
ylabel('Count','FontSize',14);
set(gca,'Box','off','TickDir','out','FontSize',14);

%%
%% Make a summary plot
% % a=[squeeze(mean_dist(1,vr_inds,1)); squeeze(mean_dist(1,cf_inds,1))]';
% % figure;
% % bar(a)
% % set(gca,'Box','off','TickDir','out','FontSize',14);
% % xlabel('Session','FontSize',14);
% % legend({'VR','CF'},'FontSize',14);
% % title('M1','FontSize',14);
% %
% % a=[squeeze(mean_dist(2,vr_inds,1)); squeeze(mean_dist(2,cf_inds,1))]';
% % figure;
% % bar(a)
% % set(gca,'Box','off','TickDir','out','FontSize',14);
% % xlabel('Session','FontSize',14);
% % legend({'VR','CF'},'FontSize',14);
% % title('PMd','FontSize',14);
%
%
% % plot(squeeze(mean_dist(2,vr_inds,1)),'ro')
%
% % a=[squeeze(mean_dist(1,[1,2],2)); squeeze(mean_dist(1,[3,5],2))]'
% % bar(a)
% % set(gca,'Box','off','TickDir','out','FontSize',14);
% % xlabel('Session','FontSize',14);
% % legend({'VR','CF'},'FontSize',14);
% %
% % a=[squeeze(mean_dist(2,[1,2],2)); squeeze(mean_dist(2,[3,5],2))]'
% % bar(a)
% % set(gca,'Box','off','TickDir','out','FontSize',14);
% % xlabel('Session','FontSize',14);
% % legend({'VR','CF'},'FontSize',14);
%
%
%
% %%
% % %% Now look at dimensionality
% % labels = epochs;
% % % labels = {'BL1','BL2','AD1','AD2','WO1','WO2'};
% %
% % a = zeros(1,9); b = zeros(1,9);
% % for i = 2:10
% %     [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( [], 1:size(smoothed_FR{1},2), i, labels, smoothed_FR, dim_red_FR);
% %     a(i-1) = angles.data(1,2);
% %     b(i-1) = angles.data(1,3);
% %     close all;
% % end
% %
% % figure;
% % hold all;
% % plot(2:10,a*180/pi,'b','LineWidth',2);
% % plot(2:10,b*180/pi,'r','LineWidth',2);
% % set(gca,'Box','off','TickDir','out','FontSize',14);
% % xlabel('Number of latent dimensions','FontSize',14);
% % ylabel('Angle between hyperplane','FontSize',14);
% % legend({'BL->CF','BL->WO'},'FontSize',14,'Location','NorthWest');
% % title('PMd Curl Field','FontSize',14);
% %
% % [angles, dim_red_FR, smoothed_FR ] = comp_neural_spaces( [], size(smoothed_FR{1},2), 3, labels, smoothed_FR, dim_red_FR);
% %
%


