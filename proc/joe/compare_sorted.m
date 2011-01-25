%This function was written by Joe Lancaster on 1/24/2011
%This function will take in a file path and two file names describing two 
%outputs of the get_plexon_data function. It will then compare the two 
%files and count the number of mismatches between the two. 

function mismatched = compare_sorted(path, name1, name2)

units{1} = load([path name1]);
units{2} = load([path name2]);

channels{1} = sortData(units{1});
channels{2} = sortData(units{2});

channels{1} = combineUnits(channels{1});
channels{2} = combineUnits(channels{2});

binary = compareChannels(channels{1}, channels{2});

mismatched = countMismatches(binary);

%Reorganizes the data in bdf.units into a 1X96 structure. Each cell of the
%structure represents a channel and contains an integer, id, that
%represents the number of the channel and a cell array, ts, that contains
%the timestamp arrays for each of the sorted units in the channel. 
    function sorted = sortData(input)
        sorted = cell(1, 96);
        chan = 1;
        id = input.bdf.units(1).id;
        loop = 1;
        while ~isempty(id)
            while chan ~= id(1)
                if isempty(sorted{chan})
                    sorted{chan} = [];
                end;
                chan = chan+1;
            end;
            sorted{chan}{id(2)} = input.bdf.units(loop).ts;
            loop = loop+1;
            id = input.bdf.units(loop).id;
        end;
    end

%Combines the .ts data from all units in each channel into a single vector
%and multiplies all the timestamp values by 10^5 to eliminate decimals.
    function combined = combineUnits(input)
        combined = cell(1,96);
        for i = 1:96
            if isempty(input{i})
                combined{i} = [];
                continue;
            end;
            units = size(input{i});
            datapoints = [];
            for j = 1:units
                datapoints = vertcat(datapoints, input{i}{j}); 
            end;
            combined{i} = (sort(datapoints)).*10^5;
        end;
    end


%Compares two attempts at sorting the same channel, producing a vector of
%ones and zeros in which the zeros represent spikes that were sorted by
%both users and ones represent spikes that were sorted by only one of the
%users. 
    function compared = compareChannels(unus, duo)
    compared = cell(1,96);
    for i = 1:96
        if isempty(unus{i})
            if isempty(duo{i})
                compared{i} = [];
            else
                num = size(duo{i});
                compared{i} = ones(num(1),1);
            end;
        else
            if isempty(duo{i})
                num = size(unus{i});
                compared{i} = ones(num(1),1);
            else
                compared{i} = compareColumns(unus{i}, duo{i});
            end;
        end;
    end;
    end
    
%Compares two columns of timestamps and outputs a vector containing zeros
%for every timestamp that is the same between the two columns and one for
%every timestamp that appears in only one column.
    function output = compareColumns(un, deux)
        sizes = [size(un); size(deux)];
        output = zeros((sizes(3)+sizes(4)),1);
        u = 1;
        d = 1;
        loop = 1;
        while u < (sizes(1)+1) && d < (sizes(2)+1)
            if abs(un(u)-deux(d)) < 1
                u = u+1;
                d = d+1;
                continue;
            elseif un(u) < deux(d)
                output(loop) = 1;
                u = u+1;
                loop = loop+1;
            elseif un(u) > deux(d)
                output(loop) = 1;
                d = d+1;
                loop = loop+1;
            end;
        end;
        if abs(u-d) < 1
            return;
        elseif u > sizes(1)
            for n = 1:(sizes(2)-d)
                output(loop) = 1;
                loop = loop+1;
            end;
        elseif d > sizes(2)
            for n = 1:(sizes(1)-u)
                output(loop) = 1;
                loop = loop+1;
            end;
        end;
    end
    
%Takes in a cell array containing vectors of ones and zeros and counts the
%number of ones in each vector, returning the total number of ones in the
%entire cell array.
    function mismatches = countMismatches(binary)
        mismatches = zeros(1,96);
        for i = 1:96
            if isempty(binary{i})
                mismatches(i) = 0;
                continue;
            end;
            count = 0;
            for j = 1:size(binary{i})
                current = binary{i};
                if current(j) == 1
                   count = count+1;
                end;
            end;
            mismatches(i) = count;
        end;
    end
end
