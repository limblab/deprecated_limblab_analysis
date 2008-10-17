function words = get_words(time_stamp_events)
% GET_WORDS(time_stamp_events)
% 
% Decodes the words of the new (Brian's) behavior system from the 
% events.timeStampEvents variable of the MAD structure.
%
% This function is designed to be placed into the current MAD structure
% creation routines between the point where timeStampEvents is created and
% when it is written into the structure.
%
%   WORDS = GET_WORDS(TIME_STAMP_EVENTS) sets words to the decoded words.
%   
%   WORDS takes the form of a two-column matrix where the first column
%   	contains the time stamp and the second column contains the word
%   
%   TIME_STAMP_EVENTS expects an 8-cell array where each cell contains an
%       Nx1 vector of time stamps.  Each cell represents 1 bit of the word,
%       LSB first (cell 1).  Time stamps are those samples where that
%       particular bit was set to TRUE.

% First, we need to get all of the time stamps where an event happened on
% any channel.
time_stamps = [];
bits = [];
for i = 1:8
    bit_time_stamps = time_stamp_events{i};% - 25e-6 * (i-1);
    time_stamps = [time_stamps; bit_time_stamps];
    bits = [bits; (i-1) * ones(length(bit_time_stamps), 1)];
end
events = [time_stamps bits];
events = sortrows(events);


% group into frames
frame_indices = find(diff(events(:,1)) > .0002) + 1;
frame_lengths = diff(frame_indices);
frame_indices = frame_indices(1:length(frame_indices)-1); % drop last index to keep lists same length

% build output
words = zeros(length(frame_indices), 2);
for frame = 1:length(frame_indices) % foreach word
    words(frame, 1) = events(frame_indices(frame));
    for bit_idx = 1:frame_lengths(frame) % foreach activated bit
        words(frame, 2) = words(frame, 2) + 2^events(frame_indices(frame) + bit_idx-1, 2);
    end
end

