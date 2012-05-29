%X_cross_corr = [peakValAll_x DecoderAges'];
%Y_cross_corr = [peakValAll_y DecoderAges'];
X_cross_corr_sortByDay = sortrows(X_cross_corr,577);
Y_cross_corr_sortByDay = sortrows(Y_cross_corr,577);
Y_cross_corr_sortByDay = Y_cross_corr_sortByDay';
X_cross_corr_sortByDay = X_cross_corr_sortByDay';

FileNum = 1;
DayIndex = 1;    
X_cross_corr_sortByDay_avg(:,DayIndex) = X_cross_corr_sortByDay(:,1);
Y_cross_corr_sortByDay_avg(:,DayIndex) = Y_cross_corr_sortByDay(:,1);

for i = 1:size(X_cross_corr_sortByDay,2)-1
   
    if X_cross_corr_sortByDay(577,i) == X_cross_corr_sortByDay(577,i+1)
        
        X_cross_corr_sortByDay_avg(1:576,DayIndex) = X_cross_corr_sortByDay_avg(1:576,DayIndex) + ...
            X_cross_corr_sortByDay(1:576,i+1);
        Y_cross_corr_sortByDay_avg(1:576,DayIndex) = Y_cross_corr_sortByDay_avg(1:576,DayIndex) + ...
            Y_cross_corr_sortByDay(1:576,i+1);
        FileNum = FileNum +1;
        
    else
        
        X_cross_corr_sortByDay_avg(1:576,DayIndex) = X_cross_corr_sortByDay_avg(1:576,DayIndex)./FileNum;
        Y_cross_corr_sortByDay_avg(1:576,DayIndex) = Y_cross_corr_sortByDay_avg(1:576,DayIndex)./FileNum;
        DayIndex = DayIndex + 1;
        X_cross_corr_sortByDay_avg(:,DayIndex) = X_cross_corr_sortByDay(:,i+1);
        Y_cross_corr_sortByDay_avg(:,DayIndex) = Y_cross_corr_sortByDay(:,i+1);
        FileNum = 1;
        
        
    end
end
% ADDED CODE RDF 05/24/2012.  wasn't doing the division for the final file,
% so that day's values were approx. 2x what they should be.
X_cross_corr_sortByDay_avg(1:576,DayIndex) = X_cross_corr_sortByDay_avg(1:576,DayIndex)./FileNum;
Y_cross_corr_sortByDay_avg(1:576,DayIndex) = Y_cross_corr_sortByDay_avg(1:576,DayIndex)./FileNum;

X_cross_corr_sortByDay_avg_99 = X_cross_corr_sortByDay_avg(featindBEST,:);
X_cross_corr_sortByDay_avg_99_sortByFreq = [X_cross_corr_sortByDay_avg_99 bestf'];

Y_cross_corr_sortByDay_avg_99 = Y_cross_corr_sortByDay_avg(featindBEST,:);
Y_cross_corr_sortByDay_avg_99_sortByFreq = [Y_cross_corr_sortByDay_avg_99 bestf'];

% MODIFIED CODE - RDF 05/24/2012. Made general the column selected for use in
% sorting by feature.
X_cross_corr_sortByDay_avg_99_sortByFreq = sortrows(X_cross_corr_sortByDay_avg_99_sortByFreq, ...
    size(X_cross_corr_sortByDay_avg_99_sortByFreq,2));
Y_cross_corr_sortByDay_avg_99_sortByFreq = sortrows(Y_cross_corr_sortByDay_avg_99_sortByFreq, ...
    size(X_cross_corr_sortByDay_avg_99_sortByFreq,2));

for i = 1:size(Y_cross_corr_sortByDay_avg,2)
DayLabel{i} = int2str(Y_cross_corr_sortByDay_avg(577,i));
end

NumDays = length(DayLabel);

% imagesc(X_cross_corr_sortByDay_avg_99(:,1:end));figure(gcf);
% title('X cross correlation sorted by Day Chewie HC')
% set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure; 
imagesc(X_cross_corr_sortByDay_avg_99_sortByFreq(1:71,1:end-2));figure(gcf);
title('X cross correlation sorted by Day and Freq Mini -- LMP')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure
imagesc(X_cross_corr_sortByDay_avg_99_sortByFreq(71:120,1:end-2));figure(gcf);
title('X cross correlation sorted by Day and Freq Mini -- Delta')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
% figure
% imagesc(X_cross_corr_sortByDay_avg_99_sortByFreq(71:120,1:end-2));figure(gcf);
% title('X cross correlation sorted by Day and Freq Mini -- Gamma 70-115')
% set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure
imagesc(X_cross_corr_sortByDay_avg_99_sortByFreq(121:133,1:end-2));figure(gcf);
title('X cross correlation sorted by Day and Freq Mini -- Gamma 130-200')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure
imagesc(X_cross_corr_sortByDay_avg_99_sortByFreq(134:end,1:end-2));figure(gcf);
title('X cross correlation sorted by Day and Freq Mini -- Gamma 200-300')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
%set(gca,'YTick',[1,23,46,60,78],'YTickLabel',{'LMP','Delta','70-115','130-200','200-300'})
figure
imagesc(Y_cross_corr_sortByDay_avg_99_sortByFreq(1:71,1:end-2));figure(gcf);
title('Y cross correlation sorted by Day and Freq Mini -- LMP')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure
imagesc(Y_cross_corr_sortByDay_avg_99_sortByFreq(72:120,1:end-2));figure(gcf);
title('Y cross correlation sorted by Day and Freq Mini -- Delta')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
% figure
% imagesc(Y_cross_corr_sortByDay_avg_99_sortByFreq(46:59,1:end-2));figure(gcf);
% title('Y cross correlation sorted by Day and Freq Mini -- Gamma 70-115')
% set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure
imagesc(Y_cross_corr_sortByDay_avg_99_sortByFreq(121:133,1:end-2));figure(gcf);
title('Y cross correlation sorted by Day and Freq Mini -- Gamma 130-200')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
figure
imagesc(Y_cross_corr_sortByDay_avg_99_sortByFreq(134:end,1:end-2));figure(gcf);
title('Y cross correlation sorted by Day and Freq Mini -- Gamma 200-300')
set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)
%set(gca,'YTick',[1,23,46,60,78],'YTickLabel',{'LMP','Delta','70-115','130-200','200-300'})
% figure
% imagesc(Y_cross_corr_sortByDay_avg_99(:,1:end));figure(gcf);
% title('Y cross correlation sorted by Day Mini')
% set(gca,'XTick',[1:NumDays],'XTickLabel',DayLabel)


% imagesc(X_cross_corr_sortByDay_avg(featindBEST,:));figure(gcf);
% for i = 1:20
% DayLabel{i} = int2str(X_cross_corr_sortByDay_avg(577,i));
% end
% set(gca,'XTick',[1:20],'XTickLabel',DayLabel)