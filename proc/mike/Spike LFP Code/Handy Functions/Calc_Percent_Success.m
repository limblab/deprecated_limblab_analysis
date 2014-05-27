for q = 1:length(Mini_2D_Learning)
    
    fnam =  findBDFonCitadel(Mini_2D_Learning{q})
    try
        load(fnam)
    catch exception
        continue
    end
    
    FirstTrialInds=find(out_struct.words(:,2)==17);
    NumTrials_File(q) = length(FirstTrialInds);
    
    AbortTrialInds=find(out_struct.words(:,2)==33);
    NumAbort_File(q) = length(AbortTrialInds);
   
    SuccessTrialInds=find(out_struct.words(:,2)==32);
    NumSuccess_File(q) = length(SuccessTrialInds);
    
    PercentSuccess_File(q) = (NumSuccess_File(q)/NumTrials_File(q))*100;
    
    
end

PercentSuccess_File_NoAbout = (NumSuccess_File./(NumTrials_File-NumAbort_File)).*100;

plot(PercentSuccess_File)
