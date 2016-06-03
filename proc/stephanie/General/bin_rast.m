function[raster,rastbin] = bin_rast(comp_tt,train,t1,t2,nbin,alignment)

% comp_tt: trialtable
% train: spike times
% t1 and t2: raster bounds (t1 can be negative)
% nbin: number of time bins
% alignment: 



if strcmp(alignment,'target')
    aligntype = 5;
elseif strcmp(alignment,'go')
    aligntype = 6;
else
    fprintf('alignment not supported: using target alignment\n');
end

raster = zeros(length(comp_tt),t2-t1+1);

for i = 1:length(comp_tt)
    
    timestart = comp_tt(i,aligntype)+t1./1000; %edit to match trialtable
    
    % Align spikes to start and get rid of those not in region
    aligned_ts = round(1000*(train - timestart));
    aligned_ts(aligned_ts<=0 | aligned_ts>=(t2-t1)) = [];
    
    raster(i,aligned_ts) = 1;
    
end

binedges = round(linspace(1,t2-t1,nbin+1));
rastbin = zeros(length(comp_tt),nbin);
for i = 1:nbin
    rastbin(:,i) = sum(raster(:,binedges(i):binedges(i+1)-1),2);
end