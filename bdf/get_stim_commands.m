function stim = get_stim_commands(bdf)


% Data recorded before the stimulator was updated with the termination pound caracter.
if datenum(bdf.meta.datetime) - datenum('03-Mar-2011 00:00:00') < 0 
    
    %find 1 ms gaps between bytes - normally 1 byte every 0.1 ms during a command.
    % so a 1ms delay should mean we have a new command.
    cmd_start = find(diff([0;bdf.raw.serial(:,1)]) > 0.001);
    cmd_end = [cmd_start(2:end)-1; size(bdf.raw.serial,1)];

    %skip last if incomplete
    if bdf.meta.duration-bdf.raw.serial(end,1)<0.001
        cmd_start = cmd_start(1:end-1);
        cmd_end = cmd_end(1:end-1);
    end
        
else
    %There is a pound character at the end of each command
    
    cmd_end   = find(bdf.raw.serial(:,2) == double('#'));
    cmd_start = cmd_end(1:end-1) + 1; %skip first cmd, probably incomplete anyways.
    cmd_end   = cmd_end(2:end) - 1; % -1 to skip # character
end

num_cmd = length(cmd_start);
% stim = cell(num_cmd,2);
ts   = zeros(num_cmd,1);
chan = zeros(num_cmd,1);
I    = zeros(num_cmd,1);
PW   = zeros(num_cmd,1);

for cmd=1:num_cmd
    asciicmd = char(bdf.raw.serial(cmd_start(cmd):cmd_end(cmd),2)');
    cmd_idx_end   = [strfind(asciicmd,',') length(asciicmd)];
    cmd_idx_start = [1 cmd_idx_end(1:end-1)+1];
    cmd_length = length(cmd_idx_start);
    decoded_cmd = zeros(1,cmd_length);
    for i=1:cmd_length
        decoded_cmd(i) = str2double(asciicmd(cmd_idx_start(i):cmd_idx_end(i)));
    end
%     stim{cmd,1} = bdf.raw.serial(cmd_end(cmd),1);
%     stim{cmd,2} = decoded_cmd;
    if decoded_cmd(1)~= 0
        %TODO: extract all stim commands.
        %   For now, only commands with prefix 0 are decoded (load and run immediately)
        %   and this assumes commands are issued to only one channel at a time (NLMSv6 auto mode)
        continue;
    end
    ts(cmd)   = bdf.raw.serial(cmd_end(cmd),1);
    chan(cmd) = log2(decoded_cmd(2));
    I(cmd)    = decoded_cmd(5)/1000; %µA to mA
    PW(cmd)   = decoded_cmd(7); %µs
end

stim = [ts chan I PW];

%remove lines with skipped commands (not prefix 0)
stim = stim(any(stim,2),:);
    
    