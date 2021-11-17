# Record Parsing

Reading a Datastream file one record at a time.

## Overview

The Datastream file format is text-based, with one record per line of a file.

These records can be accessed using ``AsyncRecordSequence`` like so:

```swift
let fileURL = URL(fileURLWithPath: "DSMEMBER.DAT")
let sequence = AsyncRecordSequence(url: fileURL)
for try await record in sequence {
    print(record.recordIdentifier)
}
```

The objects produced by `AsyncRecordSequence` will be an implementation of the `Record` protocol specific to the type of record returned. 

For example, if `AsyncRecordSequence` returns a record with identifier ``RecordIdentifier/nmrDetails``, it will have a Type of ``NMRDetails``. You can then downcast the object to this type to inspect specific properties of the record.

Because the records are delivered as an `AsyncSequence`, you can use the range of Swift functions for searching and manipulating sequences. For example:

```swift
let fileURL = URL(fileURLWithPath: "DSMEMBER.DAT")
let sequence = AsyncRecordSequence(url: fileURL)

let statementSequence = sequence.filter({ $0.recordIdentifier.section == .statement })
for try await record in statementSequence {
    // Only records in the .statement section
}
```

> Tip: While it is possible to validate record sizes and checksums during parsing, it is not recommended. Real-world files and some demonstration data files contain invalid checksums. It does not appear to adversely affect the rest of the file.


## Topics

### Basic types

- ``AsyncRecordSequence``
- ``Record``
- ``RecordIdentifier``
- ``SomeRecord``
