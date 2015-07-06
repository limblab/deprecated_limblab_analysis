function out=apply_to_slices(func, data)
    %takes a function handle and a 3d array, and applies the function to
    %each slice of the 3d array:
    %out(1,:,:)=fhandle(data(1,:,:))
    %out(2,:,:)=fhandle(data(2,:,:))
    %etc
    
        applyToGivenRow = @(func, matrix) @(row) func(matrix(row,:,:));
        newApplyToRows = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1), 'UniformOutput', false)';
        takeAll = @(x) reshape([x{:}], size(x{1},2), size(x,1))';
        genericApplyToRows = @(func, matrix) takeAll(newApplyToRows(func, matrix));
        
        out=genericApplyToRows(func, data);

% applyToGivenRow = @(func, matrix) @(row) func(matrix(row,:, :));
% applyToRows = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1))';
% out=applyToRows(func, data);
    
end