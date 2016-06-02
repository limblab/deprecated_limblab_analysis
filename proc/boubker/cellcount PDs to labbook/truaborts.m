 clc; clear; close all;
 tic
 root={'Pedro_2011-04-18_BC_001'};
pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Processed\';
bdf=LoadDataStruct([pathname,char(root),'.mat']);

abort='21';
startdec=bitor(hex2dec('10'),hex2dec('0A'));
centerhold=[96:105];
rewarddec=bitor(hex2dec('00'),hex2dec('20'));
mvttime=1.4;
abortdec=hex2dec(abort);


aborttime=bdf.words(find(bdf.words(:,2)==abortdec),1);
allstarts=bdf.words(find(bdf.words(:,2)==startdec),1);
rewardtime=bdf.words(find(bdf.words(:,2)==rewarddec),1);
centerholdtime=[];
for i=1: length(centerhold)
centerholdtime=[centerholdtime;bdf.words(find(bdf.words(:,2)==centerhold(i)),1)];
end
centerholdtime=sort (centerholdtime);
while aborttime(1)<allstarts(1)
    aborttime(1)=[];
end;

for i=1 : length(aborttime)
startabort(i,1)=bdf.words(find(bdf.words(:,1)==aborttime(i)),1);
end
for i=1 : length(aborttime)
xmaxabort(i)=max(bdf.pos([find((bdf.pos(:,1)<=startabort(i)+0.001)& (bdf.pos(:,1)>=startabort(i)-0.001),1) :  find((bdf.pos(:,1)<=startabort(i)+0.001+mvttime)& (bdf.pos(:,1)>=startabort(i)-0.001+mvttime),1)],2));
end


for i=1 : length(rewardtime)
xreward(i)=bdf.pos(find(bdf.pos(:,1)<=rewardtime(i)+0.001& bdf.pos(:,1)>=rewardtime(i)-0.001,1),2);
end


for i=1 : length(centerholdtime)
xcenterholdtime(i)=bdf.pos(find(bdf.pos(:,1)<=centerholdtime(i)+0.001& bdf.pos(:,1)>=centerholdtime(i)-0.001,1),2);
end
figure
subplot(3,1,1)
 hist(xcenterholdtime);
 xlim([-30 40])
 ylabel('count');
 title('x position at center')
 subplot(3,1,2)

 hist(xmaxabort);
 hold on;
 plot([(max (xcenterholdtime)+min(xreward))/2 (max (xcenterholdtime)+min(xreward))/2],[0 50])
 xlim([-30 40])
  ylabel('count')
   title('max x pos from start to 1.4 s when abort')
   hold off;
  subplot(3,1,3)

 hist(xreward); xlim([-30 40])
 xlabel('xpos');
 ylabel('count')
    title('x pos at reward')
    
trueaborts=length(find(xmaxabort>  (max (xcenterholdtime)+min(xreward))/2));
 falseaborts=length(find(xmaxabort<  (max (xcenterholdtime)+min(xreward))/2));
 
toc