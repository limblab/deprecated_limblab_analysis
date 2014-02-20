function [p_i] = binAmpByPhase(PhaseMat,AmpMat)

% factors to consider
% phase precision (Phase col 2,3), spike bin size

Phases(:,1) = [0 : pi/8 : pi, -pi : pi/8 : -pi/4];
Phases(:,2) = Phases(:,1) - (11.25 *(pi/180));
Phases(:,3) = Phases(:,1) + (11.25 *(pi/180));

fprintf('Phases being used are: \n')
Phases * (180/pi)

for p = 1:size(Phases,1)
    if p == size(Phases,1)/2+1
        %This is for the case where phase equals 180 (pi).  The
        %hilbert transform flips the phase once it gets past 180
        %and becomes -180 (-pi), so angles above 180 are negative,
        %and below them they are positive.
        phaseLow1= Phases(p,2) < PhaseMat ~=0;
        phaseHigh1 = PhaseMat < Phases(p,3) ~=0;
        InPhase1 = phaseLow1;
        InPhase1(phaseHigh1 == 0) = 0;
        
        phaseLow2= Phases(p+1,2) < PhaseMat ~=0;
        phaseHigh2 = PhaseMat < Phases(p+1,3) ~=0;
        InPhase2 = phaseLow2;
        InPhase2(phaseHigh2 == 0) = 0;
        
        InPhase = InPhase2;
        InPhase(InPhase1 == 1) = 1;
        
        % Here is where you pick out the amplitudes at a
        % certain phase
        AmpMatTemp = AmpMat;
        AmpMatTemp(InPhase == 0) = [];
        
        %Randomly shuffling phases to check for errors in my
        %analysis
        %                 InPhase1D = squeeze(InPhase);
        %                 InPhaseShift = [InPhase1D randsample(1:size(InPhase1D,1),size(InPhase1D,1))'];
        %                 shiftPhase = sortrows(InPhaseShift,2);
        %                 InPhase(1,1,:) = shiftPhase(:,1);
        
        p_i(p) = mean(abs(AmpMatTemp));
        clear InPhase AmpMatTemp
    elseif p ==size(Phases,1)/2+2
        % Phase 5 and 6 correspond to 180 and -180 (taken care of
        % in previous step.
        continue
    else
        if p < size(Phases,1)/2+1
            phaseLow= Phases(p,2) < PhaseMat ~=0;
            phaseHigh = PhaseMat < Phases(p,3) ~=0;
            InPhase = phaseLow;
            InPhase(phaseHigh == 0) = 0;
            
            % Here is where you pick out the amplitudes at a
            % certain phase
            AmpMatTemp = AmpMat;
            AmpMatTemp(InPhase == 0) = [];
            
            %Randomly shuffling phases to check for errors in my
            %analysis
            %                     InPhase1D = squeeze(InPhase);
            %                     InPhaseShift = [InPhase1D randsample(1:size(InPhase1D,1),size(InPhase1D,1))'];
            %                     shiftPhase = sortrows(InPhaseShift,2);
            %                     InPhase(1,1,:) = shiftPhase(:,1);
            
            p_i(p) = mean(abs(AmpMatTemp));
            clear InPhase AmpMatTemp
        else % Lazy way of keeping phase index appropriate (since
            % we skip p =6 because it is the same step as p =5
            phaseLow= Phases(p,2) < PhaseMat ~=0;
            phaseHigh = PhaseMat < Phases(p,3) ~=0;
            InPhase = phaseLow;
            InPhase(phaseHigh == 0) = 0;
            
            % Here is where you pick out the amplitudes at a
            % certain phase
            AmpMatTemp = AmpMat;
            AmpMatTemp(InPhase == 0) = [];
            
            %Randomly shuffling phases to check for errors in my
            %analysis (see if its an artifact of something else)
            %                     InPhase1D = squeeze(InPhase);
            %                     InPhaseShift = [InPhase1D randsample(1:size(InPhase1D,1),size(InPhase1D,1))'];
            %                     shiftPhase = sortrows(InPhaseShift,2);
            %                     InPhase(1,1,:) = shiftPhase(:,1);
            
            p_i(p-1) = mean(abs(AmpMatTemp));
            clear InPhase AmpMatTemp
        end
        
    end
end