


[vaf_1taps,R2_1taps,predsF_1taps] = plot_predsF(testData,{N2E;E2F_1tap},'cascade');
[vaf_5taps,R2_5taps,predsF_5taps] = plot_predsF(testData,{N2E;E2F_5taps},'cascade');
[vaf_10taps,R2_10taps,predsF_10taps] = plot_predsF(testData,{N2E;E2F_10taps},'cascade');

[vaf_direct,R2_direct,predsF_direct] = plot_predsF(testData,{N2F},'direct');

[psdX_1tap f] = pwelch(predsF_1taps(:,1),length(predsF_1taps)/2,0,[],20);
figure;loglog(f,psdX_1tap);title('X psd | 1 tap'); MillerFigure;
[psdY_1tap  f] = pwelch(predsF_1taps(:,2),length(predsF_1taps)/2,0,[],20);
figure; loglog(f,psdY_1tap);title('Y psd | 1 tap'); MillerFigure;

[psdX_5tap  f]= pwelch(predsF_5taps(:,1),500,0,[],20);
figure; loglog(f,psdX_5tap);title('X psd | 5 taps'); MillerFigure;
[psdY_5tap  f]= pwelch(predsF_5taps(:,2),length(predsF_5taps)/2,0,[],20);
figure; loglog(f,psdY_5tap);title('Y psd | 5 taps'); MillerFigure;

[psdX_10tap  f]= pwelch(predsF_10taps(:,1),500,0,[],20);
figure; loglog(f,psdX_10tap);title('X psd | 10 taps'); MillerFigure;
[psdY_10tap  f]= pwelch(predsF_10taps(:,2),length(predsF_10taps)/2,0,[],20);
figure; loglog(f,psdY_10tap);title('Y psd | 10 taps'); MillerFigure;

[psdX_direct f]= pwelch(predsF_direct(:,1),length(predsF_direct)/2,0,[],20);
figure; loglog(f,psdX_direct);title('X psd | direct'); MillerFigure;
[psdY_direct  f]= pwelch(predsF_direct(:,2),length(predsF_direct)/2,0,[],20);
figure; loglog(f,psdY_direct);title('Y psd | direct'); MillerFigure;

[psdX_actual f]= pwelch(testData.cursorposbin(:,1),length(testData.cursorposbin)/2,0,[],20);
figure; loglog(f,psdX_actual);title('X psd | actual'); MillerFigure
[psdY_actual  f]= pwelch(testData.cursorposbin(:,2),length(testData.cursorposbin)/2,0,[],20);
figure; loglog(f,psdY_actual);title('Y psd | actual'); MillerFigure;



