numbins = 15;

%% Calculate KL-MI for gamma 2 (80 -150 Hz) with randomized theta phase 
numfiles = 4;
KL_dist2_rand = zeros(96,max(foldnums),max(foldnums));
foldi = 1;
inumfold = 1;
shifti = 1;
clear mu
Index = [];

% for numfolds = in(foldnums,[16 50])
%     Index = cumsum(foldnumslist(foldnumslist < numfolds));
%     % Index(end)-numfolds+1:Index(end),numfolds
%     %     if numfolds ==101
%     if isempty(Index) == 0
%         foldi = Index(end)+1;
%     else
%         foldi = 1;
%     end
% %     end
%     for i = 1:numfolds  
%         p_i_ThetaGamma2_Rand_Phase_norm = p_i_ThetaGamma2_RandPhase{foldi,numfolds}./...
%             repmat(sum( p_i_ThetaGamma2_RandPhase{foldi,numfolds},2),1,size( p_i_ThetaGamma2_RandPhase{foldi,numfolds},2));
%         mu(:,foldi) = mean( p_i_ThetaGamma2_RandPhase_norm,2);
%         KL_dist2_rand(:,numfolds,i) = KL_dist2_rand(:,numfolds,i) + sum( p_i_ThetaGamma2_RandPhase_norm.* ...
%             log( p_i_ThetaGamma2_RandPhase_norm./repmat(mu(:,foldi),1,size( p_i_ThetaGamma2_RandPhase{foldi,numfolds},2))),2);
%         foldi = foldi +1;
%     end
%     
%     KL_dist2_rand_norm(:,numfolds,:) = KL_dist2_rand(:,numfolds,:)./log(numbins);
%     
% end   
    
% for numfolds = in(foldnums,[0 100])
%     numfolds
% %     Index = cumsum(foldnumslist(foldnumslist < numfolds));
% %     foldi = Index(end)+1;
%     for j = 1000:1000:size(p_i_ThetaGamma2_RandPhase,2)
%         for i = 1:numfolds
%             p_i_ThetaGamma2_RandPhase_norm = p_i_ThetaGamma2_RandPhase{foldi,j,inumfold}./...
%                 repmat(sum(p_i_ThetaGamma2_RandPhase{foldi,j,inumfold},2),1,size(p_i_ThetaGamma2_RandPhase{foldi,j,inumfold},2));
%             mu(:,numfolds,foldi) = mean(p_i_ThetaGamma2_RandPhase_norm,2);
%             KL_dist2_rand(:,numfolds,foldi) = KL_dist2_rand(:,numfolds,foldi) + sum(p_i_ThetaGamma2_RandPhase_norm.* ...
%                 log(p_i_ThetaGamma2_RandPhase_norm./repmat(mu(:,numfolds,foldi),1,size(p_i_ThetaGamma2_RandPhase{foldi,j,inumfold},2))),2);
%             foldi = foldi +1;
%         end
%         foldi = 1;
%         KL_dist2_rand_norm{inumfold}(:,shifti,:) = KL_dist2_rand(:,numfolds,:)./log(numbins);
%         KL_dist2_rand = zeros(96,max(foldnums),max(foldnums));
%         shifti = shifti + 1;
%     end
%     shifti = 1;
%     inumfold = inumfold + 1;
% end

for q = 1:size(p_i_ThetaGamma2_RandPhase,2)
    
    numFolds = nnz(~cellfun(@isempty,p_i_ThetaGamma2_RandPhase(:,q)));
    numReps = nnz(~cellfun(@isempty,squeeze(p_i_ThetaGamma2_RandPhase(1,q,1:end))));
    KL_dist2_rand = zeros(96,numFolds,numReps);
    
    for j = 1:numFolds
        for i = 1:numReps
            
            p_i_ThetaGamma2_RandPhase_norm = p_i_ThetaGamma2_RandPhase{j,q,i}./...
                repmat(sum(p_i_ThetaGamma2_RandPhase{j,q,i},2),1,size(p_i_ThetaGamma2_RandPhase{j,q,i},2));
            mu(:,j,i) = mean(p_i_ThetaGamma2_RandPhase_norm,2);
            KL_dist2_rand(:,j,i) = KL_dist2_rand(:,j,i) + sum(p_i_ThetaGamma2_RandPhase_norm.* ...
                log(p_i_ThetaGamma2_RandPhase_norm./repmat(mu(:,j,i),1,size(p_i_ThetaGamma2_RandPhase{j,q,i},2))),2);
            
        end
        KL_dist2_rand_norm{q}(:,:,:) = KL_dist2_rand(:,:,:)./log(numbins);     
        
    end
    
end

% set(gca,'Xtick',1:length(SecondsPerFold),'XTicklabel',{flip(SecondsPerFold)})
% ylabel('80-150 Hz Chance Modulation Index')
% xlabel('Fold Length(s)')
% hold on

% figure
% % plot(KL_dist2_rand_norm')
% plot(mean(KL_dist2_rand_norm,1))
% ylabel('80-150 Hz Modulation Index')
% xlabel('Fold Length(s)')
% legend('80-150 Hz MI','Chance 80-150 Hz MI')

clear mu
%% Calculate KL-MI for gamma 2 (80 -150 Hz)

numfiles = 4;
KL_dist2 = zeros(96,max(foldnums),max(foldnums));
foldi = 1;
inumfold = 1;
Index = [];
%  for numfolds = in(foldnums,[0 100])
% %     Index = cumsum(foldnumslist(foldnumslist < numfolds));
%     % Index(end)-numfolds+1:Index(end),numfolds
%     %     if numfolds ==101
%     if isempty(Index) == 0
%         foldi = Index(end)+1;
%     else
%         foldi = 1;
%     end
% %     end
%     for i = 1:numfolds  
%          p_i_ThetaGamma2_norm =  p_i_ThetaGamma2{foldi,numfolds}./...
%             repmat(sum( p_i_ThetaGamma2{foldi,numfolds},2),1,size( p_i_ThetaGamma2{foldi,numfolds},2));
%         mu(:,foldi) = mean( p_i_ThetaGamma2_norm,2);
%         KL_dist2(:,numfolds,i) = KL_dist2(:,numfolds,i) + sum( p_i_ThetaGamma2_norm.* ...
%             log( p_i_ThetaGamma2_norm./repmat(mu(:,foldi),1,size( p_i_ThetaGamma2{foldi,numfolds},2))),2);
%         foldi = foldi +1;
%     end
%     
%     KL_dist2_norm(:,numfolds,:) = KL_dist2(:,numfolds,:)./log(numbins);
%     
%  end  
%  
% figure
% plot(mean(squeeze(KL_dist2_norm(:,foldnums(1),1:foldnums(1))),1))
% hold on
% plot(mean(squeeze(KL_dist2_rand_norm(:,foldnums(1),1:foldnums(1))),1),'r')
% xlabel('Fold #')
% ylabel('KL-MI')
% legend('Mean KL-MI across all channels','Chance KL-MI')
% 
% figure
% plot(mean(squeeze(KL_dist2_norm(:,foldnums(2),1:foldnums(2))),1))
% hold on
% plot(mean(squeeze(KL_dist2_rand_norm(:,foldnums(2),1:foldnums(2))),1),'r')
% xlabel('Fold #')
% ylabel('KL-MI')
% legend('Mean KL-MI across all channels','Chance KL-MI')

% for numfolds = in(foldnums,[1 100])
% %     Index = cumsum(foldnumslist(foldnumslist < numfolds));
% %     foldi = Index(end)+1;
%     %     Index = cumsum(1:numfolds);
%     % Index(end)-numfolds+1:Index(end),numfolds
%     %     if numfolds ==101
%     %             foldi = 1;
%     %     end
%     for i = 1:numfolds
%         p_i_ThetaGamma2_norm = p_i_ThetaGamma2{foldi,numfolds}./...
%             repmat(sum(p_i_ThetaGamma2{foldi,numfolds},2),1,size(p_i_ThetaGamma2{foldi,numfolds},2));
%         mu(:,numfolds,foldi) = mean(p_i_ThetaGamma2_norm,2);
%         KL_dist2(:,inumfold,i) = KL_dist2(:,inumfold,i) + sum(p_i_ThetaGamma2_norm.* ...
%             log(p_i_ThetaGamma2_norm./repmat(mu(:,numfolds,foldi),1,size(p_i_ThetaGamma2{foldi,numfolds},2))),2);
%         foldi = foldi +1;
%     end
%     
%     KL_dist2_norm(:,inumfold,:) = KL_dist2(:,inumfold,:)./log(numbins);
%     inumfold = inumfold + 1;
% end

% figure
% plot(mean(squeeze(KL_dist2_norm(:,1,1:foldnums(1)))',2))
% hold on
% plot(mean(squeeze(mean(KL_dist2_rand_norm{1}(:,:,1:foldnums(1)),2))',2),'r')
% xlabel('Fold #')
% ylabel('KL-MI')
% legend('Mean KL-MI across all channels','Chance KL-MI')
% 
% figure
% plot(mean(squeeze(KL_dist2_norm(:,2,1:foldnums(2)))',2))
% hold on
% plot(mean(squeeze(mean(KL_dist2_rand_norm{2}(:,:,1:foldnums(2)),2))',2),'r')
% xlabel('Fold #')
% ylabel('KL-MI')
% legend('Mean KL-MI across all channels','Chance KL-MI')

for q = 1:size(p_i_ThetaGamma2,2)
    
    numFolds = nnz(~cellfun(@isempty,p_i_ThetaGamma2(:,q)));
    numReps = nnz(~cellfun(@isempty,squeeze(p_i_ThetaGamma2(1,q,1:end))));
    KL_dist2 = zeros(96,numFolds,numReps);
    
    for j = 1:numFolds
        for i = 1:numReps
            
            p_i_ThetaGamma2_norm = p_i_ThetaGamma2{j,q,i}./...
                repmat(sum(p_i_ThetaGamma2{j,q,i},2),1,size(p_i_ThetaGamma2{j,q,i},2));
            mu(:,j,i) = mean(p_i_ThetaGamma2_norm,2);
            KL_dist2(:,j,i) = KL_dist2(:,j,i) + sum(p_i_ThetaGamma2_norm.* ...
                log(p_i_ThetaGamma2_norm./repmat(mu(:,j,i),1,size(p_i_ThetaGamma2{j,q,i},2))),2);
            
        end
        KL_dist2_norm{q}(:,:,:) = KL_dist2(:,:,:)./log(numbins);     
        
    end
    
end

figure
KL_dist2_norm_mean_MAT = cell2mat(cellfun(@mean,KL_dist2_norm,'UniformOutput',0));
KL_dist2_norm_std_MAT = cell2mat(cellfun(@std,KL_dist2_norm,'UniformOutput',0));
totalFold = length(KL_dist2_norm_mean_MAT);
[numChan numFold] = cellfun(@size,KL_dist2_norm,'UniformOutput',0)
FileInd = cumsum(cell2mat(numFold));

mean3D = @(x) mean(x,3); % anonymous function
std3D = @(x) std(x,0,3);
KL_dist2_rand_norm_mean_MAT = cell2mat(cellfun(mean3D,cellfun(@mean,KL_dist2_rand_norm,'UniformOutput',0),'UniformOutput',0))
KL_dist2_rand_norm_std_MAT = cell2mat(cellfun(std3D,cellfun(@mean,KL_dist2_rand_norm,'UniformOutput',0),'UniformOutput',0))
ylim([0 .01])
shadedErrorBar(1:totalFold,KL_dist2_norm_mean_MAT,KL_dist2_norm_std_MAT)
hold on
shadedErrorBar(1:totalFold,KL_dist2_rand_norm_mean_MAT,KL_dist2_rand_norm_std_MAT,'r')


KL_dist2_norm_AllCh_MAT = cell2mat(KL_dist2_norm);
totalFold = length(KL_dist2_norm_mean_MAT); 
Abovechance = KL_dist2_norm_AllCh_MAT > repmat(KL_dist2_rand_norm_mean_MAT,96,1)
for c = 1 :96
    AboveChancePerCh(c) = nnz(Abovechance(c,:));
end
[B I] = sort(AboveChancePerCh,'descend')

figure
plot(KL_dist2_norm_AllCh_MAT(I(1:8),:)')
hold on
shadedErrorBar(1:totalFold,KL_dist2_rand_norm_mean_MAT,KL_dist2_rand_norm_std_MAT,'r')

for f = 1:3:length(numFold)
        plot([FileInd(f) FileInd(f)],[0 100],'y--')
end
for f = 2:3:length(numFold)
        plot([FileInd(f) FileInd(f)],[0 100],'b--')
end
for f = 3:3:length(numFold)
        plot([FileInd(f) FileInd(f)],[0 100],'g--')
end 

plot()
hold on
plot(mean(squeeze(mean(KL_dist2_rand_norm{1}(:,:,1:foldnums(1)),2))',2),'r')
xlabel('Fold #')
ylabel('KL-MI')
legend('Mean KL-MI across all channels','Chance KL-MI')

figure
plot(mean(squeeze(KL_dist2_norm(:,2,1:foldnums(2)))',2))
hold on
plot(mean(squeeze(mean(KL_dist2_rand_norm{2}(:,:,1:foldnums(2)),2))',2),'r')
xlabel('Fold #')
ylabel('KL-MI')
legend('Mean KL-MI across all channels','Chance KL-MI')

% plot(flip(KL_dist2_norm(:,foldnums)'))
% title('KL MI over all channels')
% ylabel('80-150 Hz Modulation Index')
% % ylim([0 .01])
% % xlim([0 105])
% [foldnums, iu, iv] = unique(floor(filelength./(foldLengths*1000)));
% SecondsPerFold = foldLengths(iu); 
% xlabel('Fold Length(s)')
% set(gca,'Xtick',1:length(SecondsPerFold),'XTicklabel',{flip(SecondsPerFold)})
% % SecondsPerFold = 1./(1:size(p_i_ThetaGamma,2))*Seconds;
% % FoldSpace = 1:size(p_i_ThetaGamma,2);
% % set(gca,'Xtick',flip(round(SecondsPerFold(find(mod(SecondsPerFold,10)<1)))),'XTicklabel',{flip(SecondsPerFold(find(mod(SecondsPerFold,10)<1)))})
% 
% figure
% plot(flip(mean(KL_dist2_norm(:,foldnums),1)))
% title('Mean KL MI over channels')
% % FoldSpace = 1:100:size(p_i_ThetaGamma,2);
% set(gca,'Xtick',1:length(SecondsPerFold),'XTicklabel',{flip(SecondsPerFold)})
% ylabel('80-150 Hz Modulation Index')
% xlabel('Fold Length(s)')
% hold on

%% Calculate KL-MI for gamma 1 (30-100 Hz)
numfiles = 4;

KL_dist = zeros(96,550);
foldi = 1;
for numfolds = in(foldnums,[23 50])
    Index = cumsum(foldnumslist(foldnumslist < numfolds));
    % Index(end)-numfolds+1:Index(end),numfolds
    %     if numfolds ==101
    foldi = Index(end)+1;
%     end
    for i = 1:numfolds  
        p_i_ThetaGamma_norm = p_i_ThetaGamma{foldi,numfolds}./...
            repmat(sum(p_i_ThetaGamma{foldi,numfolds},2),1,size(p_i_ThetaGamma{foldi,numfolds},2));
        mu(:,foldi) = mean(p_i_ThetaGamma_norm,2);
        KL_dist(:,numfolds) = KL_dist(:,numfolds) + sum(p_i_ThetaGamma_norm.* ...
            log(p_i_ThetaGamma_norm./repmat(mu(:,foldi),1,size(p_i_ThetaGamma{foldi,numfolds},2))),2);
        foldi = foldi +1;
    end
    
    KL_dist_norm(:,numfolds) = KL_dist(:,numfolds)./log(numbins);
    
end


hold on
plot(KL_dist2_norm(:,foldnums),'y')

ylabel('30-100 Hz Modulation Index')
ylim([0 0.1])
xlabel('Fold Length(s)')

figure
plot(mean(KL_dist_norm,1))
title('Mean KL MI over channels')
Seconds = out_struct.pos(end,1);
SecondsPerFold = 1./(1:50:size(p_i_ThetaGamma,2))*Seconds;
FoldSpace = 1:50:size(p_i_ThetaGamma,2);
set(gca,'Xtick',FoldSpace,'XTicklabel',{SecondsPerFold})
  
ylabel('30-100 Hz Modulation Index')
ylim([0 0.1])
xlabel('Fold Length(s)')


%% Calculate KL-MI for gamma (30 - 80 Hz) with randomized theta phase 
KL_dist_rand = zeros(size(p_i_ThetaGamma2_RandPhase,1));

for j = 1:size(p_i_ThetaGamma2_RandPhase,1)
    mu(j) = mean(p_i_ThetaGamma_RandPhase(j,:));
    
    for i = 1:size(p_i_ThetaGamma_RandPhase,2)
        KL_dist_rand(j) = KL_dist_rand(j) + p_i_ThetaGamma_RandPhase(j,i) * log(p_i_ThetaGamma_RandPhase(j,i)/mu(j));
    end
    
    KL_dist_norm_rand(j) = KL_dist_rand(j)/log(size(p_i_ThetaGamma_RandPhase,2));
    
end