function check_pct_left(tt,RA_flag)
%accepts a trial table and computes statistics on the distribution of
%reaching directions. If you want to check only complete trials set the
%RA_flag to 1, and the abort trials will be excluded

    %compute the number of trials in each direction of interest
    dirs=tt(:,3);
    if RA_flag==1
        dirs=removerows(dirs,find(tt(:,7)==65));
    end
    nt=length(dirs);%total reaches
    nl=length(dirs(dirs>90&dirs<270));%reaches left
    nr=nt-nl;%reaches right
    nu=length(dirs(dirs>0&dirs<180));%reaches up
    nd=nt-nu;%reaches down
    nlu=length(dirs(dirs>90&dirs<180));%reaches up left
    nld=length(dirs(dirs>180&dirs<270));%reaches down left
    nru=nu-nlu;%reaches up right
    nrd=nd-nld;%reaches down right
    
    %get CDF for each count. I used p_* for variable names but these are
    %not actually the p-values, they represent the cumulative likelyhood of
    %observing counts less than the input amount
    p_nl=binocdf(nl,nt,.5);
    p_nu=binocdf(nu,nt,.5);
    p_nd=binocdf(nd,nt,.5);
    p_nr=binocdf(nr,nt,.5);
    
    p_nlu=binocdf(nlu,nt,.25);
    p_nld=binocdf(nld,nt,.25);
    p_nru=binocdf(nru,nt,.25);
    p_nrd=binocdf(nrd,nt,.25);
    
  %print out the cdf and other useful info. Interleaved with the prints are
  %displays of the 95% CI for the expected number of counts given the
  %probabilities assigned above
    disp(strcat('total number of trials:',num2str(nt)))
    disp(strcat('number of leftward trials:',num2str(nl),' with a cdf of :',num2str(p_nl)))
    disp('expected range for number of leftward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    disp(strcat('number of rightward trials:',num2str(nr),' with a cdf of :',num2str(p_nr)))
    disp('expected range for number of leftward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    disp(strcat('number of upward trials:',num2str(nu),' with a cdf of :',num2str(p_nu)))
    disp('expected range for number of upward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    disp(strcat('number of downward trials:',num2str(nd),' with a cdf of :',num2str(p_nd)))
    disp('expected range for number of downward trials is:')
    disp(binoinv([.05 .95],nt,0.5))
    
    disp(strcat('number of up-leftward trials:',num2str(nlu),' with a cdf of :',num2str(p_nlu)))
    disp('expected range for number of up-leftward trials is:')
    disp(binoinv([.05 .95],nt,0.25))
    disp(strcat('number of down-leftward trials:',num2str(nld),' with a cdf of :',num2str(p_nld)))
    disp('expected range for number of down-leftward trials is:')
    disp(binoinv([.05 .95],nt,0.25))
    disp(strcat('number of up-rightward trials:',num2str(nru),' with a cdf of :',num2str(p_nru)))
    disp('expected range for number of up-rightward trials is:')
    disp(binoinv([.05 .95],nt,0.25))
    disp(strcat('number of down-rightward trials:',num2str(nrd),' with a cdf of :',num2str(p_nrd)))
    disp('expected range for number of down-rightward trials is:')
    disp(binoinv([.05 .95],nt,0.25))    
end