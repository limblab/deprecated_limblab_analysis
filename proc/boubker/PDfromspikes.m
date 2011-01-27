clear; close all;clc;


pathname='C:\Documents and Settings\Administrator\Desktop\Boubker_Data\LFPs\Chewie\';
root=('CHEWlfp');
data=load([pathname,root,'.mat']);

nbtarget=8;
rewardword=32;
timebef=0.005;%s
timeaft=0.7;%s
degres=30;
degres=degres * pi / 180;
os=-pi:degres:pi;
direc=os;
direc(1)=[];

dd=[];
dd=[dd data.(root).units.id];
chan=dd(1:2:end-1);
units=dd(2:2:end);
chanunit(:,1)=dd(1:2:end-1)';
chanunit(:,2)=dd(2:2:end)';
cha_uni=chanunit;
cha_uni(find(cha_uni(:,2)==0),:)=[];

postimes=(data.(root).pos(:,1)*1000);



xposall=data.(root).pos(:,2);
yposall=data.(root).pos(:,3);

psr= 1/(postimes(2)- postimes(1))*1000;


if psr<1000
postim=(postimes(1):1:(postimes(end)))';
xposall=interp1(postimes,data.(root).pos(:,2),postim,'nearest');
yposall=interp1(postimes,data.(root).pos(:,3),postim,'nearest');
end

cuesall= data.(root).words(:,1);
words=data.(root).words(:,2);
starts=cuesall(find(words==rewardword)-nbtarget);
ends=cuesall(find(words==rewardword));
while (starts(1)<=0)
    starts(1)=[];
end;
while (ends(1)<starts(1))
    ends(1)=[];
end;
moves=[];
trials=[];
direction=[];
modul=[];
yud=0;
unitscall=[];
 for i=1: length(starts)
     moves=[moves; cuesall(find(ends(i)> cuesall & cuesall > starts(i)))];
     
 end;

for i=1: length(starts)
    %% x and y positions for each cues in each trial
    rt=starts(i);
    while rt<ends(i)
        
        xpos=xposall(find(postimes==round(rt*1000)));
        xpos2=xposall(find(postimes==round((rt+timeaft)*1000)));
        ypos=yposall(find(postimes==round(rt*1000)));
        ypos2=yposall(find(postimes==round((rt+timeaft)*1000)));
         %% vector calculate
        
        %  xposvect(i,j)=xpos(i+1,j)-xpos(i,j);
        xposvect=xpos2-xpos;
        yposvect=ypos2-ypos;
        yud=yud+1;
        direction=[direction; atan2(xposvect,yposvect)];
% get the spikes count for each unit
unitsc=[];
for h=1:size(chanunit,1)
    if chanunit(h,2)~=0
        unitsc=[unitsc;(length(find(data.(root).units(1,h).ts>rt & data.(root).units(1,h).ts<rt+timeaft)))];
    end
end

unitscall=[unitscall unitsc];
                
         rt=rt+timeaft;    
    end
end
means=[];
band1=[];
yu=0;
 unitscall=unitscall';
unitscall(size(direction,1)+1:end,:)=[];
spike_counts = cell(1,size(cha_uni,1));


for r=1:size(cha_uni,1)
    unitsp=unitscall(:,r);
    for i=1:length(os)-1
        angles(i,r)=mean(unitsp(find(os(i) < direction & direction < os(i+1))));
      spike_counts{r}{i}=unitsp(find(os(i) < direction & direction < os(i+1)));
    end
end;
for r=1:size(cha_uni,1)

[l,d]=(max(angles(:,r)));
PD(r)=direc(d);

end;

s = struct('filename', {root}, 'counts_unit', {cell2struct(spike_counts,'counts_unit_direction',15)}, ...
 'directions', {direction});
%% bootstrapping then calculate the circular mean and the CI
cd('..\..');
load_paths;

bootstrapPDS = cell(1, size(cha_uni,1));

PDMatrix=zeros(size(cha_uni,1),3);
for x = 1:size(cha_uni,1)
    bootstrapPDS{x} = bootstrap(@vector_sum_pd, spike_counts{x}, 'all', 1000);
    ss=bootstrapPDS{x}(:,1);
    PDMatrix(x,:)=cprctile(ss,[5 50 95]);
end
%% get the mean magnitudes and plot PD as a polar 
for x = 1:size(cha_uni,1)
   mag(x) =mean(bootstrapPDS{x}(:,2));end;

[pdcartx,pdcarty]=pol2cart(PDMatrix(:,2),mag');
figure;compass(pdcartx,pdcarty);

%% convert to degrees and plot histogram

 PDMatrix=PDMatrix/pi*180;
 figure;
 bar(PDMatrix(:,2));hold;
 errorbar([1:1:size(cha_uni,1)],PDMatrix(:,2),PDMatrix(:,2)-PDMatrix(:,1),PDMatrix(:,3)-PDMatrix(:,2),'+')
xlabel('Units');
ylabel('PD');
