function [bdf,rw_bdf,AT_struct] = AT_load_data(file_details,reload_data)

if reload_data        

    bdf = get_nev_mat_data([file_details.datapath file_details.AT_file_prefix],'rothandle',file_details.rot_handle,3);
    clear NEVNSx

    if ~isempty(file_details.RW_file_prefix)
        NEVNSx_RW = cerebus2NEVNSx(file_details.datapath,file_details.RW_file_prefix);
        rw_bdf = get_nev_mat_data(NEVNSx_RW,'rothandle',file_details.rot_handle,3);
        clear NEVNSx_RW
        PDs = PD_table(rw_bdf,0);
    else
        rw_bdf = [];
        PDs = [];
    end
    
    dummy = 0;
    AT_struct = AT_create_struct(bdf,file_details);
%     AT_struct = [];
    if ~isempty(PDs)
        AT_struct.PDs = PDs;
    end
    save([file_details.datapath file_details.AT_file_prefix '-bdf'],'dummy','bdf','rw_bdf','AT_struct','-v7.3');    
else
    if ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('AT_struct','var')
        load([file_details.datapath file_details.AT_file_prefix '-bdf'],'bdf','rw_bdf','AT_struct');
    end
end      