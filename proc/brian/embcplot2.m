% embcplot2.m

% tiki_r2 = [
%     0.6912    0.7415    0.0014    0.0006 % velocity prediction, movement
%     0.4872    0.4743    0.0018    0.0015 % force prediction, movement
%     0.2415    0.3103    0.0013    0.0022 % velocity prediction, loaded movement
%     0.5365    0.3087    0.0058    0.0047 % force prediction, loaded movement
%     0.5667    0.4053    0.0051    0.0085 % force prediction, isometric
% ];

tiki_r2 = [
    0.6912    0.7415    0.0014    0.0006 % velocity prediction, movement
    0.4872    0.4743    0.0018    0.0015 % force prediction, movement
    0.6740    0.6954    0.0008    0.0012 % velocity prediction, loaded movement
    0.2300    0.3678    0.0023    0.0046 % force prediction, loaded movement
    0.5667    0.4053    0.0051    0.0085 % force prediction, isometric
];

mini_r2 = [
    0.6534    0.6053    0.0009    0.0020 % velocity prediction, loaded movement
    0.1946    0.1504    0.0032    0.0039 % force prediction, loaded movement
    0.7513    0.6073    0.0018    0.0027 % force prediction, isometric movement
];


% tiki_vaf2 = [
%     0.7001    0.0289 % velocity prediction, movement
%     0.4229    0.0471 % force prediction, movement
%     0.6224    0.0393 % velocity prediction, loaded movement
%     0.0808    0.2398 % force prediction, loaded movement
%     0.3740    0.0837 % force prediction, isometric
% ];

tiki_cross = [
    0.0737    0.1244    0.0011    0.0054 % force prediction chr->iso
    0.0257    0.0590    0.0003    0.0008 % force prediction iso->chr
];


% turn vars into stdevs
mini_r2(:,[3 4]) = sqrt(mini_r2(:,[3 4]));
tiki_r2(:,[3 4]) = sqrt(tiki_r2(:,[3 4]));
tiki_cross(:,[3 4]) = sqrt(tiki_cross(:,[3 4]));

% do the plots
x = [1 3 2 4 5];
x2 = [2 4 5];
figure; hold on;
errorbar(x-.05, tiki_r2(:,1), tiki_r2(:,3), tiki_r2(:,3), 'ks'); % Tiki Horiz
errorbar(x-.15, tiki_r2(:,2), tiki_r2(:,4), tiki_r2(:,4), 'ko'); % Tiki Vert
errorbar(x2+.15, mini_r2(:,1), mini_r2(:,3), mini_r2(:,3), 'bs'); % Mini Horiz
errorbar(x2+.05, mini_r2(:,2), mini_r2(:,4), mini_r2(:,4), 'bo'); % Mini Vert

legend('Monkey T: Horizontal','Monkey T: Vertical','Monkey M: Horizontal','Monkey M: Vertical');

figure; hold on;
x = [1 2];
errorbar(x-.02, tiki_cross(:,1), tiki_cross(:,3), tiki_cross(:,3), 'ks'); % Tiki Horiz
errorbar(x+.02, tiki_cross(:,2), tiki_cross(:,4), tiki_cross(:,4), 'ko'); % Tiki Vert