function [counts1,counts2] = getCounts(doFiles,cellClasses,doType,numClasses)

% get counts for each class
%   tied to investigateMemoryCells;

switch lower(doType)
    case 'task'
        % break down by file type
        counts1 = zeros(sum(strcmpi(doFiles(:,4),'co')),numClasses);
        counts2 = zeros(sum(strcmpi(doFiles(:,4),'rt')),numClasses);
        for j = 1:numClasses % loop along the classes
            counts1(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'co'),:));
            counts2(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'rt'),:));
        end
        
    case 'perturbation'
        % break down by perturbation
        counts1 = zeros(sum(strcmpi(doFiles(:,3),'ff')),numClasses);
        counts2 = zeros(sum(strcmpi(doFiles(:,3),'vr')),numClasses);
        for j = 1:numClasses % loop along the classes
            counts1(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'ff'),:));
            counts2(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses(strcmpi(doFiles(:,4),'vr'),:));
        end
        
    case 'none'
        % just give all percentages
        counts1 = zeros(size(doFiles,1),numClasses);
        for j = 1:numClasses % loop along the classes
            counts1(:,j) = cellfun(@(x) 100*sum(x==j)/length(x==j),cellClasses);
            % counts1(:,j) = cellfun(@(x) sum(x==j),cellClasses);
        end
end

end