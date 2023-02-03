import random,qrcode
from PIL import Image
import os

import pdf_conv as pdf

def gen_rno(title,no,date):
    
    t_list = [ ord(i) for i in title]
    d_list = [ ord(i) for i in date]
    s_value = sum(t_list)+sum(d_list)+int(no)
    
    #seed the random
    random.seed(s_value)
    rno = 0
    #generate 10 digit random number
    for i in range(10):
        rno += random.randint(0,9) * 10 ** i

    return rno

def gen_qr(no,img_name):
    qr_img = qrcode.make(str(no))
    qr_img.save(img_name)

def add_qr(pdf_path):
    pdf.conv(pdf_path)     
    p_img = Image.open(pdf_path[:-4]+"_img.jpg")
    qr_img = Image.open(pdf_path[:-4]+"_qr.jpg")
    p_img.paste(qr_img,(1,1))
    p_img = p_img.save(pdf_path[:-4]+"_qr_added.jpg")
    pdf.img_conv(pdf_path[:-4]+"_output.pdf",pdf_path[:-4]+"_qr_added.jpg")
    
    os.remove(pdf_path[:-4]+"_img.jpg")
    os.remove(pdf_path[:-4]+"_qr.jpg")
    os.remove(pdf_path[:-4]+"_qr_added.jpg")


#Main code
if __name__ == "__main__":
    p_path = "test_circular.pdf"
    qr_path = "qr.jpg"
    no = gen_rno("ABC Circular",2204,"01/11/20022") 
    print("Number generated is",no)
    gen_qr(no ,qr_path)
    add_qr(p_path,qr_path)


