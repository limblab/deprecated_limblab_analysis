%
% Function that calculates pair-wise changes in firing rate (raw and
% normalized), across up to three blocks of neural recordings. It also
% performs a Wilcoxon signed rank comparison.
%
% function [neural_activity_1, neural_activity_2, neural_activity_3] = ...
%    calc_stats_firing_rate_btw_blocks( neural_activity_1, neural_activity_2, neural_activity_3 )
%
%


function [neural_activity_1, neural_activity_2, neural_activity_3] = ...
    calc_stats_firing_rate_btw_blocks( neural_activity_1, neural_activity_2, neural_activity_3 )


% Block 2 wrt to Block 1
neural_activity_2.change_firing_rate                    = mean(neural_activity_2.mean_firing_rate,1) ...
                                                            - mean(neural_activity_1.mean_firing_rate,1);
neural_activity_2.change_norm_firing_rate               = mean(neural_activity_2.norm_firing_rate,1) ...
                                                            - mean(neural_activity_1.norm_firing_rate,1);
                                                        
neural_activity_2.wilcox                                = signrank(mean(neural_activity_1.mean_firing_rate,1),...
                                                            mean(neural_activity_2.mean_firing_rate,1));
neural_activity_2.wilcox_norm                           = signrank(mean(neural_activity_1.norm_firing_rate,1),...
                                                            mean(neural_activity_2.norm_firing_rate,1));

if ~isempty( neural_activity_3 )
                                                        
    % Block 3 wrt to Block 2
    neural_activity_3.change_firing_rate              	= mean(neural_activity_3.mean_firing_rate,1) ...
                                                            - mean(neural_activity_2.mean_firing_rate,1);
    neural_activity_3.change_norm_firing_rate           = mean(neural_activity_3.norm_firing_rate,1) ...
                                                            - mean(neural_activity_2.norm_firing_rate,1);

    neural_activity_3.wilcox                            = signrank(mean(neural_activity_2.mean_firing_rate,1),...
                                                            mean(neural_activity_3.mean_firing_rate,1));
    neural_activity_3.wilcox_norm                       = signrank(mean(neural_activity_2.norm_firing_rate,1),...
                                                            mean(neural_activity_3.norm_firing_rate,1));

    % Block 3 wrt to Block 1
    neural_activity_3.change_firing_rate_bsln           = mean(neural_activity_3.mean_firing_rate,1) ...
                                                            - mean(neural_activity_1.mean_firing_rate,1);
    neural_activity_3.change_norm_firing_rate_bsln      = mean(neural_activity_3.norm_firing_rate,1) ...
                                                            - mean(neural_activity_1.norm_firing_rate,1);

    neural_activity_3.wilcox_bsln                       = signrank(mean(neural_activity_3.mean_firing_rate,1),...
                                                            mean(neural_activity_1.mean_firing_rate,1));
    neural_activity_3.wilcox_norm_bsln                  = signrank(mean(neural_activity_3.norm_firing_rate,1),...
                                                            mean(neural_activity_1.norm_firing_rate,1));
end