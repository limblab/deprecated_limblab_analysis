function I = pnam2index(FixedP, AllP)
% Convert fixed parameter names to their indices in parameter list AllP.
%
%   An entry in FixedP containing wildcard '*' implies ellipsis - zero or
%   more characters.
%
%   An entry in Plist with the symbol '?' is interpreted as a wildcard for
%   all strings that match, except for the symbol in this position.

%   Copyright 2010 The MathWorks, Inc.

if any(strcmp(AllP,'*')) || any(strcmp(AllP,'?'))
   ctrlMsgUtils.error('Ident:general:pnam2index1')
end

I = [];
for ct = 1:length(FixedP)
   p = FixedP{ct};
   i1 = strfind(p,'*'); i2 = strfind(p,'?');
   if ~isempty(i1) && ~isempty(i2)
      ctrlMsgUtils.error('Ident:idmodel:fixpCheck1')
   elseif ~isempty(i1)
      [~,Match] = regexp(AllP,sprintf('\\<%s\\>',strrep(p,'*','.*')));
      Ict = find(cellfun(@(x)~isempty(x),Match));
   elseif ~isempty(i2)
      [~,Match] = regexp(AllP,sprintf('\\<%s\\>',strrep(p,'?','.')));
      Ict = find(cellfun(@(x)~isempty(x),Match));
   else
      % No special characters
      Ict = find(strcmp(p,AllP));
   end
   if isempty(Ict)
      ctrlMsgUtils.warning('Ident:general:pnam2index2',p)
   else
      I = [I; Ict(:)];
   end
end

I = unique(I(I>0));
