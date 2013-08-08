function stereotax_conversions
measuring_from = 'right';
APst_zero = '7.1P';
MLst_zero = '42.0';

HPst_ap = '22.5P';
HPst_ml = '42.0';
[HP_ap HP_ml] = stereotax2monkey(APst_zero,MLst_zero,HPst_ap,HPst_ml,measuring_from)

A_ap = '12.9A';
A_ml = '17R';

end

function [AP, ML] = stereotax2monkey(APst_zero,MLst_zero,APst,MLst,measuring_from)
    sign_ap_st = -strcmp(APst(end),'P');
    sign_ap_zero = -strcmp(APst_zero(end),'P');
    APst_zero = sign_apst*str2double(APst_zero(1:end-1));
    MLst_zero = str2double(MLst_zero);
    APst = str2double(APst(1:end-1));
    MLst = str2double(MLst(1:end-1));
    
    AP = sign_ap_zero*APst_zero + sign_ap_st*APst;
    if strcmp(measuring_from,'right')
        ML = MLst_zero - MLst;
    elseif strcmp(measuring_from,'left')
        ML = MLst_zero + MLst;
    end
    if sign(AP) == -1
        P_or_A = 'P';
    else
        P_or_A = 'A';
    end
    
    AP = [num2str(abs(AP)) P_or_A];
    ML = num2str(ML);
end

function [APst, MLst] = monkey2stereotax(APst_zero,MLst_zero,AP,ML,measuring_from)
    sign_ap = -strcmp(APst_zero(end),'P');
    sign_ap_st_zero = -strcmp(APst_zero(end),'P');
    APst_zero = sign_ap*str2double(APst_zero(1:end-1));
    MLst_zero = str2double(MLst_zero);
end


