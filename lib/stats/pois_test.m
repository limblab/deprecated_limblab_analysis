function [ out, out2 ] = pois_test(c1, t1, c2, t2)
% Tests whether lambda2 > lambda1 where c1, c2 are counts and t1, t2 are
% the observation times for two poisson distributions.  Assumes p=.9 and
% alpha = .05
%
% with two output arguments this gives the reverse test also: 
% lambda1 > lambda 2
%
% See: Huffman, Michael. An Improved Apporoximate Two-sample Poisson Test.
% Appl. Statist 33(2)224-226. (1984)

d = t2/t1;
Za = 1.96; % alpha = .05; (Za is normal distribution quantile for 1-alpha)

Z2 = 2*(sqrt(c2+3/8) - sqrt(c1+3/8)) / sqrt(1+d);

out = Z2 > Za;
