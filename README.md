# pibench2

A dead-simple, multi-threaded performance benchmark.

Approximates π using the (pretty inefficient) Leibniz infinite series.

## Installing

Prerequisites:
 - [Nim](http://nim-lang.org/)

To install pibench2, use the following command:
```sh
$ nimble install https://github.com/liquid600pgm/pibench2
```

## Usage

pibench2 can be launched without any parameters:
```sh
$ pibench2
```
This will run the benchmark, computing 10 digits of π, using as many processor
threads as possible.

pibench2 can be tweaked using the following command line parameters:
```
  --d:x --digits:x
    Makes pibench2 compute x digits of π instead of the default value (10).
  --t:x --threads:x
    Makes pibench2 run on x threads instead of all of the CPU's threads.
    Do note that this may, and probably will decrease performance if the amount
    specified is greater than the CPU's thread count.
```

## Contributing

pibench2 started as a small, and very simple benchmark, but any contributions
willing to make the benchmark better, or more efficient, are welcome.

Please keep in mind the following principles while contributing:
 - adhere to the [Nim Style Guide](https://nim-lang.org/docs/nep1.html),
 - don't make unneccessary changes that make the codebase more convoluted,
 - try not to split pibench2 into multiple modules, at least not yet,
 - don't make the CLI ugly, it's supposed to be nice and modern, even if it
   makes the benchmark less efficient (it doesn't).

Right now the goals of pibench2 are:
 - improve the (currently) very messy codebase,
 - make it more modular,
 - add more (efficient) π computing algorithms.
