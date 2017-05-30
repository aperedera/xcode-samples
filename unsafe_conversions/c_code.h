//
//  c_code.h
//  unsafe_conversions
//
//  Created by Anatoli on 10/29/15.
//  Copyright © 2015 Anatoli. All rights reserved.
//
#pragma pack(2)

#ifndef c_code_h
#define c_code_h

#include <stdio.h>

/**
 * This is the C struct being imported.
 */
typedef struct
{
    uint16_t        myInt16;
    uint64_t        myTime;
    uint32_t        myInt32;
} APIStruct;

/** Typedefs & prototypes, self-explanatory.  See c_code.c. */
typedef void(*my_cb_t)(APIStruct *);
void invokeCallBack( my_cb_t );

typedef void(*my_cbv_t)(void *);
void invokeCallBackVoid( my_cbv_t );

#endif /* c_code_h */
