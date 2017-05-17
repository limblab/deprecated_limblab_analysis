function [amp,phas,w,sdamp,sdphas] = ffplot(varargin)
%FFPLOT Plots a diagram of a frequency function or spectrum with linear
%       frequency scales and Hz as the frequency unit.
% FFPLOT is obsolete. Use BODE and BODEPLOT commands with appropriate
% scaling options.

%   Copyright 1986-2013 The MathWorks, Inc.

%   FFPLOT(M)
%   FFPLOT(M,'SD',SD)
%   FFPLOT(M,W)
%   FFPLOT(M,SD,W)
%
%   where M is an IDMODEL or IDFRD object, like IDPOLY, IDSS, IDARX or
%   IDGREY, obtained by any of the estimation routines, including
%   ETFE and SPA.
%   The frequencies in W are always specified in Hz.
%
%   The syntax is the same as for BODE. See BODE for all
%   details. When used with output arguments,
%   [Mag,Phase,W2,SDMAG,SDPHASE] = FFPLOT(M,W1)
%   The frequency unit of W1 is in Hz while frequency unit of W2 is rad/s.
%
% See also BODE, BODEPLOT, BODEOPTIONS.

% Convert frequencies into rad/s
ni = nargin; w = {};
for ct = 2:ni
   vct = varargin{ct};
   if isnumeric(vct) && isvector(vct) && ~ischar(varargin{ct-1})
      w = {2*pi*vct};
      varargin{ct} = w{1};
   end
end

I = idpack.findOptionInList('ap',varargin,2);
if ~isempty(I)
   if length(varargin)>I(end)
      AP = strcmpi(varargin{I(end)+1},{'a','p','b'});
      if ~any(AP)
         ctrlMsgUtils.error('Ident:general:InvalidSyntax','ffplot','ffplot')
      end
   else
      ctrlMsgUtils.error('Ident:general:InvalidSyntax','ffplot','ffplot')
   end
   varargin([I, I+1]) = [];
end

% bode(sys, 'a') 
I = idpack.findOptionInList('a',varargin,1);
if ~isempty(I)
   varargin(I) = [];
end

no = nargout; ni = length(varargin);
if no==0
   AllTsModel = true;
   for ct = 1:ni
      if isa(varargin{ct},'DynamicSystem')
         if ~(isa(varargin{ct},'idfrd') || isa(varargin{ct},'idlti')) || size(varargin{ct},2)>0
            AllTsModel = false; break;
         elseif size(varargin{ct},2)==0
            if isa(varargin{ct},'idfrd') && ~isempty(w)
               m = interp(varargin{ct},w{:});
            else
               m = idfrd(varargin{ct},w{:});
            end
            varargin{ct} = noise2meas(m);
         end
      end
   end
   opt = bodeoptions;
   opt.FreqScale = 'linear';
   opt.FreqUnits = 'Hz';
   opt.MagScale = 'linear';
   opt.MagUnits = 'dB';
   if AllTsModel
      opt.PhaseVisible = 'off';
   end
   bode(varargin{:},opt)
elseif no<=3
   [amp,phas,w] = bode(varargin{:});
   w = w/2/pi;
else
   [amp,phas,w,sdamp,sdphas] = bode(varargin{:});
   w = w/2/pi;
end
