function [tuning,stats,methodData]=get_all_tuning(bdf,fhandle,method,statTest,varargin)
    %computes tuning curves for every unit in a bdf.
    %[tunCurves,stats,methodData]=get_all_tuning(bdf,fhandle,method,statTest,varargin)
    %input : 
    %the bdf to compute all tuning on, 
    %a function handle for a function that returns the data array for the 
    %   call to get_unit_tuning. The function must accept input of the form
    %   fhandle(bdf,unit_num). The function can optionally accept a 3rd 
    %   input which may be a variable or struct to dictate the function's 
    %   operation
    %A cell array defining the method used for computing the tuning. The
    %   first cell must be a string defininf the method type. Additional
    %   cells depend on the method type. See get_unit_tuning for defined
    %   method types and the required additional cells.
    %a cell array defining the stats test to perform on each call to
    %   get_unit_tuning. The first cell must be a string defining the
    %   test type. Additional fields depend on the selected test. See 
    %   get_unit_tuning for defined method types and the required 
    %   additional cells.
    %
    %output:
    %a matrix of tuning curves. Each row contains the tuning curve data for
    %   a single unit, with rows in the same order as bdf.units
    %a cell array of statistical data for each fit. Each cell contains the
    %   statistical data where each cell corresponds to own row of the
    %   tuning curve matrix
    %a cell array of method data from get_unit_tuning, where each cell 
    %   corresponds to a row in the tuning curve matrix
    for i=1:length(bdf.units)
        if ~isempty(varargin)
            data=fhandle(bdf,i,varargin{1});
        else
            data=fhandle(bdf,i);
        end
         [tuning(i,:),stats{i},methodData{i}]=get_unit_tuning(data,method,statTest);
    end
    
    

end