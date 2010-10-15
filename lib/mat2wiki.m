function mat2wiki(table,headers)

if nargin==1
    headers = cell(size(table,2));
end

if ~iscell(table)
    table = num2cell(table);
end

if length(headers)~=size(table,2)
    error('Number of headers and columns in matrix is different.')
end

disp('Copy text below this line to wiki: ')
disp(' ')
disp('{| class="wikitable"')
disp('|-')
for i=1:length(headers)
    disp(['! ' headers{i}])
end

for i=1:size(table,1)
    disp('|-')
    for j=1:size(table,2)
        if ischar(cell2mat(table(i,j)))
            disp(['| ' cell2mat(table(i,j))])
        else
            disp(['| ' num2str(cell2mat(table(i,j)),4)])
        end
    end
end
disp('|}')