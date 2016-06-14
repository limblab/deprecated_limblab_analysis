close all;
home;
clear all;

directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';

animal = 'A5';
date = '20160608';


[trialdata_plexon] = load_plexon_emg(animal,date,directories);