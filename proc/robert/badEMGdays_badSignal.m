function varargout=badEMGdays_badSignal

% syntax [badDays,badChannels]=badEMGdays;

n=1;
badChannelInfo{n,1}='ChewieSpikeLFP282';
badChannelInfo{n,2}=2;						% which channel is bad
n=n+1;
badChannelInfo{n,1}='ChewieSpikeLFP286';
badChannelInfo{n,2}=2;						% which channel is bad
n=n+1;
badChannelInfo{n,1}='Thor_11-3-10_mid_iso_002';
badChannelInfo{n,2}=[6 9 12];						% which channel is bad
n=n+1;
badChannelInfo{n,1}='Thor_11-3-10_prone_iso_001';
badChannelInfo{n,2}=[6 9 12];						% which channel is bad


varargout{1}=badChannelInfo(:,1);
if nargout >= 2
	varargout{2}=badChannelInfo(:,2);
end

