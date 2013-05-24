%decoder age

j = 1;
q=1;

for i = 1: size(Mini_LFP_BC_Decoder1_filenames,1)
    
    [s, tokens] = regexp(Mini_LFP_BC_Decoder1_filenames{i,2}, '[0-9]{1}','match','split')
    
    Mini_DateNames{i} = [s{1},s{2},'-',s{3},s{4},'-',s{5},s{6},s{7},s{8}];
    
%     if strcmp(s(11),'1')
%         First_File_Index(j) = i;
%         Mini_LFP1_FirstFileNames{j} = Mini_LFP1filenames{i,1};
%         j = j+1;
%     else
%         Last_File_Index(q) = i;
%         q = q+1;
%     end
    
    Mini_LFP_BC_Decoder1_filenames{i,3} = datenum(Mini_DateNames{i}) - datenum('01-25-2012');
    %Chewie_LFP1filenames{i,2} = datenum(Mini_DateNames{i}) - datenum('09-01-2011');
    
    clear s
end

