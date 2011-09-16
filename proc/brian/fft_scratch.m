
dims = {'?', 'X', 'Y'};

for dim = 2:3
    
%     th_t = bdf_m.raw.enc(:,1); % encoder time stamps
% 
%     adfreq = 1000; %Arbitrarily 1KHz
%     start_time = 1.0;
%     last_enc_time = bdf_m.raw.enc(end,1);
%     stop_time = floor(last_enc_time) - 1;
%     analog_time_base = start_time:1/adfreq:stop_time;
%     th_1 = bdf_m.raw.enc(:,2) * 2 * pi / 18000;
%     th_2 = bdf_m.raw.enc(:,3) * 2 * pi / 18000;
%     th_1_adj = interp1(th_t, th_1, analog_time_base);
%     th_2_adj = interp1(th_t, th_2, analog_time_base);
% 
%     th_1_adj = smooth(th_1_adj, 51)';
%     th_2_adj = smooth(th_2_adj, 51)';
% 
%     % convert to x and y
%     l1=24.0; l2=23.5;
%     x = - l1 * sin( th_1_adj ) + l2 * cos( -th_2_adj );
%     y = - l1 * cos( th_1_adj ) - l2 * sin( -th_2_adj );
%     
%     x = detrend(diff(x));
%     NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
%     Y = fft(x,NFFT)/length(x);
%     fp = 1000/2*linspace(0,1,NFFT/2);
%     pp = smooth(2*abs(Y(1:NFFT/2)),51);
    
    x = detrend(bdf_m.vel(:,dim));
    NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
    Y = fft(x,NFFT)/length(x);
    fv = 1000/2*linspace(0,1,NFFT/2);
    pv = smooth(2*abs(Y(1:NFFT/2)),51);

    x = detrend(bdf_m.force(:,dim));
    NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
    Y = fft(x,NFFT)/length(x);
    ff = 1000/2*linspace(0,1,NFFT/2);
    pf = smooth(2*abs(Y(1:NFFT/2)),51);

    x = detrend(bdf_i.force(:,dim));
    NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
    Y = fft(x,NFFT)/length(x);
    fii = 1000/2*linspace(0,1,NFFT/2);
    pii = smooth(2*abs(Y(1:NFFT/2)),51);
    
    figure; hold on;
    plot(fii,pii/sum(pii)*1000,'k-');
    plot(ff,pf/sum(pf)*1000,'b-');
    plot(fv,pv/sum(pv)*1000,'r-');
    plot(fp,pp/sum(pp)*1000,'g-');

    axis([0 10 0 1]);
    title(sprintf('%s axis values', dims{dim}));
    legend('isometric force', 'movement force', 'movement velocity');
    %legend('isometric force', 'movement force', 'movement velocity', 'non-filtered velocity');
end




