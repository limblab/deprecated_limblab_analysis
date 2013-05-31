function UF_plot_STAEMG(UF_struct,bdf)
if isfield(bdf,'units')

    UF_struct.t_axis = bdf.pos(:,1);
    all_chans = reshape([bdf.units.id],2,[])';   
    units = unit_list(bdf);
    dt = round(mean(diff(bdf.pos(:,1)))*10000)/10000;
    emg_window = -.1:dt:.1;
    idx_vec = emg_window/dt;
    bin_size = dt;     
    t = double(bdf.emg.data(:,1))';
    t = round(t/dt)*dt;     

    for iUnit = 1:size(units,1)    
        unit_idx = find(all_chans(:,1)==units(iUnit,1) & all_chans(:,2)==units(iUnit,2));
        electrode = UF_struct.elec_map(find(UF_struct.elec_map(:,3)==all_chans(unit_idx,1)),4);  
        ts = bdf.units(unit_idx).ts; 
        ts = round(ts/dt)*dt;
        
        spike_vector = zeros(size(t));
        [~,it,~] = intersect(t,ts);      
        it_fake = sort(it+1000*rand+500);
        it_fake = it_fake(it_fake<length(t));
        
        figure;
        for iEMG = 1:UF_struct.num_emg
            emg_mat = zeros(length(ts),length(emg_window));
            idx_mat = round(repmat(idx_vec,length(it),1) + repmat(it',1,size(idx_vec,2)));
            emg_mat(idx_mat>0 & idx_mat<=length(bdf.emg.data)) =...
                UF_struct.emg_filtered(idx_mat(idx_mat>0 & idx_mat<=length(bdf.emg.data)),iEMG);
            emg_mat = abs(emg_mat);
            emg_mat = emg_mat - repmat(mean(emg_mat,2),1,size(emg_mat,2));
            keep_idx = sum(emg_mat > repmat(mean(emg_mat)+3*std(emg_mat),size(emg_mat,1),1),2)>=0;
            emg_mat = emg_mat(keep_idx,:);
            
            emg_mat_fake = zeros(length(it_fake),length(emg_window));
            idx_mat = round(repmat(idx_vec,length(it_fake),1) + repmat(it_fake',1,size(idx_vec,2)));
            emg_mat_fake(idx_mat>0 & idx_mat<=length(bdf.emg.data)) =...
                UF_struct.emg_filtered(idx_mat(idx_mat>0 & idx_mat<=length(bdf.emg.data)),iEMG);
            emg_mat_fake = abs(emg_mat_fake);
            emg_mat_fake = emg_mat_fake - repmat(mean(emg_mat_fake,2),1,size(emg_mat_fake,2));
            keep_idx = sum(emg_mat_fake > repmat(mean(emg_mat_fake)+3*std(emg_mat_fake),size(emg_mat_fake,1),1),2)>=0;
            emg_mat_fake = emg_mat_fake(keep_idx,:);

            subplot(UF_struct.num_emg,1,iEMG)

            plot(emg_window(1:end-1),mean(emg_mat(:,1:end-1)),'b')  
            hold on
            plot(emg_window(1:end-1),mean(emg_mat(:,1:end-1))+1.96*std(emg_mat(:,1:end-1))/sqrt(sum(keep_idx)),'Color',[.7 .7 1])
            plot(emg_window(1:end-1),mean(emg_mat(:,1:end-1))-1.96*std(emg_mat(:,1:end-1))/sqrt(sum(keep_idx)),'Color',[.7 .7 1])
            
            plot(emg_window(1:end-1),mean(emg_mat_fake(:,1:end-1)),'k')  
            plot(emg_window(1:end-1),mean(emg_mat_fake(:,1:end-1))+1.96*std(emg_mat_fake(:,1:end-1))/sqrt(sum(keep_idx)),'Color',[.7 .7 .7])
            plot(emg_window(1:end-1),mean(emg_mat_fake(:,1:end-1))-1.96*std(emg_mat_fake(:,1:end-1))/sqrt(sum(keep_idx)),'Color',[.7 .7 .7])
            

            xlabel('t (s)')
            ylabel(['|' bdf.emg.emgnames{iEMG} '| (mV)'],'interpreter','none')
            xlim([-.03 .03])
        end
        set(gcf,'NextPlot','add');
        gca = axes;
        h = title({UF_struct.UF_file_prefix;...
            ['Elec: ' num2str(electrode) ' (Chan: ' num2str(units(iUnit,1)) ') Unit: ' num2str(units(iUnit,2))];...
            ['n = ' num2str(sum(keep_idx))]},...
            'interpreter','none');
        set(gca,'Visible','off');
        set(h,'Visible','on');
    end
end