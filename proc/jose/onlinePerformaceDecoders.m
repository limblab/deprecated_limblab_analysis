function [time2Target pathLength trials_min std_t2T std_PL std_st pT2T pPL pST N_t2t N_PL N_st] = onlinePerformaceDecoders()

time2Target = [];
pathLength = [];
trials_min = [];

std_t2T = [];
std_PL = [];
std_st = [];

N_t2t = [];
N_PL  = [];
N_st  = [];

pT2T = [];
pPL = [];
pST = [];

count = 0;

%% GUI
MoreFiles = questdlg('Do you want to add a day file?');

while strcmp(MoreFiles,'Yes')

    dataPath = ':\'; 
    % Call GUI
    [FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Hand Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
    if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        HCData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
        HCData = HCData.binnedData; % changin binneData name for other name
    else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
    end

    % Call GUI
    [FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose Cascade Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
    if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        N2E2PData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
        N2E2PData = N2E2PData.binnedData; % changin binneData name for other name
    else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
    end

    % Call GUI
    [FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose N2P Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
    if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        N2PData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
        N2PData = N2PData.binnedData; % changin binneData name for other name
    else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
    end


    % Call GUI
    [FileName_tmp, PathName] = uigetfile( [dataPath '*.mat'], 'Choose N2P + LPF Control BinnedData File');
    datafile = fullfile(PathName,FileName_tmp);
    % Verify if the file indeed exists
    if exist(datafile, 'file') == 2 % return 2 when there is a .m or .mat file
        % It exists.
        N2PLPFData = load(datafile,'binnedData'); % datafile automatically loaded as binnedData
        N2PLPFData = N2PLPFData.binnedData; % changin binneData name for other name
    else
        % It doesn't exist.
        warningMessage = sprintf('Error reading mat file\n%s.\n\nFile not found',datafile);
        uiwait(warndlg(warningMessage));
    end

    %% extracting features per each decoder

    [t_HC x_HC y_HC] = get_path_WF(HCData);
    [t_N2E2P x_N2E2P y_N2E2P] = get_path_WF(N2E2PData);
    [t_N2P x_N2P y_N2P] = get_path_WF(N2PData);
    [t_N2PLPF x_N2PLPF y_N2PLPF] = get_path_WF(N2PLPFData);

    [st_HC length_HC] = get_length_path_WF(HCData);
    [st_N2E2P length_N2E2P] = get_length_path_WF(N2E2PData);
    [st_N2P length_N2P] = get_length_path_WF(N2PData);
    [st_N2PLPF length_N2PLPF] = get_length_path_WF(N2PLPFData);

    % Time to Target
    % HC
    v_aux = t_HC(:);
    t2T_hc = v_aux(v_aux~=0);
    HC_label_t2T = repmat('HC    ',length(t2T_hc),1);
    tHC = mean(t2T_hc);
    stdHC = std(t2T_hc);
    NHC_t2t = length(t2T_hc);
    
    % CD
    v_aux = t_N2E2P(:);
    t2T_CD = v_aux(v_aux~=0);
    CD_label_t2T = repmat('CD    ',length(t2T_CD),1);
    tCD= mean(t2T_CD);
    stdCD = std(t2T_CD);
    NCD_t2t = length(t2T_CD);

    % N2P
    v_aux = t_N2P(:);
    t2T_N2P = v_aux(v_aux~=0);
    N2P_label_t2T = repmat('N2P   ',length(t2T_N2P),1);
    tN2P= mean(t2T_N2P);
    stdN2P = std(t2T_N2P);
    NN2P_t2t = length(t2T_N2P);

    % N2P + LPF
    v_aux = t_N2PLPF(:);
    t2T_N2PLPF = v_aux(v_aux~=0);
    N2PLPF_label_t2T = repmat('N2PLPF',length(t2T_N2PLPF),1);
    tN2PLPF= mean(t2T_N2PLPF);
    stdN2PLPF = std(t2T_N2PLPF);
    NN2PLPF_t2t = length(t2T_N2PLPF);

    
    % anova in pairs
    p1 = anova1([t2T_hc;t2T_CD],[HC_label_t2T;CD_label_t2T],'off'); % 1,2
    p2 = anova1([t2T_hc;t2T_N2P],[HC_label_t2T;N2P_label_t2T],'off'); % 1,3
    p3 = anova1([t2T_hc;t2T_N2PLPF],[HC_label_t2T;N2PLPF_label_t2T],'off'); % 1,4
    p4 = anova1([t2T_CD;t2T_N2P],[CD_label_t2T;N2P_label_t2T],'off'); % 2,3
    p5 = anova1([t2T_CD;t2T_N2PLPF],[CD_label_t2T;N2PLPF_label_t2T],'off'); % 2,4    
    p6 = anova1([t2T_N2P;t2T_N2PLPF],[N2P_label_t2T;N2PLPF_label_t2T],'off'); % 3,4
    % all 4
    Y = [t2T_hc;t2T_CD;t2T_N2P;t2T_N2PLPF];
    decod = [HC_label_t2T;CD_label_t2T;N2P_label_t2T;N2PLPF_label_t2T];
    p7 = anova1(Y,decod,'off');
    p_t2T = [p1;p2;p3;p4;p5;p6;p7];
    
    pT2T = [pT2T,p_t2T];
    
    % mean for bar plot day i
    t2T =[tHC tCD tN2P tN2PLPF];
    time2Target = [time2Target;t2T];
    % standard deviation for day 1
    std_aux = [stdHC stdCD stdN2P stdN2PLPF];
    std_t2T = [std_t2T;std_aux];
    N_t2t = [N_t2t; NHC_t2t NCD_t2t NN2P_t2t NN2PLPF_t2t];

    % PathLength
    % HC
    v_aux = length_HC(:);
    l_hc = v_aux(v_aux~=0);
    HC_label_l = repmat('HC    ',length(l_hc),1);
    lHC = mean(l_hc);
    stdHC = std(l_hc);
    NHC_pl = length(l_hc);
    % CD
    v_aux = length_N2E2P(:);
    l_CD = v_aux(v_aux~=0);
    CD_label_l = repmat('CD    ',length(l_CD),1);
    lCD= mean(l_CD);
    stdCD = std(l_CD);
    NCD_pl = length(l_CD);
    % N2P
    v_aux = length_N2P(:);
    l_N2P = v_aux(v_aux~=0);
    N2P_label_l = repmat('N2P   ',length(l_N2P),1);
    lN2P= mean(l_N2P);
    stdN2P = std(l_N2P);            
    NN2P_pl = length(l_N2P);
    % N2P + LPF
    v_aux = length_N2PLPF(:);
    l_N2PLPF = v_aux(v_aux~=0);
    N2PLPF_label_l = repmat('N2PLPF',length(l_N2PLPF),1);
    lN2PLPF= mean(l_N2PLPF);
    stdN2PLPF = std(l_N2PLPF);
    NN2PLPF_pl = length(l_N2PLPF);
    
    % anova in pairs
    p1 = anova1([l_hc;l_CD],[HC_label_l;CD_label_l],'off'); % 1,2
    p2 = anova1([l_hc;l_N2P],[HC_label_l;N2P_label_l],'off'); % 1,3
    p3 = anova1([l_hc;l_N2PLPF],[HC_label_l;N2PLPF_label_l],'off'); % 1,4
    p4 = anova1([l_CD;l_N2P],[CD_label_l;N2P_label_l],'off'); % 2,3
    p5 = anova1([l_CD;l_N2PLPF],[CD_label_l;N2PLPF_label_l],'off'); % 2,4    
    p6 = anova1([l_N2P;l_N2PLPF],[N2P_label_l;N2PLPF_label_l],'off'); % 3,4
    % all 4
    Y = [l_hc;l_CD;l_N2P;l_N2PLPF];
    decod = [HC_label_l;CD_label_l;N2P_label_l;N2PLPF_label_l];
    p7 = anova1(Y,decod,'off');
    p_l = [p1;p2;p3;p4;p5;p6;p7];
    
    pPL = [pPL,p_l];
    
    % means
    l2T =[lHC lCD lN2P lN2PLPF];
    pathLength = [pathLength;l2T];
    % standard deviation for day 1
    std_aux = [stdHC stdCD stdN2P stdN2PLPF];
    std_PL = [std_PL;std_aux];
    N_PL = [N_PL; NHC_pl NCD_pl NN2P_pl NN2PLPF_pl];

    % Successful trials per minute
    % HC
    v_aux = st_HC(:);
    st_hc = v_aux(v_aux~=0);
    HC_label_st = repmat('HC    ',length(st_hc),1);
    stHC = mean(st_hc);
    stdHC = std(st_hc);
    NSTHC = length(st_hc);
    % CD
    v_aux = st_N2E2P(:);
    st_CD = v_aux(v_aux~=0);
    CD_label_st = repmat('CD    ',length(st_CD),1);
    stCD= mean(st_CD);
    stdCD = std(st_CD);
    NSTCD = length(st_CD);
    % N2P
    v_aux = st_N2P(:);
    st_N2P = v_aux(v_aux~=0);
    N2P_label_st = repmat('N2P   ',length(st_N2P),1);
    stN2P= mean(st_N2P);
    stdN2P = std(st_N2P);
    NSTN2P = length(st_N2P);
    % N2P + LPF
    v_aux = st_N2PLPF(:);
    st_N2PLPF = v_aux(v_aux~=0);
    N2PLPF_label_st = repmat('N2PLPF',length(st_N2PLPF),1);
    stN2PLPF= mean(st_N2PLPF);
    stdN2PLPF = std(st_N2PLPF);
    NSTN2PLPF = length(st_N2PLPF);
    
    % anova in pairs
    p1 = anova1([st_hc;st_CD],[HC_label_st;CD_label_st],'off'); % 1,2
    p2 = anova1([st_hc;st_N2P],[HC_label_st;N2P_label_st],'off'); % 1,3
    p3 = anova1([st_hc;st_N2PLPF],[HC_label_st;N2PLPF_label_st],'off'); % 1,4
    p4 = anova1([st_CD;st_N2P],[CD_label_st;N2P_label_st],'off'); % 2,3
    p5 = anova1([st_CD;st_N2PLPF],[CD_label_st;N2PLPF_label_st],'off'); % 2,4    
    p6 = anova1([st_N2P;st_N2PLPF],[N2P_label_st;N2PLPF_label_st],'off'); % 3,4
    % all 4
    Y = [st_hc;st_CD;st_N2P;st_N2PLPF];
    decod = [HC_label_st;CD_label_st;N2P_label_st;N2PLPF_label_st];
    p7 = anova1(Y,decod,'off');
    p_st = [p1;p2;p3;p4;p5;p6;p7];
    
    pST = [pST,p_st]; 
    
    % means
    st =[stHC stCD stN2P stN2PLPF];
    trials_min = [trials_min;st];
    % standard deviation for day 1
    std_aux = [stdHC stdCD stdN2P stdN2PLPF];
    std_st = [std_st;std_aux];
    N_st = [N_st; NSTHC NSTCD NSTN2P NSTN2PLPF];
    
    count = count + 1
    
    MoreFiles = questdlg('Do you want to add another day?');
end

se_t2T = std_t2T./sqrt(N_t2t);
se_PL = std_PL./sqrt(N_PL);
se_st = std_st./sqrt(N_st);

figure 
% barwitherr(std_t2T,time2Target)
barwitherr(2*se_t2T,time2Target)
title('time to target')
xlabel('days')
ylabel('seconds')
ylim([0 4.5]) 
legend('Hand Control','CD Control','N2P Control','N2P + LPF')

figure
% barwitherr(std_PL,pathLength)
barwitherr(2*se_PL,pathLength)
title('Path Length from center to target')
xlabel('days')
ylabel('cm')
ylim([0 80]) 
legend('Hand Control','CD Control','N2P Control','N2P + LPF')

figure 
% barwitherr(std_st,trials_min)
barwitherr(2*se_st,trials_min)
title('Successful trials per minute')
xlabel('days')
ylabel('trials/min')
ylim([0 18]) 
legend('Hand Control','CD Control','N2P Control','N2P + LPF')
