function [ neighbors ] = getNearestNeighbors( electrode, map )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    xSize = 10;
    ySize = 10;
    [row, col] = find(map == electrode);
    neighbors = [];
    if (col > 1 && col < 10) && (row > 1 && row < 10)
        neighbors = [map(row-1, col) map(row+1,col) map(row, col-1) map(row, col+1)];
    elseif row == 1
        if col == 2
            neighbors = [map(row+1,col) map(row, col+1)];
        elseif col == 9
            neighbors = [map(row+1,col) map(row, col-1)];
        else
            neighbors = [map(row+1,col) map(row, col-1) map(row, col+1)];
        end
    elseif row ==10
        if col == 2
            neighbors = [map(row-1, col) map(row, col+1)];
        elseif col == 9
            neighbors = [map(row-1, col)  map(row, col-1) ];
        else
            neighbors = [map(row-1, col)  map(row, col-1) map(row, col+1)];
        end
    elseif col == 1
        if row ==2
            neighbors = [map(row+1, col) map(row, col+1)];
        elseif row == 9
            neighbors = [map(row-1, col) map(row, col+1)];
        else
            neighbors = [map(row-1, col) map(row+1,col) map(row, col+1)];
        end 
    elseif col == 10
        if row ==2
            neighbors = [map(row+1,col) map(row, col-1)];
        elseif row == 9
            neighbors = [map(row-1, col) map(row, col-1)];
        else
            neighbors = [map(row-1, col) map(row+1,col) map(row, col-1)];
        end
    end
end

