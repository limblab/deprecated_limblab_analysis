% Find PDs

filename = 'D:\Data\Pedro\Pedro_S1_043-s_multiunit';
% filename = 'D:\Data\Tiki_B\tiki_S1_b_006-presort';

curr_dir = pwd;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
addpath('D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo');
load_paths;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
if ~exist([filename '.mat'],'file')
   
    bdf = get_plexon_data([filename '.plx'],2);
    save(filename,'bdf');
    
end
cd(curr_dir)
load(filename,'trial_table','bdf')

units = unit_list(bdf);
monkey = 'T';

clear out;

tic;
for i = 1:size(units, 1)
    chan = units(i,1);
    unit = units(i,2);
    
    et = toc;
    disp(sprintf('%d of %d\t%d-%d\tET: %f', i, size(units, 1), chan, unit, et));
    
    mi_peak = 0;
    

    % GLM Fitting Method
    [b, dev, stats] = glm_kin(bdf, chan, unit, mi_peak);    
    s = train2bins(get_unit(bdf, chan, unit) - mi_peak, bdf.vel(:,1));
    vs = bdf.vel(s>0,2:3);
    [p_vs, theta, rho] = vel_pdf_polar(vs);

    
    % GLM evaluation
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(b, state, 'log').*20;
        end
    end
    figure(1)
    subplot(11,10,i), h=pcolor(theta, rho, p_glm );
    axis square;
%     title('GLM Likelihood');
%     xlabel('Direction');
%     ylabel('Speed (cm/s)');
    set(gca,'XTick',0:pi:2*pi)
    set(gca,'XTickLabel',{'0','pi','2*pi'})
    set(h, 'EdgeColor', 'none');
    drawnow
    %caxis([0 b_ml*3]);
        
    tuning = mean(p_glm' .* 1000);
    tt = [tuning.*cos(theta(:,1)'); tuning.*sin(theta(:,1)')];
    tt = sum(tt');    
    pd2 = atan2(tt(2), tt(1));
    
    out(i) = struct('chan', chan, 'unit', unit, 'glmb', b, 'glmstats', stats, ...       
        'glmpd', pd2);
end
%%
dm = zeros(1,length(out));
speed_comp = zeros(1,length(out));
plotting = 0;
for i=1:length(out)
    % GLM evaluation
    i
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(out(i).glmb, state, 'log').*20;
        end
    end
    if plotting
        subplot(11,10,i);
        h=pcolor(theta, rho, p_glm );
        axis square;
    %     title('GLM Likelihood');
    %     xlabel('Direction');
    %     ylabel('Speed (cm/s)');
        set(gca,'XTick',0:pi:2*pi)
        set(gca,'XTickLabel',{'0','pi','2pi'})
        set(h, 'EdgeColor', 'none');
        title([num2str(out(i).chan) '-' num2str(out(i).unit)])
        drawnow
    end
    dm(i) = max(max(p_glm'))/mean(max(p_glm'));
    speed_comp(i) = mean(max(p_glm'))/20;
%     dm(i) = (max(max(p_glm')) - min(max(p_glm')))/20;
%     speed_comp(i) = mean(max(p_glm'))/20;
end

%%
figure; plot(speed_comp,'b'); hold on; plot(dm,'r'); plot(speed_comp+dm,'k')
[sorted_dm sorted_dmx] = sort(dm,'descend');
sorted_speed = speed_comp(sorted_dmx);
figure; plot(sorted_dm,'r'); hold on; plot(sorted_speed,'b');
xlabel('unit')
ylabel('modulation (Hz)')
legend('Depth of modulation','Speed component')

%% PDs and depth of modulation.  Top view of array, wire bundle to the right
if sum([bdf.units.id]) > 0
    figure
%     modulation = sqrt(pd_vector(:,1).^2 + pd_vector(:,2).^2)./mean(binned_fr_matrix)';
% %     modulation = sqrt(pd_vector(:,1).^2 + pd_vector(:,2).^2)./mean_firing_rate';
%     modulation(isnan(modulation))=0;
%     modulation = (modulation-min(modulation))/(.75*max(modulation-min(modulation)));
%     modulation = min(1,modulation);
    chan_unit = [out.chan]';
    
    modulation = min(dm/(1*max(dm)),1);
    
%     pref_dirs = atan2(pd_vector(:,2),pd_vector(:,1));
%     pref_dirs(pref_dirs<0) = 2*pi+pref_dirs(pref_dirs<0);
    for i = 1:length(out)
        pref_dirs(i) = out(i).glmpd;
    end
    pref_dirs(pref_dirs<0) = pref_dirs(pref_dirs<0)+2*pi;

    for i = 1:length(out)
        subplot(10,10,electrode_pin(electrode_pin(:,2)==out(i).chan(1),1))
        area([0 0 1 1],[0 1 1 0],'FaceColor',hsv2rgb([pref_dirs(i)/(2*pi) modulation(i) 1]))
        hold on
        vectarrow(.5+[0 0],.5+modulation(i)*[0.5*cos(pref_dirs(i)) 0.5*sin(pref_dirs(i))],.3,.3,'k')
        axis off
        title(num2str(chan_unit(i,1)))
        out(i).chan = out(i).chan(1);
        out(i).pd = pref_dirs(i);
    end
    
    no_unit_electrodes = setdiff(electrode_pin(:,2),chan_unit(:,1));
    for i = 1:length(no_unit_electrodes)
        subplot(10,10,electrode_pin(electrode_pin(:,2)==no_unit_electrodes(i),1))     
        area([0 0 1 1],[0 1 1 0],'FaceColor','white')
        axis off
        title(num2str(no_unit_electrodes(i)))
    end
    
    subplot(10,10,1)    
    n = 20; 
    theta = pi*(0:2*n)/n; 
    r = (0:n)'/n;
    x = r*cos(theta); 
    y = r*sin(theta); 
    c = ones(size(r))*theta; 
    pcolor(x,y,c)
    colormap hsv(360)
    set(get(gca,'Children'),'LineStyle','none');
    axis equal
    axis off
    title('PD color')
end

%% Preferred direction distribution
figure;
subplot(1,2,1)
compass(modulation.*cos(pref_dirs'),modulation.*sin(pref_dirs'))
subplot(1,2,2)
hist(180*pref_dirs/pi,18)
xlim([0 360])
xlabel('Preferred directions (degrees)')
ylabel('Count')

%% Compare GLM and bump PDs
if sum([bdf.units.id]) > 0 && isstruct(actual_units)
    figure
    chan_unit_glm = [out.chan]';
    chan_unit_bump = [actual_units.id]';
    chan_unit_both = intersect(chan_unit_glm,chan_unit_bump);
    pref_dirs_glm = zeros(length(out),1);
    pref_dirs_bump = zeros(length(actual_units),1);

    for i = 1:length(out)
        pref_dirs_glm(i) = out(i).glmpd;
    end
    pref_dirs_glm(pref_dirs_glm<0) = pref_dirs_glm(pref_dirs_glm<0)+2*pi;
    
    for i = 1:length(actual_units)
        pref_dirs_bump(i) = actual_units(i).pd;
    end
%     pref_dirs_bump = pref_dirs_bump';
    
    [temp, index_bump, index_glm] = intersect(chan_unit_bump,chan_unit_glm);
    pref_dirs_diff = abs(pref_dirs_bump(index_bump(:))-pref_dirs_glm(index_glm(:)));
    cos_pref_dirs = cos(pref_dirs_bump(index_bump(:))-pref_dirs_glm(index_glm(:)));
    pref_dirs_diff = min(pref_dirs_diff,2*pi-pref_dirs_diff);
        
    for i = 1:length(index_bump)
        subplot(10,10,electrode_pin(electrode_pin(:,2)==out(index_glm(i)).chan(1),1))
%         area([0 0 1 1],[0 1 1 0],'FaceColor',hsv2rgb([pref_dirs_diff(i)/(2*pi) 1 1]))
        area([0 0 1 1],[0 1 1 0],'FaceColor',hsv2rgb([1 1 cos_pref_dirs(i)/2 + .5]))
        hold on
        vectarrow(.5+[0 0],.5+[0.5*cos(pref_dirs_diff(i)) 0.5*sin(pref_dirs_diff(i))],.3,.3,'white')
        axis off
        title(num2str(chan_unit(i,1)))
    end
    
    no_unit_electrodes = setdiff(electrode_pin(:,2),chan_unit_both(:,1));
    for i = 1:length(no_unit_electrodes)
        subplot(10,10,electrode_pin(electrode_pin(:,2)==no_unit_electrodes(i),1))     
        area([0 0 1 1],[0 1 1 0],'FaceColor','white')
        axis off
        title(num2str(no_unit_electrodes(i)))
    end
    
    subplot(10,10,1)    
    n = 20; 
    theta = pi*(0:2*n)/n; 
    r = (0:n)'/n;
    x = r*cos(theta); 
    y = r*sin(theta); 
    c = ones(size(r))*theta; 
    pcolor(x,y,c)
    colormap hsv(360)
    set(get(gca,'Children'),'LineStyle','none');
    axis equal
    axis off
    title('PD difference')
end

%% PD difference histogram
if sum([bdf.units.id]) > 0 && isstruct(actual_units)
    figure; hist(180*pref_dirs_diff/pi)
    xlabel('Absolute PD difference (deg)')
    ylabel('Count')
end

%%
[[out.chan]' [out.glmpd]' [dm]']
save(filename,'out','-append')

%% Get electrode distance
electrode_distance_x = zeros(5);
electrode_distance_y = zeros(5);
interelectrode = 0.4; %mm
for i =1:5
    for j =1:5
        electrode_distance_x(j,i) = (i-1);
        electrode_distance_y(i,j) = (i-1);
    end
end

electrode_distance_x = 4*interelectrode*electrode_distance_x/max(electrode_distance_x(1,:));
electrode_distance_x = electrode_distance_x + interelectrode/2;
electrode_distance_y = 4*interelectrode*electrode_distance_y/max(electrode_distance_y(:,1));
electrode_distance_y = electrode_distance_y + interelectrode/2;

electrode_distance_x = [-electrode_distance_x(:,end:-1:1),electrode_distance_x(:,:);...
    -electrode_distance_x(:,end:-1:1),electrode_distance_x(:,:)];

electrode_distance_y = [electrode_distance_y(end:-1:1,:),electrode_distance_y(end:-1:1,:);...
    -electrode_distance_y(:,:),-electrode_distance_y(:,:)];

electrode_distance = [map_pedro(:) electrode_distance_x(:) electrode_distance_y(:)];
[temp idx_dist temp] = intersect(electrode_distance(:,1),chan_unit_both);
electrode_distance = electrode_distance(idx_dist,:);
%% Find centroid
cos_centroid_mat = [electrode_distance(:,2) electrode_distance(:,3) cos_pref_dirs];
centroid_x_y = mean([cos_centroid_mat(:,3).*cos_centroid_mat(:,1) cos_centroid_mat(:,3).*cos_centroid_mat(:,2)]);

num_iter = 10000;
centroids_rand = zeros(num_iter,2);
%bootstrapping
for i=1:num_iter
    rand_indexes = randperm(length(cos_centroid_mat));
    centroids_rand(i,:) = mean([cos_centroid_mat(:,3).*cos_centroid_mat(rand_indexes,1) cos_centroid_mat(:,3).*cos_centroid_mat(rand_indexes,2)]);
end
figure; 
plot(centroids_rand(:,1),centroids_rand(:,2),'.')
hold on
plot(centroid_x_y(1),centroid_x_y(2),'.r')

rs = sqrt(sum(centroids_rand.^2,2));
r = sqrt(sum(centroid_x_y.^2,2));
prob = length(find(rs>r))/num_iter