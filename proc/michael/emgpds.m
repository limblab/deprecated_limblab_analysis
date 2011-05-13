function [PDm,stas]  = emgpds(bdf)

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

    
    tmp_sta = STAsl(u, [t tmp_emg], timebefore, timeafter);

    
    %stas(:,:,i) = tmp_sta(:,2:end) - repmat(mean(tmp_sta(:,2:end)), size(tmp_sta,1), 1);
    
    stas(:,:,i) = tmp_sta(:,2:end);
    %STAs matrix row=time, col=Each muscle

    tsta = tmp_sta(:,1);

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
end


