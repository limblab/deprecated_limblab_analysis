function [meanHonS_PC_mse meanIonS_PC_mse meanWonS_PC_mse meanSonS_PC_mse ...
    stdHonS_PC_mse stdIonS_PC_mse stdWonS_PC_mse stdSonS_PC_mse] ...
    = Get_mse_meanandstd_Spring(HonS_PC_mse, IonS_PC_mse, WonS_PC_mse, SonS_PC_mse);


    meanHonS_PC_mse = mean(HonS_PC_mse); stdHonS_PC_mse = std(HonS_PC_mse);
    meanWonS_PC_mse = mean(WonS_PC_mse); stdWonS_PC_mse = std(WonS_PC_mse);
    meanIonS_PC_mse = mean(IonS_PC_mse); stdIonS_PC_mse = std(IonS_PC_mse);
    meanSonS_PC_mse = mean(SonS_PC_mse); stdSonS_PC_mse = std(SonS_PC_mse);