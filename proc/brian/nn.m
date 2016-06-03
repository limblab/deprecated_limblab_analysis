% nn.m

% Setup Training Set
th = rand(1,1000)*2*pi;
pro = rand(1,1000)*pi - pi/2;

train_in  = [pro; sin(th); cos(th)];
train_out = [sin(th+pro); cos(th+pro)];

% Setup Network
net = network;

net.numInputs = 1;
net.inputs{1}.size = 3;

net.numLayers = 2;
net.layers{1}.size = 100;
net.layers{2}.size = 2;

net.inputConnect(1) = 1;
net.layerConnect(2,1) = 1;
net.outputConnect(1) = 1;
net.outputConnect(2) = 1;
net.targetConnect(2) = 1;
net.biasConnect(1) = 1;
net.biasConnect(2) = 1;

net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'purelin';
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initnw';
net.layers{2}.initFcn = 'initnw';

net.performFcn = 'mse';
net.trainFcn = 'traingdm';
net.trainParam.lr = 0.1;
net.trainParam.mc = 0.9;
net.trainParam.epochs = 1000;
net.trainParam.show = 100;
net = init(net);

% Train the network
net = train(net, train_in, train_out, [], []);

%% Test the network

th = 0:pi/4:7*pi/4;
pro = pi/2 * [-ones(1,8) ones(1,8)];

test_set = [pro; sin([th th]); cos([th th])];

q = sim(net, test_set);

plot(atan2(q(101,:), q(102,:)), mod(pro+[th th],2*pi), 'k.');

%%

pds = zeros(100,2);

for n = 80:102
    nn = q(n,:);
    figure; hold on;
    plot((2+nn(1:8)).*sin(th), (2+nn(1:8)).*cos(th), 'k-');
    plot((2+nn(9:16)).*sin(th), (2+nn(9:16)).*cos(th), 'r-');
    
    [(2+nn(1:8)).*sin(th); (2+nn(1:8)).*cos(th)];
end

