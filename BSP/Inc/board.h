#ifndef	__BOARD_H__
#define __BOARD_H__

#include "ti_msp_dl_config.h"
#include "string.h"
#include "math.h"

#define MOTOR_STOP    0
#define MOTOR_SPEED   1
#define MOTOR_DIR  		2
#define MOTOR_TRACK  	3
#define MOTOR_GYRO 	  4
void board_init(void);

void delay_us(unsigned long __us);
void delay_ms(unsigned long ms);
void delay_1us(unsigned long __us);
void delay_1ms(unsigned long ms);

void uart0_send_char(char ch);
void uart0_send_string(char* str);



#endif
