# force.py

import csv
import numpy as np
import statsmodels.api as sm
from numpy.linalg import lstsq

def sim_points(n = 100):
	baseline = np.random.normal(15., 4.)
	w_force, w_vel = np.random.normal(5., 3., size=(2,))
	w_cross = np.random.normal(3., .1)
	def fr(x):
		fv = np.array([w_vel, w_force]).dot(np.cos(x.T))
		cross = w_cross * np.cos(x[:, 0]) * np.cos(x[:, 1])
		return baseline + fv + cross
	points = 2 * np.pi * np.random.rand(n, 2)
	duration = np.random.normal(0.2, 0.05, (n,))
	la = duration * fr(points)
	fr = np.random.poisson(la) / duration
	w = [w_vel, w_force, w_cross, baseline]
	x = np.hstack((points, fr[np.newaxis].T))
	return (w, x)


def get_pd(th, la):
	x = np.vstack([np.cos(th), np.sin(th), np.ones(th.shape)]).T
	N,_,_,_ = lstsq(x, la)
	A,B,mu = N 
	return np.arctan2(B, A)


def remove_pd(x):
	def remove_pd_from_axis(xyf, axis):
		th = xyf[:,axis]
		la = xyf[:,2]
		pd = get_pd(th, la)
		xyf[:,axis] = xyf[:,axis] - pd
		return xyf
	x = remove_pd_from_axis(x, 0)
	x = remove_pd_from_axis(x, 1)
	return x


def reg_m(x, y):
    ones = np.ones(len(x[0]))
    X = sm.add_constant(np.column_stack((x[0], ones)))
    for ele in x[1:]:
        X = sm.add_constant(np.column_stack((ele, X)))
    results = sm.OLS(y, X).fit()
    return results


def fit_mdl(xy, fr):
	v_comp = np.cos(xy[:,0])
	f_comp = np.cos(xy[:,1])
	x_comp = f_comp * v_comp

	X = np.vstack([v_comp, f_comp, x_comp, np.ones(v_comp.shape)]).T
	return sm.OLS(fr, X).fit()


def pred_mdl(mdl, xy):
	v_comp = np.cos(xy[:,0])
	f_comp = np.cos(xy[:,1])
	x_comp = f_comp * v_comp

	X = np.vstack([v_comp, f_comp, x_comp, np.ones(v_comp.shape)]).T
	return mdl.predict(X)


def fit_lin_mdl(xy, fr):
	v_comp = np.cos(xy[:,0])
	f_comp = np.cos(xy[:,1])

	X = np.vstack([v_comp, f_comp, np.ones(v_comp.shape)]).T
	return sm.OLS(fr, X).fit()


def pred_lin_mdl(mdl, xy):
	v_comp = np.cos(xy[:,0])
	f_comp = np.cos(xy[:,1])

	X = np.vstack([v_comp, f_comp, np.ones(v_comp.shape)]).T
	return mdl.predict(X)


def parse_file(filename):
	csvfile = open(filename, 'r')
	reader = csv.reader(csvfile)
	vf = []
	la = []
	for row in reader:
		vf.append([float(row[0]), float(row[1])])
		la.append([float(x) for x in row[2:]])
	return np.array(vf), np.array(la).T


if __name__ == '__main__':
	# filename = "/Users/brianlondon/Desktop/cleanup/data/Arthur_S1_016.csv"
	filename = "/Users/brianlondon/Desktop/cleanup/data/Pedro_S1_014_s2.csv"
	# filename = "/Users/brianlondon/Desktop/cleanup/data/tiki_rw026.csv"

	vf, la = parse_file(filename)

	var_ratios = np.empty([0, 2])
	pvalues = np.empty([0, 4])
	for neuron in range(len(la)):

		x = np.hstack([vf, np.atleast_2d(la[neuron]).T])
		x = remove_pd(x)

		vf_m = x[:, 0:2]
		la_m = x[:, 2]
		
		mdl = fit_mdl(vf_m, la_m)
		pvalues = np.vstack([pvalues, mdl.pvalues])

		lin_mdl = fit_lin_mdl(vf_m, la_m)

		full_ratio = 1 - np.var(mdl.resid) / np.var(la_m)
		partial_ratio = 1 - np.var(lin_mdl.resid) / np.var(la_m)

		var_ratios = np.vstack([[full_ratio, partial_ratio], var_ratios])

	print(np.sum(pvalues < .05, 0))
	print(pvalues.shape)

	# # Test One
	# w,x = sim_points()
	# mdl = fit_mdl(x[:,0:2], x[:,2])

	# # Test Two
	# w,x = sim_points(1000)
	# x2 = np.copy(x)
	# x2[:,0] = x2[:,0]-.1
	# x2[:,1] = x2[:,1]+.2


