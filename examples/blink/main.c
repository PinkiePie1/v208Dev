#include "debug.h"

/* Global define */

/* Global Variable */


/*********************************************************************
 * @fn      main
 *
 * @brief   Main program.
 *
 * @return  none
 */
int main(void)
{
    RCC->APB2PCENR |= RCC_APB2Periph_GPIOA;
	GPIOA->CFGLR &= 0xFFF0;
	GPIOA->CFGLR |= 0x0007;


    while( 1 )
    {
        FirmwareDelay(0x00FF);
        GPIOA->BSHR = GPIO_Pin_0;
        FirmwareDelay(0x00FF);
        GPIOA->BCR = GPIO_Pin_0;
    }

}
