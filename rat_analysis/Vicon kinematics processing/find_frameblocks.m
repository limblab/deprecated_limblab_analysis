function [new_data,frames] = find_frameblocks(data,varargin)
%function [new_data,frames] = find_frameblocks(data,opts)
%   Function to preprocess kinematic data returned by Vicon.  It's looking
%   for continuous blocks of data where all markers are labelled.  It needs
%   a mininum of 50 frames to constitute a block.  It allows a gap of 10
%   frames before saying that it's not continuous.
%   
%

if nargin == 1
    OPTS.MAX_NFRAMES_2_DROP = 1;
    OPTS.MIN_NFRAMES_PER_BLOCK = 50;
else
    OPTS = varargin{1};
end
    
data = data(5:end,:);  % these are the marker positions - skip the first 4 rows

% look for dropped markers - they're NaN in the CSV file
temp = sum(data,2);  % sum across all the markers
ind = find(~isnan(temp));
good_data = data(ind,:);  % the data with no missing markers

% now find continuous blocks of data
frame_number = good_data(:,1);
break_inds = find(diff(frame_number) > OPTS.MAX_NFRAMES_2_DROP);  % look for gaps in marked frames

% now extract the separate blocks of good, continuous markings
nblocks = length(break_inds);
% break_inds(end+1) = size(good_data,1);
if nblocks == 0
    break_inds(1) = size(good_data,1);
end

block(1,:) = [1 break_inds(1)];

for ii = 2:(nblocks)  % create all the blocks of continuous frames
    block(ii,:) = [break_inds(ii-1)+1 break_inds(ii)];
end
block(end+1,:) = [break_inds(end)+1 size(good_data,1)];

% look for blocks that are too short and drop them
block_length = diff(block')';  % now screen the blocks as to whether there are enough frames in each of them to define a block
ind = find(block_length > OPTS.MIN_NFRAMES_PER_BLOCK);
good_blocks = block(ind,:);

% now create the set of frame indices and the corresponding marker position data
for ii = 1:size(good_blocks,1)
    new_data{ii} = good_data(good_blocks(ii,1):good_blocks(ii,2),3:end);
    frames{ii} = frame_number(good_blocks(ii,1):good_blocks(ii,2));
end

