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
while isnan(str2double(tline(1)));
    tline = fgetl(fid);
end

% Loop through channels and parse grid position
map = zeros(10);
for i = 1:96
    
    col = str2double(tline(1)) + 1;
    row = str2double(tline(3)) + 1;
    
    space_locations = find(isspace(tline));
    bank_ind = (space_locations(2)+1):(space_locations(3)-1);
    pin_ind = (space_locations(3)+1):(space_locations(4)-1);
    
    elec_num = (hex2dec(tline(bank_ind))-10)*32 + eval(tline(pin_ind));
    
    map(col,row) = elec_num; %Place number on grid
    
    tline = fgetl(fid); %next line
end

% Convert from (row,col) to (x,y)
map = flipud(map');