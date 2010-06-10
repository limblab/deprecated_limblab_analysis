%% Create bdf and save in .mat file

function var = create_bdf(dataFile)

bdf = get_plexon_data(dataFile);
dataFile = dataFile(1:strfind(dataFile,'.plx')-1);
save(dataFile,'bdf');