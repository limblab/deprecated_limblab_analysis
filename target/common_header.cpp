/**
 * common_headder.cpp
 * Contains the includes required to build a subclass of Behavior
 * 
 * $Id: $
 */

#include <math.h>
#include <stdlib.h>
#include "simstruc.h"

/*
 * common state definitions
 */
#define STATE_REWARD 82
#define STATE_ABORT 65
#define STATE_FAIL 70
#define STATE_INCOMPLETE 74
#define STATE_DATA_BLOCK 255

/*
 * define "byte"
 */
typedef unsigned char byte;

/*
 * include library functions
 */

#define __COMMON_HEADER_CPP 1

#include "lib_cpp/Helpers.cpp"
#include "lib_cpp/Timer.cpp"
#include "lib_cpp/DataBurst.cpp"
#include "lib_cpp/Targets.cpp"
#include "lib_cpp/Bumps.cpp"
#include "lib_cpp/Staircase.cpp"
#include "lib_cpp/Behavior.cpp"
#include "lib_cpp/RobotBehavior.cpp"

#undef __COMMON_HEADER_CPP

