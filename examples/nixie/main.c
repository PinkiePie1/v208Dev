#include "debug.h"

/* Global define */

/* Global Variable */


void TIM_Init(void)
{
	//GPIO，定时器输出和定时器时基的初始化结构体
	GPIO_InitTypeDef GPIO_InitStructure={0};
	TIM_OCInitTypeDef TIM_OCInitStructure={0};
	TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure={0};

	RCC_APB2PeriphClockCmd( RCC_APB2Periph_GPIOA | RCC_APB2Periph_TIM1, ENABLE ); //开启GPIOA和TIM1的外设时钟
	RCC_APB1PeriphClockCmd( RCC_APB1Periph_TIM2 | RCC_APB1Periph_TIM3, ENABLE );//开启TIM2和3的外设时钟，他们挂在APB1上。

	//设置PA8为复用输出
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_8|GPIO_Pin_6|GPIO_Pin_0;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init( GPIOA, &GPIO_InitStructure );

	//时基设置，144Mhz，不分频，166khz，向上数数。
	TIM_TimeBaseInitStructure.TIM_Period = 864;
	TIM_TimeBaseInitStructure.TIM_Prescaler = 0;
	TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
	TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
	TIM_TimeBaseInit( TIM1, &TIM_TimeBaseInitStructure);

	TIM_TimeBaseInit( TIM2, &TIM_TimeBaseInitStructure);
	TIM_TimeBaseInit( TIM3, &TIM_TimeBaseInitStructure);

	//输出设置，PWM模式2，50%占空比，高有效，只开CH1
	//注意要开对应的channel就要调用OCxInit。
	TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM2;
	TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;	
	TIM_OCInitStructure.TIM_Pulse = 864/2;
	TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
	TIM_OC1Init( TIM1, &TIM_OCInitStructure );

	TIM_OC1Init( TIM2, &TIM_OCInitStructure );//TIM2CH1,PA0
	TIM_OC1Init( TIM3, &TIM_OCInitStructure );//TIM3CH1,PA6

	
	TIM_CtrlPWMOutputs(TIM1, ENABLE );
	TIM_OC1PreloadConfig( TIM1, TIM_OCPreload_Disable );
	TIM_ARRPreloadConfig( TIM1, ENABLE );
	TIM_CtrlPWMOutputs(TIM2, ENABLE );
	TIM_OC1PreloadConfig( TIM2, TIM_OCPreload_Disable );
	TIM_ARRPreloadConfig( TIM2, ENABLE );
	TIM_CtrlPWMOutputs(TIM3, ENABLE );
	TIM_OC1PreloadConfig( TIM3, TIM_OCPreload_Disable );
	TIM_ARRPreloadConfig( TIM3, ENABLE );
	TIM_Cmd( TIM1, ENABLE );
	TIM_Cmd( TIM2, ENABLE );
	TIM_Cmd( TIM3, ENABLE );
	
}

/*********************************************************************
 * @fn      main
 *
 * @brief   Main program.
 *
 * @return  none
 */
int main(void)
{
	Delay_Init();
	TIM_Init();

	uint16_t duty = 0;
    while( 1 )
    {	
    	duty = duty>=(864>>1) ? 0 : duty;
    	duty+=5;
        Delay_Ms(10);
        TIM1->CH1CVR = duty<<1;
        TIM2->CH1CVR = duty<<1;
        TIM3->CH1CVR = duty<<1;
    }

}
