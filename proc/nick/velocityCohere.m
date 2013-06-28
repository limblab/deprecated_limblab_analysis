function [Cx, Cy, Cfreq] = velocityCohere(binnedData, decoder, window, genplot)
% [Cx, Cy, Cfreq] = velocityCohere(binnedData, decoder, window, genplot)
%
% Calculates a predicted velocity based on spike inputs in binnedData and
% filter coefficients in decoder, then computes the transfer function
% between the original velocity (input) and predicted velocity (output).
% This function uses the TFESTIMATE function, which divides data into
% segments of length WINDOW and calculates the TF using Welch's averaged 
% modified periodogram method.
%
% BINNEDDATA contains the spike data and original velocities.
% DECODER should be a wiener filter decoder file.
% WINDOW indicates the number of data points to use for each calculation.
%   Default is 128.
% GENPLOT indicates whether to generat a plot of the FIR in x and y.
%   Default is 0.

% check inputs
if (nargin < 2 || nargin > 4)
    disp('wrong number of inputs')
    return
end
if(nargin < 4)
    genplot = 0;
    if(nargin == 2)
        window = 128;
    end
end

% set paths to include necessary functions
if (exist('BMI_analysis','dir') ~= 7)
    load_paths; % for predictSignals and DuplicateAndShift
end

% transpose P matrix in decoder if necessary
if size(decoder.P,1) ~= size(binnedData.velocbin,2)
    decoder.P = decoder.P';
end

% calculate sampling frequency
Fs = round(1/(binnedData.timeframe(2)-binnedData.timeframe(1)));

% predict velocity
pred = predictSignals(decoder,binnedData);
startindex = length(binnedData.velocbin) - length(pred.preddatabin) + 1;

[Cx,Cfreq] = mscohere(binnedData.velocbin(startindex:end,1),pred.preddatabin(:,1),window,[],[],Fs);
[Cy,Cfreq] = mscohere(binnedData.velocbin(startindex:end,2),pred.preddatabin(:,2),window,[],[],Fs);

% code for plotting figure:
% plot TF
if genplot
    
    figure;
    plot(Cfreq,Cx,'b',Cfreq,Cy,'r')
    grid on
    legend('x','y')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude Squared')
    title('Coherence')
    
end