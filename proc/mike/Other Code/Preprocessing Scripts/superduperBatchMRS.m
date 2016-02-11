DateNums = [735787 735790]

for i = 1:length(DateNums)
    for j = 1%:5
        DateString = datestr(DateNums(i)+(j-1),'mm-dd-yy')
        superBatch('Mini',DateString)
    end
    
end