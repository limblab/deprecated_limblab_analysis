function varargout=badEMGdays

% syntax [badDays,badChannels]=badEMGdays;

badChannelInfo{1,1}='ChewieSpikeLFP282';
badChannelInfo{1,2}=2;						% which channel is bad
badChannelInfo{2,1}='ChewieSpikeLFP286';
badChannelInfo{2,2}=2;						% which channel is bad

varargout{1}=badChannelInfo(:,1);
if nargout >= 2
	varargout{2}=badChannelInfo(:,2);
end
