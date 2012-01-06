function [LFPfilesPDs]=PDs_from_LFPs_MWSpos(root,LFPs,fbandst,fbanden,startword,rewardword,shiftstart,lag,bin_size,pvallim)

% [LFPfilesPDs]=PDs_from_LFPs('E:\Chewie\SpikeLFP\Chewie_Spike_LFP_',[1 10 95],[10,70,130,200,300],[50,110,190,290,390],18 ,32,0,0.05,0.2,0.05);


% this fuction generates a cell array called LFPfilesPDs and it uses
% bootstrap.m
%-each column corresponds to a file designated in the allroots arguments.
%-for each file, first row contains all the PDs (preferred direction) and all the informations about each unit :
%--- 'chanel','unit','lower confidence interval','mean PD','upper...
%---confidence interval','mean magnitude of the PD','spik count','file length','spik...
%---count/data lenght','stdISI','mean ISI','CV'(coefficient of variation)

%-seconfd row contains the name of the file
%-third row contains the recorded date time of the file

%INPUTS:
%-root: designtte the path to the folder and the filename containing the
%mat file to be analysed without the extension .mat
%
%LFPs: put the LFP channels you want to be analized:LFPs=(1:96);
%fbandst=[10,70,130]; starts  of each frequency band
%fbanden=[50,110,190];ends  of each frequency band

%-rewardword= word corresponding to the rewrard;
%-startword= word corresponding to the start( the program will find the starts that corresponded
%to a real reward and discard the starts that ended with a failure).
%-shiftstart in seconds , shiffts the start (avoids noise after the
%start of a trial).CAREFULL shiftstart should be less than the minimum the
%program will ask you to input a shiftstart if it is superior to this
%minimums trial duration.
%-duration of a trial.
%lag time difference (in seconds) between the handle position and t'he spike cout periods. for M1 the lag should  be negative as spike preceed the movement whereas for s1 lag should be positive

%-bin_size=time of the window form where the directions vectors would be
%calculed.
%-pvallim= for example it could be 0.1,0.05,0.01...corresponding  to a 10%,
%5% or 1% allows us to get the lower limit and upper limit pf the PD
%confidence interval.

%%%Modified 11/28/11 by MWS to use more efficient way of calculating power
%%%in freq band
degres=30;%if you change degres (degrees) here change it also in vector_sum_PDs_LFPs
MINTT=0.3;  %300 ms minimum reach length

LFPfilesPDs=cell(3,1);
    data=LoadDataStruct([root,'.mat']);
     
    disp('data loaded');
    degres=degres * pi / 180;
    os=-pi:degres:pi; 

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
    starts=zeros(size(ends));
    for i=1 :length(ends)
        inend=(find(startI<ends(i)));
        starts(i)=startI(inend(end));
%         if (ends(i)-starts(i))<MINTT 
%             if length(inend)>1              %if in multi-target RW
%                 n=0;
%                 while (startI(inend(end)-n)-startI(inend(end-1)-n))<MINTT
%                     n=n+1;
%                 end
%                 starts(i)=startI(inend(end-1)-n); %use the next to last reach
%             else            %if only 1 target RW
%                 starts(i)=0;
%             end
%         end
                
    end
    ends(starts==0)=[];
    starts=nonzeros(starts');
    
    mintrialtime=min(ends-starts);
    
    
    while abs(shiftstart)> mintrialtime
        beep
        shiftstart= input(['shiftstart should be less than ',num2str(mintrialtime),'; shiftstart = ']);
    end
    
%     starts=starts+abs(shiftstart);
    
    starts=starts+shiftstart;
    td=sum(ceil((ends-starts)/bin_size));
    disp('starting');
    
    while ends(end)>data.pos(end,1)-bin_size
        
        ends(end)=[];
        starts(end)=[];
        disp(['removing  trial starting at ',int2str( starts(end)) ]);
    end
    moves=[];
    trials=[];
    direction=zeros(td,1);
    modul=[];
    yud=0;
   
    for i=1: length(starts)
        moves=[moves; cuesall(find(ends(i)> cuesall & cuesall > starts(i)))];
        
    end;
    
     disp('Starting getting direction for each trial');tic
 
     LFPrate=data.raw.analog.adfreq(1,LFPs(1));
% LFPrate=data.raw.analog.adfreq(1,LFPs(1));
f=linspace(0,LFPrate/2,floor((LFPrate*bin_size)/2)+1);
g=find(f<fbanden(end)+10);
bmax=g(end);
win = hanning(floor(LFPrate*bin_size)+1);
fsam=f(1,2:bmax);

     
     for i=1: length(starts)
        %% x and y position for each cues in each trial
        rt=starts(i);

 
        while rt<ends(i)+bin_size+lag
            RTind=floor(rt*LFPrate);
            xpos=data.pos(find(data.pos(:,1)>=rt,1),2);
            xpos2=data.pos(find(data.pos(:,1)>=rt+bin_size,1),2);
            
            ypos=data.pos(find(data.pos(:,1)>=rt,1),3);
            ypos2=data.pos(find(data.pos(:,1)>=rt+bin_size,1),3);
            %% vector calculate
            xposvect=xpos2-xpos;
            yposvect=ypos2-ypos;
            yud=yud+1;
            direction(yud)= atan2(yposvect,xposvect);

               chi=0;
             for j=1:length(LFPs)
                  chi=chi+1;
                LFP=(data.raw.analog.data{1,LFPs(j)});
                LFPsample=win.*LFP(RTind+lag*LFPrate:RTind+bin_size*LFPrate+lag*LFPrate);
%                 powlfp=zeros(1,length(LFPsample));
%                 lfp=zeros(1,length(LFPsample));
                lfp=fft(LFPsample);
                powlfp=lfp.*conj(lfp);
                gat=(powlfp(2:bmax));
                for k=1:length(fbandst)
                    fst=find(fsam>=fbandst(k),1);
                    fend=find(fsam>=fbanden(k),1);
                    %               LFPall{1,k}(yud,chi)=max(gat(fst:fend));
                    LFPall{1,k}(yud,chi)=mean(gat(fst:fend));        %use mean power over all freqs instead of max
                end
             end
             % disp(['LFP ',int2str(j),' done']);
            rt=rt+bin_size;
        end
    end
     disp('End getting direction for each trial');toc
for r=1:size(LFPs,2)
    for k=1:length(fbandst)
        chLFP=LFPall{1,k}(:,r);
        
        for i=1:length(os)-1
            LFP_counts{r,k}{i}=chLFP(find(os(i) < direction & direction < os(i+1)));
        end
    end
    end;
    %% bootstrapping then calculate the circular mean and the CI
    pvallim=pvallim*100;
    lowCI=pvallim/2;
    upCI=100-pvallim/2;

  for k=1:length(fbandst)
      disp(['band',int2str(k),'/',int2str(length(fbandst))]);toc
    for x = 1:size(LFPs,2)
     
             disp(['LFP',int2str(x),'/',int2str(size(LFPs,2))]);toc
        bootstrapPDS{x,k} = bootstrap(@vector_sum_PDs_LFPs,LFP_counts{x,k}, 'all', 1000);
        ss=bootstrapPDS{x,k}(:,1);
        ss(find(ss<0))=ss(find(ss<0))+2*pi;
        PDMatrix{1,k}(x,:)=cprctile(ss,[lowCI 50 upCI]);
        
    end
  end   
    
    %% get the mean magnitudes and plot PD as a polar
    
    for k=1:length(fbandst)
        
    for x = 1:size(LFPs,2)
        
   
        PDMatrix{1,k}(x,5)= LFPs(x);  
        PDMatrix{1,k}(x,4) =mean(bootstrapPDS{x,k}(:,2));
        PDMatrix{1,k}(x,6:7)= prctile(bootstrapPDS{x,k}(:,2),[lowCI upCI]); %bootstrap stats of magnitude
    end;
    end   
  LFPfilesPDs{1,1}= PDMatrix;
    LFPfilesPDs{2,1}= root;

    LFPfilesPDs{3,1}=data.meta.datetime;
      

 toc

 end
