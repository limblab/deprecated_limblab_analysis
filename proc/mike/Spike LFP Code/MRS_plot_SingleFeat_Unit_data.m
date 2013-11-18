%% Plot code
plotWhat = 2;

%if plotWhat == 1 you're plotting LFPs, if 2, spikes.

if plotWhat == 1
    
    for q = 1:size(Onlinefeatind,2)
    
    [C,sortInd]=sortrows(OnlinefeatInd(:,q));
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
    
    Monkey = 1; % 1 == Chewie, 2 == Mini
    fileStart = 154; % 0 if starting on first file, else one less than file to start on
    
    for q = 1:size(DecNeuronIDsOUT,3)
        
        for i = 1:(length(Monkeys{Monkey})-fileStart)
            
            for k = 1:size(DecNeuronIDsOUT{i+fileStart,Monkey,q},1)
                
                if DecNeuronIDsOUT{i+fileStart,Monkey,q}(k,1) == 0
                    continue
                else
                    DecNeuronIDsMAT(DecNeuronIDsOUT{i+fileStart,Monkey,q}(k,1),i,q) = k;
                end
                
            end
        end
    end
    
    
     j = 1;
     k = 1;
     
     columnSize = size(DecNeuronIDsMAT,2);
     ThirdDimSize = size(DecNeuronIDsMAT,3);
     r2_X_SingleUnitsMAT = zeros(96, columnSize, ThirdDimSize);
     r2_Y_SingleUnitsMAT = zeros(96, columnSize, ThirdDimSize);
     
    if size(r2_X_SingleUnits,3)== 1
        TestFileStart = 1;
    else
        TestFileStart = size(r2_X_SingleUnits,3)-5;
    end
     
    for i = TestFileStart:size(r2_X_SingleUnits,3)
            %1:6
        for m = 1:(length(Monkeys{Monkey})-fileStart)
            
            for p = 1:size(DecNeuronIDsMAT,1)
                
                if DecNeuronIDsMAT(p,m,j) == 0
                    r2_X_SingleUnitsMAT(p,k,j) = 1;
                    r2_Y_SingleUnitsMAT(p,k,j) = 1;
                else
%                     try
                        r2_X_SingleUnitsMAT(p,k,j) = r2_X_SingleUnits{(m+fileStart),Monkey,i}(DecNeuronIDsMAT(p,m,j));
                        r2_Y_SingleUnitsMAT(p,k,j) = r2_Y_SingleUnits{(m+fileStart),Monkey,i}(DecNeuronIDsMAT(p,m,j));
                    
%                     catch
%                         r2_X_SingleUnitsMAT(p,k,j) = 2;
%                         r2_Y_SingleUnitsMAT(p,k,j) = 2;
%                         continue
%                         
%                     end
                end
            end
            k = k + 1;
        end
        k = 1;
        j = j +1;
        
    end
    
    r2_X_SingleUnitsMATavg = mean(r2_X_SingleUnitsMAT,3);
    r2_Y_SingleUnitsMATavg = mean(r2_Y_SingleUnitsMAT,3);
            
    
    
    
end

r2_X_SingleUnitsFirstFile = cell2mat(r2_X_SingleUnits(:,:,end-5:end))

r2_X_SingleUnitsFirstFile = cell2mat(r2_X_SingleUnits);
r2_X_SingleUnitsFirstFile(isnan(r2_X_SingleUnitsFirstFile)==1) = 0;
r2_X_SingleUnitsFirstFile = reshape(r2_X_SingleUnitsFirstFile,[150,size(H_SingleUnits,2),size(H_SingleUnits,2)]);
r2_X_SingleUnitsAvg = mean(r2_X_SingleUnitsFirstFile,3);

r2_Y_SingleUnitsFirstFile = cell2mat(r2_Y_SingleUnits);
r2_Y_SingleUnitsFirstFile(isnan(r2_Y_SingleUnitsFirstFile)==1) = 0;
r2_Y_SingleUnitsFirstFile = reshape(r2_Y_SingleUnitsFirstFile,[150,size(H_SingleUnits,2),size(H_SingleUnits,2)]);
r2_Y_SingleUnitsAvg = mean(r2_Y_SingleUnitsFirstFile,3);


r2_X_SingleUnitsFirstFileDec1_HC = [r2_X_SingleUnitsFirstFile bestf_bychan(:,1)];
r2_Y_SingleUnitsFirstFileDec1_HC = [r2_Y_SingleUnitsFirstFile bestf_bychan(:,1)];

r2_X_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_X_SingleUnitsFirstFileDec1_HC,[size(r2_X_SingleUnitsFirstFileDec1_HC,2) -1]);
r2_Y_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileDec1_HC,[size(r2_Y_SingleUnitsFirstFileDec1_HC,2) -1]);
imagesc(sqrt(r2_X_SingleUnitsFirstFileDec1_HCSorted(:,1:end-2)));figure(gcf);
title('X Vel Single Feature Dec 1 First File Performance Hand Control-- Chewie')

imagesc(sqrt(r2_X_SingleUnitsFirstFileDec1_HCSorted(:,First_File_Index(:))));figure(gcf);
set(gca,'YTick',[1,78,98,123],'YTickLabel',{'LMP','Delta','130-200','200-300'})
set(gca,'YTick',[1,84,124,126,138],'YTickLabel',{'LMP','Delta','Mu','130-200','200-300'})
set(gca,'YTick',[1,87,124,128,137],'YTickLabel',{'LMP','Delta','70-110','130-200','200-300'})
set(gca,'YTick',[1,83,102,131,135,140],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
caxis([0 .6])


figure;
r2_Y_SingleUnitsFirstFileAvgDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileAvgDec1_HC,[length(r2_Y_SingleUnitsFirstFileAvgDec1_HC) -8]);
imagesc(sqrt(r2_Y_SingleUnitsFirstFileDec1_HCSorted(:,1:end-2)));figure(gcf);
figure;
imagesc(sqrt(r2_Y_SingleUnitsFirstFileDec1_HCSorted(:,First_File_Index(:))));figure(gcf);
title('Y Vel Single Feature Dec 1 First File Performance Hand Control -- Chewie')

set(gca,'XTick',[1:4:96],'XTickLabel',{Chewie_LFP1_FirstFileNames{1:4:96,2}})

% Mini X-vel SFD
imagesc(sqrt(r2_X_SingleUnitsSorted_DayAvg_Valid));figure(gcf);
set(gca,'YTick',[1,72,88],'YTickLabel',{'LMP','130-200','200-300'})
set(gca,'XTick',[1:10:41 48],'XTickLabel',{'156','180','205','239','271','307'})
caxis([0 .6])

set(gca,'XTick',[1:10:71 77],'XTickLabel',{'111','134','154','176','200','223','251','294','323'})
set(gca,'YTick',[1,33,66,71,92,117],'YTickLabel',{'LMP','Delta','Mu','70-110','130-200','200-300'})
caxis([0 .6])

%y-label
bandLabelsY=LFP_AllFreq_Online_Sorted_NoDelta(:,2);
[uBands,uBandYticks,~]=unique(bandLabelsY);
uBandYticks=[1; uBandYticks(1:end-1)+1];
allBands={'LMP','Delta','Mu','70-100','130-200','200-300'};
set(gca,'YTick',uBandYticks,'YTickLabel',allBands(uBands))

%x-label - Chewie
Xlabels=ChewieLFP2_DayNames;

Xticks=[1:5:size(Xlabels,1) size(Xlabels,1)];
allXticks= [ChewieLFP2_DayNames_Valid(1:5:end,2); ChewieLFP2_DayNames_Valid(end,2)];
set(gca,'XTick',Xticks,'XTickLabel',allXticks)

%x-label Mini
Xlabels=r2_X_SingleUnits_Dayavg_sorted(13:end,:);

Xticks=[1:4:size(Xlabels,2)] %size(Xlabels,2)-1];
allXticks= [Mini_DayNames(1:4:end,2)]%; Mini_DayNames_BadFileRemov(end,2)];
set(gca,'XTick',Xticks,'XTickLabel',allXticks)

