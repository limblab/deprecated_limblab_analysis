% clear; close all; clc;
figure
[ndata, headertext] = xlsread('tikimap.xls', 'coor');
xtra=strmatch('name', headertext);
for i =1 : length(xtra);
    pen(i)=(ndata(xtra(i),1));
    lenti(i)=length(ndata(xtra(i)+2,:))-(length(find(isnan(ndata(xtra(i)+2,:))==1)));

end

CMS=[17.1,-6.9];

CMM=[59.1,54.3];

ang=24;


subplot(2,3,1)
hold on;
for v =1 :  length(xtra)
  
for i =1 : lenti(v)
    
  text(CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),CMS(2)-(CMM(2)-(ndata(xtra(v)+1,2))),num2str(pen(v)))
    plot(CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),CMS(2)-((CMM(2)-(ndata(xtra(v)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(v)+1,3))-(ndata(xtra(v)+2,i)))),char(headertext(xtra(v)+3,i+1)),...
        'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
   'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
  

end
end
grid on
hold off

xlabel('AP');
ylabel('ML');


subplot(2,3,4:6)
hold on;
for v =1 :  length(xtra)
  
for i =1 : lenti(v)
    
  text(CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),CMS(2)-(CMM(2)-(ndata(xtra(v)+1,2))),num2str(pen(v)))
    plot3(CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),CMS(2)-((CMM(2)-(ndata(xtra(v)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(v)+1,3))-(ndata(xtra(v)+2,i)))),((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3))),char(headertext(xtra(v)+3,i+1)),...
        'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
   'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
  

end
end
grid on
hold off

xlabel('AP');
ylabel('ML');
zlabel('Ht')


subplot(2,3,2)
hold on;
for v =1 :  length(xtra)
  
for i =1 : lenti(v)
    
  text(CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),0,num2str(pen(v)))
    plot(CMS(1)-(ndata(xtra(v)+1,1)-(CMM(1))),((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3))),char(headertext(xtra(v)+3,i+1)),...
        'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
   'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
  

end
end
grid on
hold off

xlabel('AP');
ylabel('Ht')
subplot(2,3,3)
hold on;
for v =1 :  length(xtra)
  
for i =1 : lenti(v)
    
  text(CMS(2)-(CMM(2)-(ndata(xtra(v)+1,2))),0,num2str(pen(v)))
    plot(CMS(2)-((CMM(2)-(ndata(xtra(v)+1,2)))*cosd(ang))+(sind(ang)*((ndata(xtra(v)+1,3))-(ndata(xtra(v)+2,i)))),((ndata(xtra(v)+2,i))-(ndata(xtra(v)+1,3))),char(headertext(xtra(v)+3,i+1)),...
        'MarkerFaceColor',char(headertext(xtra(v)+4,i+1)),...
   'MarkerEdgeColor',char(headertext(xtra(v)+4,i+1)));
  

end
end
grid on
hold off

xlabel('ML');
ylabel('Ht');
