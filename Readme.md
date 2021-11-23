# FailableSequence

Swift Sequences are limited in that they don't support Iterators with a throwing next().

There are several use cases for such sequences, for example FileHandles and other data streams can yield an error on each read operation. The FailableSequence module aims to provide support for these use cases.

Swift may in the future have build-in support for failable Sequences. See the discussion on the [swift language forums](https://forums.swift.org/t/pitch-rethrowing-protocol-conformances/42373).

## Installation

#### For a Swift Package

Edit the Package.swift file. Add the FailableSequence as a dependency:
 
```
let package = Package(
    name: " ... ",
    products: [ ... ],
    dependencies: [
        .package(url: "https://github.com/berikv/FailableSequence.git", from: "0.0.1") // here
    ],
    targets: [
        .target(
            name: " ... ",
            dependencies: [
                "FailableSequence" // and here
            ]),
    ]
)
```

#### For .xcodeproj projects

1. click the menu File > Add Packages...
2. Search for "https://github.com/berikv/FailableSequence.git" and click Add Package.
3. Open your project file, select your target in "Targets".
4. Open Dependencies
5. Click the + sign
6. Add FailableSequence

### Use the module by importing it in a .swift file:

```swift
import FailableSequence

failableSequence(first: 0) { $0 + 1 }

```

## Usage

Create a failable sequence using a start and next()
```swift
        struct DivisionByZero: Error {}
        
        let sequence = failableSequence(first: 10) { element in
            if element == 0 { throw DivisionByZero() }
            return 1 / element
        }

        do {
            try sequence.forEach { number in
                print(number)
            }
        } catch {
            print(error)
        }
```

Create a lazy failable map from another sequence
```swift
        struct DivisionByZero: Error {}

        let sequence = (0..<4).failableMap { number -> Int in
            if (3 - number) == 0 { throw DivisionByZero() }
            return 1 / (3 - number)
        }

        do {
            try sequence.forEach { number in
                print(number)
            }
        } catch {
            print(error)
        }
```

Create an Array from a FailableSequence
```swift
        struct DivisionByZero: Error {}
        
        // Note, if this sequence would throw it would be reported on Array init 
        let sequence = (0..<4).failableMap { number -> Int in
            if (4 - number) == 0 { throw DivisionByZero() }
            return 1 / (4 - number)
        }

        let array = try Array(sequence) // [0, 0, 0, 1]
```
