function [PDm]  = sta_mean_subtract(bdf,stas)

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
t = bdf.emg.data(:,1);
tmp_emg = zeros(size(bdf.emg.data,1),size(bdf.emg.data,2) - exclEMG);

PDm= zeros(length(List), nEmgs+4);

for i=1:length(List)

    u= get_unit(bdf, List(i,1), List(i,2));

    tsta = -2:.0005:2;

    n = sqrt(sum(stas(:,:,i).^2,2));
    %Calculate magnitude of STAs across time
    
    opt_delay = find(n==max(n), 1, 'first');
    %Find index of maximum magnitude STA
    
    opt_delay_t = tsta(opt_delay);
    %Index time array tsta to find the optimum delay=opt_delay
    
    PDm(i,1)= List(i,1);
    PDm(i,2)= List(i,2);
    PDm(i,3)= opt_delay_t;
    PDm(i,4)= length(u);

    PDm(i,5:end) = stas(opt_delay,:,i);
    PDm(i,5:end) = PDm(i,5:end)./ sqrt(sum(PDm(i,5:end).^2));
    %Assign STAs at opt_delay to PDM and convert STA vector to unit vector by dividing
    %by vector length
end


