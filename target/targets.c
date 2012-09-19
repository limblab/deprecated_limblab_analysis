/*
 * targets.c
 */

#include "simstruc.h"
#include "targets.h"

void drawRectTarget(real_T *output, int index, real_T *location, int type) {
	output[0 + index*5] = (real_T)type;
	output[1 + index*5] = location[0];
	output[2 + index*5] = location[1];
	output[3 + index*5] = location[2];
	output[4 + index*5] = location[3];
}

void drawSquareTarget(real_T *output, int index, real_T *location, real_T target_color) {
	output[0 + index*5] = SquareTargetType;
	output[1 + index*5] = location[0];
	output[2 + index*5] = location[1];
	output[3 + index*5] = location[2];
	output[4 + index*5] = target_color;
}

void drawCircleTarget(real_T *output, int index, real_T *location, real_T target_color) {
	output[0 + index*5] = CircleTargetType;
	output[1 + index*5] = location[0];
	output[2 + index*5] = location[1];
	output[3 + index*5] = location[2];
	output[4 + index*5] = target_color;
}


