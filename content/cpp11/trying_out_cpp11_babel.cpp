#include "cpp11/doubles.hpp"
using namespace cpp11;

[[cpp11::register]]
doubles pdist_cpp(double x, doubles ys) {
  int n = ys.size();
  writable::doubles out(n);
  for(int i = 0; i < n; ++i) {
    out[i] = sqrt(pow(ys[i] - x, 2.0));
  }
  return out;
}
