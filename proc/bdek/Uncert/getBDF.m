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

if(~strcmp(filename(end-3:end),'.nev'))
    error('ERROR: File must be .nev extension');
    return;
end
cdir = pwd;
% CHANGE THIS TO YOUR ANALYSIS FOLDER (i.e. whereever load_paths is
% located)
cd('C:\Users\limblab\Desktop\s1_analysis\');
load_paths;

% CHANGE THE PATH HERE TO WHERE YOUR .nev FILES ARE STORED
bdf = get_cerebus_data(['C:\Users\limblab\Desktop\Mihili_bdf\' filename],3);

% CHANGE THIS PATH TO YOUR ANALYSIS SUBDIR WHERE YOU WANT THE BDF SAVED
% IF DIFFERENT FROM ORIGINAL PATH
cd(cdir);
if sv
    fn =['bdf_' filename(1:end-4) '.mat'];
    save(fn,'bdf');
end

return;