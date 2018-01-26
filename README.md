# tesseract

> Extract text from an image. Requires that you have training data for the language you are reading. Works best for images with high contrast, little noise and horizontal text.

[![Build Status](https://travis-ci.org/ropensci/tesseract.svg?branch=master)](https://travis-ci.org/ropensci/tesseract)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/tesseract?branch=master&svg=true)](https://ci.appveyor.com/project/jeroen/tesseract)
[![Coverage Status](https://codecov.io/github/ropensci/tesseract/coverage.svg?branch=master)](https://codecov.io/github/ropensci/tesseract?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/tesseract)](https://cran.r-project.org/package=tesseract)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/tesseract)](https://cran.r-project.org/package=tesseract)
[![Github Stars](https://img.shields.io/github/stars/ropensci/tesseract.svg?style=social&label=Github)](https://github.com/ropensci/tesseract)

## Hello World

Simple example

```r
# Simple example
text <- ocr("https://jeroen.github.io/images/testocr.png")
cat(text)

# Get XML HOCR output
xml <- ocr("https://jeroen.github.io/images/testocr.png", HOCR = TRUE)
cat(xml)
```

Roundtrip test: render PDF to image and OCR it back to text

```r
# Full roundtrip test: render PDF to image and OCR it back to text
curl::curl_download("https://cran.r-project.org/doc/manuals/r-release/R-intro.pdf", "R-intro.pdf")
orig <- pdftools::pdf_text("R-intro.pdf")[1]

# Render pdf to png image
img_file <- pdftools::pdf_convert("R-intro.pdf", format = 'tiff', pages = 1, dpi = 400)

# Extract text from png image
text <- ocr(img_file)
unlink(img_file)
cat(text)
```

## Installation

On Windows and MacOS the package binary package can be installed from CRAN:

```r
install.packages("tesseract")
```

Installation from source on Linux or OSX requires the `Tesseract` library (see below).

### Install from source

 On __Debian__ or __Ubuntu__ install [libtesseract-dev](https://packages.debian.org/testing/libtesseract-dev) and
[libleptonica-dev](https://packages.debian.org/testing/libleptonica-dev). Also install [tesseract-ocr-eng](https://packages.debian.org/testing/tesseract-ocr-eng) to run english examples.

```
sudo apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng
```

On __Fedora__ we need [tesseract-devel](https://apps.fedoraproject.org/packages/tesseract-devel) and
[leptonica-devel](https://apps.fedoraproject.org/packages/leptonica-devel)

```
sudo yum install tesseract-devel leptonica-devel
````

On __RHEL__ and __CentOS__ we need [tesseract-devel](https://apps.fedoraproject.org/packages/tesseract-devel) and
[leptonica-devel](https://apps.fedoraproject.org/packages/leptonica-devel) from EPEL

```
sudo yum install epel-release
sudo yum install tesseract-devel leptonica-devel
````


On __OS-X__ use [tesseract](https://github.com/Homebrew/homebrew-core/blob/master/Formula/tesseract.rb) from Homebrew:

```
brew install tesseract
```

Tesseract uses training data to perform OCR. Most systems default to English
training data. To improve OCR performance for other langauges you can to install the
training data from your distribution. For example to install the spanish training data:

  - [tesseract-ocr-spa](https://packages.debian.org/testing/tesseract-ocr-spa) (Debian, Ubuntu)
  - [tesseract-langpack-spa](https://apps.fedoraproject.org/packages/tesseract-langpack-spa) (Fedora, EPEL)

On other platforms you can manually download training data from [github](https://github.com/tesseract-ocr/tessdata)
and store it in a path on disk that you pass in the `datapath` parameter. Alternatively
you can set a default path via the `TESSDATA_PREFIX` environment variable.
