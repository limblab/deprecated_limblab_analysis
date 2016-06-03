function [init_params, Q, U, integ_params] = read_initialization_file(filename)

% Reads a parameter file from AUTOLEV and assigns values to variables.
% Based off init.c by Dan Moran
% 1. Inputs: File name header.
% 2. Ouputs: init_params - structure containing arm parameters
%            Q (7x1) - initial joint angles (elbow is 90')
%            U (7x1) - initial joint angular velocity
%            integ_params - integration parameters
%
% Created by Sherwin Chan
% Date: 2/18/2004
% Last modified : 2/18/2004

if nargin == 0
    filename = 'human_arm_7';
end

fid = fopen([filename,'.in']);

while ~feof(fid)
    tline = fgetl(fid);
    if ~ischar(tline), break, end
%    disp(tline(61:end))
    if size(tline, 2) > 14
        switch (tline(1:14))
            case {'Constant:     '}
                switch (tline(22:26))
                    case{'ALPHA'}
                        init_params.Alpha = str2num(tline(61:end));
                    case{'GRAV '}
                        init_params.Grav = str2num(tline(61:end));
                    case{'IA1  '}
                        init_params.Ia(1) = str2num(tline(61:end));
                    case{'IA2  '}
                        init_params.Ia(2) = str2num(tline(61:end));
                    case{'IA3  '}
                        init_params.Ia(3) = str2num(tline(61:end));
                    case{'IB1  '}
                        init_params.Ib(1) = str2num(tline(61:end));
                    case{'IB2  '}
                        init_params.Ib(2) = str2num(tline(61:end));
                    case{'IB3  '}
                        init_params.Ib(3) = str2num(tline(61:end));
                    case{'IC1  '}
                        init_params.Ic(1) = str2num(tline(61:end));
                    case{'IC2  '}
                        init_params.Ic(2) = str2num(tline(61:end));
                    case{'IC3  '}
                        init_params.Ic(3) = str2num(tline(61:end));
                    case{'ID1  '}
                        init_params.Id(1) = str2num(tline(61:end));
                    case{'ID2  '}
                        init_params.Id(2) = str2num(tline(61:end));
                    case{'ID3  '}
                        init_params.Id(3) = str2num(tline(61:end));
                    case{'LA1  '}
                        init_params.La(1) = str2num(tline(61:end));
                    case{'LA2  '}
                        init_params.La(2) = str2num(tline(61:end));
                    case{'LA3  '}
                        init_params.La(3) = str2num(tline(61:end));
                    case{'LB1  '}
                        init_params.Lb(1) = str2num(tline(61:end));
                    case{'LB2  '}
                        init_params.Lb(2) = str2num(tline(61:end));
                    case{'LB3  '}
                        init_params.Lb(3) = str2num(tline(61:end));
                    case{'LC1  '}
                        init_params.Lc(1) = str2num(tline(61:end));
                    case{'LC2  '}
                        init_params.Lc(2) = str2num(tline(61:end));
                    case{'LC3  '}
                        init_params.Lc(3) = str2num(tline(61:end));
                    case{'MASSA'}
                        init_params.MassA = str2num(tline(61:end));
                    case{'MASSB'}
                        init_params.MassB = str2num(tline(61:end));
                    case{'MASSC'}
                        init_params.MassC = str2num(tline(61:end));
                    case{'MASSD'}
                        init_params.MassD = str2num(tline(61:end));
                    case{'MUSA1'}
                        init_params.MusA(1) = str2num(tline(61:end));
                    case{'MUSA2'}
                        init_params.MusA(2) = str2num(tline(61:end));
                    case{'MUSA3'}
                        init_params.MusA(3) = str2num(tline(61:end));
                    case{'MUSB1'}
                        init_params.MusB(1) = str2num(tline(61:end));
                    case{'MUSB2'}
                        init_params.MusB(2) = str2num(tline(61:end));
                    case{'MUSB3'}
                        init_params.MusB(3) = str2num(tline(61:end));
                    case{'MUSC1'}
                        init_params.MusC(1) = str2num(tline(61:end));
                    case{'MUSC2'}
                        init_params.MusC(2) = str2num(tline(61:end));
                    case{'MUSC3'}
                        init_params.MusC(3) = str2num(tline(61:end));
                    case{'MUSD1'}
                        init_params.MusD(1) = str2num(tline(61:end));
                    case{'MUSD2'}
                        init_params.MusD(2) = str2num(tline(61:end));
                    case{'MUSD3'}
                        init_params.MusD(3) = str2num(tline(61:end));
                    case{'MUSN1'}
                        init_params.MusN(1) = str2num(tline(61:end));
                    case{'MUSN2'}
                        init_params.MusN(2) = str2num(tline(61:end));
                    case{'MUSN3'}
                        init_params.MusN(3) = str2num(tline(61:end));
                    case{'PULL1'}
                        init_params.Pull(1) = str2num(tline(61:end));
                    case{'PULL2'}
                        init_params.Pull(2) = str2num(tline(61:end));
                    case{'PULL3'}
                        init_params.Pull(3) = str2num(tline(61:end));
                    case{'RHOA1'}
                        init_params.RhoA(1) = str2num(tline(61:end));
                    case{'RHOA2'}
                        init_params.RhoA(2) = str2num(tline(61:end));
                    case{'RHOA3'}
                        init_params.RhoA(3) = str2num(tline(61:end));
                    case{'RHOB1'}
                        init_params.RhoB(1) = str2num(tline(61:end));
                    case{'RHOB2'}
                        init_params.RhoB(2) = str2num(tline(61:end));
                    case{'RHOB3'}
                        init_params.RhoB(3) = str2num(tline(61:end));
                    case{'RHOC1'}
                        init_params.RhoC(1) = str2num(tline(61:end));
                    case{'RHOC2'}
                        init_params.RhoC(2) = str2num(tline(61:end));
                    case{'RHOC3'}
                        init_params.RhoC(3) = str2num(tline(61:end));
                    case{'RHOD1'}
                        init_params.RhoD(1) = str2num(tline(61:end));
                    case{'RHOD2'}
                        init_params.RhoD(2) = str2num(tline(61:end));
                    case{'RHOD3'}
                        init_params.RhoD(3) = str2num(tline(61:end));
                    case{'SHO1 '}
                        init_params.Shoulder(1) = str2num(tline(61:end));
                    case{'SHO2 '}
                        init_params.Shoulder(2) = str2num(tline(61:end));
                    case{'SHO3 '}
                        init_params.Shoulder(3) = str2num(tline(61:end));
                    case{'QROT1'}
                        init_params.qrot(1) = str2num(tline(61:end));
                    case{'QROT2'}
                        init_params.qrot(2) = str2num(tline(61:end));
                    case{'QROT3'}
                        init_params.qrot(3) = str2num(tline(61:end));
                    case{'MONKM'}
                        init_params.MonkMass = str2num(tline(61:end));
                        
                    otherwise
                        disp(['This parameter ', tline(22:27), ' is unknown.']);
                end
                
            case('Initial Value:')
                switch(tline(22:23))
                    case{'Q1'}
                        Q(1) = str2num(tline(61:end));
                    case{'Q2'}
                        Q(2) = str2num(tline(61:end));
                    case{'Q3'}
                        Q(3) = str2num(tline(61:end));
                    case{'Q4'}
                        Q(4) = str2num(tline(61:end));
                    case{'Q5'}
                        Q(5) = str2num(tline(61:end));
                    case{'Q6'}
                        Q(6) = str2num(tline(61:end));
                    case{'Q7'}
                        Q(7) = str2num(tline(61:end));
                    case{'U1'}
                        U(1) = str2num(tline(61:end));
                    case{'U2'}
                        U(2) = str2num(tline(61:end));
                    case{'U3'}
                        U(3) = str2num(tline(61:end));
                    case{'U4'}
                        U(4) = str2num(tline(61:end));
                    case{'U5'}
                        U(5) = str2num(tline(61:end));
                    case{'U6'}
                        U(6) = str2num(tline(61:end));
                    case{'U7'}
                        U(7) = str2num(tline(61:end));
                    otherwise
                        disp(['This parameter ', tline(22:22), ' is unknown.']);
                end
                
            case{'Initial Time: '}
                integ_params.tinitial = str2num(tline(61:end));
            case{'Final Time:   '}
                integ_params.tfinal = str2num(tline(61:end));
            case{'Integration St'}
                integ_params.Integstp = str2num(tline(61:end));
            case{'Print-Integer:'}
                integ_params.printint = str2num(tline(61:end));
            case{'Absolute Error'}
                integ_params.Abserr = str2num(tline(61:end));
            case{'Relative Error'}
                integ_params.Relerr = str2num(tline(61:end));
                
            otherwise
                ;
        end
    end                     
end

fclose(fid);
return;
