function check_pct_left(tt)
%accepts a trial table and computes statistics on the distribution of
%reaching directions

    %compute the number of trials in each direction of interest
    dirs=tt(:,3);
    nt=length(dirs);%total reaches
    nl=length(dirs(dirs>90&dirs<270));%reaches left
    nr=nt-nl;%reaches right
    nu=length(dirs(dirs>0&dirs<180));%reaches up
    nd=nt-nu;%reaches down
    nlu=length(dirs(dirs>90&dirs<180));%reaches up left
    nld=length(dirs(dirs>180&dirs<270));%reaches down left
    nru=nu-nlu;%reaches up right
    nrd=nd-nld;%reaches down right
    
    
    p_nl=binocdf(nl,nt,.5);
    p_nu=binocdf(nu,nt,.5);
    p_nd=binocdf(nd,nt,.5);
    p_nr=binocdf(nr,nt,.5);
    
    p_nlu=binocdf(nlu,nt,.25);
    p_nld=binocdf(nld,nt,.25);
    p_nru=binocdf(nru,nt,.25);
    p_nrd=binocdf(nrd,nt,.25);
    
    disp(strcat('total number of trials:',num2str(nt)))
    disp(strcat('number of leftward trials:',num2str(nl),' with a likelyhood of p=',num2str(p_nl)))
    disp('expected range for number of leftward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    disp(strcat('number of upward trials:',num2str(nu),' with a likelyhood of p=',num2str(p_nu)))
    disp('expected range for number of upward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    disp(strcat('number of rightward trials:',num2str(nr),' with a likelyhood of p=',num2str(p_nr)))
    disp('expected range for number of leftward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    disp(strcat('number of downward trials:',num2str(nd),' with a likelyhood of p=',num2str(p_nu)))
    disp('expected range for number of downward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    
    disp(strcat('number of up-leftward trials:',num2str(nlu),' with a likelyhood of p=',num2str(p_nlu)))
    disp('expected range for number of up-leftward trials is:')
    disp(binoinv([.05 .95],nt,0.25))
    disp(strcat('number of down-leftward trials:',num2str(nld),' with a likelyhood of p=',num2str(p_nld)))
    disp('expected range for number of down-leftward trials is:')
    disp(binoinv([.05 .95],nt,0.25))
    disp(strcat('number of up-rightward trials:',num2str(nru),' with a likelyhood of p=',num2str(p_nru)))
    disp('expected range for number of up-rightward trials is:')
    disp(binoinv([.05 .95],nt,0.25))
    disp(strcat('number of down-rightward trials:',num2str(nrd),' with a likelyhood of p=',num2str(p_nrd)))
    disp('expected range for number of down-rightward trials is:')
    disp(binoinv([.05 .95],nt,0.25))    
end