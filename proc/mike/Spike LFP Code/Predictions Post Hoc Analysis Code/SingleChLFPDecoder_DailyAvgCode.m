j =1;
FilesCounter = 1;

for i = 1:length(Chewie_filenames)-1

    if strcmp(Chewie_filenames{i}(1:24),Chewie_filenames{i+1}(1:24))== 1
        
        if i == 1
        r2_X_SingleUnitsSorted_DayAvg(:,j) = r2_X_SingleUnitsSorted(:,i) +  r2_X_SingleUnitsSorted(:,i+1);
        r2_Y_SingleUnitsSorted_DayAvg(:,j) = r2_Y_SingleUnitsSorted(:,i) +  r2_Y_SingleUnitsSorted(:,i+1);
        
        else
        r2_X_SingleUnitsSorted_DayAvg(:,j) = r2_X_SingleUnitsSorted_DayAvg(:,j) + r2_X_SingleUnitsSorted(:,i+1);
        r2_Y_SingleUnitsSorted_DayAvg(:,j) = r2_Y_SingleUnitsSorted_DayAvg(:,j) + r2_Y_SingleUnitsSorted(:,i+1);
        
        end
        
        FilesCounter = FilesCounter + 1;
        Chewie_DayNames{j} = Chewie_filenames{i};
        
    else
        
        if i ==1 && strcmp(Chewie_filenames{i}(1:24),Chewie_filenames{i+1}(1:24))== 0
            r2_X_SingleUnitsSorted_DayAvg(:,j) = r2_X_SingleUnitsSorted(:,i);
            r2_Y_SingleUnitsSorted_DayAvg(:,j) = r2_Y_SingleUnitsSorted(:,i);
        end
           
        r2_X_SingleUnitsSorted_DayAvg(:,j) = r2_X_SingleUnitsSorted_DayAvg(:,j)/FilesCounter;
        r2_Y_SingleUnitsSorted_DayAvg(:,j) = r2_Y_SingleUnitsSorted_DayAvg(:,j)/FilesCounter;
        Chewie_DayNames{j} = Chewie_filenames{i};
        
        FilesCounter = 1;
        j = j+1;
        
        r2_X_SingleUnitsSorted_DayAvg(:,j) = r2_X_SingleUnitsSorted(:,i+1);
        r2_Y_SingleUnitsSorted_DayAvg(:,j) = r2_Y_SingleUnitsSorted(:,i+1);
    
    end
end

r2_X_SingleUnitsSorted_DayAvg(:,j) = r2_X_SingleUnitsSorted_DayAvg(:,j)/FilesCounter;
r2_Y_SingleUnitsSorted_DayAvg(:,j) = r2_Y_SingleUnitsSorted_DayAvg(:,j)/FilesCounter;
Chewie_DayNames{j} = Chewie_filenames{i};
        
        