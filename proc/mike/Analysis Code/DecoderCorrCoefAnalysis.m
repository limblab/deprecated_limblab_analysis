for i = 1:size(DecWts_X,1)
    for j = 1:size(DecWts_X,1)
        diff = sum(abs(DecWts_X(i,1:99,14) - DecWts_X(j,1:99,14)));
        [XCF1,Lags,Bounds] = crosscorr(DecWts_X(i,1:99,14),DecWts_X(j,1:99,14));
        %[XCF2,Lags,Bounds] = crosscorr(DecWts_X{i,1,4}(:,2),DecWts_X{j,1,4}(:,2));
      
        Decoder_CrossCorrX = max(XCF1);
        %Decoder_CrossCorrY = max(XCF2);
        Decoder_MaxCrossCorrX(i,j) = Decoder_CrossCorrX;
        %Decoder_MaxCrossCorrY(i,j) = Decoder_CrossCorrY;
        
        Decoder_diff(i,j) = diff;
        
        r_squared2 = corrcoef(DecWts_X(i,1:99,14),DecWts_X(j,1:99,14));
        features_Rsquared(i,j) = r_squared2(1,2);
    end
end