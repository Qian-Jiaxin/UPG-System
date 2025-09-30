#include "UserFSMC.h"

extern SRAM_HandleTypeDef hsram1;

int User_InitModule(void)
{
    uint8_t pBuffer[4] = {0x00, 0x00, 0x00, 0x00};

    // HAL_GPIO_WritePin(FPGA_NRST_GPIO_Port, FPGA_NRST_Pin, GPIO_PIN_RESET);
    // HAL_Delay(10);
    HAL_GPIO_WritePin(FPGA_NRST_GPIO_Port, FPGA_NRST_Pin, GPIO_PIN_SET);
		
    if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
    {
        return FSMC_STATUS_WRITE_ERROR;
    }
    else
    {
        return FSMC_STATUS_OK;
    }

}

int User_EnableModule(uint8_t ModuleID)
{
    union EnBit_U
    {
        uint32_t Enbit;
        uint8_t pBuffer[4];
    } enbit_u;
		
    if(ModuleID >= 28)
    {
        return FSMC_STATUS_ADDRESS_ERROR;
    }
    else
    {
        if (HAL_SRAM_Read_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enbit_u.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
        {
            return FSMC_STATUS_READ_ERROR;
        }
        else
        {
            enbit_u.Enbit |= (0x01 << ModuleID);

            if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enbit_u.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
            {
                return FSMC_STATUS_WRITE_ERROR;
            }
            else
            {
                return FSMC_STATUS_OK;
            }
        }
    }
}

int User_DisableModule(uint8_t ModuleID)
{
    union EnBit_U
    {
        uint32_t Enbit;
        uint8_t pBuffer[4];
    } enbit_u;

    if(ModuleID >= 28)
    {
        return FSMC_STATUS_ADDRESS_ERROR;
    }
    else
    {
        if (HAL_SRAM_Read_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enbit_u.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
        {
            return FSMC_STATUS_READ_ERROR;
        }
        else
        {
            enbit_u.Enbit &= ~(0x01 << ModuleID);

            if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enbit_u.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
            {
                return FSMC_STATUS_WRITE_ERROR;
            }
            else
            {
                return FSMC_STATUS_OK;
            }
        }
    }
}

int User_DisableAllModule(void)
{
    uint8_t pBuffer[4] = {0x00, 0x00, 0x00, 0x00};

    if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
    {
        return FSMC_STATUS_WRITE_ERROR;
    }
    else
    {
        return FSMC_STATUS_OK;
    }
}

int User_CheckModuleStatus(uint8_t ModuleID, uint8_t* pStatus)
{
    union EnableBit
    {
        uint32_t Enbit;
        uint8_t pBuffer[4];
    } enablebit;

    if(ModuleID >= 28)
    {
        return FSMC_STATUS_ADDRESS_ERROR;
    }
    else
    {
        if (HAL_SRAM_Read_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enablebit.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
        {
            return FSMC_STATUS_READ_ERROR;
        }
        else
        {
            *pStatus = (enablebit.Enbit >> ModuleID) & 0x01;
            return FSMC_STATUS_OK;
        }
    }
}

int User_SetModuleBeat(uint8_t ModuleID, uint8_t* pBeatDelay)
{
    if(ModuleID >= 28)
    {
        return FSMC_STATUS_ADDRESS_ERROR;
    }
    else
    {
        if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)(BEATCONTROLLER_ADDRESS + ModuleID), pBeatDelay, 0x01) != HAL_OK)
        {
            return FSMC_STATUS_WRITE_ERROR;
        }
        else
        {
            return FSMC_STATUS_OK;
        }
    }
}

int User_SetAllModuleBeat(uint8_t* pBeatDelay)
{
    if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)BEATCONTROLLER_ADDRESS, pBeatDelay, BEATCONTROLLER_SIZE) != HAL_OK)
    {
        return FSMC_STATUS_WRITE_ERROR;
    }
    else
    {
        return FSMC_STATUS_OK;
    }
}

int User_SetPulseWidth(uint32_t PulseWidth)
{
    uint8_t pPulseWidth[PULSEWIDTH_SIZE] = {0};

    pPulseWidth[0] = (uint8_t)(PulseWidth & 0x000000FF);
    pPulseWidth[1] = (uint8_t)((PulseWidth >> 8) & 0x000000FF);
    pPulseWidth[2] = (uint8_t)((PulseWidth >> 16) & 0x000000FF);
    pPulseWidth[3] = (uint8_t)((PulseWidth >> 24) & 0x000000FF);

    if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)PULSEWIDTH_ADDRESS, pPulseWidth, PULSEWIDTH_SIZE) != HAL_OK)
    {
        return FSMC_STATUS_WRITE_ERROR;
    }
    else
    {
        return FSMC_STATUS_OK;
    }
}

void User_FSMC_Test(void) {
    uint32_t base_address = 0x60000000;
    uint8_t write_data = 0xAA;  // 起始写入数据
    uint8_t read_data;
    uint32_t test_size = 128;
    uint32_t error_count = 0;

    // 连续写入并立即读取验证
    for (uint32_t i = 0; i < test_size; i++) {
        uint32_t target_addr = base_address + i;
        HAL_SRAM_Write_8b(&hsram1, (uint32_t*)target_addr, &write_data, 1);
        HAL_SRAM_Read_8b(&hsram1, (uint32_t*)target_addr, &read_data, 1);

        if (read_data != write_data) {
            error_count++;
            // 可以在这里打印错误信息，或者记录错误地址和值
        }

        write_data++;  // 每次写入数据递增
    }

    // 整体读取验证
    write_data = 0xAA;  // 重置为起始写入数据
    for (uint32_t i = 0; i < test_size; i++) {
        uint32_t target_addr = base_address + i;
        HAL_SRAM_Read_8b(&hsram1, (uint32_t*)target_addr, &read_data, 1);

        if (read_data != write_data) {
            error_count++;
            // 可以在这里打印错误信息，或者记录错误地址和值
        }

        write_data++;
    }

}