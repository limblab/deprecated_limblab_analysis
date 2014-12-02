t = 0:.01:10;
data = sin(t);
data2 = cos(t);

hBanana = figure;
hBananaAxes = gca;
hApple = figure;

plot(t,data,'b')
hold on
plot(t,data2,'g')


plot(hBananaAxes,t,data+data2,'r')


name_of_cell_array = {'This','is','a','string','cell','array',12,hBanana;...
    'This','is','a','string','cell','array',12,ones(10,10)};

name_of_array = 1:10;
name_of_array = [1:10];

my_new_struct = struct('t',0:10,'data',0:10:100);
% my_new_struct.t
% my_new_struct.data
my_new_struct.new_data = 100:-10:0;

save('my_new_datafile')
save('my_new_datafile','my_new_struct')

disp(num2str(name_of_array))

plot(my_new_struct.t,my_new_struct.data,...
    my_new_struct.t(2:8),my_new_struct.new_data(2:8))

plot(my_new_struct.t,[my_new_struct.data ; my_new_struct.new_data])

plot(my_new_struct.t,[my_new_struct.data ; my_new_struct.new_data],...
    'Color',[1 0 0],'LineStyle','.','MarkerSize',15)

xlim([3 7.5])
ylim([25 50])
xlabel('time (s)')
ylabel('data (_au)','Interpreter','none')
title('This is our data')

% Mask image
Lenna = imread('Lenna.png','png');
temp = zeros(512,512,3);
temp(:,:,1) = 1;
imshow(Lenna.*uint8(temp))

my_vector = nan(100);

clear Lenna

new_matrix = rand(10);
new_matrix(5:8,2:4) = nan;
new_matrix(2,9) = nan;
new_matrix(9,9) = 0;
[a,b] = find(isnan(new_matrix));
new_matrix(min(a):max(a),min(b):max(b)) = 0;

new_matrix(isnan(new_matrix)) = 0;

sin_var = sin(t);
find(sin_var<0,1,'first')



% function MatlabTutorial
%     result = fact_n(5);
%     disp(num2str(result))
% end
% function output = fact_n(n)
%     output = factorial(n);
% end