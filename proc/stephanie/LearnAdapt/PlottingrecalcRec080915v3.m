%tr=['062113';'062813';'071213';'071813';'072613'];

%need to load RadialP2Ptest (variables included are P2PMDowdenAllLevelp5, P2PMAll, Rect, and RecP, DowP, SelP)
%load('C:\Users\Natalie\Desktop\NHPINVIVO\P5\RadialP2Ptest.mat')

figure
coltr='kbmgcry';
for n=1:1; %radial nerve
    %subplot(1,2,n)
    hold on
    
    for tr=1:5;
        SelD= max(P2PMDowdenAllLevelp5{n}{tr},[],2);
        SelC=  max(P2PMAll{n}{tr},[],2);
        
        scatter(SelD,SelC,strcat('o',coltr(tr)),'filled')
        text(SelD,SelC,num2str([1:length(SelD)]'))
        xlabel('Dowden')
        ylabel('Standard')
        axis square
        axis([0 1 0 1])
    end
    
    legend('tr 1','tr 2','tr 3','tr 4','tr 5')
    plot([0 1],[0 1],'k')
end

%TESTING values
figure
%tr is the color order from the scatter which is the date order ['062113';'062813';'071213';'071813';'072613']
%f is the file number in that day and is the number at each scatter point

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tr=3;f=25; %CHANGE the trial date (tr, color) and f (number of rec file for that day)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hold on;
%legend
scatter(SelP{n}{tr}{f}(1),SelP{n}{tr}{f}(2),'ok','filled');scatter(DowP{n}{tr}{f}(1),DowP{n}{tr}{f}(4),'ob','filled');
legend('Func Sel','Dowden Sel')

%Recruitment curves from testing scatter point
[rr cr]=size(RecP{n}{tr}{f});
for m=1:rr;
    hold on
    plot(Rect{n}{tr}{f},RecP{n}{tr}{f}(m,:),strcat(coltr(m),'.-'));
    hold off
end

%Vertical lines at sel locations
hold on;
plot([0 max(Rect{n}{tr}{f})],[.2 .2],'k');plot([0 max(Rect{n}{tr}{f})],[.5 .5],'b')% %Dowden EMGlevel vertical line
plot([SelP{n}{tr}{f}(1) SelP{n}{tr}{f}(1)],[0 1],':k');plot([DowP{n}{tr}{f}(1) DowP{n}{tr}{f}(1)],[0 1],':b')% Sel .2 neighbor vertical line

%Selectivity values
scatter(SelP{n}{tr}{f}(1),SelP{n}{tr}{f}(3),100,'ok','filled'); scatter(DowP{n}{tr}{f}(1),DowP{n}{tr}{f}(4),100,'ob','filled');

%Selectivity values and muscle of interest numbers used to calculate the
%selectivity values
text(DowP{n}{tr}{f}(1),DowP{n}{tr}{f}(2),num2str(round(DowP{n}{tr}{f}(2)*100)/100),'Color','b'); %second largest EMG in dowden
text(DowP{n}{tr}{f}(1),DowP{n}{tr}{f}(3),num2str(round(DowP{n}{tr}{f}(3)*100)/100),'Color','b'); %largest EMG in dowden closet to EMGlevel
text(DowP{n}{tr}{f}(1),DowP{n}{tr}{f}(4),num2str(round(DowP{n}{tr}{f}(4)*100)/100),'Color','b'); %Dowden Sel value
text(SelP{n}{tr}{f}(1),SelP{n}{tr}{f}(2),num2str(round(SelP{n}{tr}{f}(2)*100)/100)); %neighbor max at .2
text(SelP{n}{tr}{f}(1),SelP{n}{tr}{f}(3),num2str(round(SelP{n}{tr}{f}(3)*100)/100)); %EMG max at neighbor closest to .2

title(strcat('tr ',num2str(tr),', f ',num2str(f))) %Testing scatter point
