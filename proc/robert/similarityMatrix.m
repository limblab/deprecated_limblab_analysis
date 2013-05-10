function newX=similarityMatrix(x)

% syntax newX=similarityMatrix(x)
%
%       INPUTS:
%                   x   - if this is a PB or x matrix with feature
%                         number X time, then the time axis should 
%                         be represented in the rows.
%
%       OUTPUTS:
%                   newX - x, with the rows sorted by descending
%                          similarity.


combos=nchoose2(1:size(x,2));
for n=1:size(combos,1)
    distances(n)=pdist(x(:,combos(n,:))');
end, clear n
[~,sortInd]=sort(distances,'descend');
combosDescend=combos(sortInd,:);
comboBank=combosDescend(1,:)';
newX=x(:,combosDescend(1,:));

while size(newX,2) < size(x,2)
    % first option: if 1 of the elements of the current row is also in the
    % next row, keep the next row right where it is.
    if ~isempty(intersect(combosDescend(2,:),combosDescend(1,:)))
        nextToInclude=setdiff(combosDescend(2,:),combosDescend(1,:));
    else
        % option 2: if one of the elements matches an earlier element
        % (but not if both match, see the setdiff), set the other one 
        % to be the next column of newX
        if ~isempty(intersect(combosDescend(2,:),comboBank))
            nextToInclude=setdiff(combosDescend(2,:),comboBank);
        end
    end
    % if the new row of combosDescend is neither close to the old row
    % (option 1 fail) or close to something above it (option 2 fail), 
    % then the following if will fail, and we'll just skip this entry. 
    % if the new row of combosDescend has BOTH elements represented in 
    % comboBank, then nextToInclude will be empty because of the setdiff,
    % and thus fail this if, and we'll skip.
    if length(unique([comboBank; nextToInclude]))==(length(comboBank)+1)
        comboBank=[comboBank; nextToInclude];
        newX=[newX, x(:,nextToInclude)];
    end
    % regardless of what else happens, we must progress forward
    combosDescend(1,:)=[];
end
