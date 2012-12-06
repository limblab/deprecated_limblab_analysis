%decoder age

j = 1;
q=1;

for i = 1: size(Chewie_LFP1filenames,1)
    
    [s, tokens] = regexp(Chewie_LFP1filenames{i}, '[0-9]{1}','match','split')
    
    Chewie_DateNames{i} = [s{1},s{2},'-',s{3},s{4},'-',s{5},s{6},s{7},s{8}];
    
    if strcmp(s(11),'1')
        First_File_Index(j) = i;
        j = j+1;
    else
        Last_File_Index(q) = i;
        q = q+1;
    end
    
    %Chewie_LFP1filenames{2,i} = datenum(Chewie_DateNames{i}) - datenum('08-24-2011');
    Chewie_LFP1filenames{i,2} = datenum(Chewie_DateNames{i}) - datenum('09-01-2011');
    
    clear s
end