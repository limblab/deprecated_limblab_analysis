nlags = 1;
nfbands = 6;
nchan = 96; 

for i = 1:size(Y_cross_corr_sorted_avg,2)
    
    [Wf(1:nfbands,:,i),Wc(1:nchan,:,i),Wt(1:nlags,:,i)]= MRScalcwtsum(XY_cross_corr_sorted_avg(1:576,:,i),nlags,nfbands,nchan,bestf,bestc);
    Wf(nfbands+1,i) = XY_cross_corr_sorted_avg(577,i);
    Wc(nchan+1,i) = XY_cross_corr_sorted_avg(577,i);
    Wt(nlags+1,i) = XY_cross_corr_sorted_avg(577,i);
    
end