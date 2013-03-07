function [ Status ] = CBInitWordRead( mode )
%CBInitWordRead Open Cerebus in mode to deliver data words
%   
%% Set up Matlab interface to Central
% 
if nargin ~= 1
    help CBInitWordRead
    return
end
CHAN=151;
% OpenCerebus(mode)
switch mode
    case {'open',''}
        try
            [c i] = cbmex('open',1);
        catch
            try
                cbmex close
                [c i] = cbmex('open',1);
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
        cbmex('mask',0,0)       % disable all channels
        cbmex('mask',CHAN,1)     % enable word channel
        cbmex('trialconfig',1,'nocontinuous')  % empty the buffer and begin collecting data
    case 'test'
        INTERVAL=0.01; % abbreviate the wait time 
        myWait = 0.01;
    otherwise
        help CBInitWordRead
        error(['unknown mode: ',mode])
end


end

