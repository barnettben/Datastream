# ``Datastream``

Parse milk recording information from the NMR Datastream file format.


## Overview

Datastream files are used to provide milk recording results to UK dairy farmers. These files contain details of milk production, animal identities, recorded events and genetic evaluations.

This library parses Datastream files into data structures as detailed below. If unable to do so, it will throw an error to aid in locating problems within a given file.


## Parsing options

There are two primary options for parsing:
- Parsing into a single ``Datastream/Datastream`` structure

    This creates a representation of an entire Datastream file where you do not need to be concerned about the underlying file structure. It is the simplest way to extract information from a file.

- Parsing record-by-record:

    The Datastream format is record-based. This library provides ``AsyncRecordSequence`` which can be used to iterate over each record in the file.
    This can be useful if you want to inspect the structure of the file in detail rather than just the information contained within it.


## Topics

### Reading Files

- ``Datastream/Datastream``
- <doc:DatastreamSections>

### Record-Based Parsing

- <doc:RecordParsing>
- <doc:RecordTypes>

### Error Handling

- ``DatastreamError``
- ``ErrorCode``
