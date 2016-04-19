function lengths = getArrayDistances(arrayMap)
    sep = 400; %distance in microns
    positions = zeros(96, 2);
    lengths = zeros(96, 96);
    for i = 1:10
        for j = 1:10
            if arrayMap(i,j) ~= 0
                positions(arrayMap(i,j),:) = sep.*[i, j];
            end
        end
    end
    for i = 1:96
        for j = 1:96
            lengths(i, j) = norm(positions(i,:) - positions(j,:));
        end
    end
end