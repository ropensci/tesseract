% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ocr.R
\name{ocr}
\alias{ocr}
\alias{ocr_data}
\title{Tesseract OCR}
\usage{
ocr(image, engine = tesseract("eng"), HOCR = FALSE)

ocr_data(image, engine = tesseract("eng"))
}
\arguments{
\item{image}{file path, url, or raw vector to image (png, tiff, jpeg, etc)}

\item{engine}{a tesseract engine created with \code{\link[=tesseract]{tesseract()}}. Alternatively a
language string which will be passed to \code{\link[=tesseract]{tesseract()}}.}

\item{HOCR}{if \code{TRUE} return results as HOCR xml instead of plain text}
}
\description{
Extract text from an image. Requires that you have training data for the language you
are reading. Works best for images with high contrast, little noise and horizontal text.
See \href{https://github.com/tesseract-ocr/tesseract/wiki/ImproveQuality}{tesseract wiki} and
our package vignette for image preprocessing tips.
}
\details{
The \code{ocr()} function returns plain text by default, or hOCR text if hOCR is set to \code{TRUE}.
The \code{ocr_data()} function returns a data frame with a confidence rate and bounding box for
each word in the text.
}
\examples{
# Simple example
text <- ocr("https://jeroen.github.io/images/testocr.png")
cat(text)

xml <- ocr("https://jeroen.github.io/images/testocr.png", HOCR = TRUE)
cat(xml)

df <- ocr_data("https://jeroen.github.io/images/testocr.png")
print(df)

\donttest{
# Full roundtrip test: render PDF to image and OCR it back to text
curl::curl_download("https://cran.r-project.org/doc/manuals/r-release/R-intro.pdf", "R-intro.pdf")
orig <- pdftools::pdf_text("R-intro.pdf")[1]

# Render pdf to png image
img_file <- pdftools::pdf_convert("R-intro.pdf", format = 'tiff', pages = 1, dpi = 400)
unlink("R-intro.pdf")

# Extract text from png image
text <- ocr(img_file)
unlink(img_file)
cat(text)
}

engine <- tesseract(options = list(tessedit_char_whitelist = "0123456789"))
}
\references{
\href{https://github.com/tesseract-ocr/tesseract/wiki/ImproveQuality}{Tesseract: Improving Quality}
}
\seealso{
Other tesseract: 
\code{\link{tesseract}()},
\code{\link{tesseract_download}()}
}
\concept{tesseract}
