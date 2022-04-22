/***************************************************************************************
* File name: main.cpp
*
* Author: Jerome Samuels-Clarke
* SID   : 10473050
* Date: Edited March 2022
*
* Description: A program that uses a SSD1306 display, to show the date, time, steps,
               temperature and humidity. The MBed os rtos is used to show the data on
               the display. The date/time can be set manually if it is incorrect.
***************************************************************************************/
/* Include the header files for the mbed functions and sensors used*/
#include <mbed.h>
#include "ds3231.h"
#include <LSM6DSLSensor.h>
#include <LSM6DSL_acc_gyro_driver.h>
#include "HTS221Sensor.h"
#include "Adafruit_SSD1306.h"
/***************************************************************************************/

/* Definitions used to turn the SSD306 display on or off */
#define SSD1306_DISPLAYOFF 0xAE
#define SSD1306_DISPLAYON 0xAF

/* Declare threads to collect readings and to display them on the SSD1306 */
Thread displayThread(osPriorityNormal);
Thread stepThread(osPriorityAboveNormal);
Thread hum_tempThread(osPriorityAboveNormal);
Thread ds3231Thread(osPriorityRealtime);

// an I2C sub-class that provides a constructed default (taken from the example code)
class I2CPreInit : public I2C
{
public:
  I2CPreInit(PinName sda, PinName scl) : I2C(sda, scl)
  {
    frequency(400000);
    start();
  };
};

/* Create an I2C object for the SSD1306, connected to I2C1*/
I2CPreInit oI2C(PB_9, PB_8);
Adafruit_SSD1306_I2c oled(oI2C, PC_7);

/* Create an I2C object for the DS3231, connected to I2C1*/
static DS3231 ds3231(PB_9, PB_8, 0xD0);

/* Create objects for the I2C sensors, connected to I2C2 internally */
static DevI2C devI2c(PB_11, PB_10);
static LSM6DSLSensor acc_gyro(&devI2c, LSM6DSL_ACC_GYRO_I2C_ADDRESS_LOW, PD_11); // low address
static HTS221Sensor hum_temp(&devI2c);

/* Variables used to store readings from sensors */
char timeBuffer[3];
char dateBuffer[4];
uint16_t stepCounter = 0;
int32_t axes[3];
float temperature, humidity;

/* Used for the printf statements in the Adafruit_SSD1306_I2c class */
static BufferedSerial serial_port(USBTX, USBRX, 9600);

/***************************************************************************************/

/* Thread used to update the display. Priotity level is the lowest and will run when
   other threads are sleeping. */
void update_display()
{
  while (1)
  {
    oled.setTextCursor(40, 12);
    oled.printf("%02d:%02d:%02d\r", timeBuffer[2], timeBuffer[1], timeBuffer[0]);

    oled.setTextCursor(74, 0);
    oled.printf("%s %02d/%02d\r", ds3231.dayNames[dateBuffer[0] - 1], dateBuffer[1], dateBuffer[2]);

    oled.setTextCursor(25, 23);
    oled.printf("%d | %dC | %d%%", stepCounter, (int)temperature, (int)humidity);

    oled.display();
  }
}

/* This thread gets current value in the stepCounter register, as well as reads the
    position of the y-axis to determine if the display should be on or off. */
void get_step_val()
{
  while (1)
  {
    /* get the current step value*/
    acc_gyro.get_step_counter(&stepCounter);

    /* read the accelerometer to determine if the value y-axis is above or below the
       thresholds. If the limits are exceeded, turn the display off, otherwise keep the
       display on. */
    acc_gyro.get_x_axes(axes);
    if (axes[1] < -800 || axes[1] > 800)
    {
      oled.command(SSD1306_DISPLAYOFF);
    }

    else
    {
      oled.command(SSD1306_DISPLAYON);
    }
    /* Reduce how frequent the thread needs to run */
    thread_sleep_for(100);
  }
}

/* This thread reads the temperature and humidity sensor. The thread goes
   to sleep every 200ms, as the readings are not needed frequently. */
void get_hum_temp()
{
  while (1)
  {
    hum_temp.get_temperature(&temperature);
    hum_temp.get_humidity(&humidity);

    thread_sleep_for(200);
  }
}

/* This thread reads the current date and time from the DS3231 sensor. It will
   go to sleep every second, to allow other threads to run and has the highest 
  pritory. */
void read_ds3231()
{
  while (1)
  {
    ds3231.getTime(timeBuffer);
    ds3231.getDate(dateBuffer);
    thread_sleep_for(1000);
  }
}
/***************************************************************************************/

int main()
{

  /* Uncomment the following lines, to set the date and time */
  // ds3231.setDate(1, 21, 3, 22);
  // ds3231.setTime(8, 26, 40);

  /* Initialise the acceleromter/gyroscope and the humitidity/temperature sensor */
  acc_gyro.init(NULL);
  hum_temp.init(NULL);

  /* Enable the accelerometer pedometer and humidity/temperature sensors*/
  acc_gyro.enable_x();
  acc_gyro.enable_pedometer();
  hum_temp.enable();

  /* Reset the step counter and set a threshold, that will trigger the readings */
  acc_gyro.reset_step_counter();
  acc_gyro.set_pedometer_threshold(10);

  /* Start each of the threads */
  displayThread.start(update_display);
  stepThread.start(get_step_val);
  ds3231Thread.start(read_ds3231);
  hum_tempThread.start(get_hum_temp);

  while (1)
  {
  }

  return 0;
}
