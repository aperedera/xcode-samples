//
//  c_code.c
//  unsafe_conversions
//
//  Created by Anatoli on 10/29/15.
//  Copyright © 2015 Anatoli. All rights reserved.
//

#include "c_code.h"
#include <time.h>

/**
 * Create an APIStruct to give to a callback
 */
APIStruct getAPIStruct()
{
    APIStruct retVal;
    retVal.myInt16 = 1234;
    retVal.myTime = time(0);
    retVal.myInt32 = 4321;
    
    return retVal;
}

/**
 * Helper to dump APIStruct.
 */
void printStructC( APIStruct * p )
{
    puts( "Here is the struct in C:" );
    printf( "  myInt16: %d\n", p->myInt16 );
    printf( "  myTime: %lld\n", p->myTime );
    printf( "  myInt32: %d\n", p->myInt32 );
}

/**
 * Invoke a callback that takes APIStruct *
 */
void invokeCallBack( my_cb_t cb )
{
    APIStruct x = getAPIStruct();
    printf( "Here is the C struct before APIStruct * callback: \n");
    printStructC(&x);
    cb( &x );
    printStructC( &x );
}

/**
 * Invoke a callback that takes an APIStruct via void *
 */
void invokeCallBackVoid( my_cbv_t cb )
{
    APIStruct x = getAPIStruct();
    printf( "Here is the C struct before void * callback: \n");
    printStructC( &x );
    cb( &x );
    printStructC( &x );
}
