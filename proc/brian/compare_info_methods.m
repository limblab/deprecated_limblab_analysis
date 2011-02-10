function compare_info_methods(summary, out, bdf, id)
% compares the three information methods.

%---------------------------------
% Log-likelihood ratio
%---------------------------------
t = -5:.01:5;
subplot(2,1,1),plot(t,1./out(id,:), 'k-');

%---------------------------------
% Mutual information
%---------------------------------
chan = summary{id}.id(1);
unit = summary{id}.id(2);

s = get_unit(bdf, chan, unit);

%end_mi = floor(s(end));

b = train2bins(s, .001); % 1ms bins
b = b(1000:end); % drop points before begin mi
v = bdf.vel(:,2:3);
x = bdf.pos(:,2:3);

if (length(b) > length(v))
    b = b(1:size(v));
else
    v = v(1:length(b),:);
    x = x(1:length(b),:);
end

dv = tmi(b, v, -5000:50:5000);
dx = tmi(b, x, -5000:50:5000);

t = -5000:50:5000;
t = t.*0.001;
%figure;
%plot(t,d,'b-')
subplot(2,1,2),plot(t,dv,'b-');
hold on
subplot(2,1,2),plot(t,dx,'r-');
xlabel('Delay (s)');
ylabel('Mutual Information (bits/s)');




