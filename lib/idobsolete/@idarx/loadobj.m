function sys = loadobj(s)
%LOADOBJ  Load filter for idpoly objects. STATIC.

%   Author(s): Rajiv Singh
%   Copyright 1986-2012 The MathWorks, Inc.
if isa(s,'idarx')
   % MCOS
   sys = s;
   sys.Version_ = ltipack.ver();
else
   % Issue warning
   localupdatewarn
   % Upgrade (this currently applies to versions < 11; in future switching
   % might be required)
   ny = size(s.na,1);
   nu = size(s.nb,2);
   a = ones(ny,ny,max(max(s.na))+1);
   a(:,:,1) = eye(ny);
   b = zeros(ny,nu,max(max(s.nb+s.nk)));
   if nu==0
      s.nb = zeros(ny,0); s.nk = s.nb;
   end
   
   if isequal(s.idmodel.InputName,[])
      s.idmodel.InputName = cell(nu,1);
   end
   
   if isequal(s.idmodel.OutputName,[])
      s.idmodel.OutputName = cell(ny,1);
   end
   
   if nu>0 && isempty(s.idmodel.InputUnit)
      s.idmodel.InputUnit = repmat({''},[nu 1]);
   end
   
   if ny>0 
      if isempty(s.idmodel.OutputUnit)
         s.idmodel.OutputUnit = repmat({''},[ny 1]);
      end
      if isempty(s.idmodel.NoiseVariance)
         s.idmodel.NoiseVariance = eye(ny);
      end
   end
   Warn = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idarxObsolete'); %#ok<NASGU>
   for ky = 1:ny
      for ku = 1:nu
         b(ky,ku,s.nk(ky,ku)+(1:s.nb(ky,ku))) = 1;
      end
   end
   sys = idarx(a,b,s.idmodel.Ts,'na',s.na,'nb',s.nb,'nk',s.nk);
   sys = reload(sys, s.idmodel);
end

function localupdatewarn
%UPDATEWARN  output a warning when LOADOBJ routines are called

persistent last_old_object;

if isempty(last_old_object) || (etime(clock, last_old_object) > 1)
   ctrlMsgUtils.warning('Ident:idmodel:idarxload')
end
last_old_object = clock;
