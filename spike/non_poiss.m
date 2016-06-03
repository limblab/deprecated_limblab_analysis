function [frvar, fanno, lpvar] = non_poiss(bdf)
% NON_POISS returns the firing rate variance and fano factor for each neuon
% in the supplied bdf

ul = unit_list(bdf);

t = bdf.vel(1,1):.025:bdf.vel(end,1);
t2 = bdf.vel(1,1):.5:bdf.vel(end,1);

frvar = zeros(1,length(ul));
fanno = zeros(1,length(ul));

for unit_num = 1:length(ul)
    ts = get_unit(bdf, ul(unit_num, 1), ul(unit_num, 2));
    b = train2bins(ts, t);
    b2 = train2bins(ts, t2);
    
    %[a2, a1] = butter(4, 3/500, 'low');
    %b2 = filtfilt(a2, a1, b2);
    
    b2 = sort(b2);
    
    frvar(unit_num) = var(b);
    fanno(unit_num) = mean(b2);%var(b)/mean(b);
    lpvar(unit_num) = -mean(b2(1:5))+mean(b2(end-5:end));%var(b2);
    
    %sum(b)
end
