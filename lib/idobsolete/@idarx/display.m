function tex3 = display(m, conf, varargin)
%DISPLAY  display for IDARX objects

%   Copyright 1986-2015 The MathWorks, Inc.

ni = nargin;
if ni==2 && ischar(conf)
   SysName = conf;
   conf = 0;
else
   SysName = inputname(1);
   if ni<2
      conf = 0;
   end
end

if isempty(SysName), SysName = 'ans'; end

if isempty(m)
   tex3 = 'Empty Multivariable ARX (IDARX) model.';
   tex3 = [' ';sprintf('\n%s =\n',SysName); {tex3}];
   if nargout == 0
      disp(char(tex3))
      clear tex3
   end
   return
end

Ts = m.Ts;
if nargout
   txt1 = evalc('displaySize(m,size(m))');
else
   fprintf('\n%s =\n',SysName)
   if conf&isreal(m)
      [A,B,dA,dB] = arxdata(m);
   else
      [A,B] = arxdata(m);
      dA =[]; dB=[];
   end
   nv = m.NoiseVariance;
   if isempty(nv) | norm(nv) == 0
      noisetxt1 = '';
      noisetxt2 = '';
      k = [];
   else
      noisetxt1 = ' + K e(t)';
      noisetxt2 = ' + e(t)';
   end
   
   
   [ny,nu]=size(m);
   if nu>0
      disp('Multivariable ARX model')
      disp(sprintf(['\n   A0*y(t)+A1*y(t-T)+ ... + An*y(t-nT) =\n' ...
         '                 B0*u(t)+B1*u(t-T)+' ...
         ' ... +Bm*u(t-mT)',noisetxt2]))
   else
      disp('Multivariable AR model')
      disp(sprintf(['\n   A0*y(t)+A1*y(t-T)+ ... + An*y(t-nT) = e(t)']))
   end
   if ~isempty(dA)
      disp(sprintf(['\nwith matrices (standard deviations given as imaginary' ...
         ' parts):']))
   end
   %[A,B,dA,dB] = arxdata(m);
   if isempty(dA)
      dA=zeros(size(A));
   end
   if isempty(dB)
      dB=zeros(size(B));
   end
   for ka=1:size(A,3)
      disp(['A',int2str(ka-1),': '])
      disp(A(:,:,ka)+dA(:,:,ka)*i)
   end
   if nu>0
      for ka=1:size(B,3)
         disp(['B',int2str(ka-1),': '])
         disp(B(:,:,ka)+dB(:,:,ka)*i)
      end
   end
end
id = m.InputDelay;
if any(id),
   txt = str2mat([sprintf('Input delays (listed by channel): ')...
      sprintf('%0.3g  ',id')]);
else
   txt = '';
end

estim = m.EstimationInfo;
switch lower(estim.Status(1:3))
   case 'est'
      DN = estim.DataName;
      if ~isempty(DN)
         if nargout
            str = str2mat(['Estimated using ',estim.Method,' on data set ',estim.DataName],...
               ['Loss fcn ',num2str(estim.LossFcn),' and FPE ',num2str(estim.FPE)]);
         else
            str = sprintf('Estimated using %s on data set %s\nLoss function %g and FPE %g',...
               estim.Method, estim.DataName,estim.LossFcn, estim.FPE);
         end
      else
         str = sprintf('Estimated using %s\nLoss function %g and FPE %g',...
            estim.Method,estim.LossFcn, estim.FPE);
      end
   case 'mod'
      str = sprintf('Originally estimated using %s (later modified).',...
         estim.Method);
   case 'not'
      str = sprintf('This model was not estimated from data.');
   case 'tra'
      str = sprintf('Model translated from the old Theta-format.');
   otherwise
      str = '';
end
txt = str2mat(txt,str);

if Ts~=0,
   txt = str2mat(txt,sprintf('Sample time: %g %s', Ts, m.TimeUnit));
end

txt = str2mat(txt,' ');

if ~nargout
   if ~isempty(txt)
      disp(txt)
   end
else
   tex2 = str2mat(txt1,txt);
   tex2c = cell(size(tex2,1),1);
   for ii = 1:numel(tex2c)
      tex2c{ii} = tex2(ii,:);
   end
   tex3 = [' ';sprintf('\n%s =\n',SysName); tex2c];
end
