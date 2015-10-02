% Function to plot the behavior data (cursor position or velocity) of a
% tDCS experiment. IT assumes three blocks of data


function plot_behavior_tDCS_exp( binned_data_1, binned_data_2, binned_data_3, exp_params )


switch exp_params.behavior_data
    case 'pos'
        fig_bhvr = figure;
        subplot(211), hold on
        plot(binned_data_1.timeframe,binned_data_1.cursorposbin(:,1),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.cursorposbin(:,1),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.cursorposbin(:,1),'b')
        ylabel('Cursor position X')
        
        subplot(212), hold on
        plot(binned_data_1.timeframe,binned_data_1.cursorposbin(:,2),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.cursorposbin(:,2),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.cursorposbin(:,2),'b')
        ylabel('Cursor position Y')
        
    case 'vel' 
        fig_bhvr = figure;
        subplot(211), hold on
        plot(binned_data_1.timeframe,binned_data_1.velocbin(:,1),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.velocbin(:,1),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.velocbin(:,1),'b')
        ylabel('Cursor velocity X')
        
        subplot(212), hold on
        plot(binned_data_1.timeframe,binned_data_1.velocbin(:,2),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.velocbin(:,2),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.velocbin(:,2),'b')       
        ylabel('Cursor velocity Y')
        
    case 'word'
        
        fig_bhvr = figure;
        subplot(211), hold on
        plot(binned_data_1.timeframe,binned_data_1.cursorposbin(:,1),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.cursorposbin(:,1),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.cursorposbin(:,1),'b')
        ylabel('Cursor position X')
        
        subplot(212), hold on
        plot(binned_data_1.timeframe,binned_data_1.cursorposbin(:,2),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.cursorposbin(:,2),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.cursorposbin(:,2),'b')
        ylabel('Cursor position Y')
        
        fig_bhvr2 = figure;
        subplot(211), hold on
        plot(binned_data_1.timeframe,binned_data_1.velocbin(:,1),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.velocbin(:,1),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.velocbin(:,1),'b')
        ylabel('Cursor velocity X')
        
        subplot(212), hold on
        plot(binned_data_1.timeframe,binned_data_1.velocbin(:,2),'k')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe,binned_data_2.velocbin(:,2),'r')
        plot(binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe,binned_data_3.velocbin(:,2),'b')       
        ylabel('Cursor velocity Y')
end
      


if exist('fig_bhvr','var')
    figure(fig_bhvr)
    subplot(211)
    set(gca,'FontSize',14), set(gca,'TickDir','out')
    xlim([0 binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe(end)]), 
    legend('baseline','tDCS on','tDCS off')
    subplot(212) 
    set(gca,'FontSize',14), set(gca,'TickDir','out')
    xlim([0 binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe(end)]), 
    xlabel('time (s)')
end


if exist('fig_bhvr2','var')
    figure(fig_bhvr)
    subplot(211)
    set(gca,'FontSize',14), set(gca,'TickDir','out')
    xlim([0 binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe(end)]), 
    legend('baseline','tDCS on','tDCS off')
    subplot(212) 
    set(gca,'FontSize',14), set(gca,'TickDir','out')
    xlim([0 binned_data_1.timeframe(end)+binned_data_2.timeframe(end)+binned_data_3.timeframe(end)]), 
    xlabel('time (s)')
end