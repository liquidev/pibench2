# pibench2 - extras

This folder contains some extras for pibench2.

## pibench

The first version of pibench.

This benchmark started out as a performance test, to see how slow is Node.js,
compared to plain old C.
This is a single-threaded performance benchmark. pibench2 was created to see
how much better could a multi-threaded pibench be.

To compile pibench, use:
```sh
$ cc -O3 -o pibench pibench.c
```
 
To run pibench, use:
```sh
$ ./pibench <digits>
```

