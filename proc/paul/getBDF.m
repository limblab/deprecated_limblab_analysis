function bdf = getBDF(filename, labnumber)
% GETBDF Fetches and saves a BDF struct from a .nev file
%   BDF = GETBDF(FILENAME,LABNUMBER) returns a BDF populated by the
%   string FILENAME for the appropriate LABNUMBER.
% 

cdir = pwd;
% CHANGE THIS TO YOUR ANALYSIS FOLDER (i.e. whereever load_paths is
% located)
cd('C:\Users\limblab\Desktop\s1_analysis\');
load_paths;

% CHANGE THE PATH HERE TO WHERE YOUR .nev FILES ARE STORED
if(strcmp(filename(end-3:end),'.nev'))
    bdf = get_cerebus_data(['C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\MONKEYDAT\' filename],labnumber);
elseif(strcmp(filename(end-3:end),'.plx'))
    bdf =  get_plexon_data(['C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\MONKEYDAT\' filename],labnumber);
else
    error('ERROR: File must be .nev or .plx extension');
end
        
% CHANGE THIS PATH TO YOUR ANALYSIS SUBDIR WHERE YOU WANT THE BDF SAVED
% IF DIFFERENT FROM ORIGINAL PATH
cd(cdir);

return;