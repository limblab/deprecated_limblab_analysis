function f = fun_des_force_sampling(x,S,mF,mDir,fdes,stim,stdM,obsN,xMin,c)

% Compute muscle forces from activations
muscF = zeros(length(x),1); amps = zeros(length(x),1);
for ii = 1:length(x)
    if x(ii) < xMin(ii)
        muscF(ii) = 0;
        amps(ii) = 0;
    else
        muscF(ii) = x(ii)*mF(ii);
        % Invert recruitment curve using current activation x(ii) to get current command
        amps(ii) = invert_rcurve_sampling(muscF(ii),S(ii));
    end
end

% Compute resultant force vector using all muscles and average directions
fhat = zeros(2,1);
fX = muscF.*cos(mDir'); fY = muscF.*sin(mDir');
fhat(1) = sum(fX);
fhat(2) = sum(fY);

% Sum squared variance at given activations
sig1 = zeros(length(x),1); sig2 = zeros(length(x),1);
fXold = 0; fYold = 0; covarAll = zeros(2,2); covarAllObs = zeros(2,2); fvecG = zeros(length(x),2);
for ii = 1:length(x)
    % Interpolate at given amplitude to get standard deviation of rcurves
    if amps(ii) < stim(1,ii)
        sig1(ii) = stdM(1,ii);
    elseif amps(ii) > stim(end,ii)
        sig1(ii) = stdM(end,ii);
    else
        sig1(ii) = interp1(stim(:,ii),stdM(:,ii),amps(ii));
    end
    
    % Interpolate at given amplitude to get standard deviation of obs noise
    TFampsO = ~isnan(obsN.amps(:,ii));
    ampsO = obsN.amps(TFampsO,ii);
    noiseO = obsN.noise(TFampsO,ii);
    if amps(ii) < ampsO(1)
        sig2(ii) = noiseO(1);
    elseif amps(ii) > ampsO(end)
        sig2(ii) = noiseO(end);
    else
        sig2(ii) = interp1(ampsO,noiseO,amps(ii));
    end
    
    % Individual muscles forces and their scalar variance
    if ii>1
        fXnew = sum(fX(1:ii));
        fYnew = sum(fY(1:ii));
        fXold = sum(fX(1:ii-1));
        fYold = sum(fY(1:ii-1));
    else
        fXnew = sum(fX(1:ii));
        fYnew = sum(fY(1:ii));
        fXold = 0;
        fYold = 0;
    end
    fvec = zeros(2,1);
    fvec(1) = fXnew-fXold;
    fvec(2) = fYnew-fYold;
    
    if ~sum(fvec)==0
        fvec = fvec/norm(fvec);
        U = [fvec(1) -fvec(2); fvec(2) fvec(1)];
        covarMusc = U*[sig1(ii) 0; 0 0]*inv(U);
        covarMuscObs = U*[sig2(ii) 0; 0 0]*inv(U);
        
        % Store covariance matrix
        covarAll = covarAll + covarMusc; 
        covarAllObs = covarAllObs + covarMuscObs;
    end
end
% Add two sources of variability together
covarTot = covarAll + covarAllObs;

% Cost function
R = c(1)*eye(length(x));
Q = eye(2)*c(2);
f = x'*R*x + (fhat-fdes)'*Q*(fhat-fdes) + trace(covarTot*Q);

