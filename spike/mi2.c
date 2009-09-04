/*
 * =============================================================
 * mi2.c
 *
 * $Id: mi.c 73 2009-04-10 16:46:05Z brian $
 *
 * called as i=mi(X,Y) where:
 * X is a vector of 1s and 0s
 * Y is a matix 
 * =============================================================
 */
 
#include "mex.h"
#include "math.h"
#define NUM_BINS 20

void mutual_info2(double s[], double v[], double *mi, int L)
{
    int i,j,x,y;
    double max_1 = -mxGetInf();
    double max_2 = -mxGetInf();
    double min_1 = mxGetInf();
    double min_2 = mxGetInf();
    char err[255];
    
    int Pv[NUM_BINS][NUM_BINS];
    int Pvs[NUM_BINS][NUM_BINS];
    
    double PvK, PvsK; /* normalization constants */
            
    /* initialize Px, Py, and Pxy counts to zero */
    for (i=0; i<NUM_BINS; i++) {
        for (j=0; j<NUM_BINS; j++) {
            Pv[i][j] = 0;
            Pvs[i][j] = 0;
        }
    }
    
    /* find max and min in each dimension of y */
    for (i=0; i<L; i++) {
        if (max_1 < v[i]) {
            max_1 = v[i];
        }
        if (max_2 < v[i+L]) {
            max_2 = v[i+L];
        }
        if (min_1 > v[i]) {
            min_1 = v[i];
        }
        if (min_2 > v[i+L]) {
            min_2 = v[i+L];
        }
    }
    
    /* group into bins */
    PvK = (double)L;
    PvsK = 0.0;
    for (i=0; i<L; i++) {
        x = (int)(floor((NUM_BINS-2) * (v[i] - (max_1+min_1)/2) / (max_1 - min_1)) + NUM_BINS/2);
        y = (int)(floor((NUM_BINS-2) * (v[i+L] - (max_2+min_2)/2) / (max_2 - min_2)) + NUM_BINS/2);
        if (x < 0 || x>=NUM_BINS || y<0 || y>= NUM_BINS) {
            sprintf(err, "Histogram Error: x=%d y=%d\nv_0 = %f\nv_1=%f", x, y, v[i],v[i+L]);
            mexErrMsgTxt(err);
        }
        
        Pv[x][y]++;
        if (s[i]>0) {
            Pvs[x][y]++;
            PvsK += 1.0;
        }        
    }
    
    
    /* now calculate mutual information */
    *mi = 0.0;

    for (i = 0; i<NUM_BINS; i++) {
        for (j = 0; j<NUM_BINS; j++) {
            if (Pvs[i][j] > 0)
                *mi += ((double)Pvs[i][j]/PvsK) * log2( ((double)Pvs[i][j]/PvsK) / ((double)Pv[i][j]/PvK));
        }
    }
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *x, *y, *mi;
  int xrows, xcols, yrows, ycols;
  int xlen;
  
  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    mexErrMsgTxt("Two inputs required.");
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments");
  }
  
  /* The input must be a noncomplex scalar double.*/
  xrows = mxGetM(prhs[0]);
  xcols = mxGetN(prhs[0]);
  yrows = mxGetM(prhs[1]);
  ycols = mxGetN(prhs[1]);
  if ((xrows != 1 && xcols != 1) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
      mexErrMsgTxt("Input X must be a vector of noncomplex doubles");
  }

  xlen = ( xrows > xcols ? xrows : xcols ); /* = max( xrows, xcols ) */
  
  if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
      mexErrMsgTxt("Input Y must be a matrix of noncomplex doubles");
  }

  /* x and y must be of equal length */
  if (xlen != yrows) {
      mexErrMsgTxt("Inputs X and Y must have equal lengths");
  }
  
  if (ycols != 2) {
      mexErrMsgTxt("Input Y must have 2 columns");
  }

  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  
  /* Assign pointers to each input and output. */
  x = mxGetPr(prhs[0]);
  y = mxGetPr(prhs[1]);
  mi = mxGetPr(plhs[0]);
  
  /* Call the timestwo subroutine. */
  mutual_info2(x,y,mi,xlen);
}

