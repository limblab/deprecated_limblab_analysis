function [filePDs]=PDs_from_spikes(root,startword ,rewardword,shiftstart,lag,timeaft,pvallim)


%Example:
%[filePDs]=PDs_from_spikes('\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\processed\Pedro_2011-04-12_RW_001',18 ,32,0,0.05,0.2,0.05);
% OUTPUT
%this fuction generates a cell array called filePDs and it uses
% bootstrap.m
%
%- first row of filePDs contains all the PDs (preferred direction) and all the informations about each unit :
%--- 'chanel','unit','lower confidence interval','mean PD','upper...
%---confidence interval','mean magnitude of the PD','spik count','file length','spik...
%---count/data lenght','stdISI','mean ISI','CV'(coefficient of variation)

%-seconfd row contains the name of the file
%-third row contains the recorded date time of the file

%INPUTS:
%-root: designtte the path to the folder and the filename containing the
%mat file to be analysed without the extension .mat
%
%-rewardword= word corresponding to the rewrard;
%-startword= word corresponding to the start( the program will find the starts that corresponded
%to a real reward and discard the starts that ended with a failure).
%-shiftstart in seconds , shiffts the start (avoids noise after the
%start of a trial).CAREFULL shiftstart should be less than the minimum the
%program will ask you to input a shiftstart if it is superior to this
%minimum trial duration.
%
%
%lag time difference (in seconds) between the handle position and the spike cout periods. for M1 the lag should  be negative as spike preceed the movement whereas for s1 lag should be positive
%-timeaft=time of the window form where the directions vectors would be
%calculed.
%-pvallim= for example it could be 0.1,0.05,0.01...corresponding  to a 10%,
%5% or 1% allows us to get the lower limit and upper limit pf the PD
%confidence interval.


%-degres= degree resolution in degree not in radian: all PDs in that degree
%wil be compiled together: if degres is 30, PDs between 0-30 degree will be
%comiled togheter befor going to the bootstrap.%if you change degres here
%change it also in vector_sum_PDs


degres=30;%if you change degres here change it also in vector_sum_PDs

filePDs=cell(3,1);
   
    data=LoadDataStruct([root,'.mat']);
    
    degres=degres * pi / 180;
    os=-pi:degres:pi;
    
    
    dd=[];
    dd=[dd data.units.id];
    chan=dd(1:2:end-1);
    units=dd(2:2:end);
    chanunit(:,1)=dd(1:2:end-1)';
    chanunit(:,2)=dd(2:2:end)';
    
    for i=1:length(chanunit)
        isi=[];
        unicount(i,1)=length(data.units(1,i).ts);
        lendata(i,1)= data.pos(end,1);
        for j=1 :  unicount(i)-1;
            isi(j,1)=data.units(1,i).ts(j+1)-data.units(1,i).ts(j);
        end
        meanisi(i,1)=mean(isi);
        stdisi(i,1)=std(isi);
        cvisi(i,1)=stdisi(i)/meanisi(i);
    end;
    cha_uni=chanunit;
    unicount(find(cha_uni(:,2)==0| cha_uni(:,2)==255),:)=[];
    lendata(find(cha_uni(:,2)==0| cha_uni(:,2)==255),:)=[];
    meanisi(find(cha_uni(:,2)==0| cha_uni(:,2)==255),:)=[];
    stdisi(find(cha_uni(:,2)==0| cha_uni(:,2)==255),:)=[];
    cvisi(find(cha_uni(:,2)==0| cha_uni(:,2)==255),:)=[];
    cha_uni(find(cha_uni(:,2)==0 | cha_uni(:,2)==255),:)=[];
    unicount=unicount';
    lendata=lendata';
    meanisi=meanisi';
    stdisi=stdisi';
    cvisi=cvisi';
    unicperlen=unicount./lendata;
    
    
    
    
    
    xposall=data.pos(:,2);
    yposall=data.pos(:,3);
    
    
    
    
    
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
    disp('starting');
    
    while ends(end)>data.pos(end,1)-timeaft
        
        ends(end)=[];
        starts(end)=[];
        disp(['removing  trial starting at ',int2str( starts(end)) ]);
    end
    moves=[];
    trials=[];
    direction=zeros(td,1);
    modul=[];
    yud=0;
    unitsall=zeros(td,size(cha_uni,1));
    for i=1: length(starts)
        moves=[moves; cuesall(find(ends(i)> cuesall & cuesall > starts(i)))];
        
    end;
    
    
    
    
    for i=1: length(starts)
        % x and y positions for each cues in each trial
        rt=starts(i);
        while rt<ends(i)+timeaft+lag
            
            xpos=data.pos(find(data.pos(:,1)>=rt,1),2);
            xpos2=data.pos(find(data.pos(:,1)>=rt+timeaft,1),2);
            
            ypos=data.pos(find(data.pos(:,1)>=rt,1),3);
            ypos2=data.pos(find(data.pos(:,1)>=rt+timeaft,1),3);
            % vector calculate
            xposvect=xpos2-xpos;
            yposvect=ypos2-ypos;
            yud=yud+1;
            direction(yud)= atan2(yposvect,xposvect);
            
            chi=0;
            for h=1:size(chanunit,1)
                if chanunit(h,2)~=0
                    chi=chi+1;
                    unitscall(yud,chi)=(length(find(data.units(1,h).ts>rt+lag & data.units(1,h).ts<rt+timeaft+lag)));
                    
                end
            end
            rt=rt+timeaft;
        end
    end
    means=[];
    
    
    unitscall(size(direction,1)+1:end,:)=[];
    spike_counts = cell(1,size(cha_uni,1));
    
    
    for r=1:size(cha_uni,1)
        unitsp=unitscall(:,r);
        for i=1:length(os)-1
            spike_counts{r}{i}=unitsp(find(os(i) < direction & direction < os(i+1)));
        end
    end;
    
    %% bootstrapping then calculate the circular mean and the CI
    pvallum=pvallim*100;
    lowCI=pvallum/2;
    upCI=100-pvallum/2;
    bootstrapPDS = cell(1, size(cha_uni,1));
    
    PDMatrix=zeros(size(cha_uni,1),3);
    disp(['bootstrap start: ', int2str(1),'/',int2str(1)]); tic
    for x = 1:size(cha_uni,1)
        
         disp(['unit ',int2str(x),'/',int2str(size(cha_uni,1))]);toc
        bootstrapPDS{x} = bootstrap(@vector_sum_PDs, spike_counts{x}, 'all', 1000);
        ss=bootstrapPDS{x}(:,1);
        ss(find(ss<0))=ss(find(ss<0))+2*pi;
        PDMatrix(x,:)=cprctile(ss,[lowCI 50 upCI]);
        
        
        
        
            
    end
    disp(['bootstrap end: ', int2str(1),'/',int2str(1)]); toc
    
    
    %% get the mean magnitudes and plot PD as a polar
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
    filePDs{1,1}=allPDs;
    filePDs{2,1}=root;
    filePDs{3,1}=data.meta.datetime;
    

beep

end