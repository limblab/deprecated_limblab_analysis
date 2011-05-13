filenames = dir('*Pedro*');

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
    temp = std(unwrap(electrode_pds{iElectrode}(:,4)));
    electrode_std(iElectrode) = min(temp,abs(temp-2*pi));    
    rand_idx = round(rand(1,length(electrode_pds{iElectrode}(:,4)))*(length(allPDs)-1))+1;
    temp = std(unwrap(sort(allPDs(rand_idx,4))));
    rand_std(iElectrode) =  min(temp,abs(temp-2*pi));    
end

figure
subplot(211)
hist(electrode_std*180/pi)
ylabel('Count')
title(['Multiunit PD across ' num2str(floor(allDates(end))) ' days'])
subplot(212)
hist(rand_std*180/pi)
xlabel('Std (deg)')
ylabel('Count')
title(['Random multiunit PD across ' num2str(floor(allDates(end))) ' days']);

same_electrode_diff = zeros(1,50000);
different_electrode_diff = zeros(1,1000000);
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

figure;
pdmeans= allPDs(:,4);
pdmeans = reshape(pdmeans,96,[]);
pdconfs =allPDs(:,5)-allPDs(:,3);
confs = reshape(pdconfs,96,10);
confs = mean(confs,2);
mmm = size(pdmeans,2)./sqrt(sum(cos(pdmeans')).^2 + sum(sin(pdmeans')).^2);
drift = acos(1./mmm);
plot(180*confs/pi,180*drift/pi,'k.')
xlabel('Uncertainty (deg)')
ylabel('Drift (deg)')