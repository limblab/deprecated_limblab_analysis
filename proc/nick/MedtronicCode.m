for t = 1:10
    h(t) = rand-0.5;
end

x = [zeros(1,150) ones(1,40) zeros(1,150)];
y = conv(x,h);
y = y(1:length(x));

X = fft(x);
Y = fft(y);
H = Y./X;

for i = 2:length(X)
    if (isinf(H(i)) || isnan(H(i)))
        H(i) = (Y(i) - Y(i-1)) / (X(i) - X(i-1));
    end
end
new_h1 = real(ifft(H));

figure
plot(h)
hold on
plot(new_h1(1:length(h)), 'r--')

clear x y X Y H;

% for t = 1:10
%     h(t) = rand-0.5;
% end

for z = 1:20
x(z,:) = [zeros(1,150) ones(1,z) zeros(1,150-z)];
y_temp = conv(x(z,:),h);
y(z,:) = y_temp(1:length(x(z,:)));

X(z,:) = fft(x(z,:));
Y(z,:) = fft(y(z,:));
end

Y_sum = sum(Y,1);
X_sum = sum(X,1);
H = Y_sum./X_sum;

new_h2 = ifft(H);

figure
plot(h)
hold on
plot(new_h2(1:length(h)), 'r--')