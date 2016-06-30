function allmarkers = read_vicon_filelist(DATADESC,OPTS)
list = DATADESC.LIST;
root = DATADESC.FNAME_ROOT;
path = OPTS.VICONDIRECTORY;

nlist = length(list);  % there's likely to be a single list for this data
for ii = 1:nlist
    nfiles = length(list{ii});
    disp(ii)
    for jj = 1:nfiles
        fnum = list{ii}(jj);
        fname = [root num2str(fnum) '.csv'];
        fullfname = [path '\' fname];
        markers = read_vicon_file(fullfname,OPTS,DATADESC);  % reads in the vicon CSV file
        nmarkers = length(markers);
        allmarkers{ii,jj} = markers;
    end
end
