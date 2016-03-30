%% read csv files
file = 'C:\Users\rhc307\Documents\Data\ForceKin\Data\mini_iso_015';
reaches_mat = csvread([file '.csv']);
thv = reaches_mat(:,1);
thf = reaches_mat(:,2);
fr = reaches_mat(:,3:end);

%% get PDs by finding circular means of reaches weighted by firing rates
vel_PD = atan2(sin(thv)'*fr,cos(thv)'*fr);
force_PD = atan2(sin(thf)'*fr,cos(thf)'*fr);

% loop through neurons
for uid = 1:size(fr,2)
%     % center reaches on PDs
%     thv_center = mod(thv-vel_PD(i)+pi,2*pi)-pi;
%     thf_center = mod(thf-force_PD(i)+pi,2*pi)-pi;
    % find cosines of velocity and force directions
    cos_v = cos(thv-vel_PD(uid));
    cos_f = cos(thf-force_PD(uid));
    
%     figure(100+uid)
    [p,tbl] = anovan(fr(:,uid),{cos_v,cos_f},'continuous',[1 2],'model','interaction','display', 'off');
    if p(3)<0.05
        display(['Yay ' num2str(uid) '!'])
    end
    
    % figure display stuff
    % convolve with a 2D gaussian kernel
    gx = zeros(size(force_dir));
    gp = zeros(size(force_dir));
    sig = .5;
    for offsetx = -2:2
        for offsety = -2:2
            dx = 2*pi*offsetx;
            dy = 2*pi*offsety;
            for i = 1:length(thf) % for every reach
                gx = gx + fr(i,uid) * exp( -sqrt((thf(i)-force_dir-dx).^2 + (thv(i)-vel_dir-dy).^2) / 2 / sig.^2 );
                gp = gp + exp( -sqrt((thf(i)-force_dir-dx).^2 + (thv(i)-vel_dir-dy).^2) / 2 / sig.^2 );
            end
        end
    end
    srf = gx ./ gp;
    
    full_map = srf;
    force_map = full_map;
    vel_map = full_map;

    for i = 1:size(force_dir,2)
%         force_center = force_dir(1,i);
%         force_bounds = [force_center-increment/2 force_center+increment/2];
%         selector = mod(thf,2*pi)>mod(force_bounds(1),2*pi) & mod(thf,2*pi)<mod(force_bounds(2),2*pi);
%         force_map(:,i) = repmat(mean(fr(selector,uid)),size(force_dir,1),1);
        force_map(:,i) = repmat(mean(full_map(:,i)),size(force_dir,1),1);
    end
    force_map = force_map-mean(mean(force_map));
    
    for i = 1:size(vel_dir,1)
%         vel_center = vel_dir(i,1);
%         vel_bounds = [vel_center-increment/2 vel_center+increment/2];
%         selector = mod(thv,2*pi)>mod(vel_bounds(1),2*pi) & mod(thv,2*pi)<mod(vel_bounds(2),2*pi);
%         vel_map(i,:) = repmat(mean(fr(selector,uid)),1,size(vel_dir,2));
        vel_map(i,:) = repmat(mean(full_map(i,:)),1,size(vel_dir,2));
    end
    vel_map = vel_map-mean(mean(vel_map));
    
    vel_PD_single = atan2(sum(sum(sin(vel_dir).*full_map)),sum(sum(cos(vel_dir).*full_map)));
    force_PD_single = atan2(sum(sum(sin(force_dir).*full_map)),sum(sum(cos(force_dir).*full_map)));
%     vel_PD = atan2(sin(vel_dir(:,1)')*vel_map(:,1)/sum(vel_map(:,1)),cos(vel_dir(:,1)')*vel_map(:,1)/sum(vel_map(:,1)));
%     force_PD = atan2(sin(force_dir(1,:))*force_map(1,:)'/sum(force_map(1,:)),cos(force_dir(1,:))*force_map(1,:)'/sum(force_map(1,:)));
    vel_PDind = round((vel_PD_single+pi)/increment);
    force_PDind = round((force_PD_single+pi)/increment);
%     [~,vel_PDind] = max(vel_map(:,1));
%     [~,force_PDind] = max(force_map(1,:));
    middle_ind = floor((length(vel_map)+1)/2);
    
    full_map = circshift(full_map,middle_ind-vel_PDind,1);
    full_map = circshift(full_map,middle_ind-force_PDind,2);
    vel_map = circshift(vel_map,middle_ind-vel_PDind,1);
    force_map = circshift(force_map,middle_ind-force_PDind,2);

%     for i = 1:size(force_dir,1)
%         for j = 1:size(force_dir,2)
%             vel_center = vel_dir(i,j);
%             vel_bounds = [vel_center-increment/2 vel_center+increment/2];
%             force_center = force_dir(i,j);
%             force_bounds = [force_center-increment/2 force_center+increment/2];
%             
%             force_selector = mod(thf,2*pi)>mod(force_bounds(1),2*pi) & mod(thf,2*pi)<mod(force_bounds(2),2*pi);
%             vel_selector = mod(thv,2*pi)>mod(vel_bounds(1),2*pi) & mod(thv,2*pi)<mod(vel_bounds(2),2*pi);
%             full_map(i,j) = mean(fr(vel_selector & force_selector,uid));
%         end
%     end
    
    resid_map = full_map - vel_map - force_map - mean(mean(full_map));
%     resid_map_total = resid_map_total+resid_map/mean(mean(resid_map));
%     figure; plot3(thf, thv, fr(:,uid), 'k.');
%     hold on;
%     mesh(xx,yy,srf);
%     xlabel('Force Direction');
%     ylabel('Velocity Direction');
%     zlabel('Firing Rate');

    h = figure;
    subplot(221)
%     mesh(vel_dir-vel_PD,force_dir-force_PD,full_map)
    imagesc(full_map)
    colorbar
    subplot(222)
%     imagesc(vel_map,clim)
    imagesc(vel_map)
    colorbar
    subplot(223)
%     imagesc(force_map,clim)
    imagesc(force_map)
    colorbar
    subplot(224)
    imagesc(resid_map)
    colorbar
    
    %titles
    subplot(221)
    title(sprintf('Neuron %d', uid));
    subplot(222)
    title(['Velocity pval: ' num2str(p(1))])
    subplot(223)
    title(['Force pval: ' num2str(p(2))])
    subplot(224)
    title(['Residual. Interaction pval: ' num2str(p(3))])
    colormap jet
    
    dir_results = dir([file '\']);
    if isempty(dir_results)
        mkdir([file '\'])
    end
    saveas(h,[file '\Neuron_' num2str(uid) '.png'])
end

% %% Construct cosine tuning map by gaussian convolution
% increment = 1/10;
% [force_cos, vel_cos] = meshgrid(-1:increment:1-increment, -1:increment:1-increment);
% resid_map_total = zeros(size(force_cos));
% for uid = 1:size(fr,2)
%     % center reaches on PDs
%     thv_center = mod(thv-vel_PD(uid)+pi,2*pi)-pi;
%     thf_center = mod(thf-force_PD(uid)+pi,2*pi)-pi;
%     
%     % convolve with a 2D gaussian kernel
%     gx = zeros(size(force_cos));
%     gp = zeros(size(force_cos));
%     sig = .15;
%     for offsetx = -2:2
%         for offsety = -2:2
%             dx = 2*pi*offsetx;
%             dy = 2*pi*offsety;
%             for i = 1:length(thf) % for every reach
%                 gx = gx + fr(i,uid) * exp( -sqrt((cos(thf_center(i))-force_cos-dx).^2 + (cos(thv_center(i))-vel_cos-dy).^2) / (2 * sig.^2) );
%                 gp = gp + exp( -sqrt((cos(thf_center(i))-force_cos-dx).^2 + (cos(thv_center(i))-vel_cos-dy).^2) / (2 * sig.^2) );
%             end
%         end
%     end
%     full_map = gx ./ gp;
%     
%     figure
%     imagesc(full_map)
%     colormap jet
%     colorbar
% end