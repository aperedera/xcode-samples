//
//  main.swift
//  callback_void
//
//  Created by Anatoli on 11/5/2015.
//  Updated for Swift 3 on 11/14/2016.
//  Copyright © 2015 Anatoli Peredera. All rights reserved.
//

/**
 * This example demonstrates how to use, in Swift, a C API that takes a void
 * pointer.  How we write Swift code depends on whether we want to modify the
 * data pointed to by void* in such a way that the changes are visible in C
 * code. Data packing used by C code is also important.
 *
 * This is our Swift code that implements a callback required by a C
 * API and invokes a C function, CUseCallback(), to use the callback.
 */

/**
 * This is a naive native Swift structure that tries to mimic APIStruct
 * from the C API.  Depending on structure packing in C code, this may or
 * may not work.
 */
struct NaiveStruct
{
    var m_Int : Int32
    var m_Long : Int64
    var m_Array : (Int16, Int16, Int16)
}

/**
 * Prints an instance of NaiveStruct.
 */
func printNaive( _ s : NaiveStruct )
{
    print( "Printing NaiveStruct: " )
    print( "  m_Int: \(s.m_Int)" )
    print( "  m_Long: \(s.m_Long)" )
    print( "  m_Array: \(s.m_Array.0) \(s.m_Array.1) \(s.m_Array.2) " )
}

/**
 * This is a naive implementation of the callback.  Uses unsafeBitCast() to
 * convert the void *, provided via an argument of type UnsafeMutableRawPointer, 
 * to UnsafeMutablePointer<NativeStruct>, takes its memory and naively
 * creates an instance of NaiveStruct from it.
 *
 * This may or may not work depending on how APIStruct is packed in C
 * code.  E.g., if #pragma pack(2) is used in C code, the content of
 * NaiveStruct won't match that of the APIStruct provided by C
 * code via the void *.
 */
let NaiveCallback : my_cb_t = {( p : UnsafeMutableRawPointer? )->Void in
    print( "In NaiveCallback(), received a void pointer. " )
    if (p != nil)
    {
        // Could have used assumingMemoryBound() here.
        var _ns = unsafeBitCast(p, to: UnsafeMutablePointer<NaiveStruct>.self).pointee
        printNaive( _ns );
    }
    else { print("Naive struct ptr is nil.") }
}

/**
 * Call the C API giving it our NaiveCallback.
 */
CUseCallback( NaiveCallback, 0 )

/**
 * Dumps an instance of the C API's structure, APIStruct, imported via
 * the bridging header.  
 */
func printAPI( _ s : APIStruct )
{
    print( "Printing APIStruct: " )
    print( "  m_Int: \(s.m_Int)" )
    print( "  m_Long: \(s.m_Long)" )
    print( "  m_Array: \(s.m_Array.0) \(s.m_Array.1) \(s.m_Array.2) " )
}

/**
 * A better callback implementation.
 *
 * This one converts the void pointer to UnsafeMutablePointer<APIStruct>,
 * then uses its memory to construct an instance of APIStruct.  Even if
 * tight packing is used by the C code, the APIStruct will correctly 
 * reflect the data placed there by the C code.  This is as long as 
 * the pack pragma is available via the bridging header.
 *
 * It is called OneWayCallback because whatever changes it makes to
 * the APIStruct provided to it by C code won't be visible to the
 * C code.  This is because we modify a copy of the structure 
 * populated by the C code.
 */
let OneWayCallback : my_cb_t = {( p : UnsafeMutableRawPointer? )->Void in
    print( "In OneWayCallback(), received a void pointer. " );
    // Could have used unsafeBitCast() here
    guard var _apiS = p?.assumingMemoryBound(to: APIStruct.self).pointee else {
        print("Could not dereference APIStruct pointer.")
        return
    }
    printAPI ( _apiS );
    print( "Setting m_Long in the structure to 98765432109" )
    _apiS.m_Long = 98765432109
    // The following change to m_Long would actually be visible in C code; this
    // is essentially the same approach as used in TwoWayCallback() later.
    /*
    if let ptr = p?.assumingMemoryBound(to: APIStruct.self) {
        ptr.pointee.m_Long = 1111111111111111111
    }
    */
}

print("")
/**
 * Call the C API giving it the 1-way callback.
 */
CUseCallback( OneWayCallback, 1 )

/**
 * A structure that wraps an UnsafeMutablePointer<APIStruct> and
 * has getter/setter properties to access the data in the APIStruct
 * pointed to by the wrapped pointer.  Because the wrapped thing is
 * not a copy of, but a pointer to the struct provided by the C code,
 * any changes made via the computed properties will be available
 * when the control returns to the C code that invoked the callback.
 * The downside, however, is that the properties will work correctly
 * only for the duration of the lifetime of the structure in the C
 * code.
 * 
 * In this case the struct mimics the APIStruct, but it doesn't have
 * to.  It could be a Swift class with plenty of added functionality.
 */
struct WrapperStruct
{
    var m_Pointer : UnsafeMutablePointer<APIStruct>

    init( _p : UnsafeMutablePointer<APIStruct> )
    {
        m_Pointer = _p
    }
    
    var m_Int : Int32 {
        get { return m_Pointer.pointee.m_Int }
        set( val ) { m_Pointer.pointee.m_Int = val }
    }
    var m_Long : Int64 {
        get { return m_Pointer.pointee.m_Long }
        set( val ) { m_Pointer.pointee.m_Long = val }
    }
    var m_Array : (Int16, Int16, Int16)
    {
        get { return (m_Pointer.pointee.m_Array.0,
                        m_Pointer.pointee.m_Array.1,
            m_Pointer.pointee.m_Array.2) }
        set ( val ) {
            m_Pointer.pointee.m_Array.0 = val.0
            m_Pointer.pointee.m_Array.1 = val.1
            m_Pointer.pointee.m_Array.2 = val.2
        }
    }
}

/**
 * Dumps an instance of WrapperStruct.
 */
func printWrapper( _ s : WrapperStruct )
{
    print( "Printing WrapperStruct: " )
    print( "  m_Int: \(s.m_Int)" )
    print( "  m_Long: \(s.m_Long)" )
    print( "  m_Array: \(s.m_Array.0) \(s.m_Array.1) \(s.m_Array.2) " )
}

/**
 * A callback implementation that converts the argument to
 * UnsafeMutablePointer<APIStrunct> and wraps it in a WrapperStruct.
 * Please note that changes made via the WrapperStruct properties
 * are visible to the C code!
 *
 * Notice that here we use a top-level Swift function instead of a closure
 * literal. We could have used a literal.
 */
func TwoWayCallback( _ p : UnsafeMutableRawPointer? )->Void
{
    print( "In TwoWayCallback(), received a void pointer. " );
    if let ptr = p?.assumingMemoryBound(to: APIStruct.self) {
        var _wS : WrapperStruct = WrapperStruct(_p: ptr)
        printWrapper( _wS )
        print( "Setting m_Long in the structure to 98765432109 " )
        _wS.m_Long = 98765432109
        print( "Setting the array to 111, 222, 333" )
        _wS.m_Array.0 = 111
        _wS.m_Array.1 = 222
        _wS.m_Array.2 = 333
    }
    else { print("APIStruct pointer is nil.") }
}

print("")
/**
 * Call C code with our more sophisticated 2-way callback.
 */
CUseCallback( TwoWayCallback , 1 )
