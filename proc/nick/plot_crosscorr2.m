function plot_crosscorr2(spikes,kinematics,numLags,states)
% plot_crosscorr2(spikes,kinematics,numLags,states)
%
% plots crosscorrelation between spikes and kinematics for zero to numlags 
% lags using the DuplicateAndShift function.

numUnits = size(spikes,2);
numDims = size(kinematics,2);
% numStates = 2;
dupSpikes = DuplicateAndShift(spikes,2*numLags+1);
dupKin = DuplicateAndShift(kinematics,2*numLags+1);
dimNames = ['x pos'; 'y pos'; 'x vel'; 'y vel'; 'speed'; 'x acc'; 'y acc'; 'd spd'];
stateNames = [' all'; 'move'; 'post'];

figure;
for b = 1:numDims
    for c = 1:2*numLags+1
        temp = corrcoef(dupKin(numLags+1:end,(b-1)*(2*numLags+1) + c),kinematics(1:end-numLags,b));
        cc0(c) = temp(1,2);
        temp = corrcoef(dupKin([false(numLags,1); states(1:end-numLags)],(b-1)*(2*numLags+1) + c),kinematics([states(1:end-numLags); false(numLags,1)],b));
        cc1(c) = temp(1,2);
        temp = corrcoef(dupKin([false(numLags,1); ~states(1:end-numLags)],(b-1)*(2*numLags+1) + c),kinematics([~states(1:end-numLags); false(numLags,1)],b));
        cc2(c) = temp(1,2);
    end
    subplot(3,numDims,b)
    plot([-numLags numLags],[0 0],'b',-numLags:numLags,cc0,'r');
    axis([-numLags numLags -1 1])
    title(dimNames(b,:))
    if b == 1
        ylabel(stateNames(1,:))
    end
    subplot(3,numDims,numDims + b)
    plot([-numLags numLags],[0 0],'b',-numLags:numLags,cc1,'r');
    axis([-numLags numLags -1 1])
    if b == 1
        ylabel(stateNames(2,:))
    end
    subplot(3,numDims,2*numDims + b)
    plot([-numLags numLags],[0 0],'b',-numLags:numLags,cc2,'r');
    axis([-numLags numLags -1 1])
    if b == 1
        ylabel(stateNames(3,:))
    end
end          

clear cc0 cc1 cc2;
for a = 1:10%numUnits
    figure;
    for b = 1:numDims
        for c = 1:2*numLags+1
            temp = corrcoef(dupSpikes(numLags+1:end,(a-1)*(2*numLags+1) + c),kinematics(1:end-numLags,b));
            cc0(c) = temp(1,2);
            temp = corrcoef(dupSpikes([false(numLags,1); states(1:end-numLags)],(a-1)*(2*numLags+1) + c),kinematics([states(1:end-numLags); false(numLags,1)],b));
            cc1(c) = temp(1,2);
            temp = corrcoef(dupSpikes([false(numLags,1); ~states(1:end-numLags)],(a-1)*(2*numLags+1) + c),kinematics([~states(1:end-numLags); false(numLags,1)],b));
            cc2(c) = temp(1,2);
        end
    subplot(3,numDims,b)
    plot([-numLags numLags],[0 0],'r',-numLags:numLags,cc0,'b');
    axis([-numLags numLags -0.3 0.3])
    title(dimNames(b,:))
    if b == 1
        ylabel(stateNames(1,:))
    end
    subplot(3,numDims,numDims + b)
    plot([-numLags numLags],[0 0],'r',-numLags:numLags,cc1,'b');
    axis([-numLags numLags -0.3 0.3])
    if b == 1
        ylabel(stateNames(2,:))
    end
    subplot(3,numDims,2*numDims + b)
    plot([-numLags numLags],[0 0],'r',-numLags:numLags,cc2,'b');
    axis([-numLags numLags -0.3 0.3])
    if b == 1
        ylabel(stateNames(3,:))
    end
    end
end          