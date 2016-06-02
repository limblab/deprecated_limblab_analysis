function [data,n] = readcursor(filename)
    %Filename is a log file with an .xls or .xlsx extension. This function
    %will not work if "Plexon recording startup" string does not indicate
    %start of brain control data.
    %data is a cell array with as many numerical array entries as there are
    %corresponding plexon recordings
    %columns of each numerical array contain the following information:
    %1 - x position
    %2 - y position
    %3 - x velocity
    %4 - y velocity
    %5 - state probability (posture/movement)
    %n is the number of corresponding plexon recordings
    [num,text,raw] = xlsread(filename); 
    x = strmatch('Plexon recording startup',text);  %Indices of beginnings of cursor data recording in raw
    n = size(x,1);  %number of recordings
    numStart=[];    %numStart indicates the number of rows in raw before the first numerical entry occurs
    for i = 1:size(raw,1),
        for j = 1:size(raw,2),
            if isnumeric(raw{i,j})==1&&isnan(raw{i,j})==0,
                numStart = i-1;
                break
            end
        end
        if numStart == i-1,
            break
        end
    end
    data = cell(1,n);
    for i = 1:n,    %loop to store cursor data
        if i <n,
            data{1,i} = num(x(i)-numStart+1:x(i+1)-numStart-1,[3:6 8]); %for all but the last recording, stores data from first line after 'plexon recording startup' string until the line before the next one 
        else
            data{1,i} = num(x(i)-numStart+1:size(num,1),[3:6 8]);   %for last entry, stores data until end of log
        end
    end
end