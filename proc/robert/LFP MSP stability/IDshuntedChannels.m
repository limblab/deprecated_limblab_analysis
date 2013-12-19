function shuntedChannels = IDshuntedChannels(monkey_name,corrMat,corrThresh)%,Data_Type, varargin) 
% see also map_array_activity.m

% This function returns an index list of non-shunted channels.  It
% determines shunting by looking at a matrix of pairwise correlation
% coefficients, calculated across all pairs of electrodes.  It takes into
% account which channels were physical neighbors on the array, when
% deciding whether two channels were shunted together or not.
% Inputs:
%       monkey_name - name of monkey.  lower case.
%    
%       corrMat - the pairwise correlation between each pair of electrodes.  
%                 Should be a 96 x 96 matrix for a normal blackrock array.
%
%        corrThresh - the tolerance of correlation.  Pairwise correlations
%                     that exceed this value will be considered to be
%                     shunted.
%
% Output:
%       nonShuntedChannels - index of channels that were determined to be 
%                            NOT shunted.
    
% if ~isempty(varargin)
%     spike_list = varargin{1};
%     if length(varargin) > 1
%         platform = varargin{2};
%     end
% end

pin_map   = [1  3  5  7  9  11 13 15 17 19 21 23 25 27 29 31 ... %bank 1
             2  4  6  8  10 12 14 16 18 20 22 24 26 28 30 32 ...
             33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 ... %bank 2
             34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 ...
             65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 ... %bank 3
             66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 ...
             0 0 0 0 ];
         
% Array ID#1025-0394; Right hemisphere - M1
% see \\citadel\limblab\lab_folder\Lab-Wide Animal Info\ ...
%         Implants\Blackrock Array Info\Array Map Files
chewie_map =[93 94 75 85 86 87 77 66 76 67 58 78 68 69 59 49 ... %pins 1-31 odd
             92 95 96 97 98 88 99 89 90 79 80 70 60 50 40 30 ... %pins 2-32 even
             83 73 63 53 43 44 33 34 24 35 25 26 27 28 29 19 ... %pins 33-63 odd
             84 74 64 54 55 45 46 65 56 47 57 36 37 38 48 39 ... %pins 34-64 even
             81 71 61 51 41 31 21 11 2  3  4  15 16 17 8  20 ... %pins 65-95 odd
             82 72 62 52 42 32 22 12 23 13 14 5  6  7  18 9  ... %pins 66-96 even
             1  10 91 100 ]; %gnd/ref electrodes

% Array ID#1025-0592; Left hemisphere - M1
% see \\citadel\limblab\lab_folder\Lab-Wide Animal Info\ ...
%         Implants\Blackrock Array Info\Array Map Files
mini_map =  [93 94 75 85 86 87 77 66 76 67 58 100 68 69 59 49 ... %pins 1-31 odd
             92 95 96 97 98 88 99 89 90 79 80 70 60 50 40 30 ... %pins 2-32 even
             83 73 63 53 43 44 33 34 24 35 25 26 27 28 29 19 ... %pins 33-63 odd
             84 74 64 54 55 45 46 65 56 47 57 36 37 38 48 39 ... %pins 34-64 even
             81 71 61 51 41 31 21 11 2  3  4  15 16 17 8  20 ... %pins 65-95 odd
             82 72 62 52 42 32 22 12 1  13 14 5  6  7  18 9  ... %pins 66-96 even
             10 23 78 91 ]; %gnd/ref electrodes
         
if strncmpi( monkey_name, 'chewie_map', length(monkey_name) )
    implant_map = [pin_map' chewie_map'];
elseif strncmpi( monkey_name, 'mini_map', length(monkey_name) )
    implant_map = [pin_map' mini_map'];
end

sorted_list = sortrows( implant_map, 2 );

map_matrix = reshape( sorted_list(:,1), 10, 10 )';

% if strcmpi(Data_Type,'LFP') && strcmpi(platform,'plx')
%     spike_channel_numbers = [65:96 1:64];
% elseif strcmpi(Data_Type,'LFP') && strcmpi(platform,'ceb')
%     spike_channel_numbers = 1:96;
% elseif strcmpi(Data_Type,'Spike')
%     spike_channel_numbers = spike_list;
% end

corrMat=mean(corrMat,3);
% square corrMat is redundant.  Remove upper half, including the main
% diagonal which will be all 1s anyway.
for n=1:size(corrMat,1)
    corrMat(n,n:end)=0;
end
[shuntR,shuntC]=find(corrMat >= corrThresh);
arrayImg=zeros(10,10);
for n=1:length(shuntR)
    arrayImg(map_matrix==shuntR(n))=1;
    arrayImg(map_matrix==shuntC(n))=1;
end
arrayImg(map_matrix==0)=0.5;

figure, imagesc(arrayImg), colormap(gray)
shuntedChannels=map_matrix(arrayImg>0.5);
