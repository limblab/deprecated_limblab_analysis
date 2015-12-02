function [pos]=enc2WFpos(cds)
%takes a timeseries of encoder data and converts it into a position signal
%assuming the hardware was configured as in the WF setup. returns a table
%with the base pos table, and a list of windows where data was missing. pos
%is a table with 3 columns: t,x,y. skips is a 2 column vector where the
%first column is the start of a window where there were missing points, and
%the second column is 
    
    
    [enc]=decimateData([cds.enc.t cds.enc.th1/1000 cds.enc.th2/1000],cds.kinFilterConfig);  
    pos = array2table(enc,'VariableNames',{'t','x','y'});
end