function [vaf, noisy_template_decoders, noisy_emg_patterns] = test_noisy_templates(testdata,E2F,varargin)

%default input variables:
tmp_pat      = load('/Users/christianethier/Dropbox/Adaptation/new_data/Jango_20140707_EMGpatterns.mat');
emg_patterns = tmp_pat.EMGpatterns;
noise_pct    = [0 0.1 0.2 0.4 0.6 0.8 1];
num_iter     = 5;

% input argument override:
if nargin>3  emg_patterns = varargin{1};end
if nargin>4  noise_pct    = varargin{2};end
if nargin>5  num_iter     = varargin{3};end

num_noise_val = length(noise_pct);

noisy_template_decoders = cell(num_noise_val,num_iter);
noisy_emg_patterns      = cell(num_noise_val,num_iter);
vaf                     = cell(num_noise_val,num_iter);

for n = 1:num_noise_val
    for i = 1:num_iter
        
%         noisy_emg_patterns{n,i} = emg_patterns + ...
%                                   (noise_pct(n)*emg_patterns) ...
%                                   .*(2*(rand(size(emg_patterns))-0.5));

        noisy_emg_patterns{n,i} = ( (1-noise_pct(n))*emg_patterns + ...
                                    (  noise_pct(n))*rand(size(emg_patterns)) );

  
        params.emg_patterns = noisy_emg_patterns{n,i};
        
        noisy_template_decoders{n,i} = train_offline_decoder('Jango',params);
        vaf{n,i} = plot_emg_preds(testdata,noisy_template_decoders{n,i},E2F);
    end
end


vafpct = zeros(11,7,5);
for i = 1:7
    for j = 1:5
        vafpct(:,i,j) = vaf{i,j};
    end
end
 m_vafpct = mean(vafpct,3);
sd_vafpct = std(vafpct,0,3);
figure;
barwitherr(sd_vafpct',m_vafpct');
set(gca,'XTickLabel',{'0' '10' '20' '40' '60' '80' '100'})
xlabel('Noise Percentage in EMG Patterns');
ylabel('VAF')
title('Force Error + L2');

