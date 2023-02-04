import PyPDF2
  
def read_text(pdf_path):
    pdfFileObj = open(pdf_path , 'rb')
  
    # creating a pdf reader object
    pdfReader = PyPDF2.PdfReader(pdfFileObj)
  
    # printing number of pages in pdf file
    print(len(pdfReader.pages))
  
    # creating a page object
    pageObj = pdfReader.pages[0]
  
    # extracting text from page
    s = (pageObj.extract_text())

    return s
  
    # closing the pdf file object
    pdfFileObj.close()

read_text("./server_pdf/Document_4.pdf")
