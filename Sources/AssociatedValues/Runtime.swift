//
//  Runtime.swift
//  Waclub
//
//  Created by iMoe Nya on 2021/3/5.
//

import Foundation

private struct RuntimeWeakRef {
    weak var object: AnyObject?
}

/// Namespace for all Runtime functions.
public enum Runtime {
    /// Void?
    public typealias Key = Void?
    
    /// Get associated value by key.
    ///
    /// ```swift
    /// private var key: Void?
    ///
    /// Runtime.set("1", to: object, by: &key)  // associate "1" to object
    /// Runtime.get(from: object, by: &key)  // returns "1"
    /// ```
    public static func get<T>(from source: Any, by key: UnsafeRawPointer) -> T? {
        if let weakRef = objc_getAssociatedObject(source, key) as? RuntimeWeakRef {
            guard let object = weakRef.object as? T else {
                set(nil, to: source, by: key)
                return nil
            }
            return object
        } else {
            return objc_getAssociatedObject(source, key) as? T
        }
    }
    
    /// Set associated value by key.
    ///
    /// ```swift
    /// private var key: Void?
    ///
    /// // associate a UIView instance to object, with a weak ref:
    /// Runtime.set(uiView!, to: object, by: &key, referencedWeakly: true)
    ///
    /// Runtime.get(from: object, by: &key)  // returns the UIView
    ///
    /// uiView = nil
    /// Runtime.get(from: object, by: &key)  // returns nil
    /// ```
    public static func set(
        _ value: Any?,
        to object: Any,
        by key: UnsafeRawPointer,
        referencedWeakly: Bool = false
    ) {
        if referencedWeakly {
            guard let value = value else {
                objc_setAssociatedObject(
                    object,
                    key,
                    nil,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return
            }
            let weakRef = RuntimeWeakRef(object: value as AnyObject)
            objc_setAssociatedObject(
                object,
                key,
                weakRef,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        } else {
            objc_setAssociatedObject(
                object,
                key,
                value,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
