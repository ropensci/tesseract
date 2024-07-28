load_all()

tesseract::tesseract_info()

tesseract_download("chi_sim", datapath = "dev", best = TRUE)

file <- system.file("examples", "chinese.png", package = "tesseract")

text1 <- ocr(file, engine = tesseract("chi_sim"))
text2 <- ocr(file, engine = tesseract("chi_sim", datapath = "dev"))
