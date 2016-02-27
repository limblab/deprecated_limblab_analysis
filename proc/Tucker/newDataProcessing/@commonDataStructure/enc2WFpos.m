function enc2WFpos(cds)
%takes a timeseries of encoder data and converts it into a position signal
%assuming the hardware was configured as in the WF setup. returns a table
%with the base pos table, and a list of windows where data was missing. pos
%is a table with 3 columns: t,x,y. skips is a 2 column vector where the
%first column is the start of a window where there were missing points, and
%the second column is 
    
    pos = array2table(enc,'VariableNames',{'t','x','y'});
    %configure labels on pos
    pos.Properties.VariableUnits={'s','cm','cm'};
    pos.Properties.VariableDescriptions={'time','x position in room coordinates. ','y position in room coordinates',};
    pos.Properties.Description='Cursor position-scaled wrist torque';
    if isempty(cds.pos)
        set(cds,'pos',pos)
    else
        cds.mergeTable('pos',pos)
    end
    cds.addOperation(mfilename('fullpath'));
end