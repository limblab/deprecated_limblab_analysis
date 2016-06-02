function [final_bdf, final_tt] = merge_days(varargin)

% find_sizes
ls = zeros(nargin,1);

for i = 1:nargin
    ls(i) = length(varargin{i}.pos);
end
length_bdf = sum(ls);

final_bdf.pos = zeros(length_bdf,3);
final_bdf.vel = zeros(length_bdf,3);
final_bdf.acc = zeros(length_bdf,3);

% Fill with first bdf/tt
bdf1 = varargin{1};
tt1 = getTT(bdf1);

final_bdf.pos(1:ls(1),:) = bdf1.pos;
final_bdf.vel(1:ls(1),:) = bdf1.vel;
final_bdf.acc(1:ls(1),:) = bdf1.acc;

final_tt = tt1;
ind = 0;
fin_time = 0;
for i = 2:nargin
    
    l_1 = ls(i-1)+1;
    l_2 = ls(i);
    fin_time = fin_time + varargin{i-1}.pos(end,1);
    ind = ind + l_1;
    
    bdf = varargin{i};
    tt = getTT(bdf);
        
    bdf.pos(:,1) = bdf.pos(:,1) + fin_time;
    bdf.vel(:,1) = bdf.vel(:,1) + fin_time;
    bdf.acc(:,1) = bdf.acc(:,1) + fin_time;
    
    final_bdf.pos(ind:ind+l_2-1,:) = bdf.pos;
    final_bdf.vel(ind:ind+l_2-1,:) = bdf.vel;
    final_bdf.acc(ind:ind+l_2-1,:) = bdf.acc;
    
   
    tt(:,[1 4:7]) = tt(:,[1 4:7]) + fin_time;
    tt(1,:) = []; tt(end,:) = [];
    
    final_tt = [final_tt;tt];
    
    clear bdf tt l1 l2;
    
end

final_bdf.pos(final_bdf.pos(:,1)==0,:) = [];
final_bdf.vel(final_bdf.vel(:,1)==0,:) = [];
final_bdf.acc(final_bdf.acc(:,1)==0,:) = [];

end
