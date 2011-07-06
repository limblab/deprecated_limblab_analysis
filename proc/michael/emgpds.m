function [PDm,stas]  = emgpds(bdf)
function [PDm stasnorm]  = emgpds(bdf)


% emgpds.m
% Calculates STA based PDS in emgspace from bdf

% $Id: $




List=unit_list(bdf);
List = List(List(:,2)~=0 & List(:,2) ~=255,:);


exclEMG=1;
%Last muscle EMG no good

nEmgs = size(bdf.emg.data,2) - 1- exclEMG;
%-1 for time column


timebefore= 2;
timeafter=2;
stas = zeros((bdf.emg.emgfreq*(timebefore+timeafter))+1,nEmgs,length(List));
t = bdf.emg.data(:,1);
tmp_emg = zeros(size(bdf.emg.data,1),size(bdf.emg.data,2) - exclEMG);




PDm= zeros(length(List), nEmgs+4);

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
tic
for i=1:length(List)
%for i=1

    update=sprintf('%s %g %s %g', 'Now running unit',i, 'of', length(List));
    disp(update);

    u= get_unit(bdf, List(i,1), List(i,2));

    tmp_emg = bdf.emg.data(:, 2 : size(bdf.emg.data,2) - exclEMG);
    %var_emg = var(tmp_emg);
    p=prctile(tmp_emg,[5,50,95]);
    tmp_emg=(tmp_emg-p(2))/(p(3)-p(1));
    %tmp_emg = tmp_emg.*(repmat(var_emg, size(tmp_emg,1),1).^-1);

    for emg_id=1:nEmgs
     
        tmp_emg(:,emg_id) = smooth(abs(tmp_emg(:,emg_id)), 201);

    
    end
    %Rectify and smooth EMG signals

    %u=rand(1,3000)*bdf.meta.duration;
    
    tmp_sta = STAsl(u, [t tmp_emg], timebefore, timeafter);

    %Calculate STA with smoothed, rectified, normalized, and baseline
    %subtracted EMG envelope
    
    %stas(:,:,i) = tmp_sta(:,2:end) - repmat(mean(tmp_sta(:,2:end)), size(tmp_sta,1), 1);
    
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


