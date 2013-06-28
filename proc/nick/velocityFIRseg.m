function [FIRx, FIRy] = velocityFIRseg(binnedData, decoder, num_lags, num_sides, genplot, numSegs)
% [FIRx, FIRy] = velocityFIR(binnedData, decoder, num_lags, num_sides, plot, numSegs)
%
% Calculates a predicted velocity based on spike inputs in binnedData and
% filter coefficients in decoder, then computes the finite impulse response
% function between the original velocity (input) and predicted velocity
% (output) for small segments and averages together.
%
% BINNEDDATA contains the spike data and original velocities.
% DECODER should be a wiener filter decoder file.
% NUM_LAGS indicates the length of the finite impulse reponse function.
%   Default is 20.
% NUM_SIDES indicates whether the FIR should be causal in nature.
%   (1 - causal, 2 - acausal) Default is 1.
% GENPLOT indicates whether to generat a plot of the FIR in x and y.
%   Default is 0.
% NUMSEGS indicates how many segments to divide data in for averaging.
%  Default is 1.

% check inputs
if (nargin < 2 || nargin > 6)
    disp('wrong number of inputs')
    return
end
if(nargin < 6)
    numSegs = 1;
    if(nargin < 5)
        genplot = 0;
        if (nargin < 4)
            num_sides = 1;
            if (nargin == 2)
                num_lags = 20;
            end
        end
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

% predict velocity
pred = predictSignals(decoder,binnedData);
seglength = floor(length(pred.preddatabin)/numSegs);
predstartindex = 1;
predendindex = seglength;
velstartindex = length(binnedData.velocbin) - length(pred.preddatabin) + 1;
velendindex = velstartindex + seglength - 1;

FIRx = zeros(numSegs,num_lags+1);
FIRy = zeros(numSegs,num_lags+1);

for seg = 1:numSegs
    % alternative method of calculating FIR
    % [FIR,vaf,mcc] = filMIMO3(binnedData.velocbin(startindex:end,1),pred.preddatabin(:,1),num_lags,num_sides,1);

    % calculating FIR
    if (num_sides == 1)
        xDS_vel = DuplicateAndShift(binnedData.velocbin(velstartindex:velendindex,1),num_lags+1);
        FIRx(seg,:) = (xDS_vel\pred.preddatabin(predstartindex:predendindex,1))';

        yDS_vel = DuplicateAndShift(binnedData.velocbin(velstartindex:velendindex,2),num_lags+1);
        FIRy(seg,:) = (yDS_vel\pred.preddatabin(predstartindex:predendindex,2))';
    else
        xDS_vel = DuplicateAndShift(binnedData.velocbin(velstartindex + num_lags/2:velendindex,1),num_lags+1);
        FIRx(seg,:) = (xDS_vel\pred.preddatabin(predstartindex:predendindex-num_lags/2,1))';

        yDS_vel = DuplicateAndShift(binnedData.velocbin(velstartindex + num_lags/2:velendindex,2),num_lags+1);
        FIRy(seg,:) = (yDS_vel\pred.preddatabin(predstartindex:predendindex-num_lags/2,2))';
    end

    if seg < numSegs
        predstartindex = predendindex + 1;
        predendindex = predendindex + seglength;
        velstartindex = velendindex + 1;
        velendindex = velendindex + seglength;
    end

end
% plot FIR
if genplot

    if num_sides == 1
        lags = (0:num_lags)*decoder.binsize;
    elseif num_sides == 2
        lags = (-(num_lags/2):num_lags/2)*decoder.binsize;
    end

    figure
    plot(lags,mean(FIRx,1),'b',lags,mean(FIRy,1),'r')
    legend('x','y')
    xlabel('lag')
    ylabel('gain')
    title('FIR')
    
end