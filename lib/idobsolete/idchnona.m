function chname = idchnona(Names)
%IDCHNONA Checks for forbidden channel names
%
%   CHNAME = IDCHNONA(Name) returns empty if Name is an allowed channel
%   name. Otherwise CHNAME is a forbidden name. The check is made
%   for case-insensitive names.

%   Copyright 1986-2011 The MathWorks, Inc.

chname = [];
if ~iscell(Names),Names={Names};end

PropList = {'measured','noise'};

% Set number of characters used for name comparison
for kk = 1:length(Names)
   Name = Names{kk};
   if isempty(Name), continue; end
   if strcmpi(Name,'all')
      ctrlMsgUtils.error('Ident:general:ALLAsChannelName',Name)
   end
   nchars = length(Name);
   
   imatch = find(strncmpi(Name,PropList,nchars));
   if ~isempty(imatch)
      chname = PropList{imatch};
   end
   
end


