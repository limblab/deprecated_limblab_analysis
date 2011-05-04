function [PDm,Allstas]  = emgpds(bdf)

% emgpds.m
% Calculates STA based PDS in emgspace from bdf

% $Id: $

List=unit_list(bdf);
List = List(List(:,2)~=0 & List(:,2) ~=255,:);

exclEMG=1;
%Last muscle EMG no good

nEmgs = size(bdf.emg.data,2) - 1- exclEMG;
%-1 for time column


timebefore= 0.25;
timeafter=0.25;
stas = zeros(nEmgs, (bdf.emg.emgfreq*(timebefore+timeafter))+1);
t = bdf.emg.data(:,1);

Allstas = zeros(nEmgs,(bdf.emg.emgfreq*(timebefore+timeafter))+1,length(List));
%Save All calculated STAs for each unit

for i=1:length(List)
    
    update=sprintf('%s %g %s %g', 'Now running',i, 'of', length(List));
    disp(update);
    
    u= get_unit(bdf, List(i,1), List(i,2));
    
    for emg_id = 1:nEmgs
        disp(emg_id);
        tmp_emg = bdf.emg.data(:,emg_id+1);
        tmp_emg = tmp_emg ./ var(tmp_emg);
        tmp_emg = smooth(abs(tmp_emg), 201);
        %Rectify and smooth EMG signals

        tmp_sta = STAsl(u, [t tmp_emg], timebefore, timeafter);
        
        stas(emg_id,:) = tmp_sta(:,2) - repmat(mean(tmp_sta(:,2)), length(tmp_sta(:,2)), 1);
        %STAs matrix now row=Each Muscle, col=Time
        
        tsta = tmp_sta(:,1);
    end

    Allstas(:,:,i)=stas(:,:);
    n = sqrt(sum(stas.^2));
    %Calculate magnitude of STAs across time
    
    opt_delay = find(n==max(n), 1, 'first');
    %Find index of maximum magnitude STA
    
    opt_delay_t = tsta(opt_delay);
    %Index time array tsta to find the optimum delay=opt_delay
    
    PDm= zeros(nEmgs+2,length(List));
    PDm(1,i)= List(i,1);
    PDm(2,i)= List(i,2);
    
    PDm(3:end,i) = stas(:, opt_delay);
    PDm(3:end,i) = PDm(3:end,i)./ sqrt(sum(PDm(3:end,i).^2));
    %Assign STAs at opt_delay to PDM and convert STA vector to unit vector by dividing
    %by vector length
end


