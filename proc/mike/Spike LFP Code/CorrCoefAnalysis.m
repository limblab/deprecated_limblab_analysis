nfiles = 149;

AllSortedR_Mini = reshape(cell2mat(AllsortedR{2,2}),1152,nfiles);

AllSortedFeatInd = AllSortedR_Mini(577:end,:);
AllSortedR_Mini(577:end,:) = [];

LMPfeatind = [1:6:576];
Deltafeatind = [2:6:576];
Mufeatind = [3:6:576];
Gam1featind = [4:6:576];
Gam2featind = [5:6:576];
Gam3featind = [6:6:576];

LMPcount = zeros(1,nfiles);
Deltacount = zeros(1,nfiles);
Mucount = zeros(1,nfiles);
Gam1count = zeros(1,nfiles);
Gam2count = zeros(1,nfiles);
Gam3count = zeros(1,nfiles);
TopLMPs_R = zeros(150,nfiles);

for i = 1:size(AllSortedFeatInd,2)
    for j = 1:150
        
        for k = 1:length(LMPfeatind)
            
            if LMPfeatind(k) == AllSortedFeatInd(j,i)
                
                LMPcount(1,i) = LMPcount(1,i) + 1;
                TopLMPs_R(i,j) = AllSortedR_Mini(j,i);
            elseif Deltafeatind(k) == AllSortedFeatInd(j,i)
                
                Deltacount(1,i) = Deltacount(1,i) + 1;
                
            elseif Mufeatind(k) == AllSortedFeatInd(j,i)
                
                Mucount(1,i) = Mucount(1,i) + 1;
                
            elseif Gam1featind(k) == AllSortedFeatInd(j,i)
                
                Gam1count(1,i) = Gam1count(1,i) + 1;
                
            elseif Gam2featind(k) == AllSortedFeatInd(j,i)
                
                Gam2count(1,i) = Gam2count(1,i) + 1;
                
            elseif Gam3featind(k) == AllSortedFeatInd(j,i)
                
                Gam3count(1,i) = Gam3count(1,i) + 1;
            
            end
            
        end
    end
    
end

plot(LMPcount)
hold on
plot(Mucount,'r')
plot(Deltacount,'g')
plot(Gam1count,'y')
plot(Gam2count,'k')
plot(Gam3count,'y')


AllCorrCoefs_Mini_LMP = AllCorrCoefs_Mini(1:6:576,:);

figure;
plot(mean(AllCorrCoefs_Mini_LMP))



