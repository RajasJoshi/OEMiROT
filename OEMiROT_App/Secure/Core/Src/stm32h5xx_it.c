/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    stm32h5xx_it.c
  * @author  MCD Application Team
  * @brief   Secure Interrupt Service Routines.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2023 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "stm32h5xx_it.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN TD */

/* USER CODE END TD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
extern funcptr_NS pSecureFaultCallback;
extern funcptr_NS pSecureErrorCallback;
/* USER CODE END 0 */


/******************************************************************************/
/*           Cortex Processor Interruption and Exception Handlers             */
/******************************************************************************/

/**
  * @brief This function handles Hard fault interrupt.
  */
void HardFault_Handler(void)
{
  /* USER CODE BEGIN HardFault_IRQn 0 */
  /* Reset for Test, Non Secure Fault Memory Fault are escaladed in Secure HW fault  */
  /* Since Non Secure Memory Fault Interrupt is not activated */
  NVIC_SystemReset();
  /* USER CODE END HardFault_IRQn 0 */
}

/**
  * @brief This function handles Memory management fault.
  */
void MemManage_Handler(void)
{
  /* USER CODE BEGIN MemoryManagement_IRQn 0 */
  while (1)
  {

  }
  /* USER CODE END MemoryManagement_IRQn 0 */
}

/**
  * @brief This function handles Prefetch fault, memory access fault.
  */
void BusFault_Handler(void)
{
  /* USER CODE BEGIN BusFault_IRQn 0 */
  while (1)
  {

  }
  /* USER CODE END BusFault_IRQn 0 */
}

/**
  * @brief This function handles Undefined instruction or illegal state.
  */
void UsageFault_Handler(void)
{
  /* USER CODE BEGIN UsageFault_IRQn 0 */
  while (1)
  {

  }
  /* USER CODE END UsageFault_IRQn 0 */
}

/**
  * @brief This function handles Secure fault.
  */
void SecureFault_Handler(void)
{
  /* USER CODE BEGIN SecureFault_IRQn 0 */
  funcptr_NS callback_NS; /* non-secure callback function pointer */

  if (pSecureFaultCallback != (funcptr_NS)NULL)
  {
    /* return function pointer with cleared LSB */
    callback_NS = (funcptr_NS)cmse_nsfptr_create(pSecureFaultCallback);

    callback_NS();
  }
  else
  {

    while (1)
    {

    }

  }
  /* USER CODE END SecureFault_IRQn 0 */
}

/**
  * @brief This function handles System service call via SWI instruction.
  */
void SVC_Handler(void)
{
  /* USER CODE BEGIN SVCall_IRQn 0 */

  /* USER CODE END SVCall_IRQn 0 */
}

/**
  * @brief This function handles Debug monitor.
  */
void DebugMon_Handler(void)
{
  /* USER CODE BEGIN DebugMonitor_IRQn 0 */
  while (1)
  {
  }
  /* USER CODE END DebugMonitor_IRQn 0 */
}

/**
  * @brief This function handles Pendable request for system service.
  */
void PendSV_Handler(void)
{
  /* USER CODE BEGIN PendSV_IRQn 0 */
  while (1)
  {
  }
  /* USER CODE END PendSV_IRQn 0 */
}

/**
  * @brief This function handles System tick timer.
  */
void SysTick_Handler(void)
{
  /* USER CODE BEGIN SysTick_IRQn 0 */
  HAL_IncTick();

  HAL_SYSTICK_Callback();
  /* USER CODE END SysTick_IRQn 0 */
}

/******************************************************************************/
/* STM32H5xx Peripheral Interrupt Handlers                                    */
/* Add here the Interrupt Handlers for the used peripherals.                  */
/* For the available peripheral interrupt handler names,                      */
/* please refer to the startup file (startup_stm32h5xx.c).                    */
/******************************************************************************/

/**
  * @brief This function handles Global TrustZone controller global interrupt.
  */
void GTZC_IRQHandler(void)
{
  /* USER CODE BEGIN GTZC_IRQn 0 */
  funcptr_NS callback_NS; /* non-secure callback function pointer */

  HAL_GTZC_IRQHandler();

  if (pSecureErrorCallback != (funcptr_NS)NULL)
  {
    /* return function pointer with cleared LSB */
    callback_NS = (funcptr_NS)cmse_nsfptr_create(pSecureErrorCallback);

    callback_NS();
  }
  else
  {
    /* Something went wrong in test case */
    while (1);
  }
  /* USER CODE END GTZC_IRQn 0 */
}
