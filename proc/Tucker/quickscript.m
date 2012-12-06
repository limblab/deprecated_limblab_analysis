%quickscript

%set the mount drive to scan and convert
folderpath='C:\Users\limblab\Desktop\11142012_end\';
matchstring='11142012';
autoconvert_nev_to_bdf(folderpath,matchstring)
bdf=concatenate_bdfs_from_folder('Z:\Kramer_10I1\BumpDirection\Data Raw\Post-implant\','11092012');
make_tdf




