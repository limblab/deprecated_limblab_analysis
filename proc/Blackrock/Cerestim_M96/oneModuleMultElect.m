% oneModuleMultElect([electrode_list], delay)
% 
% csmex interface code to interleave multiple electrodes on a single current
% module, with interleaving delay "delay"

%         <----stimdur-------->
%          -----
%         |  ^  |          <-->slack
%         |  |  |
% --------   |   ----       ------------------------------------------
%     duration    ^  |     |
%                 |  |     |
%        interphase   -----    <--delay->
%                                         -----
%                                        |     |
%                                        |     |
% ---------------------------------------       ----       -----------
%                                                   |     |
%          <-----Period(msec)=1000/freq-->          |     |
%                                                    -----

function retv = oneModuleMultElect(electrodes, delay)

if nargin ~= 2
    help oneModuleMultElect
    errstr = sprintf('%s\n%s\n','Not enough arguments',...
        'select electrode list and delay (msec)');
    error(errstr);
end

numels = numel(electrodes);
if numels < 1 || floor(delay) ~= delay
    help oneModuleMultElect
    errstr = sprintf('%s\n%s\n',...
        'electrode list must provide at least one electrode',...
        'delay must be an integer number of milliseconds');
    error(errstr)
end

try
    [retval] = csmex('connect');
catch
    if retval~=-10  % code for already connected, fail for other error
        error('fail to initialize csmex')
    end
end

% All times are in microseconds
interphase = 54;
duration = 500;
slack = 200;    % put in a little extra time between electrode switches
stimdur = 2*duration+interphase+slack;

% if numels > 1 && delay < stimdur
%     error('delay too short!')
% end
% configure pattern #1
configID = 1;   % Use stimulator module #1
freq = 10;      % period = 50 msec
polarity = 0;   % anode first
numpuls = 2;
ampl = 20;      % pulse amplitude in  microAmps

if 1000/freq <= numels*stimdur/1000
    help oneModuleMultElect
    errmsg=sprintf('Period is %d ms but last electrode delay is %d ms', ...
        1000/freq, (numel(electrodes)-1)*delay);
    error(errmsg)
end

csmex('configure',configID,polarity,numpuls,ampl,ampl,...
    duration,duration,freq,interphase);

csmex('beginningOfSequence');
csmex('beginningOfGroup');
for i=1:numel(electrodes)
    if electrodes(i)==0
        break
    end
    if i>1
        csmex('wait',delay)
    end
    as=tic;
    csmex('autoStimulus',electrodes(i),configID);
    fprintf('Time to run (ms)=%.2f\n',toc(as)*1000)
end
csmex('endOfGroup');
csmex('endOfSequence');

csmex('play',1);

csmex('disconnect');
end