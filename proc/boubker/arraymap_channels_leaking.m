function [data,r,p,units_correlated,chan]=arraymap_channels_leaking(mapfile,root,chan,thresh)
%mapfile cmp file 
%root is the mat data with waveforms
%chan=first column channels second row units 
%%chan=[4,1;9,2;11,3,;7,1];
%%chan can be empty so it will look for channels with units that are highly
%%correlated
%%thresh: threshold of how highly correlated must the units be. 
 data=LoadDataStruct(root);



fid=fopen(mapfile);
tline = fgetl(fid);
while isnan(str2double(tline(1)))
tline = fgetl(fid);
end

correspond = -1*ones(96,3);
line = 0;
delim = char(9); %delimitation character

while line<96
 
     line=line+1;
    tabs = strfind(tline,delim);
    
    correspond(line,1) = str2double(tline(1:tabs(1)-1));
    correspond(line,2) = str2double(tline(tabs(1)+1:tabs(2)-1));
    bank = 32*(double(tline(tabs(2)+1:tabs(3)-1))-double('A'));
    if length(tabs)==4
    correspond(line,3) = str2double(tline(tabs(3)+1:tabs(4)-1))+bank;
    else
      correspond(line,3) = str2double(tline(tabs(3)+1:end))+bank; 
    end
    tline = fgetl(fid);
  
end

X(1:96,2)=0;
if ~isempty (chan)
for fr=1:length(chan)
  for gt=1: size(data.waveforms.ID,2) 
if data.waveforms.ID{1,gt}==chan(fr,:)
X(chan(fr,1),2)= data.waveforms.amp{1,gt};
end
  end
end
else
 binw=floor(data.meta.duration/100);
 chi=0;

for j=1: size(data.units,2) 
    if data.units(1,j).id(2)~=0 && data.units(1,j).id(2)~=255
        chi=chi+1;
        k=0;
         binde=0;
        while binde+binw< data.units(1,j).ts(end)
            k=k+1;
    binned(k,chi)=length(find(data.units(1,j).ts<binde+binw & data.units(1,j).ts>binde));
    binde=binde+binw;
        end
    end
end



[r,p] = corrcoef( binned);  % Compute sample correlation and p-values.
[i,j] = find((r)>thresh);  % Find significant correlations.
 hh(:,1)=i;
 hh(:,2)=j;
 hh(find(i==j),:)=[];
  hh=sortrows(hh);
  hh(find(hh(:,2)<hh(:,1)),:)=[];
  ffd=unique(hh);
  for jh=1:length(ffd);chan(jh,:)=data.waveforms.ID{ffd(jh)};end
  units_correlated=chan;
% figure
% imagesc(r)
% colorbar
for fr=1:length(chan)
  for gt=1: size(data.waveforms.ID,2) 
if data.waveforms.ID{1,gt}==chan(fr,:)
X(chan(fr,1),2)= data.waveforms.amp{1,gt};
end
  end
end


end
X(1:96,1)=1:96;
if size(X,2)==1 

    X(:,1) =1:96;
end
for j=1:10
    for i=1: 10
        arrays(10-(i-1),10-(j-1))=i+(10*(j-1));
     end
end;
for j=1:10
    for i=1: 10
        arrays2((i-1)+1,(j-1)+1)=i+(10*(j-1));
     end
end;
for j=1:10
    for i=1: 10
        arrays3((i-1)+1,(j-1)+1)=j+(10*(i-1));
     end
end;
arrays2=fliplr(fliplr(fliplr(fliplr(fliplr(fliplr(arrays))))));

effects=-1*ones(10,10);



    for i=1: length(X) 
        row=10-correspond(find(correspond(:,3)==X(i,1)),1);
        col=10-correspond(find(correspond(:,3)==X(i,1)),2);
        effects(row,col)=X(i,2);

    end


figure;
I=(effects);
imagesc(I);hold;


for j=1:10
    for i=1: 10
       
        text(i,j,int2str(correspond(find(correspond(:,2)*10+correspond(:,1)+1==arrays(j,i)),3)));
       
    end
end;

colorbar
colormap(hot)
set(gca,'XTick',[],'XTicklabel',[],'YTick',[],'YTicklabel',[])
xlabel('lateral');
ylabel('anterior')
[pathstr, name, ext] = fileparts(mapfile);
title(strvcat(name,'wire bundle'))
colorbar
colormap(hot)

