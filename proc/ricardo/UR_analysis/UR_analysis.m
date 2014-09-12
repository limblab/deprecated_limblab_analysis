function [fig_handles,data_struct] = UR_analysis(target_folder,params)    
    params.fig_handles = [];
    params.elec_map = read_cmp(params.cmp_file); 
    params.target_folder = target_folder;
    if ~exist([target_folder '\Output_Data\bdf.mat'],'file')
        params.reprocess_data = 1;
    end
    
    if params.reprocess_data        
        data_struct.bdf = get_nev_mat_data([target_folder '\' params.UR_file_prefix],'rothandle',params.rot_handle,3);       
        data_struct.bdf = artifact_removal(data_struct.bdf,10,0.001,1);
        data_struct.UR = UR_create_struct(data_struct.bdf,params);        
    else        
        disp('Data already processed, loading from disk.');
        load([target_folder '\Output_Data\bdf.mat']);
        data_struct.bdf = bdf;
        load([target_folder '\Output_Data\UR.mat']);      
        if exist('UR','var')
            data_struct.UR = UR;
        end
    end  
    if params.plot_behavior
        params = UR_plot_behavior(data_struct,params);
    end
    if params.plot_units
        params = UR_plot_firing_rates(data_struct,params);
    end    
    if params.plot_emg
        params = UR_plot_emg(data_struct,params);
    end
    if params.plot_raw_emg
        params = UR_plot_raw_emg(data_struct,params);
    end
    if params.decode_arm
        [params,data_struct] = UR_decode_arm(data_struct,params);
    end
    if params.make_movie
        params = UR_make_movie(data_struct,params);
    end
    data_struct.params = params;
    fig_handles = params.fig_handles;
end