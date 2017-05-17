function [nb,nk] = time2firorder(command,T,Ts,ioSize,Causal)
% Convert time vector specification to FIR filter orders nb and nk.
% Used by iddata/impulse, iddata/step, idfrd/impulse, idfrd/step.
%
% Causal flag is used only for interpreting start time for scalar T. In
% case T is a vector, causality is determined by sign of T(1).

%   Author(s): Rajiv Singh
%   Copyright 2012 The MathWorks, Inc.

ny = ioSize(1); nu = ioSize(2); 
ImpulseEst = strcmp(command,'impulseest'); 
nb = []; nk = []; 
if isempty(T), return; end
if ~isnumeric(T) || ~isvector(T) || ~isreal(T) || ~any(isfinite(T))
   if ImpulseEst
      error(message('Ident:estimation:impulseest4'))
   else
      error(message('Ident:estimation:impulseest4a',command))
   end
else
   T = double(full(T));
   T = T(:)';
end

if numel(T)>2
   T = [T(1), T(end)];
elseif isscalar(T)
   if ~Causal
      T = [-T/4, T];
   else
      T = [0, T];
   end
end

Tr = round(sort(T)/Ts);
% nk denotes the starting sample time
nk = min(Tr(1),0);  % nk cannot be > 0 in old time vector syntax
nk2 = max(Tr(2),0)+1; 
nb = nk2-nk;

% Scalar expansion
nb = nb*ones(ny,nu);
nk = nk*ones(ny,nu);
