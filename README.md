# tesseract

> Bindings to [Tesseract-OCR](https://opensource.google/projects/tesseract): 
  a powerful optical character recognition (OCR) engine that supports over 100 languages.
  The engine is highly configurable in order to tune the detection algorithms and
  obtain the best possible results.

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/tesseract)](https://cran.r-project.org/package=tesseract)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/tesseract)](https://cran.r-project.org/package=tesseract)

 - Upstream Tesseract-OCR documentation: https://tesseract-ocr.github.io/tessdoc/
 - Introduction: https://docs.ropensci.org/tesseract/articles/intro.html
 - Reference: https://docs.ropensci.org/tesseract/reference/ocr.html

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
[libleptonica-dev](https://packages.debian.org/testing/libleptonica-dev). Also install [tesseract-ocr-eng](https://packages.debian.org/testing/tesseract-ocr-eng) to run examples.

```
sudo apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng
```

On __Ubuntu__ you can optionally use [this PPA](https://launchpad.net/~alex-p/+archive/ubuntu/tesseract-ocr-devel) to get the latest version of Tesseract:

```
sudo add-apt-repository ppa:alex-p/tesseract-ocr-devel
sudo apt-get install -y libtesseract-dev tesseract-ocr-eng
```

On __Fedora__ we need [tesseract-devel](https://src.fedoraproject.org/rpms/tesseract) and
[leptonica-devel](https://src.fedoraproject.org/rpms/leptonica)

```
sudo yum install tesseract-devel leptonica-devel
````

On __RHEL__ and __CentOS__ we need [tesseract-devel](https://src.fedoraproject.org/rpms/tesseract) and
[leptonica-devel](https://src.fedoraproject.org/rpms/leptonica) from EPEL

```
sudo yum install epel-release
sudo yum install tesseract-devel leptonica-devel
````


On __OS-X__ use [tesseract](https://github.com/Homebrew/homebrew-core/blob/master/Formula/tesseract.rb) from Homebrew:

```
brew install tesseract
```

Tesseract uses training data to perform OCR. Most systems default to English
training data. To improve OCR results for other languages you can to install the
appropriate training data. On Windows and OSX you can do this in R using 
`tesseract_download()`:


```r
tesseract_download('fra')
```

On Linux you need to install the appropriate training data from your distribution. 
For example to install the spanish training data:

  - [tesseract-ocr-spa](https://packages.debian.org/testing/tesseract-ocr-spa) (Debian, Ubuntu)
  - [tesseract-langpack-spa](https://src.fedoraproject.org/rpms/tesseract-langpack) (Fedora, EPEL)

Alternatively you can manually download training data from [github](https://github.com/tesseract-ocr/tessdata)
and store it in a path on disk that you pass in the `datapath` parameter or set a default path via the
`TESSDATA_PREFIX` environment variable. Note that the Tesseract 4 and Tesseract 3 use different 
training data format. Make sure to download training data from the branch that matches your libtesseract version.

