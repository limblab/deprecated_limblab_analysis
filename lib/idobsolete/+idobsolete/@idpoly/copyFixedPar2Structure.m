function sys = copyFixedPar2Structure(sys)
% Copy FixedParameter specifications from Algorithm to Free property of
% polydata Structure.
%
% FixedParameter can be get/set independently of Structure.*.Free. It is
% copied over the Structure only at estimation time. Same entries apply to
% all systems in the array.

%   Copyright 2010-2011 The MathWorks, Inc.

fp = sys.FixedParameter;
if iscell(fp)
   Empt = cellfun(@(x)isempty(x),fp);
   fp(Empt) = []; % remove empty entries from FixedParameter value
end
if isempty(fp), return; end

Nsys = numel(sys.Data_);
for ksys = 1:Nsys
   PName = getParInfo(sys.Data_(ksys), 'Name');
   if all(strcmp(PName,''))
      Warn = ctrlMsgUtils.SuspendWarnings;
      sys(:,:,ksys) = setpname(sys(:,:,ksys));
      PName = getParInfo(sys.Data_(ksys), 'Name');
      delete(Warn)
   end
   if iscellstr(fp), fp = idobsolete.pnam2index(fp, PName); end
   if any(fp>length(PName)), ctrlMsgUtils.error('Ident:estimation:InvalidFixedPar'), end
   fp = PName(fp);
   
   S = sys.Data_(ksys).Structure;
   a = S.a;
   if ~isempty(a)
      for ct = 1:numel(a)
         [~,~,J] = intersect(fp,cat(1,{a(ct).Info(:).Label}));
         %fp(I) = [];
         a(ct).Free(J) = false;
      end
      S.a = a;
   end
   
   b = S.b;
   if ~isempty(b) %&& ~isempty(fp)
      for ct = 1:numel(b)
         [~,~,J] = intersect(fp,cat(1,{b(ct).Info(:).Label}));
         %fp(I) = [];
         b(ct).Free(J) = false;
      end
      S.b = b;
   end
   
   c = S.c;
   if ~isempty(c) %&& ~isempty(fp)
      for ct = 1:numel(c)
         [~,~,J] = intersect(fp,cat(1,{c(ct).Info(:).Label}));
         %fp(I) = [];
         c(ct).Free(J) = false;
      end
      S.c = c;
   end
   
   d = S.d;
   if ~isempty(d) %&& ~isempty(fp)
      for ct = 1:numel(d)
         [~,~,J] = intersect(fp,cat(1,{d(ct).Info(:).Label}));
         %fp(I) = [];
         d(ct).Free(J) = false;
      end
      S.d = d;
   end
   
   f = S.f;
   if ~isempty(f) %&& ~isempty(fp)
      for ct = 1:numel(f)
         [~,~,J] = intersect(fp,cat(1,{f(ct).Info(:).Label}));
         %fp(I) = [];
         f(ct).Free(J) = false;
      end
      S.f = f;
   end
   
   sys.Data_(ksys).Structure = S;
end
