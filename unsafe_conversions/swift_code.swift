//
//  swift_code.swift
//  unsafe_conversions
//
//  Created by Anatoli on 10/29/15.
//  Copyright © 2015 Anatoli. All rights reserved.
//

/**
 * This is our naive native Swift structure.
 *
 * In C you can pack structures for different alignment.  We do this in c_code.h. 
 * If #pragma pack(2) is used, then the unsafe conversion, i.e. casting 
 * UnsafeMutableRawPointer to UnsafeMutablePointer<MyStruct> and using .pointee
 * to get MyStruct, will yield corrupted data.
 *
 * This structure is handy to use when callbacks take APIStruct *, as is or
 * as void *, as an IN parameter, i.e. the pointer is not used to send info
 * back to the C code.  If it's an INOUT parameter and we need to modify it 
 * to communicate back to C, then MyStructUnsafe can be used, with the 
 * disadvantage that we have to worry about object lifetime.
 */
struct MyStruct
{
    
    init( _apis : APIStruct)
    {
        myInt16 = _apis.myInt16
        myTime = _apis.myTime
        myInt32 = _apis.myInt32
    }

    var     myInt16 : UInt16
    var     myTime : UInt64
    var     myInt32 : UInt32
}

/**
 * A typealias to save some typing and make code more readable.
 */
typealias APIStructPtr = UnsafeMutablePointer<APIStruct>

/**
 * This one performs a function similar to that of MyStruct, but changes 
 * made to it are reflected in the C code.  Careful with object lifetime here!
 *
 * It's a struct, but we might just as well make it a class.
 */
struct MyStructUnsafe
{
    init( _p : APIStructPtr )
    {
        pAPIStruct = _p
    }
    
    var myTime: UInt64 {
        get {
            return pAPIStruct.pointee.myTime
        }
        set( newVal ) {
            pAPIStruct.pointee.myTime = newVal
        }
    }
    var   pAPIStruct: APIStructPtr
}

/**
 * This one takes an APIStruct *.  Works fine regardless of alignment
 * difference.  Our hand-crafted native Swift structs are not used here.
 * 
 * Please note that we take some liberties here by force-unwrapping the 
 * pointer that is passed in; shouldn't do that in production code.
 */
func swiftCallBack( _ p: UnsafeMutablePointer<APIStruct>? )
{
    print( "Received APIStruct * in swift callback via APIStruct * ...")
    print( "Retrieving APIStruct via subscript...")
    // This is if we want to use the struct imported from C via the bridging header;
    // it's a copy, so changes made to _locAS won't be visible in C code.
    var _locAS:APIStruct = p![0]
    printAPIStruct(_locAS)
    print( "Retrieving APIStruct via .memory...")
    // Again, changes made to this _locAS won't be visible to C
    _locAS = p!.pointee
    printAPIStruct(_locAS)
    print("Now, in Swift, change its time to 1234567890")
    print("   (do this via a pointer to the original, not a copy!)")
    // And this change will survive and get back to C code
    p![0].myTime = 12345678901
}

/**
 * This one receives an APIStruct via void *.  Brute force conversion of
 * the argument to UnsafeMutablePointer<MyStruct> won't work when MyStruct
 * is aligned differently enough from APIStruct.
 *
 * Again, the pointer that's passed in is force unwrapped, which is risky!
 */
func swiftCallBackVoid( _ p: UnsafeMutableRawPointer? )
{
    print( "Received APIStruct * in swift callback via VOID * ...")
    print( "First print MyStruct obtained in a not very safe way: ")
    let _locMS:MyStruct = p!.assumingMemoryBound(to: MyStruct.self).pointee
    printMyStruct(_locMS)
    print("Print MyStruct obtained from void * in a safer way:")
    // Modifications to MyStruct thus obtained won't be visible back in C
    printMyStruct(MyStruct(_apis: p!.assumingMemoryBound(to: APIStruct.self).pointee))
    print( "Print MyStructUnsafe obtained from void *: ")
    var _myUnsafe : MyStructUnsafe = MyStructUnsafe(_p: p!.assumingMemoryBound(to: APIStruct.self))
    printMyStructUnsafe(_myUnsafe)
    print("Now set its time to 9876543210. ")
    _myUnsafe.myTime = 9876543210
    printMyStructUnsafe(_myUnsafe)
}

/**
 * Helper to dump an APIStruct.  
 */
func printAPIStruct( _ s : APIStruct )
{
    print( "Printing APIStruct: ")
    print( "  myInt16: \(s.myInt16)")
    print( "  myTime: \(s.myTime)" )
    print( "  myInt32: \(s.myInt32)" )
}

/**
 * Helper to dump a MyStruct.
 */
func printMyStruct( _ s: MyStruct )
{
    print( "Printing MyStruct: ")
    print( "  myInt16: \(s.myInt16)" )
    print( "  myTime: \(s.myTime)" )
    print( "  myInt32: \(s.myInt32)" )
}

/**
 * Helper to dump a MyStructUnsafe.  Print only time, which is sufficient
 * for our purposes.
 */
func printMyStructUnsafe( _ s: MyStructUnsafe )
{
    print( "Printing MyStructUnsafe: ")
    print( "  myTime: \(s.myTime)" )
}
