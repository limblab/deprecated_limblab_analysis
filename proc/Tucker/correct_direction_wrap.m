function tt=correct_direction_wrap(tt)
    for i=1:length(tt(:,1))
        if tt(i,3)>=360
            tt(i,3)=tt(i,3)-360;
        end
        if tt(i,3)<0
            tt(i,3)=tt(i,3)+360;
        end
    end
end