function neurFR96 = FRfromEMGs(emgs)
%generate 96 channels of fake neural data related to different parameters of the 'outs' signals

numNeur  = 96;
[numPts,numEMGs] = size(emgs);
neurFR96 = zeros(numPts,numNeur);
% 
% pos    = pos./repmat(max(pos),numPts,1);
% vel    = [0 0;diff(pos)];
% vel    = vel./repmat(max(vel),numPts,1);
% theta  = atan2(pos(:,2),pos(:,1));
% magVel = sqrt(sum(vel.^2,2));
% magVel = magVel./repmat(max(magVel),numPts,1);
% 
% 
% acc    = [0 0;diff(vel)];
% acc    = acc./repmat(max(acc),numPts,1);
% magAcc = sqrt(sum(acc.^2,2));
% magAcc = magAcc./repmat(max(magAcc),numPts,1);

% BaselineFR, 10-60 Hz
BaseFR   = 10+50*rand(1,96);
% PDs    = 2*pi()*rand(1,96); %prefered directions

%Scale FR with xPos, yPos, theta, magVel, magAcc
%random weights for each factor for each neuron.
%Weigths are between -10 and + 10 for each param
FRfactors = 60*(rand(numEMGs,96)-0.5);

for p = 1:numPts
   
    %EMG Contribution
    FR = emgs(p,:) * FRfactors;

%     %Directional tuning
%     TunFR = cos(theta(p)-PDs) .* FRfactors(3,:);
%     
%     %Velocity magnitude
%     VelFR = magVel(p) * FRfactors(4,:);
%     
%     %Acceleration
%     AccFR = magAcc(p) * FRfactors(5,:);
%     
%     %Combine
%     FR = BaseFR + PosFR + TunFR + VelFR + AccFR;
    
    %Add noise
    FR = BaseFR + FR + 60*rand(1,96);
    
    %Discretize
    FR = 20*round(FR/20);
    
    %Remove negative FR
    neurFR96(p,FR>=0) = FR(FR>=0);
    
end

