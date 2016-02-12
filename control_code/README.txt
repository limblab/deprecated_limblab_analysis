Ian Stevenson and Beau Cronin
Jan 12, 2010 (version 1)

This code package performs fully Bayesian estimation of parametric tuning curves with various noise models, and contains examples for model comparison and hypothesis testing. It accompanies the paper...

Hierarchical Bayesian modeling and Markov chain Monte Carlo sampling for tuning curve analysis (2010)
Cronin B*, Stevenson IH*, Sur M, and Körding KP. Journal of Neurophysiology 103: 591-602.
http://jn.physiology.org/cgi/content/abstract/103/1/591


*** USE ***

1. Tuning Curve Estimation

Open the script 'test_tc_sample.m' and run. This script contains code for estimating the parameters of a circular gaussian tuning curve from simulated data (see Fig 2B and Fig 3 in the paper). Code for estimating a cosine tuning curve is commented out (lines 9-12).


2. Model Comparison

The script 'test_tc_hypothesistest' contains code for reproducing Fig 7 from the paper.


3. Additional tuning curve functions and noise models are described in 'tc_sample.m' and the Supplementary Material for the paper.