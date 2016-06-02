function [forceAve, varargout] = manStimForceAve(bdf, timeBefore, timeAfter, plotflag)

    stimChans = unique(bdf.stim(:,2))';
    numChans  = length(stimChans);
    numForce  = size(bdf.force.data,2);
    forceAve  = zeros((timeBefore+timeAfter)*bdf.force.forcefreq+1,numForce,numChans);
    nStim     = zeros(1,numChans);
    peakForce = zeros(1,numForce-1,numChans);
    stimBins  = zeros(size(bdf.force.data,1),1);
    
    
    for chan = 1:numChans
        disp(sprintf('Averaging Force Evoked from Stim ch %g',stimChans(chan)));
        stimStart   = bdf.stim((bdf.stim(:,2)==stimChans(chan) & bdf.stim(:,3) > 0),1);
        stimStop    = bdf.stim((bdf.stim(:,2)==stimChans(chan) & bdf.stim(:,3)== 0),1);
        stimDur     = mean(stimStop-stimStart);
        nStim(chan) = length(stimStart);
        for i = 1:nStim(chan)
            stimIdx  = find(bdf.force.data(:,1)>= stimStart(i) & bdf.force.data(:,1) <= stimStop(i));
            stimBins(stimIdx) = ones(length(stimIdx),1);
        end

        % Get average response
        forceAve(:,:,chan) = STA(stimStart,bdf.force.data,timeBefore,timeAfter);

        % Force baseline at time 0 and find peak during stimulation period
        baseline_window = timeBefore*bdf.force.forcefreq;
        peak_window     = timeBefore*bdf.force.forcefreq : (timeBefore+stimDur)*bdf.force.forcefreq ;

        baselines = forceAve(baseline_window,2:end,chan);

        %find absolute peak
        for i = 1:numForce-1
            windowedData = forceAve(peak_window,i+1,chan)-baselines(i);
            absMaxIdx    = find(abs(windowedData)==max(abs(windowedData)),1,'first');
            peakForce(1,i,chan)   = windowedData(absMaxIdx);
        end
        
        if plotflag
            figure;
            plot(forceAve(:,1,chan),forceAve(:,2:end,chan));
            legend(strrep(bdf.force.labels,'Force_',''));
            [pathstr,filename] = fileparts(bdf.meta.filename);
            title(sprintf('File %s\n Stim chan : [%g]',filename,stimChans(chan)));
            yTop = ylim; yTop = yTop(2)*0.9;
            text('String',[ 'Peak Force : ' sprintf('%.0f mV ',peakForce(1,:,chan))],...
                 'Position',[0 yTop],'fontsize',12);
        end
            
        
    varargout = { stimChans, nStim, peakForce };
    
    end
    
    if plotflag
        figure;
        plot(bdf.force.data(:,1),bdf.force.data(:,2:end));
        scaleFactor = max(max(bdf.force.data(:,2:end)));
        hold on;
        plot(bdf.force.data(:,1),stimBins*scaleFactor,'k');
    end      

end
