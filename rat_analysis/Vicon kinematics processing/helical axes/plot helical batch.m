% let the user choose the file and then read it in
[filename,pathname] = uigetfile('*.csv');
fname = fullfile(pathname, filename);
raw_data = xlsread(fname);
[new_data,frames] = find_frameblocks(raw_data,OPTS);
% [x,y,z] = separate_points(new_data);

[x,y,z,allframes,blocked_data] = preprocess(raw_data,OPTS);
close all
plot3(x,y,z,'rx')
%%

x = x - repmat(mean(x(:)),size(x));
y = y - repmat(mean(y(:)),size(y));
z = z - repmat(mean(z(:)),size(z));
y2 = z;
z = y;
y = y2;
%%

ind = 200:1600;
nframes = length(ind);
skip = 1;
for ii = 1:nframes
    nn = ind(ii);
    A = [x(nn,:); y(nn,:); z(nn,:)];
    B = [x(nn+skip,:); y(nn+skip,:); z(nn+skip,:)];
    [regParams,Bfit,ErrorStats]=absor(A,B);
    T = [regParams.R regParams.t; 0 0 0 1];
    [v,point,phi,t] = screw(T);
    allv(ii,:) = v;
    allpoint(ii,:) = point;
    allphi(ii) = phi;
    allt(ii) = t;
    alldir(ii) = sign(allv(ii,:)*[0 1 0]');
end
    
%%

ind2 = find(allphi > .5);
nframes = length(ind2);
for ii = 1:nframes
    nn = ind2(ii);
    allv2 = allv(nn,:)/norm(allv(nn,:));
%     p2 = allpoint(nn,:) -450*allv(nn,:);
%     p1 = allpoint(nn,:) - 550*allv(nn,:);
    p2 = allpoint(nn,:)*0 +2*allv2*alldir(ii);
    p1 = allpoint(nn,:)*0 -5*allv2*alldir(ii);
    plot3([p1(1) p2(1)],[p1(2) p2(2)],[p1(3) p2(3)],'g')
%     plot3(allpoint(ii,1),allpoint(ii,2),allpoint(ii,3),'go')
    hold on
end

% plot3(x(ind,:),y(ind,:),z(ind,:),'rx')
% hold off
axis('equal')
grid

%%

for ii = 1:1:length(allv)
    temp = allv(ii,:)/norm(allv(ii,:))*allphi(ii)*alldir(ii);
%     plot3([0 allv(ii,1)],[0 allv(ii,2)],[0 allv(ii,3)]);
    plot([0 temp(1)],[0 temp(2)]);
    allang1(ii) = atan2(temp(2),temp(1));
    allang2(ii) = atan2(temp(1),temp(3));
    hold on
end
hold off
grid
axis('equal')