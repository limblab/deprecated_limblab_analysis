% filelist={'ChewieSpikeLFP068-09','ChewieSpikeLFP069-10','ChewieSpikeLFP016-14','ChewieSpikeLFP017-12','MiniSpike181-final',...
%     'MiniSpike184-final','MiniSpike187-final','MiniSpike186-02'}
%MiniSpikeLFP106-22
% filelist={'MiniSpikeLFP108-19','ChewieSpikeLFP232-03','ChewieSpikeLFP236-
% 04'}; 
% runplx2bdf 
%'ChewieSpikeLFP068fp4',
% filelist={'MiniSpikeLFP046-06'}'ChewieSpikeLFP068-09','ChewieSpikeLFP069-
% 10','ChewieSpikeLFP113-18','ChewieSpikeLFP114-16'
filelist={'Chewie_Spike_LFP2_105'};

% runplx2bdf
% filelist={'ChewieSpikeLFP214','ChewieSpikeLFP215'};%'Jaco010711_LFPs
% ','Jaco_01-11-11_002fp4',
% filelist={'Jaco_01-13-11_002fp4'}
binlen=100;  %[50,100]
for i=1:length(filelist)
fnam=filelist{i}
% if ~exist([fnam,'.mat'],'file')
% %     if strncmpi(fnam,'Mini',4)
% %         cd('E:\Data\Mini\Spikes')
% %     else
% %         error('Something wrong with your filename')
% %     end
% end
 load([fnam,'.mat'],'bdf')
%  for lambda=0:1
     lambda=1;
 Poly=3; emglpf=5;
 for b=1:length(binlen)
% [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
% predictions_mwstikpoly(bdf,'emg',[],.05,10,10,1,lambda,Poly,0,fnam,emglpf);
%  save([fnam,'tik emgpred 5hzlpf 50ms bins.mat lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],'v*','y*','r*','x*','H','P');
% clear all

%  lambda=0;
%  Poly=2;
% [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
% predictions_mwstikpoly(bdf,'emg',[],(binlen(b))/1000,10,10,1,lambda,Poly,0,fnam);
%  save([fnam,'spikes tik emgpred ',num2str(binlen(b)),'ms bins lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],'v*','y*','r*','x*','H','P');
%  clear all
 Poly=3;
% fnam='Chewie_Spike_CO_017-sorted-01'
% bdf=get_plexon_data([fnam,'.plx'],0);
% save([fnam,'.mat'],'bdf')
% %  load([fnam,'.mat'])
%  lambda=0;
%  Poly=0;
[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
MRSpredictions_mwstikpoly(bdf,'pos',[],(binlen(b))/1000,10,10,1,lambda,Poly,0,fnam);
 save([fnam,'spikes tik pospred ',num2str(binlen(b)),'ms bins lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],'v*','y*','r*','x','H','P');
% % clear all
% 
% % [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
% % predictions_mwstikpoly(bdf,'pos',[],.1,10,10,1,lambda,Poly,0,fnam);
% %  save([fnam,'tik pospred ',num2str(b),'ms bins lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],'v*','y*','r*','x','H','P');
% 
 %[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
%MRSpredictions_mwstikpoly(bdf,'vel',[],(binlen(b))/1000,10,10,1,lambda,Poly,0,fnam);
 %save([fnam,'spikes tik velpred ',num2str(binlen(b)),'ms bins lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],'v*','y*','r*','x','H','P');
% clear all

% [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
% predictions_mwstikpoly(bdf,'vel',[],.1,10,10,1,lambda,Poly,0,fnam);
%  save([fnam,'tik velpred 100ms bins lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],'v*','y*','r*','x','H','P');
 end %for b
%  end
end