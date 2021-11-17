# Datastream

**A parser for NMR Datastream files**

***

### Requirements: 

- **Swift:** 5.5+
- **Platforms:** macOS 12+, iOS 15+
- **Xcode:** Xcode 13+

### Contact:

- Report bugs as [GitHub issues](https://github.com/benrb/Datastream/issues/).
- Reach out on Twitter [@__bb](https://twitter.com/__bb)
- If you use this in a project, please let me know

***

## What is this?
This library parses [NMR](https://www.nmr.co.uk/) Datastream files into Swift objects for use in your own code.

Datastream files are used to provide milk recording results to UK dairy farmers. These files contain details of milk production, animal identities, recorded events and genetic evaluations.


### Documentation
Documentation is provided in [DocC format](https://www.swift.org/documentation/docc/) as part of the repository.

Once you have cloned this repository, selecting `Build Documentation` within Xcode will create a documentation bundle which is viewable in the Developer Documentation window.
### Goals
- To provide a fast and simple to use API for loading a Datastream from a file and converting it into a useful in-memory representation.
- To provide a utility for locating and inspecting records within a Datastream file without loading the entire file at once.

### Non-goals
- Writing back into a new or edited Datastream file.

Datastream files are usually provided *to* farmers and it would be most unusual to need to edit one after it has been issued.

- Validating the factual content of a Datastream file.

The library will check that the *format* of the file is correct, but not that the content is coherent. By this I mean it will not attempt to detect oddities like a cow aged 99 years producing 150,000 litres a month.

