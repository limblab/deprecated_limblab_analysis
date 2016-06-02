function [EstMag,EstPhase,EstOmega,EstF] = impulse_txy_decoder(Actual,Pred,varagin)
% Estimate the impulse transfer function given actual and predicted data of
% a given system.
% Actual and Pred are vector of equal size!, number of variables = number of columns
% varign: Fs = 20 Hz by default


% values by default
Fs = 20; % 0.05 ms bin = 20 Hz

if nargin==1
    Fs = varigin(1);
end


if all(size(Actual) == size(Pred))
    EstMag =[];
    EstPhase =[];
    EstOmega = [];
    EstF = [];
    num_var = size(Actual,2);
    for i=1:num_var        
    [EstHx, EstFx] = tfestimate(Actual(:,i), Pred(:,i), 128, [], [], Fs);    
    EstMag   = [EstMag,abs(EstHx)];
    EstPhase = [EstPhase,angle(EstHx)];
    EstOmega = [EstOmega,EstFx*2*pi];
    EstF = [EstF,EstFx];
    end
else
    error('Actual and Pred Data have not the sime size')
end
            

end
