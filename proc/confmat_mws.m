function [Cmat,p1off]=confmat_mws(predt,realt)
%8/15/09 by MWS
%confmat plots a confusion matrix from real and predicted target
%information (for centerout). 
%predt and realt are 2d matrices of predicted and real targets, respectively, 
%with dimensions folds X trials.

%p1off is the fraction of predicted targets that were <=1 target off from
%correct guess
ntargs=length(unique(realt));

RO=reshape(realt',[],1);    %can put these vectors in 1d to simplify
PO=reshape(predt',[],1);

for i=1:ntargs          %i is index of real targets
    ro{i}=find(RO==(i-1));  %Find the indices of realt to this target (subtract 1 since targets numbered 0-7 not 1-8)
    po{i}=PO(ro{i});
    for j=1:ntargs
        Cmat(i,j)=length(find(po{i}==(j-1)));   %Cmat is real X pred targets
    end
    Cmat(i,:)=Cmat(i,:)/sum(Cmat(i,:)); %normalize to 1 for each row (i.e. each real target)
end

%Now plot confusion matrix Cmat
imagesc(Cmat)
set(gca,'YDir','normal') 
xlabel('Predicted Target')
ylabel('Real Target')
title('Normalized confusion matrix')
colorbar
n1off=0;
rtot=sum(Cmat,2);   %row (real) reach totals
    Cm1=circshift(Cmat,[0,1]);      %To get i-1th column, use circshift (to avoid indexing errors)
    Cp1=circshift(Cmat,[0,-1]);

for i=1:ntargs
    n1off=n1off+Cmat(i,i)+Cm1(i,i)+Cp1(i,i);     %number of guesses that were <=1 target off from correct
end
p1off=n1off/sum(rtot);


