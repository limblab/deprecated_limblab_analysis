function [BC_sorted_filelist BC_non_sorted_filelist] = BC_sorted_files(filelist)

datapaths = {filelist(1).datapath};

for iFile = 2:length(filelist)
    datapath_in_list = 0;
    for iPaths = 1:length(datapaths)
        if strcmp(filelist(iFile).datapath,datapaths{iPaths})
            datapath_in_list = datapath_in_list+1;
        end
    end
    if ~datapath_in_list
        datapaths = {datapaths; {filelist(iFile).datapath}};
    end
end

BC_raw_files = [];
BC_sorted_files = [];
for iPaths = 1:length(datapaths)
    BC_raw_files = [BC_raw_files; dir([cell2mat(datapaths{iPaths}) 'Raw\*_BC_*.nev'])];
    BC_sorted_files = [BC_sorted_files; dir([cell2mat(datapaths{iPaths}) 'Sorted\*_BC_*.nev'])];
end

for iRaw = 1:length(BC_raw_files)
    BC_file = BC_raw_files(iRaw).name;
    filelist_idx = find(strcmp({filelist.name},BC_file(1:end-4)));
    BC_raw_list_temp(iRaw) = filelist(filelist_idx); %#ok<AGROW>
end

% BC_raw_files = filelist;

BC_non_sorted_filelist = BC_raw_list_temp;
BC_sorted_filelist = struct(filelist);
BC_sorted_filelist(1:end) = [];

for iSorted = 1:length(BC_sorted_files)
    raw_file{iSorted} = BC_sorted_files(iSorted).name(1:findstr(BC_sorted_files(iSorted).name,'-s')-1);    
    BC_non_sorted_filelist(find(strcmp({BC_non_sorted_filelist.name},raw_file{iSorted}))) = [];
    BC_sorted_filelist(iSorted) = filelist(strcmp({filelist.name},raw_file{iSorted}));
    BC_sorted_filelist(iSorted).name = BC_sorted_files(iSorted).name(1:end-4);
end