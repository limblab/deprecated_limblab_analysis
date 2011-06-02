function A = convertMAP2MAT(fileName)
% A = [col row ch label]
% col and row are 0-based coordinates of electrode location on array
% ch is the electrode channel, based on bank
% e.g. pin 6 of bank B = ch 38, pin 1 of bank C = ch 65, pin 8 of bank A = ch 8, etc.
% label is the electrode number shown in Cerebus with the default mapfile
% e.g. elec10, elec 20 are elec30 are all located
% in the first three rows of the 10th column of the array

% fileName e.g. 'C:\Monkey\Jaco\1025-0397.cmp';

fid=fopen(fileName);
%skip 3 lines:
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
line = 0;

A = -1*ones(96,4);

delim = char(9); %delimitation character

while ~feof(fid)
    line=line+1;
    tline = fgetl(fid);
    tabs = strfind(tline,delim);
    
    A(line,1) = str2double(tline(1:tabs(1)-1));
    A(line,2) = str2double(tline(tabs(1)+1:tabs(2)-1));
    bank = 32*(double(tline(tabs(2)+1:tabs(3)-1))-double('A'));
    A(line,3) = str2double(tline(tabs(3)+1:tabs(4)-1))+bank;
    A(line,4) = str2double(strrep(tline(tabs(4)+1:end),'elec',''));

end

fclose(fid);
