function encoder = get_encoder(strobed_events)
% GET_ENCODER(time_stamp_events)
% 
% Decodes the encoder positions of the new (Brian's) behavior system from
% the events.strobedEvents variable of the MAD structure.
%
% This function is designed to be placed into the current MAD structure
% creation routines between the point where strobedEvents is created and
% when it is written into the structure.
%
%   ENCODER = GET_ENCODER(STROBED_EVENTS) sets ENCODER to the decoded 
%       encoder readings.
%   
%   ENCODER takes the form of a three-column matrix where the first column
%   	contains the time stamp and the subsequent columns contain the word
%       encoder positions.
%   
%   STROBED_EVENTS expects a two column array where the first column
%       contains the time-stamps, and the second column contains the byte
%       recorded by plexon.

% $Id$

[n,m] = size(strobed_events);
if (m ~= 2)
    error('input strobed_events must be a two column matrix');
end

% get time-stamps of the first strobe in a set of four
ts = strobed_events(:,1);
ts_index = find( diff(ts) > .000275 )+1;
ts_index = ts_index( diff(ts_index) == 4 ); % throw out bad points
time_stamps = ts( ts_index );

% assemble encoder signals
encoder = zeros(length(ts_index)-2, 3);

if (length(ts_index)-2>=1)
    encoder(:,1) = time_stamps(1:end-2);
    encoder(:,2) = strobed_events(ts_index(1:end-2),2) + strobed_events(ts_index(1:end-2)+1,2)*2^8 - 32765;
    encoder(:,3) = strobed_events(ts_index(1:end-2)+2,2) + strobed_events(ts_index(1:end-2)+3,2)*2^8 - 32765;
end

temp_indices = (diff(encoder(:,2))<50 & diff(encoder(:,2))>-50 &...
    diff(encoder(:,3))<50 & diff(encoder(:,3))>-50);
encoder_temp(:,1) = encoder(temp_indices,1);
encoder_temp(:,2) = encoder(temp_indices,2);
encoder_temp(:,3) = encoder(temp_indices,3);
encoder = encoder_temp;

clear encoder_temp;

temp_indices = (diff(encoder(:,2))<50 & diff(encoder(:,2))>-50 &...
    diff(encoder(:,3))<50 & diff(encoder(:,3))>-50);
encoder_temp(:,1) = encoder(temp_indices,1);
encoder_temp(:,2) = encoder(temp_indices,2);
encoder_temp(:,3) = encoder(temp_indices,3);
encoder = encoder_temp;
