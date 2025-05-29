
#include "sys.h"
#include "ti_msp_dl_config.h"

int flag = 0;
int main(void)
{
    SYSCFG_DL_init();
    
    while (1)
    {   
        flag++;
        DL_GPIO_togglePins(GPIO_LED_PORT, GPIO_LED_PIN_LED_PIN);
        delay_ms(1000);
    }
}
