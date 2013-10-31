%% Fake decoder for 10 inputs, 1 output, 10 bins

H1 = [0 1 2 3 4 5 6 7 4 2];
H2 = [2 5 8 4 2 -3 -5 -7 -3 3];
H3 = [-4 -2 0 2 5 8 6 3 2 0];
H4 = [-4 -2 1 3 6 7 4 4 3 3];
H5 = [0 4 6 9 6 3 0 0 0 0];
H6 = - H5;
H7 = [-8 -6 -4 -2 0 2 4 6 8 10];
H8 = -H7;
H9 = [ 0 1 1 1 0 0 -1 -1 -1 0];
H10 = -2*H9;
H11 = [ 0 1 2 3 5 8 3 2 1 3];
H12 = [-5 -2 -6 -3 -4 0 0 0 1 4];
H13 = [-3 -3 -3 -3 -2 0 0 3 3 5];
H14 = [-5 -6 -3 -2 -2 0 3 4 6 8];

H = [H1 H2 H3 H4 H5 H6 H7 H8 H9 H10 H11 H12 H13 H14]';
 clear H1 H2 H3 H4 H5 H6 H7 H8 H9 H10 H11 H12 H13 H14;

% Inputs
baseline   = rand(14)*2/10;
modulation = (rand(20000,14)-0.5)*6/10;

for i = 1:14
    tmpInputs(:,i) = baseline(i)+modulation(:,i);
end
Inputs = zeros(size(tmpInputs));
% Inputs(tmpInputs>0) = tmpInputs(tmpInputs>0);
Inputs(tmpInputs>0) = round(tmpInputs(tmpInputs>0)*6)*20;

%Create output with 14 neurons
Output = predMIMO3(Inputs, H,1,1,Inputs);
% % add some noise
Output = Output + (rand(20000,1)-0.5)*mean(abs(Output))/4;
% offset
Output = Output - 30000;


% Create the spikeguide with electrode names
spikeguide = char(zeros(10,6));
for i=1:10
    spikeguide(i,:)=['ee' sprintf('%02d', i) 'u0'];
end

FakeData_train = struct('timeframe', (0:9999)*0.05,...
                  'spikeratedata', Inputs(1:10000,:),...
                  'spikeguide', spikeguide,...
                  'emgdatabin', Output(1:10000),...
                  'emgguide', 'Output1     '...
                  );
FakeData_test = struct('timeframe', (0:9999)*0.05,...
                  'spikeratedata', Inputs(10001:end,:),...
                  'spikeguide', spikeguide,...
                  'emgdatabin', Output(10001:end),...
                  'emgguide', 'Output1     '...
                  );
              
% preds with real H
YhatH = predMIMO3(Inputs(10001:end,:),H,1,1,Output);

% estimate H for 7 neurons
[Hhat, ~, ~] = filMIMO3([ones(10000,1) Inputs(1:10000,1:7)],Output(1:10000),10,1,1);
% [Hhat, ~, ~] = filMIMO3(Inputs(1:10000,1:7),Output(1:10000),10,1,1);


% preds with estimated H
YhatHat = predMIMO3([ones(10000,1) Inputs(10001:end,1:7)],Hhat,1,1,Output);
% YhatHat = predMIMO3(Inputs(10001:end,1:7),Hhat,1,1,Output);

figure;
plot(YhatH,'g');
hold on;
plot(YhatHat,'r');
plot(Output(10001:end),'k');
realH = CalculateR2(YhatH,Output(10001:end));
estH  = CalculateR2(YhatHat,Output(10001:end));
legend(sprintf('realH R2=%.3f',realH),sprintf('estH R2=%.3f',estH),'actual');

figure;
subplot(211); bar(H);
subplot(212); bar(Hhat);
hold off;


