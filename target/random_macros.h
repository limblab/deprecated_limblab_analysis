/*  $Id: random_macros.h 845 2012-04-03 14:26:28Z brian $ */
#ifndef RANDOM_MACROS_H
#define RANDOM_MACROS_H

#define znew  (z=36969*(z&65535)+(z>>16))
#define wnew  (w=18000*(w&65535)+(w>>16))
#define MWC   ( (znew<<16)+wnew )
#define SHR3  (jsr=(jsr=(jsr=jsr^(jsr<<17))^(jsr>>13))^(jsr<<5))
#define CONG  (jcong=69069*jcong+1234567)
#define KISS  ((MWC^CONG)+SHR3)
#define UNI   (KISS*2.328306e-10)
#define VNI   (((long) KISS)*4.656613e-10)
typedef unsigned long UL;

/*  Global static variables: */
static UL z=362436069, w=521288629, jsr=123456789, jcong=380116160;

/* Any one of KISS, MWC, LFIB4, SWB, SHR3, or CONG  can be used in
   an expression to provide a random 32-bit integer, while UNI
   provides a real in (0,1) and VNI a real in (-1,1).   */
   
#endif /* RANDOM_MACROS_H */

