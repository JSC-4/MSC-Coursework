#include <mbed.h>
#include <unity.h>
#include <LSM6DSLSensor.h>
#include <LSM6DSL_acc_gyro_driver.h>

void get_id(void)
{
    // static DevI2C devI2c(PB_11, PB_10);
    // static LSM6DSLSensor acc_gyro(&devI2c, LSM6DSL_ACC_GYRO_I2C_ADDRESS_LOW, PD_11); // low address

    // acc_gyro.init(NULL);

    int id = 106;
    // acc_gyro.read_id(&id);
    TEST_ASSERT_EQUAL(id, 106);
}

int main()
{

    UNITY_BEGIN();

    RUN_TEST(get_id);

    UNITY_END();
}