//
//  bridging.h
//  callback_void
//
//  Created by Anatoli on 11/5/2015.
//  Updated for Swift 3 on 11/14/2016.
//  Copyright © 2015 Anatoli Peredera. All rights reserved.
//

/**
 * Bridging header.  C stuff found here is imported by Swift.
 *
 * If you want to use it in your Xcode project, either place this code
 * in the Xcode-generated bridging header, or set this file as the
 * bridging header in Build Settings.
 */
#ifndef bridging_h
#define bridging_h

// This is to ensure memory layout mismatch
// This pragma needs to be visible to Swift via the bridging header.  
#pragma pack(1)  // pack(2) & pack(4) would have the same effect
                 // NaiveCallback() works with no pragma or with pack(8)
#include <stdlib.h>

/**
 * This is the structure used by our sample C "API."
 */
typedef struct
{
    int32_t m_Int;
    int64_t m_Long;
    int16_t m_Array[3];
} APIStruct;

/**
 * Function pointer type for the callback.  Callback receives a void 
 * pointer, which is then treated as APIStruct * in the callback.
 *
 * The callback will be implemented in Swift.
 */
typedef void (*my_cb_t)( void * );

/**
 * Our C API function that uses the callback.  In our example the 
 * callback is in Swift.
 */
int CUseCallback( my_cb_t, int );

#endif /* bridging_h */
