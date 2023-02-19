Fake Circular Detector

* Python Flask Backend
* Flutter mobile app Frontend
* ElephantSQL postgres Database

Features

* Staff can login with their key and upload the circular as pdf
* A QR code will be generated on the top left corner of the pdf
* Staff can distribute this circular to students
* Students can upload this pdf in the app and check if it's fake or original
* It detects the originality by checking if the qr code and the content are the same, and if the content of the circular is the same 
  
To implement

* Users can upload the pdf directly by using androids open with feature
* Remove manual entering of the title,no,date of the circular
* Encrypt the content of the circular and store in qr
