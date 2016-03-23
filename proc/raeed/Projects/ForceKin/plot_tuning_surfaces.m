%% read csv files
reaches_mat = csvread('C:\Users\rhc307\Documents\Data\ForceKin\Data\Arthur_S1_012-s.csv');
thv = reaches_mat(:,1);
thf = reaches_mat(:,2);
fr = reaches_mat(:,3:end);

%% Plot the tuning curves
increment = pi/10;
[force_dir, vel_dir] = meshgrid(-pi:increment:pi-increment, -pi:increment:pi-increment);
resid_map_total = zeros(size(force_dir));
for uid = 1:size(fr,2)
%     [force_dir, vel_dir] = meshgrid(-pi:increment:pi, -pi:increment:pi);
    gx = zeros(size(force_dir));
    gp = zeros(size(force_dir));
    sig = .5;
    for offsetx = -2:2
        for offsety = -2:2
            dx = 2*pi*offsetx;
            dy = 2*pi*offsety;
            for i = 1:length(thf)
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
    
    vel_PD = atan2(sum(sum(sin(vel_dir).*full_map)),sum(sum(cos(vel_dir).*full_map)));
    force_PD = atan2(sum(sum(sin(force_dir).*full_map)),sum(sum(cos(force_dir).*full_map)));
%     vel_PD = atan2(sin(vel_dir(:,1)')*vel_map(:,1)/sum(vel_map(:,1)),cos(vel_dir(:,1)')*vel_map(:,1)/sum(vel_map(:,1)));
%     force_PD = atan2(sin(force_dir(1,:))*force_map(1,:)'/sum(force_map(1,:)),cos(force_dir(1,:))*force_map(1,:)'/sum(force_map(1,:)));
    vel_PDind = round((vel_PD+pi)/increment);
    force_PDind = round((force_PD+pi)/increment);
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

    clim = [min(min(full_map)) max(max(full_map))];
    figure
    subplot(221)
    imagesc(full_map,clim)
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
    subplot(221)
    title(sprintf('Neuron %d', uid));
    colormap jet

end % foreach unit

% figure
% imagesc(resid_map_total)
% colormap jet