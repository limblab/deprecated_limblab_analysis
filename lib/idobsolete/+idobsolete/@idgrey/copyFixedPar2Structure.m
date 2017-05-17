function sys = copyFixedPar2Structure(sys)
% Copy FixedParameter specifications from Algorithm to Free property of
% greydata Structure. 
%
% FixedParameter can be get/set independently of Structure.*.Free. It is
% copied over the Structure only at estimation time using this method.
%
% Does not work for model arrays.

%   Copyright 2010-2011 The MathWorks, Inc.

fp = sys.FixedParameter;
if iscell(fp)
   Empt = cellfun(@(x)isempty(x),fp);
   fp(Empt) = []; % remove empty entries from FixedParameter value
end
if isempty(fp), return; end

ctrlMsgUtils.warning('Ident:estimation:StructureModifiedForFixedPar')
PName = sys.PName;
if all(strcmp(PName,''))
   Warn = ctrlMsgUtils.SuspendWarnings;
   sys = setpname(sys);
   PName = sys.PName;
   delete(Warn)
end
if iscellstr(fp)
   fp = idobsolete.pnam2index(fp, PName);
end
if any(fp>length(PName)), ctrlMsgUtils.error('Ident:estimation:InvalidFixedPar'), end
fp = PName(fp);
if isempty(fp), return, end

S = sys.Structure;
p = S.Parameters;
for ct = 1:numel(p)
   [~,~,J] = intersect(fp,cat(1,{p(ct).Info(:).Label}));
   p(ct).Free(J) = false;
   S.Parameters(ct) = p;
end

sys.Structure = S;
