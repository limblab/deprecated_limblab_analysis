function varargout = strobed2encoder(strobed_events,varargin)
% GET_ENCODER(time_stamp_events)
% 
% Decodes the encoder values from the strobedEvents variable of the MAD structure.
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

% $Id: get_encoder.m 1907 2015-07-10 20:37:29Z tucker $

if ~isempty(varargin)
    %variable input used to pass times that this function will ignore step
    %shifts in the output. particularly important for ignoring shifts that
    %occur when files are concatenated together.
    ignore_windows=varargin{1};
else
    ignore_windows=[];
end

if (size(strobed_events,2) ~= 2)
    error('get_encoder:BadMatrix','input strobed_events must be a two column matrix');
end

% Old encoding scheme would create problems whenever two consecutive bytes
% had the exact same value (the second one was not recorded). The new
% scheme is more complicated but it gets rid of the problem. The first bit
% of every byte is a "clock" signal that is toggled between bytes. The
% encoder data is encoded in five bytes as follows:
% Bit 1 of every encoder is most significant bit, bit 16 is least
% significant.
% Byte 1 = [clock encoder1(1:7)];
% Byte 2 = [clock encoder1(8:14)];
% Byte 3 = [clock encoder1(15:16) encoder2(1:5)];
% Byte 4 = [clock encoder2(6:12)];
% Byte 5 = [clock encoder2(13:16) 0 0 0];

% New encoding mode sends a new byte faster, every 125 usec.
if mode(diff(strobed_events(:,1))) < 0.00016
    encoding_scheme = 1;
else
    encoding_scheme = 0;
end

if encoding_scheme == 0
    % Get rid of repeated numbers
    strobed_events(diff(strobed_events(:,1))<1.9E-4,:) = []; 
    
    % get time-stamps of the first strobe in a set of four
    ts = strobed_events(:,1);
    
    ts_index = find( diff(ts) > .000275 )+1;
    ts_index(diff(ts(ts_index))<.0009) = [];

    % Fix strobed events
    ts_index = ts_index( diff(ts_index) == 4 ); % throw out bad points
    time_stamps = ts( ts_index );

    % assemble encoder signals
    encoder = zeros(length(ts_index)-2, 3);

    if (length(ts_index)-2>=1)
        encoder(:,1) = time_stamps(1:end-2);
        encoder(:,2) = strobed_events(ts_index(1:end-2),2) + strobed_events(ts_index(1:end-2)+1,2)*2^8 - 32765;
        encoder(:,3) = strobed_events(ts_index(1:end-2)+2,2) + strobed_events(ts_index(1:end-2)+3,2)*2^8 - 32765;
    end
elseif encoding_scheme == 1
    % Get rid of repeated numbers
    strobed_events(diff(strobed_events(:,1))<5E-5,:) = [];  

    % get time-stamps of the first strobe in a set of four
    ts = strobed_events(:,1);
    
    byteDec = bitand(strobed_events(:,2),127);
    ts_index = find( diff(ts) > .0004 )+1;
    ts_index(diff(ts(ts_index))<.0008) = [];

    % Fix strobed events
    ts_index = ts_index( diff(ts_index) == 5 ); % throw out bad points
    ts_index = ts_index(1:end-1);
    time_stamps = ts( ts_index );
    
    byteMat = [byteDec(ts_index) byteDec(ts_index+1) byteDec(ts_index+2) byteDec(ts_index+3) byteDec(ts_index+4)];
    
    s_dec = (bitand(byteMat(:,1),127)*2 + bitshift(byteMat(:,2),-6))*2^8 + bitand(byteMat(:,2),63)*4 + bitshift(byteMat(:,3),-5) - 32765;
    e_dec = (bitand(byteMat(:,3),31)*8 + bitshift(byteMat(:,4),-4))*2^8 + bitand(byteMat(:,4),15)*16 + bitshift(byteMat(:,5),-3) - 32765;
    
    encoder = [time_stamps(1:end-2) s_dec(1:end-2) e_dec(1:end-2)];
end
%make mask vector to use as flag for ignoring timepoints
mask=ones(size(time_stamps));
temp=[];
if ~isempty(ignore_windows)
    for i=1:size(ignore_windows,1)
        range=[find(time_stamps>=ignore_windows(i,1),1,'first'),find( time_stamps<=ignore_windows(i,2),1,'last')];
        %if there are no points inside the window, as the case with
        %fileseparateions, the first point of range will be larger than the
        %second. Thus we use min and max to get the actual window for all
        %cases
        temp=[temp;[min(range):max(range)]'];
    end
    mask(temp)=0;
end

%fix steps in encoder 1
temp_indices = find( (diff(encoder(:,2))>50 | diff(encoder(:,2))<-50) & mask(1:end-3));
data_jumps=0;
jump_times=encoder(temp_indices,1);
if ~isempty(temp_indices)
    for i=length(temp_indices):-1:1
        if mask(temp_indices(i))
            encoder(temp_indices(i)+1:end,2) = encoder(temp_indices(i)+1:end,2)-(encoder(temp_indices(i)+1,2)-encoder(temp_indices(i),2));
        end
    end
    data_jumps=length(temp_indices);
end

%fix steps in encoder 2
temp_indices = find( (diff(encoder(:,3))>50 | diff(encoder(:,3))<-50) & mask(1:end-3));
jump_times=[jump_times;encoder(temp_indices,1)];
if ~isempty(temp_indices)
    for i=length(temp_indices):-1:1
        if mask(temp_indices(i))
            encoder(temp_indices(i)+1:end,3) = encoder(temp_indices(i)+1:end,3)-(encoder(temp_indices(i)+1,3)-encoder(temp_indices(i),3));
        end
    end
    data_jumps=data_jumps+length(temp_indices);
end

if data_jumps
    warning('get_encoder:corruptEncoderSignal','The encoder data contains large jumps. These jumps were removed in get_encoder')
    disp(['Found',num2str(data_jumps),' step offsets in the data'])
    if ~isempty(ignore_windows)
        disp('Steps associated with some time points such as file concatination times may have been ignored')
    end
end
varargout{1}=encoder;
if nargout>1
    varargout{2}=jump_times;
end