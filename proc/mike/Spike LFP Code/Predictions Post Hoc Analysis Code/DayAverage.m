function [DayAvgDataX DayAvgDataY DayNames] = DayAverage(DataX, DataY, DayNamesIn, DayNumber)

% This function averages data across columns to find daily averages

%**Input**
    % Data X, Data Y - array of data with time across columns
    % DayNamesIn - Dates/Filenames of each column of DataX/Y
    % DayNumber - vector with day number (either datenum format or decoder age)
    
    
if size(DataX,2) ~= length(DayNumber)
    disp('Number of days does not match number of columns in data')
    return
end

j =1;
FilesCounter = 1;

for i = 1:length(DayNumber)-1

    if DayNumber{i} == DayNumber{i+1}
        
        if i == 1
        DayAvgDataX(:,j) = DataX(:,i) +  DataX(:,i+1);
        DayAvgDataY(:,j) = DataY(:,i) +  DataY(:,i+1);
        
        else
        DayAvgDataX(:,j) = DayAvgDataX(:,j) + DataX(:,i+1);
        DayAvgDataY(:,j) = DayAvgDataY(:,j) + DataY(:,i+1);
        
        end
        
        FilesCounter = FilesCounter + 1;
        DayNames{j,1} = DayNamesIn{i};
        DayNames{j,2} = DayNumber{i};
        
    else
        
        if i ==1 && (DayNumber{i} ~= DayNumber{i+1})
            DayAvgDataX(:,j) = DataX(:,i);
            DayAvgDataY(:,j) = DataY(:,i);
        end
           
        DayAvgDataX(:,j) = DayAvgDataX(:,j)/FilesCounter;
        DayAvgDataY(:,j) = DayAvgDataY(:,j)/FilesCounter;
        DayNames{j,1} = DayNamesIn{i};
        DayNames{j,2} = DayNumber{i};
        
        FilesCounter = 1;
        j = j+1;
        
        DayAvgDataX(:,j) = DataX(:,i+1);
        DayAvgDataY(:,j) = DataY(:,i+1);
    
    end
end

DayAvgDataX(:,j) = DayAvgDataX(:,j)/FilesCounter;
DayAvgDataY(:,j) = DayAvgDataY(:,j)/FilesCounter;
DayNames{j,1} = DayNamesIn{i};
DayNames{j,2} = DayNumber{i};
        
        