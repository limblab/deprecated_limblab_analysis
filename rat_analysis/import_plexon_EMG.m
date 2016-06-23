close all;
home;
clear all;

%directories.rawdata = '/Volumes/fsmresfiles-1/Basic_Sciences/Phys/L_MillerLab/data/rats/AK/' 
directories.rawdata = '/Volumes/L_MillerLab/data/rats/AK/';
directories.figure   = '/Users/amina/Dropbox/motorcortex_database/figures';
directories.database = '/Users/amina/Dropbox/motorcortex_database/';

animal = 'A5';
date = '20160615';
channels = 1; 
channels = channels+48; 

[trialdata_plexon] = load_plexon_emg(animal,date,directories, channels);