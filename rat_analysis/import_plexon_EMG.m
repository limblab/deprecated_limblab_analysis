close all;
home;
clear all;

%directories.rawdata = '/Volumes/fsmresfiles-1/Basic_Sciences/Phys/L_MillerLab/data/rats/AK/' 
data_dir = '/Users/mariajantz/Documents/Work/data/plexon/';
%directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
%directories.database = '/Users/amina/Dropbox/motorcortex_database/';

filename = 'isometric_pulse_test.plx'; 
channel = 16; 

cd(data_dir);

[adfreq, n, ts, fn, ad] = plx_ad_v(filename, channel);

plot(ad, '.-')
