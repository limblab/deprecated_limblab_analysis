%script to make polar plot for all the PD sets tested so far
close all
h = figure;
    polar(0,1)
    hold on
    r=1;
    

    %21
    disp('working on 21deg PD set')
    PDS=[.54 .53 .57 .35];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'r');
    end
    
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','r','linewidth',3)
    
    %210
    disp('working on 210deg PD set')
    PDS=[-2.63 -2.47 -2.54 -2.48];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'g');
    end
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','g','linewidth',3)
    
    %270
    disp('working on 270deg PD set')
    PDS=[-1.51 -1.66 -1.95 -1.42];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'b');
    end
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','b','linewidth',3)
    
    %70
    disp('working on 70deg PD set')
    PDS=[.93 1.35 .78 1.48];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'y');
    end
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','y','linewidth',3)
    
    %140
    disp('working on 140deg PD set')
    PDS=[2.91 2.58 2.38 2.2];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'k');
    end
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','k','linewidth',3)
    
    %352
    disp('working on 352deg PD set')
    PDS=[-.45 -.31 -.21 -.36];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'c');
    end
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','c','linewidth',3)
    
    %211
    disp('working on 211deg PD set')
    PDS=[-1.89 -2.41 -2.88 -2.31];
    for i=1:length(PDS)
        angle=PDS(i);
        polar([0 angle],[0,r],'m');
    end
    h2=polar([0 mean(PDS)],[0 r]);
    set(h2,'color','m','linewidth',3)
    
        
        
        