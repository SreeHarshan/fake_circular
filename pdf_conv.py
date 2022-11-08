from pdf2image import convert_from_path
from PIL import Image 
import img2pdf


# convert pdf to images
def conv(pdf_path):
    images = convert_from_path(pdf_path)
   
    images[0].save(pdf_path[:-4]+'_img'+'.jpg', 'JPEG')

# convert image to pdf
def img_conv(pdf_path,img_path):

    with open(pdf_path,"wb") as f:
	    f.write(img2pdf.convert(img_path))
  
  
  
  
