% Find PDs
plotting = 1;
datapath = 'D:\Data\Tiki\FMAs\';
filename = 'Tiki_2011-03-29_RW_001-s';
extension = '.nev';
filename_analyzed = [datapath 'Processed\' filename];

curr_dir = pwd;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis';
load_paths;
cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';

if ~exist([datapath 'Processed\' filename '.mat'],'file')
    if strcmp(extension,'.nev')
        bdf = get_cerebus_data([datapath 'Sorted\' filename extension],2);
    else
        bdf = get_plexon_data([datapath 'Sorted\' filename extension],2);
    end
    save([datapath 'Processed\' filename],'bdf');    
else
    load([datapath 'Processed\' filename],'bdf')
end
cd(curr_dir)

units = unit_list(bdf);
units = units(units(:,2)>0 & units(:,2)<10,:);
monkey = 'T';

clear out;

tic;
%% figure
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
%     plot(vs(:,1),vs(:,2),'.')
%     xlim([-150 150])
%     ylim([-150 150])
%     drawnow
%     pause
    [p_vs, theta, rho] = vel_pdf_polar(vs);
    
    % GLM evaluation
    p_glm = zeros(size(rho));
    for x = 1:size(p_glm,1)
        for y = 1:size(p_glm,2)
            state = [0 0 rho(x,y)*cos(theta(x,y)) rho(x,y)*sin(theta(x,y)) rho(x,y)];
            p_glm(x,y) = glmval(b, state, 'log').*20;
        end
    end
    if plotting
        figure(1)
        subplot(11,10,i), h=pcolor(theta, rho, p_glm );
        axis square;
        set(gca,'XTick',0:pi:2*pi)
        set(gca,'XTickLabel',{'0','pi','2*pi'})
        set(h, 'EdgeColor', 'none');
        drawnow
    end
        
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

if plotting
    figure
end

for i=1:length(out)
    % GLM evaluation
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
    dm(i) = (max(max(p_glm')) - min(max(p_glm')))/20;
    speed_comp(i) = mean(max(p_glm'))/20;
end

%%
if plotting
    figure; plot(speed_comp,'b'); hold on; plot(dm,'r'); plot(speed_comp+dm,'k')
    [sorted_dm sorted_dmx] = sort(dm,'descend');
    sorted_speed = speed_comp(sorted_dmx);
    figure; plot(sorted_dm,'r'); hold on; plot(sorted_speed,'b');
    xlabel('unit')
    ylabel('modulation (Hz)')
    legend('Depth of modulation','Speed component')
end

%% Mutual information
[pos_mi, mis] = batch_mi(bdf, 'vel');

%% map
if plotting
    figure;
    hold on
    max_mi = max(pos_mi(:,3));
    scaling = 2;
    alpha = .2;
    beta = .3;
    load('D:\Ricardo\Miller Lab\Matlab\map_tiki')
    map_tiki = map_tiki_b;
    for i=1:length(out)
    %     electrode = premap_tiki(premap_tiki(:,1) == out(i).chan,2);
        [map_row map_column] = find(map_tiki==out(i).chan);
        p0 = [map_column map_row];
        if scaling
            p1 = [map_column+cos(out(i).glmpd)*pos_mi(i,3)/max_mi...
                map_row-sin(out(i).glmpd)*pos_mi(i,3)/max_mi];
        else
            p1 = [map_column+cos(out(i).glmpd) map_row-sin(out(i).glmpd)];
        end
        p = p1-p0;
        x0 = p0(1);
        y0 = p0(2);
        x1 = p1(1);
        y1 = p1(2);
        plot([x0;x1],[y0;y1]);
        hu = [x1-alpha*(p(1)+beta*(p(2)+eps)); x1; x1-alpha*(p(1)-beta*(p(2)+eps))];
        hv = [y1-alpha*(p(2)-beta*(p(1)+eps)); y1; y1-alpha*(p(2)+beta*(p(1)+eps))];
        plot(hu(:),hv(:))
        text(x0,y0,num2str(out(i).chan))
    %     text(x0,y0,[num2str(out(i).chan) ' (' num2str(floor((out(i).chan-1)/32)+1) '-'...
    %         num2str(mod(out(i).chan,32) + 32*(mod(out(i).chan,32)==0)) ')'])
    end
    for i = 1:100
    %     text(mod(i-1,10)+1,(i-mod(i-1,10))/10+1,num2str(i))
    %     text(mod(i,11)+1,1+(i-mod(i,11))/11,num2str(i))
    end
    set(gca,'YDir','reverse')
    xlim([0 11])
    ylim([0 11])
    title(filename)       
end
%%
% [[out.chan]' [out.glmpd]' [dm]']
% save(filename_analyzed,'out','pos_mi','mis')