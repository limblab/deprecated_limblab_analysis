function[cont_signal] = train2cont(train,maxISI)

% train2cont(train,reach) converts a spike train (raster) to a continuous
% signal using Gaussian convolution. The rise time will be approximately
% 1.5*maxISI

% train: Input spike train (zeros and ones)
% maxISI: represents two standard deviations of the Gaussian kernel (in ms) 
%        Example: maxISI = 50 means that the amplitude of the continuous
%        signal will only significantly increase when an ISI is less than
%        50 ms. 

sd = maxISI/2;
N = 6*sd+1;

gaussfilt = fspecial('gaussian',[N 1],sd);

K_ki = conv(train,gaussfilt);
K_ki(1:(N-1)/2) = [];
K_ki(end-(N-1)/2+1:end)=[];
K_ki = 1000*K_ki;

%h = figure; 
%h = stem(train*max(K_ki)); set(h,'Marker','none');

%hold on; plot(1:length(K_ki),K_ki);

cont_signal = K_ki;
