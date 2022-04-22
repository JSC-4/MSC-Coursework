/***************************************************************************************
* File name: ds3231.h
*
* Author: Jerome Samuels-Clarke
* SID   : 10473050
* Date: Edited March 2022
*
* Description: A class created for controlling the DS3231 rtc module. The date and time 
               can be set and retrived using the public methods.
***************************************************************************************/
/* Include the header files for the mbed functions and sensors used*/
#include <mbed.h>

/* The DS3231 registers, taken from the datasheet */
#define DS3231_SECONDS  0x00
#define DS3231_MINUTES  0x01
#define DS3231_HOURS    0x02
#define DS3231_DAY      0x03
#define DS3231_DATE     0x04
#define DS3231_MONTH    0x05
#define DS3231_YEAR     0x06

/* Create a class for the DS3231 rtc module */
class DS3231
{
private:
    /* Object composition for the I2C class */
    I2C rtcI2C;

    /* private attribute to hold sensor address */
    char sensorAddr;

public:
    /* Constructor used when an object is created */
    DS3231(PinName sda, PinName scl, int sensorAddr);

    /* constant array used for converting the day of the week into a string */
    const char *dayNames[7] = {"MON", "TUE", "WED", "THR", "FRI", "SAT", "SUN"};

    /* Methods used to set/get the time and date */
    int setTime(int hh, int mm, int ss);
    int setDate(int dow, int dd, int mm, int yy);
    int getTime(char *data);
    int getDate(char *data);
};
