# ``Datastream``

Datastream is a parser for the NMR Datastream file format.

## Overview

Datastream files are used to provide milk recording results to UK dairy farmers.  

This library can parse valid Datastream files into various data structures as detailed below. If unable to do so, it will throw an error to aid in locating problems within a given file.

There are two primary options for parsing:
- Parsing into a single ``Datastream/Datastream`` structure

    This creates a representation of an entire Datastream file where you do not need to be concerned about the underlying file structure. You can create this using ``Datastream/init(url:)``.

- Parsing record-by-record:

    The Datastream format is record-based. This library provides ``AsyncRecordSequence`` which can be used to iterate over each record in the file.
    This can be useful if you want to inspect the structure of the file in detail rather than just the information contained within it.


## Topics

### Essentials

- ``Datastream/Datastream``
- ``DatastreamError``

### Sections

- ``HerdDetails``
- ``HerdRecording``
- ``Animal``
- ``AnimalStatement``
- ``Lactation``
- ``BullDetails``

### Record-Based Parsing

- ``AsyncRecordSequence``
- ``Record``
- ``RecordDescriptor``
- ``BaseRecord``

### Record types

- ``TextRecord``
- ``NMRDetails``
- ``ServiceIndicators``
- ``ServiceIndicatorsContinued``
- ``RecordingPart1``
- ``RecordingPart2``
- ``AnimalIdentityRecord``
- ``AnimalOtherDetailsRecord``
- ``AnimalNameRecord``
- ``AnimalParentsRecord``
- ``PTARecord``
- ``StatementHeaderRecord``
- ``CowIDRecord``
- ``WeighingRecord``
- ``ServiceRecord``
- ``ActualCalvingRecord``
- ``ActualThirdCalfRecord``
- ``AssumedCalvingRecord``
- ``OtherEventRecord``
- ``LactationDetailsRecord``
- ``CompletedLactationRecord``
- ``CalvingDetailsRecord``
- ``CalvingExtraCalvesRecord``
- ``LactationTotalsRecord``
