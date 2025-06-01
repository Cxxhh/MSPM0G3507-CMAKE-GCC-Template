
#include "ti_msp_dl_config.h"
#include "board.h"
#include <stdint.h>

int main(void)
{
    SYSCFG_DL_init();
    volatile uint8_t flag = 0;
    while (1)
    {   
       if (flag == 1)
       {
        


       }
        DL_GPIO_togglePins(GPIO_LED_PORT, GPIO_LED_PIN_LED_PIN);
        delay_ms(1000);
        flag+=1;
    }
}

