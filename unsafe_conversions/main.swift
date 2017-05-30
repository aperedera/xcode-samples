//
//  main.swift
//  unsafe_conversions
//
//  Created by Anatoli on 10/29/15.
//  Copyright © 2015 Anatoli. All rights reserved.
//
/**
 * A simple command line program to demo various ways of converting, in Swift, an imported C
 * structure.  The C structure is APIStruct, the corresponding Swift structure is MyStruct.
 * MyStruct is a naive native Swift structure; using it is unsafe and normally doesn't work.
 * An instance of APIStruct is created in C code and passed to Swift via callbacks.  
 * Alternatively, another native Swift structure, MyStructUnsafe, can also be used to
 * avoid copying of the data and to allow changes made in Swift to be visible in C code.
 *
 * If you are going to do something like this in your code, please be careful with object
 * lifetime management!  That discussion is outside of the scope here.
 */

/**
 * Invoke a Swift callback that takes APIStruct *.
 * This is a C function defined in c_code.h.
 */
invokeCallBack( swiftCallBack )

/**
 * Invoke a Swift callback that takes APIStruct * via void *.
 * This is a C function defined in c_code.h.
 */
invokeCallBackVoid( swiftCallBackVoid )



