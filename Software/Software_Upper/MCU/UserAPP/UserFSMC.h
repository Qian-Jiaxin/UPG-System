#ifndef __USER_FSMC_H
#define __USER_FSMC_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include <stdio.h>

#define ENABLECONTROLLER_SIZE               0x04 // 4 Enable_byte ([0:27]] enable_bit + [28:31]] reserved_bit) 
#define BEATCONTROLLER_SIZE                 0x1C // 28 Beat_byte
#define PULSEWIDTH_SIZE                     0x04 // 4 PulseWidth_byte

#define FSMC_ADDRESS                        ((uint32_t)0x60000000)

#define ENABLECONTROLLER_ADDRESS             FSMC_ADDRESS + 0x00
// #define ENABLECONTROLLER_ADDRESS            0x00
#define BEATCONTROLLER_ADDRESS              ENABLECONTROLLER_ADDRESS + ENABLECONTROLLER_SIZE
#define PULSEWIDTH_ADDRESS                  BEATCONTROLLER_ADDRESS + BEATCONTROLLER_SIZE

#define  FSMC_STATUS_ADDRESS_ERROR          ((int32_t)-3)
#define  FSMC_STATUS_READ_ERROR             ((int32_t)-2)
#define  FSMC_STATUS_WRITE_ERROR            ((int32_t)-1)
#define  FSMC_STATUS_OK                     ((int32_t) 0)

int User_InitModule(void);
int User_EnableModule(uint8_t ModuleID);
int User_DisableModule(uint8_t ModuleID);
int User_DisableAllModule(void);
int User_CheckModuleStatus(uint8_t ModuleID, uint8_t* pStatus);
int User_SetModuleBeat(uint8_t ModuleID, uint8_t* pBeatDelay);
int User_SetAllModuleBeat(uint8_t* pBeatDelay);
int User_SetPulseWidth(uint32_t PulseWidth);

void User_FSMC_Test(void);

#ifdef __cplusplus
}
#endif

#endif /* __USER_FSMC_H */