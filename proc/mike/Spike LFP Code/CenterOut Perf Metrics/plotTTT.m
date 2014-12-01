BC_I = 34:41
xInd = 1:size(BC_I,2)
for i = 1:size(Trials,2)
    if isfield(Trials{ControlCh,i},'TTT')
        if isfield(Trials{ControlCh,i},'Fail_Path_MO')
            meanTTT(i) = mean([Trials{ControlCh,i}.TTT ones(1, size(Trials{ControlCh,i}.Fail_Path_MO,2))*10])
            steTTT(i)  = std( [Trials{ControlCh,i}.TTT ones(1, size(Trials{ControlCh,i}.Fail_Path_MO,2))*10])/sqrt(length(Trials{ControlCh,i}.TTT))
        else
            meanTTT(i) = mean(Trials{ControlCh,i}.TTT);
            steTTT(i) = std(Trials{ControlCh,i}.TTT)/sqrt(length(Trials{ControlCh,i}.TTT))
        end
    else
        continue
    end
end


[FileList, DateNames] = CalcDecoderAge(Mini_Ch39_Gam3X_SpikeY, ['09-09-2014']) 

for i = 2:length(DateNames)
    if strcmpi(DateNames{i-1},DateNames{i}) == 0
        NewDay(i) = 1;
    else
        NewDay(i) = 0;
    end
end
figure
shadedErrorBar(xInd,meanTTT(BC_I),steTTT(BC_I),'b')
hold on
k = 1;
for i = BC_I(1):BC_I(end)
    
    if NewDay(i) == 1
        plot([k k],[0 100],'k--')
    end
    k = k+1;
end
%     set(ax(1),'Xlim',[0 500])
     set(gca,'XTick',[1,3,5,7,9,11,13,15,17],'XTickLabel',{'10','30','50','70','90','110','130','150','170'})
     set(gca,'XTick',[2,4,6,8],'XTickLabel',{'20','40','60','80'})
     
     ylabel('Time to Target')
     xlabel('Minutes of Exposure to ONF')
     ylabel('Percent Success')
     
%     set(H(1),'Color','b')
%     set(ax(2),'Xlim',[0 500])
%     set(ax(2),'XTick',[0,250,500],'XTickLabel',{'-0.25','0','.25'})
%     set(H(2),'LineWidth',3.0)
% if i == BC_Ind
%     title('Brain Control')
% end
ah = findobj(gca,'TickDirMode','auto')
set(ah,'Box','off')
set(ah,'TickLength',[0,0])

% legend('High Gamma 200-300 Hz','Spikes')