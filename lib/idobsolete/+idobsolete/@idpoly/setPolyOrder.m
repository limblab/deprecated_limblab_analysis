function sys = setPolyOrder(sys, Name, N, Nold, Size)
% Update IDPOLY model's polynomials in response to changes in na, nb, nc,
% nd or nf.

%  Author(s): Rajiv Singh
%  Copyright 2009-2015 The MathWorks, Inc.

if isequal(N,Nold)
   return
end

Data = sys.Data_;
if numel(Data)>1
   ctrlMsgUtils.error('Ident:idmodel:setPolyOrder1')
end

N = full(double(N));

% Changing I/O size is not supported.
if ~isequal(size(N),Size)
   ctrlMsgUtils.error('Ident:idmodel:setPolyOrder2',Name)
elseif ~isequal(N,round(N)) || ~isnumeric(N) || any(~isfinite(N(:))) || ...
      any(N(:)<0) || ~isreal(N)
   error(message('Ident:general:nonnegativeIntPropVal',['n',lower(Name)]))
end

P = getPolyValue(Data, Name, Size);
Ts = getTs(sys);
IsB = strcmp(Name,'b');
IsA = strcmp(Name,'a');
if IsB
   if any(N==0)
      ctrlMsgUtils.error('Ident:idmodel:setPolyOrder3')
   end
   Nk = sys.nk;
   N = N+Nk-1;
   Nold = Nold+Nk-1;
end

for ct = 1:numel(Nold)
   Pct = P{ct};
   if N(ct)>Nold(ct)
      % Use eps to extend polynomials in order to maintain old behavior.
      if Ts~=0 || ~IsB
         Pct = [Pct, eps*ones(1,N(ct)-Nold(ct))]; %#ok<*AGROW>
      else
         Pct = [eps*ones(1,N(ct)-Nold(ct)), Pct];
      end
   else
      if Ts~=0
         Pct = Pct(1:N(ct)+1);
      else
         Pct = Pct(end-N(ct):end);
         if ~(IsB || (IsA && rem(ct,Size(1)+1)~=1))
            % Try making monic after truncation. Do so only for C, Data and
            % diagonal A polynomials.
            if Pct(1)~=0
               Pct = Pct/Pct(1);
            else
               Pct(1) = 1;
            end
         end
      end
   end
   
   % Do not stabilize B or off-diagonal polynomials of A.
   if IsB || (IsA && rem(ct,Size(1)+1)~=1)
      P{ct} = Pct;
   else
      P{ct} = fstab(Pct,Ts);
   end
end

sys.(upper(Name)) = P;
