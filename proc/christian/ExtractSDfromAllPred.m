for pred = 1:6
    for state = 1:2
        if pred ==1
            max_class = 5;
        else
            max_class = 1;
        end
        for class = 1:max_class

            RawSTD = OLPredData{1,pred}.stateSTD{state,class};
            validIDX = find(std(RawSTD,0,2)>0.0001);

            switch pred
                case 1
                    if state == 1
                        switch class
                            case 1
                                FW_VelThresh_Posture_STD  = RawSTD(validIDX,:);
                            case 2
                                FW_CompBayes_Posture_STD  = RawSTD(validIDX,:);
                            case 3
                                FW_PeakBayes_Posture_STD  = RawSTD(validIDX,:);
                            case 4
                                FW_CompLDA_Posture_STD  = RawSTD(validIDX,:);
                            case 5
                                FW_PeakLDA_Posture_STD  = RawSTD(validIDX,:);
                        end
                    else
                        switch class
                            case 1
                                FW_VelThresh_Movement_STD = RawSTD(validIDX,:);
                            case 2
                                FW_CompBayes_Movement_STD = RawSTD(validIDX,:);
                            case 3
                                FW_PeakBayes_Movement_STD = RawSTD(validIDX,:);
                            case 4
                                FW_CompLDA_Movement_STD = RawSTD(validIDX,:);
                            case 5
                                FW_PeakLDA_Movement_STD = RawSTD(validIDX,:);
                        end
                    end
                case 2
                    if state ==1
                        VelThresh_Posture_STD  = RawSTD(validIDX,:);
                    else
                        VelThresh_Movement_STD = RawSTD(validIDX,:);
                    end
                case 3
                    if state ==1
                        CompBayes_Posture_STD  = RawSTD(validIDX,:);
                    else
                        CompBayes_Movement_STD = RawSTD(validIDX,:);
                    end
                case 4
                    if state ==1
                        PeakBayes_Posture_STD  = RawSTD(validIDX,:);
                    else
                        PeakBayes_Movement_STD = RawSTD(validIDX,:);
                    end
                case 5
                    if state ==1
                        CompLDA_Posture_STD  = RawSTD(validIDX,:);
                    else
                        CompLDA_Movement_STD = RawSTD(validIDX,:);
                    end
                case 6
                    if state==1
                        PeakLDA_Posture_STD  = RawSTD(validIDX,:);
                    else
                        PeakLDA_Movement_STD = RawSTD(validIDX,:);
                    end
            end
        end
    end
end


 






