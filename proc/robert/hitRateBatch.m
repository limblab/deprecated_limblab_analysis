%%
PathName = uigetdir('/Volues/data/','select folder with data files');
cd(PathName)
Files=dir(PathName);
Files(1:2)=[];
FileNames={Files.name};
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'Spike_LFP.*(?<!poly.*)\.mat'))==0);

for ind=1:length(MATfiles)
    MATfiles{ind}
    load(MATfiles{ind},'out_struct')
    HR(ind)=hitRate(out_struct);
    clear out_struct
end

clear FileNames Files ans ind