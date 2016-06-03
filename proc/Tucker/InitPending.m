function Pending = InitPending()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% FUNCTION InitPending
% Set up structure to support repeated invocations and keep track of
% databurst fragments
Pending.ts = [];
Pending.codes = [];
Pending.Start_ts = -1;
Pending.MissingEND = false;
end
