# tesseract

> Open Source OCR Engine

[![Build Status](https://travis-ci.org/ropensci/tesseract.svg?branch=master)](https://travis-ci.org/ropensci/tesseract)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/tesseract?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/tesseract)
[![Coverage Status](https://codecov.io/github/ropensci/tesseract/coverage.svg?branch=master)](https://codecov.io/github/ropensci/tesseract?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/tesseract)](https://cran.r-project.org/package=tesseract)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/tesseract)](https://cran.r-project.org/package=tesseract)
[![Github Stars](https://img.shields.io/github/stars/ropensci/tesseract.svg?style=social&label=Github)](https://github.com/ropensci/tesseract)

## Hello World

Example to render a PDF file to various image formats and then OCR it back to text.

```r
# Some packages
library(pdftools)
library(tesseract)
library(png)
library(jpeg)
library(tiff)

# Render pdf to png
setwd(tempdir())
news <- file.path(Sys.getenv("R_DOC_DIR"), "NEWS.pdf")
bitmap <- pdf_render_page(news, dpi = 300)
png::writePNG(bitmap, "page.png")
jpeg::writeJPEG(bitmap, "page.jpg")
tiff::writeTIFF(bitmap, "page.tiff")

# Extract text from images
txt <- ocr(c("page.png", "page.png", "page.tiff"))
cat(txt)
```

## Installation

Installation from source on Linux or OSX requires [`tesseract-ocr`](https://github.com/tesseract-ocr/tesseract). On __Debian__ or __Ubuntu__ install [libtesseract-dev](https://packages.debian.org/testing/libtesseract-dev) and
[libleptonica-dev](https://packages.debian.org/testing/libleptonica-dev):

```
sudo apt-get install -y libtesseract-dev libleptonica-dev
```

On __Fedora__ and __CentOS__ we need [tesseract-devel](https://apps.fedoraproject.org/packages/tesseract-devel) and
[leptonica-devel](https://apps.fedoraproject.org/packages/leptonica-devel)

```
sudo yum install tesseract-devel leptonica-devel
````

On __OS-X__ use [tesseract](https://github.com/Homebrew/homebrew-core/blob/master/Formula/tesseract.rb) from Homebrew:

```
brew install tesseract
```
