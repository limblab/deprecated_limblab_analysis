function[map] = ArrayMap(monkey,implant,mapfile,varargin)
% map = ArrayMap(monkey,implant) returns (x,y) mapfile information using
% Mapfile_repo.m
%
% map = ArrayMap(mapfile) returns coordinate information from specified
% mapfile 'mapfile'. 

if nargin == 2
    filename = Mapfile_repo(monkey,implant);
elseif nargin == 1
    filename = mapfile;
else
    warning('Incorrect Input');
    return
end

% mapfile cmp file 
fid=fopen(filename);

% Go to the first line of electrode information
tline = fgetl(fid);
while isempty(tline)
    tline = fgetl(fid);
end
while isnan(str2double(tline(1)))
    tline = fgetl(fid);
end

% Loop through channels and parse grid position
map = zeros(10);
for i = 1:96
    
    col = str2double(tline(1)) + 1;
    row = str2double(tline(3)) + 1;
    
    bank = tline(5);
    bank_elec1 = str2double(tline(7));
    bank_elec2 = str2double(tline(8));
    
    if ~isnan(bank_elec2)
        bank_elec = 10*bank_elec1 + bank_elec2;
    else
        bank_elec = bank_elec1;
    end
    
    if strcmp(bank,'A')
        elecoffset = 0;
    elseif strcmp(bank,'B')
        elecoffset = 32;
    elseif strcmp(bank,'C')
        elecoffset = 64; 
    end
    
    chan_num = elecoffset + bank_elec;
    fprintf('%d %s %d\n',i,bank,bank_elec);
    
%     num_ind = strfind(tline,'elec');
%     elec_num = str2double(tline((num_ind+4):end));

    map(col,row) = chan_num; %Place number on grid
    
    tline = fgetl(fid); %next line
end

% Convert from (row,col) to (x,y)
map = flipud(map');