% Draw
figure
subplot(2,1,1)
h = plot(IsoBinned.cursorposbin(1,1),0,'o','MarkerSize',5,'MarkerFaceColor','b');
set(h,'EraseMode','normal');
xlim([-15,15]);
ylim([-15,15]);
rectangle('Position',[8,-1,2,2])
rectangle('Position',[6,-1,2,2])
rectangle('Position',[4,-1,2,2])
rectangle('Position',[-6,-1,2,2])
rectangle('Position',[-8,-1,2,2])
rectangle('Position',[-10,-1,2,2])
rectangle('Position',[-1,-1,2,2])


subplot(2,1,2);
hE1 = plot(IsoBinned.timeframe(1,1),IsoBinned.emgdatabin(1,2),'bx', 'MarkerSize', 8);
hold on
hE2 = plot(IsoBinned.timeframe(1,1),IsoBinned.emgdatabin(1,3),'gx', 'MarkerSize', 8);
set(hE1,'EraseMode','none');
set(hE2,'EraseMode','none');
xlim([0,15]);
ylim([-15,15]);


i = 1;
for i = 70:120%length(IsoBinned.cursorposbin(:,1))
    set(h,'XData',IsoBinned.cursorposbin(i,1));
    set(hE1, 'XData', IsoBinned.timeframe(i,1), 'YData',IsoBinned.emgdatabin(i,2));
    set(hE2, 'XData', IsoBinned.timeframe(i,1), 'YData',IsoBinned.emgdatabin(i,3));
    drawnow;
   
    %pause(0.01);
    %refreshdata(hE, 'caller')
    
     pause(0.1);
    i = i+1;
    
end



