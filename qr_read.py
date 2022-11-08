import cv2
import pdf_conv 
def readqr(path):

    img=cv2.imread(path)
    det=cv2.QRCodeDetector()
    val, pts, st_code=det.detectAndDecode(img)
    if pts is not None:
        return (val)
    return None

def readpdf(path):
    pdf_conv.conv(path)
    return readqr(path[:-4]+"_img.jpg")

#main
if __name__ == "__main__":
    print(readpdf("output.pdf"))
