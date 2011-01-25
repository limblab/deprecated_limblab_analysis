%This function will take in two file paths describing two outputs of the
%get_plexon_data function. It will then compare the two files and generate
%a correlation coefficient to describe how similarly the two were sorted. 

function correlationCoeff = sorting_comparison(path, name1, name2)

units1 = load([path name1]);

units2 = load([path name2]);

chans1 = sortData(units1.bdf.units);
chans2 = sortData(units2.bdf.units);




%Reorganizes the data in bdf.units into a 1X96 structure. Each cell of the
%structure represents a channel and contains an integer, id, that
%represents the number of the channel and a cell array, ts, that contains
%the timestamp arrays for each of the sorted units in the channel. 
    function sorted = sortData(input)
        sorted = cell(1, 96);
        chan = 1;
        id = input(1).id;
        loop = 1;
        while ~isempty(id)
            while chan ~= id(1)
                if isempty(sorted{chan})
                    sorted{chan} = [];
                end;
                chan = chan+1;
            end;
            sorted{chan}{id(2)} = input(loop).ts;
            loop = loop+1;
            id = input(loop).id;
        end;
    end

%

% %calculates the correlation coefficient between the two files for each of
% %the units
%     function output = tsToCorr(uno, dos)
%         output = cell(1,96);
%         for i = 1:96
%             if isempty(uno{i})
%                 if isempty(dos{i})
%                     output{i} = nan;
%                     continue;
%                 else
%                     output{i} = zeros(size(dos{i}));
%                 end;
%             else
%                 if isempty(dos{i})
%                     output{i} = zeros(size(uno{i}));
%                 else
%                     output{i} = combopick(uno{i}, dos{i});
%                 end;
%             end;
%         end;
%     end
% 
% %Matches the sorted units in the two files to one another by testing each
% %possible combination of data and choosing the combination with the highest
% %average covariance.
%     function bestChoice = combopick(unus, duo)
%         size1 = size(unus);
%         size2 = size(duo);
%         sizes = [size1(2) size2(2)];
%         bestChoice = zeros(1,max(sizes));
%         corrs = zeros(sizes(1), sizes(2));
%         for i = 1:sizes(1)
%             for j = 1:sizes(2)
%                 corrs(i,j) = corr(unus{i}, duo{j});
%             end;
%         end;
%         corrs = reshape(corrs, 1, sizes(1)*sizes(2));
%         corrs = sort(corrs,'descend');
%         for i = 1:min(sizes)
%             bestChoice(i) = corrs(i);
%         end; 
%     end
% 
% 
% %Sifts through a cell array containing doubles and takes their average
%     function output = getAvg(cells)
%         for i = 1:96
%             output = nan;
%             if isnan(cells{i})
%                 continue;
%             end;
%             units = size(cells{i});
%             for j = 1:units
%                 if isnan(output)
%                     output = cells{i}(j);
%                     continue;
%                 end;
%                output = (output+cells{i}(j))/2; 
%             end;
%         end;
%     end
end