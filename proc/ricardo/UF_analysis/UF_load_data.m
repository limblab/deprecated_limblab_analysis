function [bdf,rw_bdf,UF_struct] = UF_load_data(file_details,reload_data)

if reload_data        
    % Experimental!        (but then again, what isn't?)
    NEVNSx = concatenate_NEVs(file_details.datapath,file_details.UF_file_prefix);
    NEVNSx.NEV = artifact_removal(NEVNSx.NEV,5,0.001,1);
    bdf = get_nev_mat_data(NEVNSx,'rothandle',file_details.rot_handle,3);
    clear NEVNSx

    if ~isempty(file_details.RW_file_prefix)
        NEVNSx_RW = concatenate_NEVs(file_details.datapath,file_details.RW_file_prefix);
        NEVNSx_RW.NEV = artifact_removal(NEVNSx_RW.NEV,5,0.001,1);
        rw_bdf = get_nev_mat_data(NEVNSx_RW,file_details.rot_handle,3);
        clear NEVNSx_RW
        UF_struct.PDs = PD_table(rw_bdf,0);
    else
        rw_bdf = [];
        UF_struct.PDs = [];
    end
    
    dummy = 0;
    UF_struct = UF_create_struct(bdf,file_details);
    save([file_details.datapath file_details.UF_file_prefix '-bdf'],'dummy','bdf','rw_bdf','UF_struct','-v7.3');    
else
    if ~exist('bdf','var') || ~exist('rw_bdf','var') || ~exist('UF_struct','var')
        load([file_details.datapath file_details.UF_file_prefix '-bdf'],'bdf','rw_bdf','UF_struct');
    end
end      