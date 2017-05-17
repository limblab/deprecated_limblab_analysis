function sys = copyFixedPar2Structure(sys)
% Copy FixedParameter specifications from Algorithm to Free property of
% procdata Structure. 
%
% FixedParameter can be get/set independently of Structure.*.Free. It is
% copied over the Structure only at estimation time using this method.
%
% Does not work for model arrays.

%   Copyright 2011 The MathWorks, Inc.

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

if all(cellfun(@(x)isempty(x),PName))
   PName = getDefaultParNames(sys); % for process models, fill in parameter names
end

if iscellstr(fp)
   fp = idobsolete.pnam2index(fp, PName);
end

sys.Data_ = fixParByIndex(sys.Data_,fp);


