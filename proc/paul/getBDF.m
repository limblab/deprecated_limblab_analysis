function bdf = getBDF(varargin)
% GETBDF Fetches and saves a BDF struct from a .nev file
%   BDF = GETBDF(FILENAME) returns a BDF populated by the
%   string FILENAME.  Saves it locally as a .mat file if sv~=0 or false.
% 

if nargin == 1
        filename   = varargin{1};
        sv = 0;
elseif nargin == 2
        filename   = varargin{1};
        sv = varargin{2};
else
    error('ERROR: Incorrect Number of Arguments');
    return;
end

cdir = pwd;
% CHANGE THIS TO YOUR ANALYSIS FOLDER (i.e. whereever load_paths is
% located)
cd('C:\Users\limblab\Desktop\s1_analysis\');
load_paths;

% CHANGE THE PATH HERE TO WHERE YOUR .nev FILES ARE STORED
if(strcmp(filename(end-3:end),'.nev'))
    bdf = get_cerebus_data(['C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\UN1D\' filename],3);
elseif(strcmp(filename(end-3:end),'.plx'))
    bdf =  get_plexon_data(['C:\Users\limblab\Documents\MATLAB\Paul_Uncertainty\UN1D\' filename],3);
else
    error('ERROR: File must be .nev or .plx extension');
    return;
end
        
% CHANGE THIS PATH TO YOUR ANALYSIS SUBDIR WHERE YOU WANT THE BDF SAVED
% IF DIFFERENT FROM ORIGINAL PATH
cd(cdir);
if sv
    fn =['bdf/bdf_' filename(1:end-4) '.mat'];
    save(fn,'bdf');
end

return;