function [meanHonI_PC_mse meanIonI_PC_mse meanWonI_PC_mse meanHonW_PC_mse ...
    meanWonW_PC_mse meanIonW_PC_mse stdHonI_PC_mse stdIonI_PC_mse ...
    stdWonI_PC_mse stdHonW_PC_mse stdWonW_PC_mse stdIonW_PC_mse] = ...
    Get_mse_meanandstd(HonI_PC_mse, IonI_PC_mse, WonI_PC_mse, HonW_PC_mse,...
    WonW_PC_mse, IonW_PC_mse)

%----------------------------------------------------------

meanHonI_PC_mse = mean(HonI_PC_mse); stdHonI_PC_mse = std(HonI_PC_mse);
meanIonI_PC_mse = mean(IonI_PC_mse); stdIonI_PC_mse = std(IonI_PC_mse);
meanWonI_PC_mse = mean(WonI_PC_mse); stdWonI_PC_mse = std(WonI_PC_mse);

meanHonW_PC_mse = mean(HonW_PC_mse); stdHonW_PC_mse = std(HonW_PC_mse);
meanWonW_PC_mse = mean(WonW_PC_mse); stdWonW_PC_mse = std(WonW_PC_mse);
meanIonW_PC_mse = mean(IonW_PC_mse); stdIonW_PC_mse = std(IonW_PC_mse);

