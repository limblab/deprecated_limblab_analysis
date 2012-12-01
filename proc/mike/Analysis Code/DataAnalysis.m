i =1;

RsqChewie(i,:) = r2m
VafChewie(i,:) = vmean

i = i+1;

j=1;
for i = 1:length(RsqChewie)/3
    
    RsqBefore(i,:) = RsqChewie((j-1)*3+1,:);
    VafBefore(i,:) = VafChewie((j-1)*3+1,:);
    RsqAfter(i,:) = RsqChewie(j*3,:);
    VafAfter(i,:) = VafChewie(j*3,:);
    
    j = j+1;
end

RsqBefmean = mean(mean(RsqBefore,2));
RsqAftmean = mean(mean(RsqAfter,2));
RsqBaselinemean = mean(mean(RsqBaselineChewie,2));
VafBefmean = mean(mean(VafBefore,2));
VafAftmean = mean(mean(VafAfter,2));

RsqBefstd = std(mean(RsqBefore,2));
RsqAftstd = std(mean(RsqAfter,2));
RsqBaselineStd = std(mean(RsqBaselineChewie,2));
VafBefstd = std(mean(VafBefore,2));
VafAftstd = std(mean(VafAfter,2));

errorbar([RsqBefmean RsqAftmean RsqBaselineMean],[RsqBefstd/sqrt(3) RsqAftstd/sqrt(3) RsqBaselineStd],'ro')


figure
errorbar([VafBefmean VafAftmean],[VafBefstd VafAftstd],'bx')
