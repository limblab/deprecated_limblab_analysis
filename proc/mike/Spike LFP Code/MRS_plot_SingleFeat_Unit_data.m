%% Plot code
plotWhat = 2;

%if plotWhat == 1 you're plotting LFPs, if 2, spikes.

if plotWhat == 1
    
    for q = 1:size(Onlinefeatind,2)
    
    [C,sortInd]=sortrows(Onlinefeatind(:,q));
    featind_bychan = C;
    
    for j = 1:length(featind_bychan)
        bestc_bychan(j,q) = ceil(featind_bychan(j)/6);
        
        if rem(featind_bychan(j),6) ~=0
            bestf_bychan(j,q) = rem(featind_bychan(j),6);
        else
            bestf_bychan(j,q) = 6;
        end
        
    end
    end

else
    for i = 1:length(DecNeuronIDs)
        
        for k = 1:length(DecNeuronIDs{i})
            
            DecNeuronIDsMAT(DecNeuronIDs{i}(k,1),i) = k;
            
        end
    end
    
    
     j = 1;
     k = 1;
     r2_X_SingleUnitsMAT = zeros(95, 176, 5);
     
    for i = size(r2_X_SingleUnits,1)-5:size(r2_X_SingleUnits,1)
        for m = 167:size(r2_X_SingleUnits,1)
            
            for p = 1:size(DecNeuronIDsMAT,1)
                
                if DecNeuronIDsMAT(p,m) == 0
                    r2_X_SingleUnitsMAT(p,k,j) = 0;
                else
                    r2_X_SingleUnitsMAT(p,k,j) = r2_X_SingleUnits{m,1,i}(DecNeuronIDsMAT(p,m));
                end
            end
            k = k + 1;
        end
        k = 1;
        j = j +1;
        
    end
            
            
            
        end
    end
    
    r2_X_SingleUnitsFirstFile = cell2mat(r2_X_SingleUnits(:,:,end-5:end)
    
end



r2_X_SingleUnitsFirstFile = cell2mat(r2_X_SingleUnits);
r2_X_SingleUnitsFirstFile(isnan(r2_X_SingleUnitsFirstFile)==1) = 0;
%r2_X_SingleUnitsFirstFile = reshape(r2_X_SingleUnitsFirstFile,[150,size(H_SingleUnits,2),size(H_SingleUnits,2)]);
% r2_X_SingleUnitsAvg = mean(r2_X_SingleUnitsFirstFile,3);

r2_Y_SingleUnitsFirstFile = cell2mat(r2_Y_SingleUnits);
r2_Y_SingleUnitsFirstFile(isnan(r2_Y_SingleUnitsFirstFile)==1) = 0;
%r2_Y_SingleUnitsFirstFile = reshape(r2_Y_SingleUnitsFirstFile,[150,size(H_SingleUnits,2),size(H_SingleUnits,2)]);
% r2_Y_SingleUnitsAvg = mean(r2_Y_SingleUnitsFirstFile,3);


r2_X_SingleUnitsFirstFileDec1_HC = [r2_X_SingleUnitsFirstFile bestf_bychan(:,1)];
r2_Y_SingleUnitsFirstFileDec1_HC = [r2_Y_SingleUnitsFirstFile bestf_bychan(:,1)];

r2_X_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_X_SingleUnitsFirstFileDec1_HC,[size(r2_X_SingleUnitsFirstFileDec1_HC,2) -1]);
r2_Y_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileDec1_HC,[size(r2_Y_SingleUnitsFirstFileDec1_HC,2) -1]);
imagesc(sqrt(r2_X_SingleUnitsFirstFileDec1_HCSorted(:,1:end-2)));figure(gcf);
title('X Vel Single Feature Dec 1 First File Performance Hand Control-- Chewie')

%imagesc(sqrt(r2_X_SingleUnitsFirstFileDec1_HCSorted(:,First_File_Index(:))));figure(gcf);
% set(gca,'YTick',[1,78,98,123],'YTickLabel',{'LMP','Delta','130-200','200-300'})
% set(gca,'YTick',[1,84,124,126,138],'YTickLabel',{'LMP','Delta','Mu','130-200','200-300'})
% set(gca,'YTick',[1,87,124,128,137],'YTickLabel',{'LMP','Delta','70-110','130-200','200-300'})
% set(gca,'YTick',[1,83,102,131,135,140],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
% %set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
caxis([0 .6])

% set(gca,'YTick',[1,72,121,137],'YTickLabel',{'LMP','Delta','130-200','200-300'})
figure;
%r2_Y_SingleUnitsFirstFileAvgDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileAvgDec1_HC,[length(r2_Y_SingleUnitsFirstFileAvgDec1_HC) -8]);
imagesc(sqrt(r2_Y_SingleUnitsFirstFileDec1_HCSorted(:,1:end-2)));figure(gcf);
%figure;
%imagesc(sqrt(r2_Y_SingleUnitsFirstFileDec1_HCSorted(:,First_File_Index(:))));figure(gcf);
title('Y Vel Single Feature Dec 1 First File Performance Hand Control -- Chewie')
% set(gca,'YTick',[1,72,121,137],'YTickLabel',{'LMP','Delta','130-200','200-300'})
% set(gca,'XTick',[1:4:96],'XTickLabel',{Chewie_LFP1_FirstFileNames{1:4:96,2}})
% %set(gca,'XTick',[1, 50, 100, 150, 200,224],'XTickLabel',{'9-01-2011','12-29-2011', '2-02-2012', '3-28-2012', '5-22-2012','7-23-2012'})
% %set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
caxis([0 .6])