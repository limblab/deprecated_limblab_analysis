/*
 * targets.h
 *
 * Contains macros and definitions for target types
 */


#ifndef TARGETS_H
#define TARGETS_H 1

/* target type definitions */
#define NullTargetType 0
#define RedTargetType 1
#define BlueTargetType 7
#define WhiteTargetType 2
#define GreenTargetType 3
#define PurpleTargetType 9
#define CircleTargetType 10
#define SquareTargetType 11

#define TARGET_RGB(r, g, b) ((real_T)( (r)*256*256 + (g)*256 + (b) ))

/* standard color definitions */
#define COLOR_RED TARGET_RGB(255,0,0)
#define COLOR_BLUE TARGET_RGB(0,0,255)
#define COLOR_GREEN TARGET_RGB(0,255,0)
#define COLOR_WHITE TARGET_RGB(255,255,255)

/* target display functions */
void drawRectTarget(real_T *output, int index, real_T *location, int type);
void drawSquareTarget(real_T *output, int index, real_T *location, real_T target_color);
void drawCircleTarget(real_T *output, int index, real_T *location, real_T target_color);

#endif /* TARGETS_H */
