function [DateNames FileList] = CalcDecoderAge(FileList, DecoderStartDate)

% Input

% FileList - list of files to calculate the decoder age on
% DecoderStartDate - date of the data that the decoder was trained on

% Output

% DateNames - just gives the date extracted from the filename
% FieList - list of files with decoder age in the second column

%decoder age

j = 1;
q=1;

for i = 1: size(FileList,1)
    
    [s, tokens] = regexp(FileList{i,1}, '[0-9]{1}','match','split');
    
    DateNames{i} = [s{1},s{2},'-',s{3},s{4},'-',s{5},s{6},s{7},s{8}];
    
%     if strcmp(s(11),'1')
%         First_File_Index(j) = i;
%         Mini_LFP1_FirstFileNames{j} = Mini_LFP1filenames{i,1};
%         j = j+1;
%     else
%         Last_File_Index(q) = i;
%         q = q+1;
%     end
    
    FileList{i,2} = datenum(DateNames{i}) - datenum(DecoderStartDate);
    %Mini_LFP1filenames{i,2} = datenum(Mini_DateNames{i}) - datenum('09-01-2011');
    
    clear s
end

