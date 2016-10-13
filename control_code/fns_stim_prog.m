function strOUT = fns_stim_prog(prefix,chList,mode,amp,pw,freq,pulses,time2run,stim_tip)
% This function generates a string to send to the FNS stimulator specifying
% a program to run.
%
% Inputs:
%       prefix - what stimulator should do with string
%       chList - list of channels (vec of integers) to output stim
%       mode - how to execute program
%       amp - stim amplitude in mA
%       pw - stim pulsewidth in msec
%       freq - stim freq in Hz
%       pulses - no. pulses in a train
%       time2run - time for train to run, in ms
%       stim_tip - used to calculate interphase time

chSTR = get_chSTR(chList);          % channels

switch prefix
    case {'p'}
        % Program channels and but DO NOT run after loading
        prefNum = '5';                      % prefix
        polarity = '1';                     % Polarity (1st phase positive)
        I1 = int2str(amp*1e3);              % Pulse amplitdue (uAmps)
        I2 = I1;
        T1 = int2str(pw*1e3);               % Pulse width (uSec)
        T2 = T1;
        TIP = int2str(stim_tip*1e3);        % Inter-phase time (uSec)
        TT = int2str((1/freq)*1e6);         % Repetition time (uSec)
        NP = int2str(pulses);               % number of pulses in train
        TTR = int2str(time2run);            % time for train to run in msec
        
        % ADD CHECKS TO THESE VALUES!!!!!!!!
        
        % Combine all values into string for FNS stimulator
        switch mode
            case {'prog'}
                modeIN = int2str(0);
                strOUT = strcat(prefNum,',',chSTR,',',modeIN,',',polarity,',',I1,',',...
                                I2,',',T1,',',T2,',',TIP,',',TT);
            case {'static_pulses'}
                modeIN = int2str(1);
                strOUT = strcat(prefNum,',',chSTR,',',modeIN,',',polarity,',',I1,',',...
                                I2,',',T1,',',T2,',',TIP);
            case {'static_train'}
                modeIN = int2str(2); 
                strOUT = strcat(prefNum,',',chSTR,',',modeIN,',',polarity,',',I1,',',...
                                I2,',',T1,',',T2,',',TIP,',',TT,',',NP);
            case {'mod_pw'}
                modeIN = int2str(2); 
                strOUT = strcat(prefNum,',',chSTR,',',modeIN,',',polarity,',',I1,',',...
                                I2,',',T1,',',T2,',',TIP,',',TT,',',NP);
            case {'mod_amp'}
                modeIN = int2str(2);
                strOUT = strcat(prefNum,',',chSTR,',',modeIN,',',polarity,',',I1,',',...
                                I2,',',T1,',',T2,',',TIP,',',TT,',',NP);
            case {'mod_amp_stair'}
                modeIN = int2str(2);
                strOUT = strcat(prefNum,',',chSTR,',',modeIN,',',polarity,',',I1,',',...
                                I2,',',T1,',',T2,',',TIP,',',TT,',',NP);
        end

    case {'r'}
        % run specified channels
        strOUT = strcat('3,',chSTR);
        
    case {'h'}
        % Halt certain channels
        prefNum = '0';                      % prefix
        chSTR = get_chSTR(chList);          % channels
        modeIN = '9';
        strOUT = strcat(prefNum,',',chSTR,',',modeIN);
end

strOUT = strcat(strOUT,'#');  % added 11-15-12 for new version of FNS code
       



