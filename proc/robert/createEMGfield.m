function BDFout=createEMGfield(BDFin)

% syntax BDFout=createEMGfield(BDFin)
%
% takes BDFin, which will have no .emg field and will contain EMG data
% as part of the bdf.raw.analog field.  This happens when emgs were not
% named 'emgxxx' but rather something else, e.g. the default 'ainp' analog
% input channel name, and the file is read in using get_cerebus_data.m
% the function will copy over relevant information into
% the proper .emg field, so that later functions which rely on the .emg
% field will not fail.

BDFout=BDFin;

% find emg channels
if isfield(BDFin,'raw.analog')
    emgchans=find(cellfun(@isempty,regexp(BDFin.raw.analog.channels,'ainp[0-9]'))==0);
    if isempty(emgchans)
        % was previously converted, or named something else.  either way, no
        % choice but to return.
        disp('createEMGfield.m did not modify the bdf')
        return
    end
else
    % was previously converted, or named something else.  either way, no
    % choice but to return.
    disp('createEMGfield.m did not modify the bdf')
    return
end
% populate bdf.emg
BDFout.emg.emgnames=BDFin.raw.analog.channels(emgchans);
BDFout.emg.emgfreq=BDFin.raw.analog.adfreq(emgchans(1));
BDFout.emg.data=cat(2,BDFin.raw.analog.data{emgchans});
emgfreq=BDFout.emg.emgfreq;
% add in the time vector; make it the first column
BDFout.emg.data=[(0:1/emgfreq:(size(BDFout.emg.data,1)-1)/emgfreq)', BDFout.emg.data]; 
% delete the emg signals from the .raw.analog fields
BDFout.raw.analog.channels(emgchans)=[];
BDFout.raw.analog.adfreq(emgchans)=[];
BDFout.raw.analog.data(emgchans)=[];
