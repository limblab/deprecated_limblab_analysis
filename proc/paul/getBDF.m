function out_struct = getBDF(filename)

% GETBDF Grabs and saves a BDF struct from a .nev file
%   OUT_STRUCT = GETBDF(FILENAME) returns a BDF populated by the
%   string FILENAME.  Saves it locally as a .mat file.
% 

if(~strcmp(filename(end-3:end),'.nev'))
    error('ERROR: File must be .nev extension');
    return;
end

% CHANGE THIS TO YOUR LOCAL ANALYSIS FOLDER (i.e. where load_paths is
% located)
cd C:\Users\limblab\Desktop\s1_analysis\;
load_paths;

% CHANGE THE PATH HERE TO WHERE YOUR FILES ARE LOCALLY STORED
bdf = get_cerebus_data(['C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\jaco_dat\' filename],3);

% CHANGE THIS PATH TO YOUR LOCAL ANALYSIS SUBDIR
cd C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\;
fn =[filename(1:end-4) '.mat'];
save(fn,'bdf');
out_struct = bdf;
return;