# ``Datastream/Datastream``
@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

The code sample below shows how to create an instance of Datastream from a file.

```swift
let fileURL = URL(fileURLWithPath: "DSMEMBER.DAT")
do {
    let datastream = try await Datastream(url: URL)
} catch {
    print(error)
}
```
