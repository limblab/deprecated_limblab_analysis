function UF_plot_STEMG(UF_struct,bdf)
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
        figure;
        for iEMG = 1:UF_struct.num_emg
            emg_mat = zeros(length(ts),length(emg_window));
            t_mat = repmat(emg_window,length(ts),1);
            idx_mat = round(repmat(idx_vec,length(it),1) + repmat(it',1,size(idx_vec,2)));
            emg_mat(idx_mat>0 & idx_mat<length(bdf.emg.data)) =...
                UF_struct.emg_filtered(idx_mat(idx_mat>0 & idx_mat<length(bdf.emg.data)),iEMG);
            emg_mat = abs(emg_mat);
            keep_idx = sum(emg_mat > repmat(mean(emg_mat)+3*std(emg_mat),size(emg_mat,1),1),2)==0;
            emg_mat = emg_mat(keep_idx,:);

            subplot(UF_struct.num_emg,1,iEMG)

            plot(emg_window,mean(emg_mat))  
            hold on
            plot(emg_window,mean(emg_mat)+1.96*std(emg_mat)/sqrt(sum(keep_idx)),'r')
            plot(emg_window,mean(emg_mat)-1.96*std(emg_mat)/sqrt(sum(keep_idx)),'r')

            xlabel('t (s)')
            ylabel(['|' bdf.emg.emgnames{iEMG} '| (mV)'],'interpreter','none')
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