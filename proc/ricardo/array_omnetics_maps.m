function array_omnetics_map = array_omnetics_maps(configuration,data_file)

if configuration=='TikiFMAs'
    array_pedestal_map = [1 6;
                         2 4;
                         3 5;
                         4 2;
                         5 1];
end

if strcmp(data_file,'Tiki_2011-03-09_RW_001.nev')
    pedestal_omnetics_map = [1 1;
                            2 2;
                            5 3;
                            6 4];
elseif strcmp(data_file,'Tiki_2011-03-18_BC_001.nev')
    pedestal_omnetics_map = [2 2;
                            5 3;
                            6 4
                            4 5];
elseif strcmp(data_file,'Tiki_2011-03-21_BC_001.nev')
    pedestal_omnetics_map = [1 1;
                            2 2;
                            5 3;
                            6 4];
elseif strcmp(data_file,'Tiki_2011-04-22_RW_001.nev')
    pedestal_omnetics_map = [1 6;
                            2 2;
                            4 5;
                            5 3;
                            6 4];
end

for i=1:length(pedestal_omnetics_map)
    array_omnetics_map(i,1) = array_pedestal_map(array_pedestal_map(:,2)==pedestal_omnetics_map(i,1),1);
    array_omnetics_map(i,2) = pedestal_omnetics_map(i,2);
end
