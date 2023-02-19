import PyPDF2
from pytesseract import pytesseract
from PIL import Image

import pdf_conv
  
def read_text_as_pdf(pdf_path):
    pdfFileObj = open(pdf_path , 'rb')
  
    # creating a pdf reader object
    pdfReader = PyPDF2.PdfReader(pdfFileObj)
  
    # creating a page object
    pageObj = pdfReader.pages[0]
  
    # extracting text from page
    s = (pageObj.extract_text())
    print("text in pdf ",pdf_path,":",s)

    # closing the pdf file object
    pdfFileObj.close()
    
    return s

def read_text(pdf_path):
    # convert pdf to image
    pdf_conv.conv(pdf_path) 
    p_img = Image.open(pdf_path[:-4]+"_img.jpg")
    
    # get text from img
    s = pytesseract.image_to_string(p_img,lang="afr")
    return s
