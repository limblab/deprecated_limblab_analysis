function [p_i] = findPhaseIndex(PhaseMat)

% factors to consider
% phase precision (Phase col 2,3), spike bin size

Phases(:,1) = [0 : pi/4 : pi, -pi : pi/4 : -pi/4];
Phases(:,2) = Phases(:,1) - (22.5 *(pi/180));
Phases(:,3) = Phases(:,1) + (22.5 *(pi/180));

fprintf('Phases being used are: \n')
Phases * (180/pi)

p_i = cell(256,1);

for p = 1:size(Phases,1)
    for i = 1:size(PhaseMat,2)
        for v = 1:size(PhaseMat,1)
            if p == 5
                %This is for the case where phase equals 180 (pi).  The
                %hilbert transform flips the phase once it gets past 180
                %and becomes -180 (-pi), so angles above 180 are negative,
                %and below them they are positive.
                phaseLow1= Phases(p,2) < PhaseMat(v,i,:) ~=0;
                phaseHigh1 = PhaseMat(v,i,:) < Phases(p,3) ~=0;
                InPhase1 = phaseLow1;
                InPhase1(phaseHigh1 == 0) = 0;
                
                phaseLow2= Phases(p+1,2) < PhaseMat(v,i,:) ~=0;
                phaseHigh2 = PhaseMat(v,i,:) < Phases(p+1,3) ~=0;
                InPhase2 = phaseLow2;
                InPhase2(phaseHigh2 == 0) = 0;
                
                InPhase = InPhase2;
                InPhase(InPhase1 == 1) = 1;
                
                p_i{v}(i,p,:) = InPhase;
                clear InPhase
            elseif p ==6
                % Phase 5 and 6 correspond to 180 and -180 (taken care of
                % in previous step.
                continue
            else
                if p < 5
                    phaseLow= Phases(p,2) < PhaseMat(v,i,:) ~=0;
                    phaseHigh = PhaseMat(v,i,:) < Phases(p,3) ~=0;
                    InPhase = phaseLow;
                    InPhase(phaseHigh == 0) = 0;
                    
                    p_i{v}(i,p,:) = InPhase;
                    clear InPhase
                else % Lazy way of keeping phase index appropriate (since
                    % we skip p =6 because it is the same step as p =5
                    phaseLow= Phases(p,2) < PhaseMat(v,i,:) ~=0;
                    phaseHigh = PhaseMat(v,i,:) < Phases(p,3) ~=0;
                    InPhase = phaseLow;
                    InPhase(phaseHigh == 0) = 0;
                    
                    p_i{v}(i,p-1,:) = InPhase;
                    clear InPhase
                end
            end
        end
    end
end
end