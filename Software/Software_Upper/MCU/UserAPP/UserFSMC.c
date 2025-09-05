#include "UserFSMC.h"

extern SRAM_HandleTypeDef hsram1;

int User_InitModule(void)
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

int User_EnableModule(uint8_t ModuleID)
{
    union EnableBit
    {
        uint32_t enable_bit;
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
            enablebit.enable_bit |= (0x01 << ModuleID);

            if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enablebit.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
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
    union EnableBit
    {
        uint32_t enable_bit;
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
            enablebit.enable_bit &= ~(0x01 << ModuleID);

            if (HAL_SRAM_Write_8b(&hsram1, (uint32_t *)ENABLECONTROLLER_ADDRESS, enablebit.pBuffer, ENABLECONTROLLER_SIZE) != HAL_OK)
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
        uint32_t enable_bit;
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
            *pStatus = (enablebit.enable_bit >> ModuleID) & 0x01;
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
