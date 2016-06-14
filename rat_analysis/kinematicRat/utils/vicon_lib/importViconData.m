%IMPORTVICONDATA imports comma-separated-values (csv) files obtained with
%the Vicon into Matlab. For the moment, this function is not general, and
%it assumes there is a subject Rat and a subject Treadmill.
%
%[ events, rat, treadmill ] = importViconData( path,        ...
%                                            ratName, tdmName,       ...
%                                            ratMarkers, tdmMarkers, ...
%                                            nColEv)
%
%INPUTS:
%
%path: Path and filename of the csv file (the extension .csv is required)
%ratName: String that identifies the subject Rat
%tdmName: String that identifies the subject Treadmill
%ratMarkers: Cell of strings with names of the markers in the subject Rat 
%tdmMarkers: Cell of strings with names of the markers in the subject
%Treadmill
%nColEv: number of columns that contain information about the events (if
%any). This parameter is optional. If not provided, its default value is 5.
%
%OUTPUTS:
%
%events: struct that contains information about the events (if any), as
%defined on Nexus. The field events.time is a Ne-by-1 column matrix with
%the time of occurance of the Ne events.
%rat: struct that contains information on the subject Rat. There is a field
%for each <marker>. Each rat.<marker> field is a N-by-3 matrix with
%the X,Y,Z coordinates of <marker> for N timestam. The fields rat.frame and
%rat.subframes are N-by-1 column vectors with the frame and the subframe
%of each sample in rat.<marker>.
%treadmill:struct that contains information on the subject Treadmill. There 
%is a field for each <marker>. Each treadmill.<marker> field is a N-by-3 
%matrix with the X,Y,Z coordinates of <marker> for N timestam. The fields 
%treadmill.frame and treadmill.subframes are N-by-1 column vectors with the 
%frame and the subframe of each sample in rat.<marker>.
%
%Author: Cristiano Alessandro (cristiano.alessandro@northwestern.edu)
%Date: April 13 2016
%Licence: GNU GPL


function [ events, rat, treadmill ] = importViconData( path,        ...
                                            ratName, tdmName,       ...
                                            ratMarkers, tdmMarkers, ...
                                            nColEv)
                                        
    nMarkers   = length(ratMarkers) + length(tdmMarkers);

    if nargin<6
        nColEv = 5;          % #columns events
    end
    nColTj = nMarkers*3 + 2; % #columns trajectories (xyz for each marker + 
                             %                        Frame and Subframe)

    % Open file
    fileID = fopen(path);

    if fileID ==-1
        error('File %s not found!\n',path);
    end

    % Read 32 columns of strings and put them in columns
    formatString = '%s';
    for j=1:max([nColEv nColTj])-1
        formatString = strcat(formatString,' %s');
    end

    C = textscan(fileID,formatString, 'Delimiter',',','EmptyValue',NaN);

    %C = textscan(fileID,['%s %s %s %s %s %s %s %s %s %s' ...
    %                     '%s %s %s %s %s %s %s %s %s %s' ...
    %                     '%s %s %s %s %s %s %s %s %s %s %s %s'], ...
    %                     'Delimiter',',','EmptyValue',NaN);

    fclose(fileID);

    tmp = C{1,1};

    idx_ev = cellfun(@(x)strcmp(x,'Events'),tmp);
    idx_tj = cellfun(@(x)strcmp(x,'Trajectories'),tmp);

    % There must be trajectory data
    if ~any(idx_tj)
        error('No data!');
    end
    idx_tj = find(idx_tj);

    % If there are events
    if any(idx_ev)
        idx_ev          = find(idx_ev);
        events.f        = str2double(tmp{idx_ev+1});
        events.colNames = cellfun(@(x)x(idx_ev+2),C(1,1:nColEv));
        events.data     = cellfun(@(x)x(idx_ev+3:idx_tj-1), C(1,1:nColEv), ...
                              'UniformOutput', false);
        events.time     = cellfun(@(x)str2double(x),events.data{1,4});
        fprintf('%d events found!\n',length(events.time));
    else
        fprintf('No events!\n')
        events = [];
    end

    % Read trajectory data
    fprintf('Read data...');
    
    rat.f        = str2double(tmp{idx_tj+1});
    rat.frame    = cellfun(@(x)str2double(x),tmp(idx_tj+5:end));
    rat.subframe = cellfun(@(x)str2double(x),C{1,2}(idx_tj+5:end));
    
    treadmill. f        = rat.f;
    treadmill. frame    = rat.frame;
    treadmill. subframe = rat.subframe;

    % Seek treadmil markers columns
    for j=1:length(tdmMarkers)
       mkName = [tdmName ':' tdmMarkers{j}];
       mkRow  = cellfun(@(x)x(idx_tj+2), C(1,1:nColTj),'UniformOutput', false);
       idxCol = find(cellfun(@(x)strcmp(x,mkName),mkRow));
       if isempty(idxCol)
           error('Marker %s not found!',mkName);
       end
       treadmill.(sprintf('%s',tdmMarkers{j})) = cell2mat( ...
           cellfun( @(x)str2double(x((idx_tj+5:end))), C(1,idxCol:idxCol+2), ...
                    'UniformOutput',false));
    end

    % Seek rat markers columns
    for j=1:length(ratMarkers)
       mkName = [ratName ':' ratMarkers{j}];
       mkRow  = cellfun(@(x)x(idx_tj+2), C(1,1:nColTj),'UniformOutput', false);
       idxCol = find(cellfun(@(x)strcmp(x,mkName),mkRow));
       if isempty(idxCol)
           error('Marker %s not found!',mkName);
       end
       rat.(sprintf('%s',ratMarkers{j})) = cell2mat( ...
           cellfun( @(x)str2double(x((idx_tj+5:end))), C(1,idxCol:idxCol+2), ...
                    'UniformOutput',false));
    end

    fprintf('done!\n');

end

