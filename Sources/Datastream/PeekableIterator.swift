//
//  PeekableIterator.swift
//  
//
//  Created by Ben Barnett on 27/10/2021.
//


/// An iterator providing the ability to peek at its next element without advancing to it
///
/// This can be useful where you wish to make decisions based on the next element, without
/// having to consume it at the time. Repeated calls to `peek()` will return the same element
/// until `next()` is called:
///
///     let numbers = [1, 2, 3, 4, 5]
///     var peekable = numbers.makeIterator().peekable()
///     peekable.peek() // returns 1
///     peekable.next() // returns 1
///     peekable.peek() // returns 2
///     peekable.peek() // returns 2
///
internal struct PeekableIterator<T: AsyncIteratorProtocol>: AsyncIteratorProtocol {
    private var wrapped: T
    private var peekedItem: T.Element?
    
    fileprivate init(wrapping otherIterator: T) {
        self.wrapped = otherIterator
    }
    
    /// Returns the element that would be provided by calling `next()`
    ///
    /// In contrast to `next()`, this function does not advance to the next element.
    mutating func peek() async throws -> T.Element? {
        if peekedItem == nil {
            peekedItem = try await wrapped.next()
        }
        return peekedItem
    }
    
    /// Advances to the next element and returns it, or `nil` if no next element exists.
    /// See `IteratorProtocol.next()`
    mutating func next() async throws -> T.Element? {
        let oldPeeked = try await peek()
        peekedItem = try await wrapped.next()
        return oldPeeked
    }
}

extension AsyncIteratorProtocol {
    
    /// Wraps another iterator inside a ``PeekableIterator``
    internal func peekable() -> PeekableIterator<Self> {
        PeekableIterator(wrapping: self)
    }
}
