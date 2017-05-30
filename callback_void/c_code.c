//
//  c_code.c
//  callback_void
//
//  Created by Anatoli on 11/5/2015.
//  Updated for Swift 3 on 11/14/2016.
//  Copyright © 2015 Anatoli Peredera. All rights reserved.
//

/**
 * This is the implementation of our simple sample API.  In real life it 
 * would not include the bridging header and be in a library.  We would not
 * even have access to this source code.  However, our bridging header
 * would include C headers that come with the library.
 */
// If his pragma is here and not available to Swift via the bridging header,
// the data will not be passed back and forth at all.  That's unless we use
// pragma pack(8) here.
//#pragma pack(2)

#include <stdio.h>
#include "bridging.h"

/**
 * Creates an instance of APIStruct.  
 *
 * This function is not visible to Swift because it is not in the bridging
 * header.
 */
APIStruct createStruct()
{
    APIStruct retVal;
    retVal.m_Int = 123;
    retVal.m_Long = 4567890123;
    retVal.m_Array[0] = 123;
    retVal.m_Array[1] = 456;
    retVal.m_Array[2] = 789;
    
    return retVal;
}

/**
 * Dump an APIStruct.
 */
void printStructInC( APIStruct * x )
{
    puts( "Printing structure in C" );
    printf( "  m_Int = %d\n", x->m_Int );
    printf( "  m_Long = %lld\n", x->m_Long );
    printf( "  m_Array = %d %d %d\n", x->m_Array[0], x->m_Array[1], x->m_Array[2] );
}

/**
 * Uses the callback provided as an argument.  Creates an APIStruct, prints it out,
 * invokes the callback giving it the APIStruct, and, if checkOnReturn != 0, prints
 * the structure again to see if it has been modified by the callback.
 */
int CUseCallback( my_cb_t cb, int checkOnReturn )
{
    APIStruct x = createStruct();
    puts( "Entered C code, printing newly created structure:");
    printStructInC( &x );
    cb( &x );
    if (checkOnReturn)
    {
        puts( "Now we are back in C code, see if the callback changed the structure...");
        printStructInC( &x );
    }
    return 0;
}
