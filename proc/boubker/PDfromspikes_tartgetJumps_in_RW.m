% % function [allfilesPDs]=PDfromspikesF(pathname,allroots,startword ,rewardword,shiftstart,degres,timeaft,pvallim)
clear; close all; clc;
pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Processed\';
allroots={'Pedro_S1_008'};
startword =18;
rewardword=32;
shiftstart=0;
degres=30;
timeaft=0.01;
pvallim=0.05;
% this fuction generates a cell array called allfilesPDs and it uses
% bootstrap.m
%-each column corresponds to a file designated in the allroots arguments.
%-for each file, first row contains all the PDs (preferred direction) and all the informations about each unit :
%--- 'chanel','unit','lower confidence interval','mean PD','upper...
%---confidence interval','mean magnitude of the PD','spik count','file length','spik...
%---count/data lenght','stdISI','mean ISI','CV'(coefficient of variation)

%-seconfd row contains the name of the file
%-third row contains the recorded date time of the file

%the inputs:
%-pathname: designtte the path to the folder containing all the mat files to be
%analysed.pathname should end with \ as in ' \';
%-allroots: contains names of the mat files to be analysed, don't
%add '.mat'; allroots should be entrered between the curly brackets{' ';' ';' '...};

%-rewardword= word corresponding to the rewrard;
%-startword= word corresponding to the start( the program will find the starts that corresponded
%to a real reward and discard the starts that ended with a failure).
%-shiftstart in seconds , shiffts the start (avoids noise after the
%start of a trial).CAREFULL shiftstart should be less than the minimum the
%program will ask you to input a shiftstart if it is superior to this
%minimums trial duration.
%-duration of a trial.
%-degres= degree resolution in degree not in radian: all PDs in that degre
%wil be compiled together: if degres is 30, PDs between 0-30 degree will be
%comiled togheter befor going to the bootstrap.
%-timeaft=time of the window form where the directions vectors would be
%calculed.
%-pvallim= for example it could be 0.1,0.05,0.01...corresponding  to a 10%,
%5% or 1% allows us to get the lower limit and upper limit pf the PD
%confidence interval.
% pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Processed\';
% allroots={'Pedro_S1_040-s','Pedro_S1_042-s','Pedro_S1_043-s','Pedro_S1_044-s','Pedro_S1_046-s','Pedro_S1_047-s'};

allfilesPDs=cell(3,length(allroots));

for nr=1:length(allroots)    
    root=char(allroots(:,nr));
    data=LoadDataStruct([pathname,root,'.mat']);
    degres=degres * pi / 180;
    os=-pi:degres:pi;
    direc=os;
    direc(1)=[];
    
    h = waitbar(0,['Please wait...analysing file ',root]);
   
    
    dd=[];
    dd=[dd data.units.id];
    chan=dd(1:2:end-1);
    units=dd(2:2:end);
    chanunit(:,1)=dd(1:2:end-1)';
    chanunit(:,2)=dd(2:2:end)';
    
    for i=1:length(chanunit)
        isi=[];
        unicount(i)=length(data.units(1,i).ts);
        lendata(i)= data.pos(end,1);
        for j=1 :  unicount(i)-1;
            isi(j)=data.units(1,i).ts(j+1)-data.units(1,i).ts(j);
        end
        meanisi(i)=mean(isi);
        stdisi(i)=std(isi);
        cvisi(i)=stdisi(i)/meanisi(i);
    end;
    cha_uni=chanunit;
    unicount(find(cha_uni(:,2)==0),:)=[];
    lendata(find(cha_uni(:,2)==0),:)=[];
    meanisi(find(cha_uni(:,2)==0),:)=[];
    stdisi(find(cha_uni(:,2)==0),:)=[];
    cvisi(find(cha_uni(:,2)==0),:)=[];
    cha_uni(find(cha_uni(:,2)==0),:)=[];
    unicount=unicount';
    lendata=lendata';
    meanisi=meanisi';
    stdisi=stdisi';
    cvisi=cvisi';
    unicperlen=unicount./lendata;
    
    postimes=(data.pos(:,1)*1000);
    
    
    
    xposall=data.pos(:,2);
    yposall=data.pos(:,3);
    
    psr= 1/(postimes(2)- postimes(1))*1000;
    
    
    if psr<1000
        postim=(postimes(1):1:(postimes(end)))';
        xposall=interp1(postimes,data.pos(:,2),postim,'nearest');
        yposall=interp1(postimes,data.pos(:,3),postim,'nearest');
    end
    
    cuesall= data.words(:,1);
    words=data.words(:,2);
    startI=cuesall(find(words==startword));
    ends=cuesall(find(words==rewardword));
    while (startI(1)<=1)
        startI(1)=[];
    end;
    while (ends(1)<startI(1))
        ends(1)=[];
    end;
    while (startI(end)>ends(end))
        startI(end)=[];
    end; 
   
for i=1 :length(ends)
    inend=(find(startI<ends(i)));
    starts(i)=startI(inend(end));
end
    starts=starts';
    
    mintrialtime=min(ends-starts);

    
while abs(shiftstart)> mintrialtime
    beep
  shiftstart= input(['shiftstart should be less than ',num2str(mintrialtime),'; shiftstart = ']);
end
    
    starts=starts+abs(shiftstart);
   
    
    
    td=sum(ceil((ends-starts)/timeaft));
    targetsx=postimes(find(cuesall==43));
    moves=[];
    trials=[];
    direction=zeros(td,1);
    modul=[];
    yud=0;
    unitsall=zeros(td,size(cha_uni,1));
    for i=1: length(starts)
        moves=[moves; cuesall(find(ends(i)> cuesall & cuesall > starts(i)))];
        
    end;
    
    
    postimes=uint64(postimes);
    
    for i=1: length(starts)
        %% x and y positions for each cues in each trial
        rt=starts(i);
        while rt<ends(i)
            
            xpos=xposall(find(postimes==round(rt*1000)));
            xpos2=xposall(find(postimes==round((rt+timeaft)*1000)));
            ypos=yposall(find(postimes==round(rt*1000)));
            ypos2=yposall(find(postimes==round((rt+timeaft)*1000)));
            %% vector calculate
            
            xposvect=xpos2-xpos;
            yposvect=ypos2-ypos;
            yud=yud+1;
            direction(yud)= atan2(yposvect,xposvect);
            posix(yud)= xpos;
              posiy(yud)= ypos;
              tpos(yud)=rt*1000;
            chi=0;
            for h=1:size(chanunit,1)
                if chanunit(h,2)~=0
                    chi=chi+1;
                    unitscall(yud,chi)=(length(find(data.units(1,h).ts>rt & data.units(1,h).ts<rt+timeaft)));
                    
                end
            end
            
            rt=rt+timeaft;
        end
       
    end
    means=[];
    tpos=uint64(tpos');
      h = waitbar(0,['Please wait...analysing file ',root]);
     
    unitscall(size(direction,1)+1:end,:)=[];
    spike_counts = cell(1,size(cha_uni,1));
    
    
    for r=1:size(cha_uni,1)
        unitsp=unitscall(:,r);
        for i=1:length(os)-1
           spike_counts{r}{i}=unitsp(find(os(i) < direction & direction < os(i+1)));
        end
    end;

    % bootstrapping then calculate the circular mean and the CI
    pvallim=pvallim*100;
    lowCI=pvallim/2;
    upCI=100-pvallim/2;
    bootstrapPDS = cell(1, size(cha_uni,1));
    
    PDMatrix=zeros(size(cha_uni,1),3);
   
    for x = 1:size(cha_uni,1)
     
        
        bootstrapPDS{x} = bootstrap(@vector_sum_pd, spike_counts{x}, 'all', 1000);
        ss=bootstrapPDS{x}(:,1)-pi;
        PDMatrix(x,:)=cprctile(ss,[lowCI 50 upCI]); 
        waitbar(x/size(cha_uni,1))
    end
    
    
    % get the mean magnitudes and plot PD as a polar
    for x = 1:size(cha_uni,1)
        mag(x) =mean(bootstrapPDS{x}(:,2));
    end;
    
    allPDs(:,1:2)= cha_uni;
    allPDs(:,3:5)= PDMatrix;
    allPDs(:,6)= mag;
    allPDs(:,7)= unicount;
    allPDs(:,8)= lendata;
    allPDs(:,9)= unicperlen;
    allPDs(:,10)= stdisi;
    allPDs(:,11)= meanisi;
    allPDs(:,12)= cvisi;
    allfilesPDs{1,nr}=allPDs;
    allfilesPDs{2,nr}=allroots(nr);
    allfilesPDs{3,nr}=data.meta.datetime;
      
beep
% end