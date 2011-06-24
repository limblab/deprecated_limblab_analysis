filenames = dir('*Tiki*.mat');

fit_func = 'm*x+b';
f_linear = fittype(fit_func,'independent','x');

allPDs = [];
allDates = [];
for iFile = 1:length(filenames)
    load(filenames(iFile).name)
    allPDs = [allPDs; allfilesPDs{1}(:,1:5)];
    this_date =  allfilesPDs{3};
%     this_date = this_date(1:find(this_date==' ',1,'first')-1);
    allDates(end+1) = datenum(this_date);
end

allDates = allDates - min(allDates);
% rand_idx = randperm(length(allPDs));

electrode_list = unique(allPDs(:,1));
for iElectrode = 1:length(electrode_list)
    electrode_pds{iElectrode} = allPDs(allPDs(:,1)==electrode_list(iElectrode),:);
%     subplot(10,10,iElectrode)

%     errorbar(allDates, unwrap(electrode_pds{iElectrode}(:,4)),electrode_pds{iElectrode}(:,4)-electrode_pds{iElectrode}(:,3),...
%         electrode_pds{iElectrode}(:,5)-electrode_pds{iElectrode}(:,4));
%     plot(allDates, unwrap(electrode_pds{iElectrode}(:,4)))
%     temp = std(unwrap(electrode_pds{iElectrode}(:,4)));
%     electrode_std(iElectrode) = min(temp,abs(temp-2*pi));
%     rand_idx = round(rand(1,length(electrode_pds{iElectrode}(:,4)))*(length(allPDs)-1))+1;
%     temp = std(unwrap(sort(allPDs(rand_idx,4))));
%     rand_std(iElectrode) =  min(temp,abs(temp-2*pi)); 

    pdmeans = electrode_pds{iElectrode}(:,4);
    temp = length(pdmeans)/(sqrt(sum(cos(pdmeans)).^2 + sum(sin(pdmeans)).^2));
    spread = acos(1/temp);
    electrode_spread(iElectrode) = spread;
    rand_idx = round(rand(1,length(electrode_pds{iElectrode}(:,4)))*(length(allPDs)-1))+1;
    randpdmeans = allPDs(rand_idx,4);
    temp = length(randpdmeans)/(sqrt(sum(cos(randpdmeans)).^2 + sum(sin(randpdmeans)).^2));
    spread = acos(1/temp);
    random_spread(iElectrode) = spread;   
end
%%
figure
subplot(211)
hist(electrode_spread*180/pi,0:1:90)
ylabel('Count')
title(['Multiunit PD across ' num2str(floor(allDates(end))) ' days'])
subplot(212)
hist(random_spread*180/pi,0:10:90)
xlabel('PD spread (deg)')
ylabel('Count')
title(['Random multiunit PD across ' num2str(floor(allDates(end))) ' days']);

%%
same_electrode_diff = zeros(1,100000);
different_electrode_diff = zeros(1,5000000);
same_counter = 0;
diff_counter = 0;
for i = 1:length(allPDs)-1
    for j = i+1:length(allPDs)
        if allPDs(i,1)==allPDs(j,1)
            same_counter = same_counter+1;
            temp = abs(allPDs(i,4)-allPDs(j,4));
            temp = min(temp,abs(temp-2*pi));
            same_electrode_diff(same_counter) = temp;
        else
            diff_counter = diff_counter+1;
            temp = abs(allPDs(i,4)-allPDs(j,4));
            temp = min(temp,abs(temp-2*pi));
            different_electrode_diff(diff_counter) = temp;
        end
    end
end

same_electrode_diff = same_electrode_diff(1:same_counter);
different_electrode_diff = different_electrode_diff(1:diff_counter);

figure
subplot(211)
hist(same_electrode_diff*180/pi)
ylabel('Count')
title('Same electrode (across days)')
subplot(212)
hist(different_electrode_diff*180/pi)
xlabel('PD difference (deg)')
title('Different electrodes')

%%
figure;
pdmeans= allPDs(:,4);
% pdmeans = reshape(pdmeans,96,[]);
pdconfs =allPDs(:,5)-allPDs(:,3);
spread = zeros(size(electrode_list));
confs = zeros(size(electrode_list));
for iElectrode = 1:length(electrode_list)
    pdmeans_temp = pdmeans(allPDs(:,1)==electrode_list(iElectrode));
    length(pdmeans_temp)
    if length(pdmeans_temp)>2
        mmm = length(pdmeans_temp)./sqrt(sum(cos(pdmeans_temp')).^2 + sum(sin(pdmeans_temp')).^2);
        spread(iElectrode) = acos(1./mmm);
    %     pdmeans_electrode(iElectrode) = pdmeans_temp
    else
        spread(iElectrode) = nan;
    end
    confs(iElectrode) = mean(pdconfs(allPDs(:,1)==electrode_list(iElectrode)));
end
confs = confs(~isnan(spread));
spread = spread(~isnan(spread));
% confs = reshape(pdconfs,96,[]);
% confs = mean(confs,2);
% mmm = size(pdmeans,2)./sqrt(sum(cos(pdmeans')).^2 + sum(sin(pdmeans')).^2);
% spread = acos(1./mmm);
confs_deg = 180*confs/pi;
spread_deg = 180*spread/pi;
plot(confs_deg,spread_deg,'k.')
[confs_spread_fit,gof] = fit(confs_deg,spread_deg,f_linear);
hold on
plot(confs_spread_fit);
xlabel('Uncertainty (deg)')
ylabel('Spread (deg)')
legend off
xlim([0 360])
ylim([0 90])

plot(confs_deg(confs_deg<30),spread_deg(confs_deg<30),'r.')