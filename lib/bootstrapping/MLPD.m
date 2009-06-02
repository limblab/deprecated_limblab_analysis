function result = MLPD(data)
% MLPD - Fits a maxium likelihood model to C/O (or virtual C/O) reach data
%        and returns the prefrerd direction

x0 = [0.0136    0.0144    0.0157    0.0209    0.0226    0.0211    0.0194    0.0160    0.1874];
fminsearch(@logP,x0,[],spikeMatrix(1,nGood))

function logProbability=logP(x, spikeMatrix)
    % X is the guess of the model parameters.  For N reach directions,
    % X(1:N) is the guessed firing rate for reaches for directions 1-N.
    % X(N+1) is SIGMA, an error term.
    sigma = x(end);
    unitLookUp = x(1:end-1);
    
    spikeMatrix=spikeMatrix(1:length(unitLookUp));
    
    logP1=sum((spikeMatrix-unitLookUp).^2/sigma^2);
    logP2=length(spikeMatrix)*log(abs(sigma));

    logProbability=logP1+logP2;
end

end