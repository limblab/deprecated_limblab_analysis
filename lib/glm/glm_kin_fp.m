function [b, dev, stats] = glm_kin_fp(bdf, chan, band, offset, mdl)
% GLM_KIN_fp fits the kinematic glm model to the requested field potential
%
%   B = GLM_KIN(BDF, CHAN, UNIT, OFFSET) returns B the vector of glm
%       weights for the fit GLM for the specified CHANnel and BAND
%       in the supplied BDF structure.  BAND should be a vector of [bandstart bandend]
%       Offset will shift the LFP
%       relative to the kinematics. (Negative Offset means LFP leads
%       kinematics, the same as in PDs_from_LFPs.m)
%
%   [B, DEV, STATS] = GLM_KIN( ... ) also returns DEV and STATS from glmfit
%
%   [B, DEV, STATS, L, L0] = GLM_KIN( ... ) also returns the negative log
%       liklihood L of the model fit given the spike train and L0 the
%       negative log liklihood under the null hypothesis of constant firing
%       rate.
%
%   [B ... ] = GLM_KIN(BDF, CHAN, UNIT, OFFSET, MDL) will use the speficied
%       model MDL as follows:
%         'pos'    -- position only (X, Y)
%         'vel'    -- velocity and speed (Vx, Vy, sqrt(Vx^2 + Vy^2)
%         'posvel' -- full kinematic model (X, Y, Vx, Vy, sqrt(Vx^2 + Vy^2)
%         'nospeed' -- no speed term (X, Y, Vx, Vy)

% $:Id $

if nargin < 5
    mdl = 'posvel';
end

ts = 256; % time step (ms)

vt = bdf.vel(:,1);
samprate=bdf.raw.analog.adfreq(chan);
lfp=bdf.raw.analog.data{chan};
% t = vt(floor(vt*ts)==vt*ts);
t = vt(1):ts/samprate:vt(end);
% spike_times = get_unit(bdf,chan,unit)-offset;
% spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
% s = train2bins(spike_times, t);
freqs=linspace(0,samprate/2,ts/2+1);
% freqs=freqs(2:end);
bandinds = freqs>=band(1) & freqs<=band(2); %To get 0-4 Hz case, use 0.1 instead of 0; 0 is DC
%hanning window
win=hanning(ts+1);
for i=1:length(t)
    rt=t(i);
    LFPsample=lfp((rt-offset)*samprate:(rt-offset)*samprate+ts); %use hanning window
    LFPsample=win.*LFPsample;
    ftlfp(i,:)=fft(LFPsample)';
end
powmat=ftlfp.*conj(ftlfp)*.75;  %factor of .75 is for hanning window
% Pmean=mean(powmat,1);   %Take mean over all bins
% logpow = 10*(log10(powmat));%-repmat(log10(Pmean),[length(t),1]));
bandpow = mean(powmat(:,bandinds),2);
glmv = interp1(bdf.vel(:,1),bdf.vel(:,2:3),t);
glmx = interp1(bdf.pos(:,1),bdf.pos(:,2:3),t);

if strcmp(mdl, 'pos')
    glm_input = glmx;
elseif strcmp(mdl, 'vel')
    glm_input = [glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'posvel')
    glm_input = [glmx glmv sqrt(glmv(:,1).^2 + glmv(:,2).^2)];
elseif strcmp(mdl, 'nospeed')
    glm_input = [glmx glmv];
else
    error('unknown model: %s', mdl);
end

[b, dev, stats] = glmfit(glm_input, bandpow, 'gamma');

% if nargout > 3
%     lambda = glmval(b, glm_input, 'log');
%     L = sum(log(lambda.^(s')) - lambda - log(factorial(s')));
% end
% 
% if nargout > 4
%     lambda = sum(s)/length(s);
%     L0 = sum(log(lambda.^(s')) - lambda - log(factorial(s')));
% end
