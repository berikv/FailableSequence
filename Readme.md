# FailableSequence

Swift Sequences are limited in that they don't support Iterators with a throwing next().

There are several use cases for such sequences, for example FileHandles and other data streams can yield an error on each read operation. The FailableSequence module aims to provide support for these use cases.

Swift may in the future have build-in support for failable Sequences. See the discussion on the [swift language forums](https://forums.swift.org/t/pitch-rethrowing-protocol-conformances/42373).

A part of the Sequence and Iterator Swift standard library has been replicated for FailableSequence and FailableIterator.

Some Swift standard library calls like `map()` and `filter()` return an *Array* while others like `drop()` and `prefix()` return a new type of Sequence. This difference is only noticable if the sequence is big (or infinite.. mapping an infinite sequence won't work well). As an alternative to the Array returning calls, the standard library has `Sequence.lazy` which provides access to Sequence returning calls.

FailableSequence calls match the standard library `Sequence.lazy` calls rather than the `Sequence` calls, where appropriate.
This is done so that errors will be thrown when the elements are retrieved, instead of when the sequence is being build.

There are calls that are available on Sequence but not on FailableSequence. This is because there are many calls, and the implementation takes time. Feel free to open a task or pull request with the calls you need. 

## Installation

### For a Swift Package

Edit the Package.swift file. Add the FailableSequence as a dependency:
 
```
let package = Package(
    name: " ... ",
    products: [ ... ],
    dependencies: [
        .package(url: "https://github.com/berikv/FailableSequence.git", from: "0.0.2") // here
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

### For .xcodeproj projects

1. Open menu File > Add Packages...
2. Search for "https://github.com/berikv/FailableSequence.git" and click Add Package.
3. Open your project file, select your target in "Targets".
4. Open Dependencies
5. Click the + sign
6. Add FailableSequence

## Usage

Create a failable sequence using a `first` and `next()`.
```swift
let sequence = failableSequence(first: 0) { number in
    let next = number + 1
    if next == 3 { throw NumberIsThreeError() }
    return next
}

var numbers = [Int]()
var theError: Error?

do {
    try sequence.forEach { numbers.append($0) }
} catch {
    theError = error
}

// numbers == [0, 1]
// error is NumberIsThreeError
```

Create a lazy failable map from another sequence.
```swift
let sequence = (0..<4).failableMap { number -> Int in
    let next = number + 1
    if next == 3 { throw NumberIsThreeError() }
    return next
}

var numbers = [Int]()
var theError: Error?

do {
    try sequence.forEach { numbers.append($0) }
} catch {
    theError = error
}

// numbers == [1, 2]
// error is NumberIsThreeError
```

Create an Array from a FailableSequence.
```swift
// Note, if this sequence would cause the *Array init* to throw an error if number == 3.
let sequence = failableSequence(first: 0) { number in
    let next = number + 1
    if next == 3 { throw NumberIsThreeError() }
    return next
}

let array = try Array(sequence.prefix(2))
// array == [0, 1]
```

Note that throwing an error will not end the sequence.
```swift
let sequence = (0...4).failableMap { number -> Int in
    let next = number + 1
    if next == 3 { throw NumberIsThreeError() }
    return next
}

let array = Array(sequence.skipOnThrowSequence)
// array == [1, 2, 4, 5]
```

## Contributing

Make sure your code is well tested. Run `./coverage.sh` for an overiew.

## License

Licensed under MIT. See the [license.md](./LICENSE.md)
