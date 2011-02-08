% clear;close all; clc;
% load('allfilesPDs.mat')
alldat=allfilesPDs;
hhh=0;
% dates={'8/30/2010','9/20/2010','9/28/2010','10/5/2010','10/6/2010','10/18/2010'};
stimch=cell(1,length(dates));
stimall=cell(1,length(dates));
for i=1:length(dates)
    stimall{1,i}=ones(size(alldat{1,i},1),1);
end
% stimch{1,1}=[75, 79, 88, 91, 93, 94];
% stimch{1,2}=[36, 37, 38, 39, 41];
% stimch{1,3}=[12, 30, 44, 47];
% stimch{1,4}= [4, 6, 8,52, 63];
% stimch{1,5}= [4, 6, 8,52, 63];
% stimch{1,6}= [95,96];
diffstim=[];
diffnostim=[];
for i=1 : size(stimch,2)
    for j=1:length(stimch{1,i})
     stimall{1,i}(find(alldat{1,i}(:,1)==stimch{1,i}(j)),1)=2;
    end
end
pathnameout='\\165.124.111.234\limblab\user_folders\Boubker\PDs\';
while length(dates)>1
    NDays=[];
    NDays(1) =0;
    for i=2 :length(dates)
        NDays(i) = days360isda(dates(1,1), dates(1,i));
    end
    Du=[];
    Pd=[];
    Pdinf=[];
    Pdsup=[];
    Pdglm=[];
     
    limdiff=std(alldat{1,1}(:,12));
    Du=zeros(size(alldat{1,1},1),size(alldat,2));
    Pd=zeros(size(alldat{1,1},1),size(alldat,2));
    Pdinf=zeros(size(alldat{1,1},1),size(alldat,2));
    Pdsup=zeros(size(alldat{1,1},1),size(alldat,2));
    Pdglm=zeros(size(alldat{1,1},1),size(alldat,2));
       Pdmag=zeros(size(alldat{1,1},1),size(alldat,2));
       
        sti=zeros(size(alldat{1,1},1),size(alldat,2));
    t=0;
    
    %% look at CVs to get indexes of each unit through files
    for j =1:size(alldat{1,1},1)
        for i=1:size(alldat,2)
            
            indexunits=[];
            comp=[];
            indexunits=find(alldat{1,i}(:,1)==alldat{1,1}(j,1));
            if length(indexunits)>0
                for n=1: length(indexunits)
                    
                    comp(n)=alldat{1,1}(j,12)-alldat{1,i}(indexunits(n),12);
                end
                [A,D]=min(abs(comp));
                if  A<limdiff
                    Du(j,i)= D+indexunits(1)-1;
                end
            end
        end
    end;
    hhh=hhh+1;
    figure;
    for i=1:size(Du,1)
        
        for j=1:size(Du,2)
            if Du(i,j)>0
                Pd(i,j)=alldat{1,j}(Du(i,j),4);
                Pdinf(i,j)=alldat{1,j}(Du(i,j),3);
                Pdsup(i,j)=alldat{1,j}(Du(i,j),5);
                Pdglm(i,j)=alldat{1,j}(Du(i,j),13);
                Pdmag(i,j)=alldat{1,j}(Du(i,j),6);
                  sti(i,j)=stimall{1,j}(Du(i,j),1);
%                 if alldat{1,1}(Du(i,1),1)==
%                   sti(i,j)=alldat{1,j}(Du(i,j),6);
%                 end
            end
        end
         if Du(i,2)>0    
       de=ceil(sqrt(length(find(Du(:,2))>0)));
          t=t+1;
            % pds=
            subplot(de,de,t)
polar(0,0)            
            hold on;
            xlid=size(Du,2);
                   xli=(find(Pd(i,:)==0));
            if length(xli)>1
            xlid=xli(1)-1;
            end
        for n=1:xlid
            
             
        
           % [X,Y] = pol2cart(Pd(i,n), Pdmag(i,n));
          [X,Y] = pol2cart(Pd(i,n), 1);
          
           if sti(i,n)==2 
               compass(X,Y,'r');
         if n>1
             if sti(i,n-1)==1
             diffstim=[diffstim Pd(i,n)-Pd(i,n-1)];
             end
         end
           else
               compass(X,Y,'b');
                 if n>1
             if sti(i,n-1)==1
             diffnostim=[diffnostim Pd(i,n)-Pd(i,n-1)];
             end
         end
           end
                  
            %set(gca,'XTickLabel',int2str(NDays))
            
            title(['cha',int2str(alldat{1,1}(Du(i,1),1)),'-u',int2str(alldat{1,1}(Du(i,1),2))])
        end
hold off
    end
           
        end

            %errorbar(NDays,Pd(i,:),Pd(i,:)-Pdinf(i,:),Pdsup(i,:)-Pd(i,:),'.k')
%                errorbar(NDays,Pd(i,:)+2*pi,Pd(i,:)-Pdinf(i,:),Pdsup(i,:)-Pd(i,:),'.')
%                errorbar(NDays,Pd(i,:)-2*pi,Pd(i,:)-Pdinf(i,:),Pdsup(i,:)-Pd(i,:),'.g')
          % 'MarkerSize',20)
%             plot(NDays,Pdglm(i,:),'sk');
            
%               plot(NDays,Pdglm(i,:)+2*pi,'s');
%                 plot(NDays,Pdglm(i,:)-2*pi,'sg');
                
%             ylim([-3*pi 5*pi]);
%             xlabel('days');
%             xlid=NDays(end);
%             
%             xli=NDays(find(Pd(i,:)==0)-1);
%             if length(xli)>1
%             xlid=xli(1);
%             end
%               xlim([-1 xlid+0.5]);
%             ylabel('PDs');
    
    %legend('PDs with error bars','PDs from GLM',-1);
     
%  saveas(gcf,([pathnameout,' PDs through days ',int2str(hhh),'.fig']))
%  
%  saveas(gcf,([pathnameout,' PDs through days ',int2str(hhh),'.jpg']))
%    
  stimall(:,1)=[];
    alldat(:,1)=[];
    dates(1)=[];
end
diffstimdeg=abs(diffstim)*180/pi;
diffnostimdeg=abs(diffnostim)*180/pi;

figure;

bar([mean(diffnostimdeg) mean(diffstimdeg)]);hold;
errorbar([1 2],[mean(diffnostimdeg) mean(diffstimdeg)],[std(diffnostimdeg) std(diffstimdeg)],'+');
set(gca,'XTickLabel',{'No stim','stim'});

ylabel('Change in PDs');