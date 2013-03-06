function [ Status ] = CBInitWordRead( mode )
%CBInitWordRead Open Cerebus in mode to deliver data words
%   
%% Set up Cerebus.
% 
% OpenCerebus(mode)
switch mode
    case 'open'
        try
            [c i] = cbmex('open',1);
        catch
            try
                cbmex close
                [c i] = cbmex('open',1, 'nocontinuous');
            catch
                %    addpath('C:\Users\Ted\Dropbox\TedBallou\Windows\v6.03.00.01\SDK\lib')
                %addpath('../SDK/')
                addpath('C:\Program Files\Blackrock Microsystems\Cerebus Windows Suite\SDK')
                try
                    [c i] = cbmex('open',1);
                catch
                    error 'cannot open cbmex via Central'
                end
            end
        end
        Pending = InitPending();
        cbmex('mask',0,0)       % disable all channels
        cbmex('mask',CHAN,1)     % enable word channel
        cbmex('trialconfig',1)  % empty the buffer and begin collecting data
    case 'update'
        % Here for repeated calls, no setup required. New data will be
        % appended to Pending data; controls for next index and nibble are
        % contained in the Pending structure. Cerebus is assumed to be
        % already collecting data.
        try
            isstruct(Pending);
        catch
            error 'Cannot call FetchAndScrub() for update without first calling for open'
        end
    case 'test'
        INTERVAL=0.01; % abbreviate the wait time 
        myWait = 0.01;
    otherwise
        help CBInitWordRead
        error(['unknown mode: ',mode])
end


end

