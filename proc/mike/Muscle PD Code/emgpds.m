function [PDm stasnorm]  = emgpds(bdf)
%% Variable Declaration and Memory Pre-allocation

%Calculates STA based PDS in emgspace from bdf
% $Id: $

List=unit_list(bdf);
%Gets list of all units from bdf

List = List(List(:,2)~=0 & List(:,2) ~=255,:);
%Excludes all units which are not well-defined/sorted

exclEMG=1;
%Last muscle EMG no good

nEmgs = size(bdf.emg.data,2) - 1- exclEMG;
%-1 for time column

timebefore= 2;
timeafter=2;
%Define time window before and after spike for STA

stas = zeros((bdf.emg.emgfreq*(timebefore+timeafter))+1,nEmgs,length(List));
stasnorm = zeros((bdf.emg.emgfreq*(timebefore+timeafter))+1,nEmgs,length(List));
PDm= zeros(length(List), nEmgs+4);
%Preallocate memory for speed

%% EMG Pre-processing

t = bdf.emg.data(:,1);
tmp_emg = bdf.emg.data(:, 2 : size(bdf.emg.data,2) - exclEMG);

%Find 1st 50th and 99th percentile of data in order to normalize properly
p=prctile(tmp_emg,[1,50,99]);

%Subtract mean (50th %tile) and divide by difference of 99th and 1st %tile
tmp_emg=(tmp_emg-repmat(p(2,:),length(tmp_emg),1))./(repmat(p(3,:),length(tmp_emg),1)-repmat(p(1,:),length(tmp_emg),1));

for emg_id=1:nEmgs
    tmp_emg(:,emg_id) = smooth(abs(tmp_emg(:,emg_id)), 201);
end
%Rectify and smooth EMG signals

EMG_baseline_start= 37000;
EMG_baseline_end = 46000;
%Pick a period of data which is representative of baseline activity

tmp_emg(:,:)= tmp_emg(:,:)-repmat(mean(tmp_emg(EMG_baseline_start:EMG_baseline_end,:)),length(tmp_emg),1);
%Subtract baseline of EMG envelope


%% STA and PDm Calculation
tic
for i=1:length(List)
%for i=1

    update=sprintf('%s %g %s %g', 'Now running unit',i, 'of', length(List));
    disp(update);

    u= get_unit(bdf, List(i,1), List(i,2));
    %Gets spike times for all sorted units

    tmp_sta = STAsl(u, [t tmp_emg], timebefore, timeafter);
    %Calculate STA with smoothed, rectified, normalized, and baseline
    %subtracted EMG envelope-(tmp_emg)
    
    stas(:,:,i) = tmp_sta(:,2:end);
    %STAs matrix row=time, col=Each muscle

    tsta = tmp_sta(:,1);

    stasnorm(:,:,i) = tmp_sta(:,2:end) - repmat((mean(tmp_sta(1:1000,2:end))+mean(tmp_sta(7000:8000,2:end)))/2, size(tmp_sta,1), 1);
    %Subtract mean to normalize

    n = sqrt(sum(stas(:,:,i).^2,2));
    %Calculate magnitude of STAs across time
    
    opt_delay = find(n==max(n), 1, 'first');
    %Find index of maximum magnitude STA
    
    opt_delay_t = tsta(opt_delay);
    %Index time array tsta to find the optimum delay=opt_delay
    
    %stas(:,:,i) = tmp_sta(:,2:end) - repmat(mean(tmp_sta(****,2:end)), size(tmp_sta,1), 1);
    %Subtract mean to normalize
    
    PDm(i,1)= List(i,1);
    PDm(i,2)= List(i,2);
    PDm(i,3)= opt_delay_t;
    PDm(i,4)= length(u);

    PDm(i,5:end) = stas(opt_delay,:,i);
    PDm(i,5:end) = PDm(i,5:end)./ sqrt(sum(PDm(i,5:end).^2));
    %Assign STAs at opt_delay to PDM and convert STA vector to unit vector by dividing
    %by vector length
    toc
end