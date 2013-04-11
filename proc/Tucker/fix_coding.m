function tt_out=fix_coding(tt,col_num,in_set,out_set)
    %takes in a trial table and changes all the elements in the specified
    %column, from the input set to the output set.
    
    if(length(in_set)~=length(out_set))
        error('S1_analysis:proc:tucker:fix_coding:INCONSISTENTSETS','the input and output datasets must have the same number of entries')
    end
    [r,c]=size(tt);
    if(col_num>c | col_num<1)
        error('S1_analysis:proc:tucker:fix_coding:BADCOLUMNINDEX',strcat('the given column index: ',num2str(col_num),', is outside the bounds of the trial table'))
    end
    tt_out=tt;
    for i=1:length(in_set)
        tt_out((tt(:,col_num)==in_set(i)),col_num)=out_set(i);
    end
end