function [Hbest, r2best, featindBEST, Pbest] = BESTdecoderLoad(Firstfilename,direct,Usefeatmat)

    load(Firstfilename);
    BEST_ind = find(max(sum(r2,2))==sum(r2,2));
    Hbest = H{BEST_ind};
    r2best(:,:) = r2(BEST_ind,:);
     
    featindBEST = featind(1:length(Hbest)/10);
%     [C,FeatsortInd]=sortrows(featindBEST');
%     featindBEST = C;
    
    Pbest = P;
    mkdir('Decoders')
    if Usefeatmat == 1
        save([direct,'\','Decoders','\',Firstfilename,'_BEST','.mat'],'Hbest','r2best','featindBEST','P');
    else
        save([Firstfilename,'_BEST','.mat'],'Hbest','r2best','featindBEST','P');
    end
    
    disp('Saved best decoder from first file');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Use if loading decoder used for online LFP control
    %if i <=3 || i == 5 || i == 6

    %Hbest = H;
    %P = P;

    %for j = 1:length(bestc)  
     %   featindBEST(1,j) = (bestc(j)-1)*6+bestf(j);
    %end

    %end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%