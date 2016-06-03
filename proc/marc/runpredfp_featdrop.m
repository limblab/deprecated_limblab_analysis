%runpredfp3 - for LFPs runs the analysis on previously analyzed files,
%used to change parameters like nfeat, PolynomialOrder, etc.
%10/8/10 uses modified predonlyxy that calculates correlation between mean of both
%x and y vel/pos, etc
% ,'ChewieSpikeLFP016','ChewieSpikeL
% FP017',...'MiniSpikeLFP181','MiniSpikeLFP184','MiniSpikeLFP187',
% 'ChewieSpikeLFP113','ChewieSpikeLFP114',,'MiniSpikeLFP083'

% 'ChewieSpikeLFP236','ChewieSpikeLFP237','ChewieSpikeLFP238','ChewieSpikeL
% FP239''MiniSpikeLFP103','MiniSpikeLFP104','ChewieSpikeLFP068','ChewieSpik
% eLFP069'
% filelist = {'ChewieSpikeLFP071','ChewieSpikeLFP073','ChewieSpikeLFP074','ChewieSpikeLFP070'};
%     };'MiniSpikeLFP106',
filelist = {'MiniSpikeLFP108','MiniSpikeLFP082'};
% filelist={'Thor_11-3-10_mid_iso_002','Thor_11-3-10_mid_iso_003','Thor_11-3-10_prone_iso_001'};

ftemp='activeonlyzscore velpred';

nfeat=[2:2:50,54:4:150];

for i=1:length(filelist)
    fnam=filelist{i}
    skip=0;
    dirscript_monk
    fname=[dir,fnam];
    UseThresh=0;
    binsize=0.1;
    binsamprate=1/binsize;
    
    %% emptying variables
    PosR2mall=[];
    PosR2sdall=[];
    PosVmall=[];
    PosVsdall=[];
    PosVtrall=[];
    
    VelR2mall=[];
    VelR2sdall=[];
    VelVmall=[];
    VelVsdall=[];
    VelVtrall=[];
    
    EMGR2mall=[];
    EMGR2sdall=[];
    EMGVmall=[];
    EMGVsdall=[];
    EMGVtrall=[];
    parindex=[];
    %% Actual code
    
    %     for lam=1:3
    
    for n=1:length(nfeat)
        n
        if exist([fname,'tik pospred 100 feats.mat'],'file')
            load([fname,'tik pospred 100 feats.mat'])
        elseif exist([fname,'tik pospred 100 feats lambda0.mat'],'file')
            load([fname,'tik pospred 100 feats lambda0.mat'])
        elseif exist([fname,'tik pospred 100 feats lambda1.mat'],'file')
            load([fname,'tik pospred 100 feats lambda1.mat'])
        else
            disp('Something wrong with your filename')
            skip=1;
            %             continue
        end
        lambda=1;
        Poly=3;
        if ~skip
            [vmean,vaf,vaftr,r2m,r2sd,r2,y_pred,y_test,ytnew,xtnew,H,P,bestf,bestc] = predonlyxy(featMat,y,Poly,0,lambda,10,1,binsamprate,10,nfeat(n));
            PosR2mall=[PosR2mall; r2m];
            PosR2sdall=[PosR2sdall; r2sd];
            PosVmall=[PosVmall;vmean];
            PosVtrall=[PosVtrall;mean(vaftr)];
        end
        
        skip=0;
        if exist([fname,'tik velpred 100 feats.mat'],'file')
            load([fname,'tik velpred 100 feats.mat'],'featMat','y')
        elseif exist([fname,'tik velpred 100 feats lambda0.mat'],'file')
            load([fname,'tik velpred 100 feats lambda0.mat'],'featMat','y')
        elseif exist([fname,'tik velpred 100 feats lambda1.mat'],'file')
            load([fname,'tik velpred 100 feats lambda1.mat'],'featMat','y')
        elseif  exist([fname,ftemp,'.mat'],'file')
            load([fname,ftemp])
            featMat=x;
        else
            skip=1;
            disp('No vel file either')
            %                 continue
        end
        lambda=1;
        Poly=3;
        if ~skip
            [vmean,vaf,vaftr,r2m,r2sd,r2,y_pred,y_test,ytnew,xtnew,H,P,bestf,bestc] = predonlyxy(featMat,y,Poly,0,lambda,10,1,binsamprate,10,nfeat(n));
            %         save([fname,'tik velpred ',num2str(nfeat(n)),' feats lambda',num2str(lambda),'.mat'],'v*','y*','x*','r*','best*','H','featMat','Poly','Use*','binsize','lambda');                    VelR2mall=[VelR2mall; r2m];
            VelR2mall=[VelR2mall; r2m];
            VelR2sdall=[VelR2sdall; r2sd];
            VelVmall=[VelVmall;vmean];
            VelVtrall=[VelVtrall;mean(vaftr)];
        end
        %
        skip=0;
        if exist([fname,'tik emgpred 100 feats.mat'],'file')
            load([fname,'tik emgpred 100 feats.mat'],'featMat','y')
            %use 2 for emg signals since they're rectified
        elseif exist([fname,'tik emgpred 100 feats lambda0.mat'],'file')
            load([fname,'tik emgpred 100 feats lambda0.mat'],'featMat','y')
        elseif exist([fname,'tik emgpred 100 feats lambda1.mat'],'file')
            load([fname,'tik emgpred 100 feats lambda1.mat'],'featMat','y')
        else
            disp(['Error, file ',fname,' not found']);
            skip=1;
        end
        if ~skip
            lambda=1;
            Poly=2;
            [vmean,vaf,vaftr,r2m,r2sd,r2,y_pred,y_test,ytnew,xtnew,H] = predonlyxy(featMat,y,Poly,0,lambda,10,1,binsamprate,10,nfeat(n));
            %             save([fname,'tik emgpred ',num2str(nfeat(n)),' feats lambda',num2str(lambda),'.mat'],'v*','y*','x*','r*','best*','H','featMat','Poly','Use*','fse','temg','binsize','lambda');
            EMGR2mall=[EMGR2mall; r2m];
            EMGR2sdall=[EMGR2sdall; r2sd];
            EMGVmall=[EMGVmall;vmean];
            EMGVtrall=[EMGVtrall;mean(vaftr)];
        end
        parindex=[parindex;[i lambda]];
        
    end
    snam=[filelist{i},' cont perfsum RW featdrop lambda',num2str(lambda),'.mat']
    save(snam,'Pos*','Vel*','EMG*','parindex','filelist','nfeat','best*')
    figure
    errorbar([nfeat' nfeat'],PosR2mall,PosR2sdall/2)
    xlabel('nfeat')
    ylabel('R2')
    fignam=[filelist{i},' pospred featdrop poly3lam1'];
    title(fignam)
    figure
    errorbar([nfeat' nfeat'],VelR2mall,VelR2sdall/2)
    xlabel('nfeat')
    ylabel('R2')
    fignam=[filelist{i},' velpred featdrop poly3lam1'];
    title(fignam)
    saveas(gcf,[fignam,'.fig'])
    if ~isempty(EMGR2mall)
        xvect=repmat(nfeat',1,size(EMGR2mall,2));
        errorbar(xvect,EMGR2mall,EMGR2sdall/2)
        xlabel('nfeat')
        ylabel('R2')
        fignam=[filelist{i},' emgpred featdrop poly3lam1'];
        title(fignam)
        saveas(gcf,[fignam,'.fig'])
    end
    
    clear feat* v* y* x* r*  emg*
    %         close all
    
end


