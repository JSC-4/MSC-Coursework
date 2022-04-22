/***************************************************************************************
 * File name: ds3231.cpp
 *
 * Author: Jerome Samuels-Clarke
 * SID   : 10473050
 * Date: Edited March 2022
 *
 * Description: CPP file for the DS3231
 ***************************************************************************************/
/* Include the header file for the DS3231 */
#include "ds3231.h"

/* Reading from the DS3231 is in binary coded decimal (bcd) format. This function 
   will convert the bcd into decimal (int).  */
void bcd2dec(char &b)
{
    b = ((b / 16) * 10 + (b % 16));
}

/* Writing to the DS3231 needs to be in binary coded decimal (bcd) format. This function 
   will convert the decimal (char) values into bcd form.  */
int dec2bcd(char d)
{
    return (((d / 10) << 4) | (d % 10));
}

/* Constructor for the DS3231 class, used to set the I2C and sensor address */
DS3231::DS3231(PinName sda, PinName scl, int sensorAddr) : rtcI2C(sda, scl),
                                                           sensorAddr(sensorAddr)
{
}

/* Method to set the time for the DS3231 */
int DS3231::setTime(int hh, int mm, int ss)
{
    char buf[2];

    buf[0] = DS3231_SECONDS;
    buf[1] = dec2bcd(ss);
    rtcI2C.write(sensorAddr, buf, 2);

    buf[0] = DS3231_MINUTES;
    buf[1] = dec2bcd(mm);
    rtcI2C.write(sensorAddr, buf, 2);

    buf[0] = DS3231_HOURS;
    buf[1] = dec2bcd(hh);
    rtcI2C.write(sensorAddr, buf, 2);

    return SUCCESS;
}

/* Method to set the date for the DS3231 */
int DS3231::setDate(int dow, int dd, int mm, int yy)
{
    char buf[2];

    buf[0] = DS3231_DAY;
    buf[1] = dec2bcd(dow);
    rtcI2C.write(sensorAddr, buf, 2);

    buf[0] = DS3231_DATE;
    buf[1] = dec2bcd(dd);
    rtcI2C.write(sensorAddr, buf, 2);

    buf[0] = DS3231_MONTH;
    buf[1] = dec2bcd(mm);
    rtcI2C.write(sensorAddr, buf, 2);

    buf[0] = DS3231_YEAR;
    buf[1] = dec2bcd(yy);
    rtcI2C.write(sensorAddr, buf, 2);

    return SUCCESS;
}

/* Method to get the time from the DS3231. The three registers are one after the 
   other, so an repeat I2C read can be done. */
int DS3231::getTime(char *data)
{
    char cmd[1];
    cmd[0] = DS3231_SECONDS;
    rtcI2C.write(sensorAddr, cmd, 1);
    rtcI2C.read(sensorAddr, data, 3);

    for (int i = 0; i < 3; i++)
    {
        bcd2dec(data[i]);
    }

    return SUCCESS;
}

/* Method to get the date from the DS3231. The four registers are one after the 
   other, so an repeat I2C read can be done. */
int DS3231::getDate(char *data)
{
    char cmd[1];
    cmd[0] = DS3231_DAY;
    rtcI2C.write(sensorAddr, cmd, 1);
    rtcI2C.read(sensorAddr, data, 4);

    for (int i = 0; i < 4; i++)
    {
        bcd2dec(data[i]);
    }

    return SUCCESS;
}