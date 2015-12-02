function [figure_list,data_struct]=export_for_katsaggelos(folderpath,input_data)
    figure_list=[];
    data_struct=[];
    
        optionstruct.compute_pos_pds=0;
        optionstruct.compute_vel_pds=0;
        optionstruct.compute_acc_pds=0;
        optionstruct.compute_force_pds=0;
        optionstruct.compute_dfdt_pds=0;
        optionstruct.compute_dfdtdt_pds=0;
        optionstruct.data_offset=0;%negative shift shifts the kinetic data later to match neural data caused at the latency specified by the offset
    
    load([folderpath,filesep,input_data.filename])
    
    for i=1:length(stable_session)
        opts.do_firing_rate=1;
        opts.do_trial_table=0;
        stable_session{i}.bdf=postprocess_bdf(stable_session{i}.bdf,opts);
        which_units=1:length(stable_session{i}.bdf.units);
        behaviors = parse_for_tuning(stable_session{i}.bdf,'continuous','opts',optionstruct,'units',which_units);
        
        data_struct.session_data(i).meta=stable_session{i}.bdf.meta;
        data_struct.session_data(i).data=dataset({behaviors.armdata(1).data(),'position'},{behaviors.armdata(2).data,'velocity'},{behaviors.armdata(4).data,'force'},{behaviors.FR,'spikes'});
        data_struct.session_data(i).raw.units=stable_session{i}.bdf.units;
        data_struct.session_data(i).raw.pos=stable_session{i}.bdf.pos;
        data_struct.session_data(i).raw.vel=stable_session{i}.bdf.vel;
        data_struct.session_data(i).raw.force=stable_session{i}.bdf.force;
        
    end
    
end