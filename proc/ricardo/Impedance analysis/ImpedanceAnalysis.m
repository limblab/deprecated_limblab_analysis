filedate = '2012-03-05';
directory = 'Y:\Pedro_4C2\Microdrive\';

broken = {'b-7','e-4','i-5'};
broken = {'b-7','e-4','i-5','a-1','a-6','b-4','c-4','g-7','h-3'};

filelist = dir([directory '*impedances*' filedate '*']);
filelist = struct2cell(filelist);
filelist = filelist(1,:);
filelist = filelist(~strcmp(filelist(1,:),'.') & ~strcmp(filelist(1,:),'..'));
% ids = '';
electrodes_all = [];
for iFile = 1:length(filelist)
    filename = strcat(directory,filelist{iFile});
    electrodes = ReadImpedanceFile(filename); 
    for iElectrode = 1:length(electrodes)
        electrodes(iElectrode).file = filename;
    end
    electrodes_all = [electrodes_all electrodes];
end
remove_idx = [];
for iElectrode = 1:length(electrodes_all)    
    for iBroken = 1:length(broken)
        if strcmp(electrodes_all(iElectrode).id,broken(iBroken))
            remove_idx(end+1) = iElectrode;
        end
    end
end
electrodes_all(remove_idx) = [];    

electrode_ids = unique({electrodes_all.id});
filenames = unique({electrodes_all.file});
impedance = nan(length(filenames),length(electrode_ids));
for iElectrode = 1:length(electrode_ids)
    for iFile = 1:length(filenames)
        idx = strcmp({electrodes_all.id},electrode_ids(iElectrode)) &...
            strcmp({electrodes_all.file},filenames(iFile));
        if sum(idx)>0
            impedance(iFile,iElectrode) = electrodes_all(idx).impedance;
        end
    end
end

figure;
plot(impedance)
xlabel('File number')
ylabel('Z (kOhms)')


figure;
noise = std(impedance)./mean(impedance);
[noise_vals idx] = sort(noise,'descend');
plot(mean(impedance),noise,'.')
% hold on
% plot(impedance(end,:),noise,'.r')
xlabel('mean(Z) (kOhms)')
ylabel('std(Z)/mean(Z)')

figure;
semilogy(impedance,'b')
hold on
semilogy(impedance(:,idx(5)),'r')
xlabel('File number')
ylabel('Z (kOhms)')
text(1.5,30,electrode_ids(idx(5)),'Color','r')

figure;
loglog(impedance(1,:),impedance(end,:),'.')
xlabel('Z first file (kOhms)')
ylabel('Z last file (kOhms)')

figure;
hist(impedance(end,:),25)