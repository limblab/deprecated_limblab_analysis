function sys = copyFixedPar2Structure(sys)
% Copy FixedParameter specifications from Algorithm to Free property of
% ssdata Structure. 
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

S = sys.Structure;
a = S.a;
if ~isempty(a.Value)
   for ct = 1:numel(a)
      [~,~,J] = intersect(fp,cat(1,{a(ct).Info(:).Label}));
      %fp(I) = [];
      a(ct).Free(J) = false;
   end
   S.a = a;
end

b = S.b;
if ~isempty(b.Value) && ~isempty(fp)
   for ct = 1:numel(b)
      [~,~,J] = intersect(fp,cat(1,{b(ct).Info(:).Label}));
      %fp(I) = [];
      b(ct).Free(J) = false;
   end
   S.b = b;
end

c = S.c;
if ~isempty(c.Value) && ~isempty(fp)
   for ct = 1:numel(c)
      [~,~,J] = intersect(fp,cat(1,{c(ct).Info(:).Label}));
      %fp(I) = [];
      c(ct).Free(J) = false;
   end
   S.c = c;
end

d = S.d;
if ~isempty(d.Value) && ~isempty(fp)
   for ct = 1:numel(d)
      [~,~,J] = intersect(fp,cat(1,{d(ct).Info(:).Label}));
      %fp(I) = [];
      d(ct).Free(J) = false;
   end
   S.d = d;
end

k = S.k;
if ~isempty(k.Value) && ~isempty(fp)
   for ct = 1:numel(k)
      [~,~,J] = intersect(fp,cat(1,{k(ct).Info(:).Label}));
      %fp(I) = [];
      k(ct).Free(J) = false;
   end
   S.k = k;
end

sys.Structure = S;
