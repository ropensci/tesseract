#ifndef CPP11_PRESERVESTORAGE_H
#define CPP11_PRESERVESTORAGE_H

#include <cpp11.hpp>

namespace cpp11 {

class preserved {
 public:
  preserved() : data_(R_NilValue) {}
  explicit preserved(SEXP data) : data_(data) { preserve(); }
  ~preserved() { release(); }

  void preserve() {
    if (data_ != R_NilValue) {
      PROTECT(data_);
    }
  }

  void release() {
    if (data_ != R_NilValue) {
      UNPROTECT(1);
      data_ = R_NilValue;
    }
  }

  SEXP get() const { return data_; }

 private:
  SEXP data_;
};

template <typename CLASS>
class preserve_storage {
 public:
  preserve_storage() : data_(R_NilValue), token_() {}

  ~preserve_storage() {
    token_.release();
    data_ = R_NilValue;
  }

  void set(SEXP x) {
    if (data_ != x) {
      data_ = x;
      token_.release();
      token_ = preserved(data_);
    }
    static_cast<CLASS&>(*this).update(data_);
  }

  SEXP get() const { return data_; }

  SEXP invalidate() {
    SEXP out = data_;
    token_.release();
    data_ = R_NilValue;
    return out;
  }

  template <typename T>
  T& copy(const T& other) {
    if (this != &other) {
      set(other.get());
    }
    return static_cast<T&>(*this);
  }

  bool inherits(const char* clazz) const { return Rf_inherits(data_, clazz); }

  operator SEXP() const { return data_; }

 private:
  SEXP data_;
  preserved token_;
};

}  // namespace cpp11

#endif  // CPP11_PRESERVESTORAGE_H
