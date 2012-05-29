
for k = 1:7%size(All_Predictions_LFPBC_SpikeHC,1)
    
    for l = 1:3%size(All_Predictions_LFPBC_SpikeHC,2)
        

        for i = 1:2

            PredLength = size(All_Predictions_HC_Decoders{k,l,2},1)

            r2 = corrcoef(All_Predictions_HC_Decoders{k,l,1}(1:PredLength,i),All_Predictions_HC_Decoders{k,l,2}(:,i))

            All_R2_HC_Decoders(k,l,i) = r2(1,2);
            
        end
    end
end