% Find PDs
monkey_array = 'Pedro_1';
RW_filename = 'D:\Data\Pedro\Pedro_S1_044-s_multiunit';
BC_filename = 'D:\Data\Pedro\Pedro_BC_031-s_multiunit';

curr_dir = pwd;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
addpath('D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo');
load_paths;

glm_output = RW_PDs(RW_filename);
glm_pd_table = glmout2table(glm_output); % [chan unit pd norm_modulation]
PD_map(glm_pd_table,monkey_array);

bump_pd_table = bumpfile2pdtable(BC_filename);
PD_map(bump_pd_table,monkey_array); 
bump_tuning_curve_map(BC_filename,monkey_array);
bump_raster(BC_filename,monkey_array,1)

PD_distribution_plot({'GLM','Bump'},glm_pd_table,bump_pd_table)
GLM_bump_PD_compare_plot(glm_pd_table,bump_pd_table,monkey_array)

% save(filename,'out','-append')

% %% Get electrode distance
% electrode_distance_x = zeros(5);
% electrode_distance_y = zeros(5);
% interelectrode = 0.4; %mm
% for i =1:5
%     for j =1:5
%         electrode_distance_x(j,i) = (i-1);
%         electrode_distance_y(i,j) = (i-1);
%     end
% end
% 
% electrode_distance_x = 4*interelectrode*electrode_distance_x/max(electrode_distance_x(1,:));
% electrode_distance_x = electrode_distance_x + interelectrode/2;
% electrode_distance_y = 4*interelectrode*electrode_distance_y/max(electrode_distance_y(:,1));
% electrode_distance_y = electrode_distance_y + interelectrode/2;
% 
% electrode_distance_x = [-electrode_distance_x(:,end:-1:1),electrode_distance_x(:,:);...
%     -electrode_distance_x(:,end:-1:1),electrode_distance_x(:,:)];
% 
% electrode_distance_y = [electrode_distance_y(end:-1:1,:),electrode_distance_y(end:-1:1,:);...
%     -electrode_distance_y(:,:),-electrode_distance_y(:,:)];
% 
% electrode_distance = [map_pedro(:) electrode_distance_x(:) electrode_distance_y(:)];
% [temp idx_dist temp] = intersect(electrode_distance(:,1),chan_unit_both);
% electrode_distance = electrode_distance(idx_dist,:);
% 
% %% Find centroid
% cos_centroid_mat = [electrode_distance(:,2) electrode_distance(:,3) cos_pref_dirs];
% centroid_x_y = mean([cos_centroid_mat(:,3).*cos_centroid_mat(:,1) cos_centroid_mat(:,3).*cos_centroid_mat(:,2)]);
% 
% num_iter = 10000;
% centroids_rand = zeros(num_iter,2);
% %bootstrapping
% for i=1:num_iter
%     rand_indexes = randperm(length(cos_centroid_mat));
%     centroids_rand(i,:) = mean([cos_centroid_mat(:,3).*cos_centroid_mat(rand_indexes,1) cos_centroid_mat(:,3).*cos_centroid_mat(rand_indexes,2)]);
% end
% figure; 
% plot(centroids_rand(:,1),centroids_rand(:,2),'.')
% hold on
% plot(centroid_x_y(1),centroid_x_y(2),'.r')
% 
% rs = sqrt(sum(centroids_rand.^2,2));
% r = sqrt(sum(centroid_x_y.^2,2));
% prob = length(find(rs>r))/num_iter

%% find mean pd of selected electrodes
selected_electrodes = [95 96];
id_pd = [bump_pd_table(:,1) bump_pd_table(:,3)];
[temp id_idx temp] = intersect(id_pd(:,1),selected_electrodes);
mean_pd_selected_electrodes = mean(id_pd(id_idx,2))
std_pd_selected_electrodes = std(id_pd(id_idx,2))