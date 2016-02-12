/*
 * =============================================================
 * train2bins.c
 *
 * $Id$
 *
 * called as [ d, t ] = train2bins( S, B ) where:
 * S is a vector
 * B is a vector (list of timestamps)
 *
 * or [ d, t ] = train2bins( S, b ) where:
 * S is a vector
 * b is a scalar (bin width)
 *
 * Give a time series of bins giving spike counts per bin for a given bin
 *   width w and spike train timesamps s.
 *
 *   Returns d: The number of spikes in each bin
 *
 *   Example:
 *    d = train2bins( [0.2 0.4 1.1 1.7], 0:0.5:2 );
 *
 *    Gives:
 *        d = [   2   0   1   1 ]
 *        t = [ 0.0 0.5 1.0 1.5 ]
 * =============================================================
 */
 
#include "mex.h"
#include "math.h"

#ifndef max
#define max(a,b) ( ((a)>(b)) ? (a) : (b) )
#endif

/*
 * s    spike times
 * b    list of bin timestamps
 * d    output of number of spikes per bin
 */
void bin(double *s, double *b, double *d, int ns, int nb)
{
    int s_count = 0;
    int b_count = 0;
    
    for (b_count = 0; b_count < nb; b_count++) {
        d[b_count] = 0.0;
        while (s[s_count] < b[b_count] && s_count < ns) {
            d[b_count] += 1.0;
            s_count++;
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *d, *s, *b;
  int srows, scols, brows, bcols;
  int slen, blen;
  
  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    mexErrMsgTxt("Two inputs required.");
  } else if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments");
  }
  
  /* s must be a noncomplex vector double */
  srows = mxGetM(prhs[0]);
  scols = mxGetN(prhs[0]);
  if ((srows != 1 && scols != 1) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
      mexErrMsgTxt("Input S must be a vector of noncomplex doubles");
  }

   /* b must be a noncomplex vector double.*/
  brows = mxGetM(prhs[1]);
  bcols = mxGetN(prhs[1]);
  if ((brows != 1 && bcols != 1) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
      mexErrMsgTxt("Input b must be a vector of noncomplex doubles");
  }

  slen = max(srows, scols);
  blen = max(brows, bcols);

  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1, blen, mxREAL);
  
  /* Assign pointers to each input and output. */
  s = mxGetPr(prhs[0]);
  b = mxGetPr(prhs[1]);
  d = mxGetPr(plhs[0]);
  
  /* Call the binning subroutine. */
  bin(s, b, d, slen, blen);

}
