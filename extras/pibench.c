#include <stdio.h>
#include <stdlib.h>

long powi(long base, long exp) {
  long i = base;
  for (int n = 0; n < exp - 1; ++n) i *= base;
  return i;
}

double pi(int digits) {
  long iter = powi(10, digits);
  double n = 1;
  int updt = 2000000;
  for (long i = 1; i < iter; ++i) {
    double den = i * 2 + 1;
    if (i % 2 == 0) { n += 1 / den; }
    else { n -= 1 / den; }
    if (i % updt == 1) {
      printf("progress: %d%%\t%ld/%ld iter\r",
        (int) ((float) i / (float) iter * 100), i, iter);
    }
  }
  printf("\n");
  return n * 4;
}

int main(int argc, char* argv[]) {
  if (argc == 2) {
    int n = atoi(argv[1]);
    printf("computing %d digits of π\n", n);
    printf("%.20f\n", pi(n));
    return 0;
  } else {
    printf("Usage: %s <digits>", argv[0]);
    return 1;
  }
}
