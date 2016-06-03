function P=test_stim_significance(varargin)
    if ~isempty(varargin)
        bdf=varargin{1};
    else
        folderpath_base='E:\processing\CO_bump\BD efficacy checking\297Deg\';
        matchstring='Kramer';
        % %matchstring2='BC';
        disp('converting nev files to bdf format')
        file_list=autoconvert_nev_to_bdf(folderpath_base,matchstring);
        % autoconvert_nev_to_bdf(folderpath,matchstring2)
        disp('concatenating bdfs into single structure')
        bdf=concatenate_bdfs_from_folder(folderpath_base,matchstring,0,0,0);
        %load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')

        make_tdf
    end
     [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian,params_stim,params_no_stim] =  bc_psychometric_curve_stim_cosplot_all(bdf.tt,bdf.tt_hdr,1);
     %temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
     figure(H_cartesian)
     title('Psychometric cartesian 20uA inverted compressed')
 %    save(strcat(folderpath,'5ua_inverted_compressed.txt'),'temp','-ascii')
 %    print('-dpdf',H_cartesian,strcat(folderpath,'Psychometric_cartesian_5ua_inverted_compressed.pdf'))


    %Test a sigmoidal curve to see if a specific data set may be drawn from
    %that curve

    % find maximum likelihood model for sigmoid on non-stim data
    
    nostim_data=[dirs_no_stim,round(number_reaches_no_stim.*proportion_no_stim),number_reaches_no_stim];
    stim_data=[dirs_stim,round(number_reaches_stim.*proportion_stim),number_reaches_stim];
    
    

%         %initialize parameter vector
%         params0=params_no_stim;
%         optifun=@(P) inv_liklihood(P,nostim_data);
%         params=fminsearch(optifun,params0);
%         figure(H_cartesian)
%         hold on
%         dd=[0:.1:360];
%         plot(dd,sigmoid_periodic2(params,dd*pi/180),'g')
%         
%         params1=params_stim;
%         optifun=@(P) inv_liklihood(P,stim_data);
%         params_stim=fminsearch(optifun,params1);
%         figure(H_cartesian)
%         hold on
%         dd=[0:.1:360];
%         plot(dd,sigmoid_periodic2(params_stim,dd*pi/180),'m')
%         hold off
%         
%         L_null=get_sigmoid_liklihood2(stim_data,params,@sigmoid_periodic);
%         L_stim=get_sigmoid_liklihood2(stim_data,params_stim,@sigmoid_periodic);
%     
% 
%     D=2*(log(L_stim)-log(L_null));
%     P=1-chi2cdf(D,1); %(assumes 1DOF)
end
function il=inv_liklihood(params,data)
    L=get_sigmoid_liklihood2(data,params,@sigmoid_periodic2);
    il=1/L;
end

function [c,ceq]=constr(params)
    x=[0,2*pi];
    y=sigmoid_periodic2(x);
    c(1)=max(y)-1;%max<1
    c(2)=-min(y);%min<0
end