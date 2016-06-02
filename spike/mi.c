/*
 * =============================================================
 * mi.c
 *
 * $Id$
 *
 * called as i=mi(X,Y) where:
 * X is a vector
 * Y is a matix 
 * =============================================================
 */
 
#include "mex.h"
#include "math.h"

void mutual_info2(double x[], double y[], double *mi, int L)
{
    int i,j,k;
    int n = 0;
    double max_x = 0;
    double max_1 = 0;
    double max_2 = 0;
    double min_1 = mxGetInf();
    double min_2 = mxGetInf();
    
    int Py[20][20];
    int Px[5];
    int Pxy[20][20][5];
    
    double px, py, pxy;
    
    for (i=0; i<L; i++) {
        n += x[i];
    }
    
    /* initialize Px, Py, and Pxy counts to zero */
    for (i=0; i<20; i++) {
        for (j=0; j<20; j++) {
            Py[i][j] = 0;
            for(k=0; k<5; k++) {
                Px[k] = 0;
                Pxy[i][j][k] = 0;
            }
        }
    }
    
    /* find max and min in each dimension of y */
    for (i=0; i<L; i++) {
        if (max_1 < y[i]) {
            max_1 = y[i];
        }
        if (max_2 < y[i+L]) {
            max_2 = y[i+L];
        }
        if (min_1 > y[i]) {
            min_1 = y[i];
        }
        if (min_2 > y[i+L]) {
            min_2 = y[i+L];
        }
        if (max_x < x[i]) {
            max_x = x[i];
        }
    }
    
    /* group into fifty bins */
    for (i=0; i<L; i++) {
        /* increment count for this number of spikes in bin */
        Px[ (int)x[i] ]++; 
        /* increment count for this 2D Y */
        Py[ (int)( 10*y[i]/(max_1-min_1) )   + 10 ]
          [ (int)( 10*y[i+L]/(max_2-min_2) ) + 10 ]++;
        /* increment count for this point in the joint distribution */
        Pxy[ (int)( 10*y[i]/(max_1-min_1) )   + 10 ]
           [ (int)( 10*y[i+L]/(max_2-min_2) ) + 10 ]
           [ (int)x[i] ]++;
    }
       
    /* now calculate mutual information */
    *mi = 0.0;

    for (i=0; i<20; i++) {
        for (j=0; j<20; j++) {
            for (k=0; k<5; k++) {
                px = (double)(Px[k]) / (double)L;
                py = (double)(Py[i][j]) / (double)L;
                pxy = (double)(Pxy[i][j][k]) / (double)L;
                
                if (pxy > 0) 
                    *mi += pxy * log2( pxy / (px * py) ); 
            }
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

