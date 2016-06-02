if (exist('BMI_analysis','dir') ~= 7)
    load_paths;
end

monkey{1} = 'Chewie'; monkey{2} = 'Mini';
datasets(1) = 9; datasets(2) = 10; % 9 files for Chewie and 10 for Mini

gvaf = cell(1,length(monkey));
hybvaf = cell(1,length(monkey));

for m = 1:length(monkey)
    
for dataset = 1:datasets(m)
        
% load binnedData and decoder files
load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_binned_' num2str(dataset) '.mat']);
load(['C:\Users\Nicholas Sachs\Desktop\SD_Datasets\' monkey{m} '_decoder_' num2str(dataset) '.mat']);

target = ones(length(binnedData.timeframe),2)*1000;
target_distance = zeros(length(target),1);
target_flag = 0;
target_index = 0;

word_index = 0;
word = 0;

trial = 0;

for x = 1:length(target)
    
    if word_index < length(binnedData.words)
        if binnedData.timeframe(x) >= binnedData.words(word_index+1,1)
            word_index = word_index + 1;
            word = binnedData.words(word_index,2);
            if word == 18
                trial = trial + 1;
                target_index = 0;
            end
            if trial > 0 && word == 49
                if target_index == 0 || (binnedData.words(word_index,1) - binnedData.words(word_index-1,1) >= 0.8 && target_index < 3)
                    target_index = target_index + 1;
                    target_flag = 1;
                end
            elseif word == 32
                   target_flag = 0;
            end    
        end
    end

    if target_flag
        target(x,1) = binnedData.targets.centers(trial, target_index*2 + 1);
        target(x,2) = binnedData.targets.centers(trial, target_index*2 + 2);
    end
    
    target_distance(x) = sqrt((target(x,1)-binnedData.cursorposbin(x,1)-5)^2 + (target(x,2)-binnedData.cursorposbin(x,2)-33)^2);
    if target_distance(x) > 100
        target_distance(x) = 0;
    end
    
end

% targetDistanceRW

general_decoder.P = general_decoder.P';
movement_decoder.P = movement_decoder.P';
posture_decoder.P = posture_decoder.P';

gpred = predictSignals(general_decoder,binnedData);
mpred = predictSignals(movement_decoder,binnedData);
ppred = predictSignals(posture_decoder,binnedData);

wm = 1./(1+exp(-4*(target_distance(10:end)-2.5)));
wp = 1 - wm;
hybpred = repmat(wm,1,3).*mpred.preddatabin + repmat(wp,1,3).*ppred.preddatabin;

% figure
% plot(binnedData.velocbin(10:end,1),'k')
% hold on
% plot(gpred.preddatabin(:,1),'g')
% % plot(mpred.preddatabin(:,1),'r')
% % plot(ppred.preddatabin(:,1),'b')
% plot(hybpred(:,1),'m')
% plot(wm,'b')
% plot(target_distance(10:end),'r')

figure
plot(binnedData.velocbin(10:end,1),gpred.preddatabin(:,1),'k.',[-40 40],[-40 40],'r')
title('Standard')
axis([-40 40 -40 40])
figure
plot(binnedData.velocbin(10:end,1),hybpred(:,1),'k.',[-40 40],[-40 40],'r')
title('Hybrid')
axis([-40 40 -40 40])

gooddata = true(length(hybpred),1);
if m == 1
    if dataset == 1
    elseif dataset == 2
        gooddata([908:945 1125:1190 1573:1633 2767:2867 3249:3299 3790:3860 4634:4668 4920:4973 5755:5828 7176:7213 7342:7407 8383:8440 9552:9651 10460:10540 11760:11830 12160:12220 12820:12890 13620:13660 14370:14480 14600:14630]) = false;
    elseif dataset == 3
        gooddata([2442:2564 3409:3482 3706:3919 4026:4486 4736:5072 8725:9187 9828:10140 12100:12330 14310:14410 16530:16640 17240:17330 18190:18320 19620:19690 20520:20610 21200:21340 22270:22450 23770:23810]) = false;
    elseif dataset == 4
        gooddata([4093:4154 4294:4629 5153:5328 5713:5878 6265:6316 7044:7435 ]) = false;
    elseif dataset == 5
        gooddata([9385:9587 14480:14560 21650:21770]) = false;
    elseif dataset == 6
    elseif dataset == 7
        gooddata([369:472 913:1094 1420:1493 1621:1748 2094:2302 2901:3215 3670:3827 4298:4609 4826:4975 5593:5644 5982:6098 6224:6408 7010:7070 7430:7519 7858:7917 8273:8332 8765:8818 9068:9223 9664:9756 9855:9946 10180:10260 10860:10950 11190:11290 11640:11790 10030:12160 13160:13220 13320:13460 13950:14030 14590:14720 15160:15200 15300:15470 15570:15660 16150:16340 17170:17230 17800:17980 18450:18620 19190:19280 20200:20310 20620:20760 21220:21280 21970:2204 22380:22430 22780:22850 22950:23020]) = false;
    elseif dataset == 8
    elseif dataset == 9
        gooddata([1030:1800 18150:18300 19070:19220]) = false;
    end
elseif m == 2
    if dataset == 2
    elseif dataset == 2
        gooddata([789:1040 1517:1766 3723:3913 4590:5004]) = false;
    elseif dataset == 3
        gooddata([11130:11280]) = false;
    elseif dataset == 4 % BAD FILE... Words indexing wrong
    elseif dataset == 5
    elseif dataset == 6
        gooddata([1100:1521 2970:3145 4958:5120 5399:5621 7334:7586 9938:10170]) = false;
    elseif dataset == 7
        gooddata([7200:7466 10060:10290 12020:12280 12440:12660 13190:13430 15340:15580 17260:17770]) = false;
    elseif dataset == 8
    elseif dataset == 9
        gooddata([3760:4110 8526:8747 9436:9658 10290:10580 10740:11160 13410:14140 14680:end]) = false;
    elseif dataset == 10
    end
end

gvaf{m}(dataset,:) = getvaf(binnedData.velocbin([false(9,1);gooddata],:),gpred.preddatabin(gooddata,:));
hybvaf{m}(dataset,:) = getvaf(binnedData.velocbin([false(9,1);gooddata],:),hybpred(gooddata,:));
% gvaf{m}(dataset,:) = getvaf(binnedData.velocbin(10:end,:),gpred.preddatabin);
% hybvaf{m}(dataset,:) = getvaf(binnedData.velocbin(10:end,:),hybpred);
end
end

hyb_mean = mean([hybvaf{1,1}(:,1); hybvaf{1,1}(:,2); hybvaf{1,2}([1:3 5:end],1); hybvaf{1,2}([1:3 5:end],2)])
g_mean = mean([gvaf{1,1}(:,1); gvaf{1,1}(:,2); gvaf{1,2}([1:3 5:end],1); gvaf{1,2}([1:3 5:end],2)])
hyb_std = std([hybvaf{1,1}(:,1); hybvaf{1,1}(:,2); hybvaf{1,2}([1:3 5:end],1); hybvaf{1,2}([1:3 5:end],2)])
g_std = std([gvaf{1,1}(:,1); gvaf{1,1}(:,2); gvaf{1,2}([1:3 5:end],1); gvaf{1,2}([1:3 5:end],2)])
