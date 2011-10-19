function arraymap(mapfile)
%mapfile cmp file 
fid=fopen(mapfile);
tline = fgetl(fid);
while isnan(str2double(tline(1)))
tline = fgetl(fid);
end

correspond = -1*ones(96,3);
line = 0;
delim = char(9) %delimitation character

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

X(1:96,2)=10:105;
X(1:96,1)=1:96;
if size(X,2)==1 
    X(:,2)=  X(:,1);
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
        row=10-correspond(find(correspond(:,3)==X(i,1)),1)
        col=10-correspond(find(correspond(:,3)==X(i,1)),2)
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
[pathstr, name, ext] = fileparts(mapfile)
title(strvcat(name,'wire bundle'))
colorbar
colormap(hot)

end