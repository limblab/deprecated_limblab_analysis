function [fig_handles,data_struct] = DCO_analysis(target_folder,params)    
    params.fig_handles = [];
    params.elec_map = read_cmp(params.cmp_file); 
    params.target_folder = target_folder;
    if ~exist([target_folder '\Output_Data\bdf.mat'],'file')
        params.reprocess_data = 1;
    end
    
    if params.reprocess_data        
        data_struct.bdf = get_nev_mat_data([target_folder '\' params.DCO_file_prefix],'rothandle',params.rot_handle,3);       
        data_struct.bdf = artifact_removal(data_struct.bdf,10,0.001,1);
        data_struct.DCO = DCO_create_struct(data_struct.bdf,params);        
    else        
        disp('Data already processed, loading from disk.');
        load([target_folder '\Output_Data\bdf.mat']);
        data_struct.bdf = bdf;
%         data_struct.bdf = temp.temp;
        load([target_folder '\Output_Data\DCO.mat']);      
        if exist('DCO','var')
            data_struct.DCO = DCO;
        end
%         data_struct.DCO = temp.temp;
    end  
    if params.plot_behavior
        params = DCO_plot_behavior(data_struct,params);
    end
    if params.plot_units
        params = DCO_plot_firing_rates(data_struct,params);
    end    
    if params.plot_emg
        params = DCO_plot_emg(data_struct,params);
    end
    if params.plot_raw_emg
        params = DCO_plot_raw_emg(data_struct,params);
    end
    if params.decode_arm
        [params,data_struct] = DCO_decode_arm(data_struct,params);
    end
    if params.build_decoders
        params = DCO_build_decoders(data_struct,params);
    end
    if params.make_movie
        params = DCO_make_movie(data_struct,params);
    end
    data_struct.params = params;
    fig_handles = params.fig_handles;
    add_filename_to_figures(fig_handles,data_struct.bdf.meta.filename)        
end