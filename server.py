from flask import Flask,render_template, request,flash,url_for, redirect, request, send_file, send_from_directory
from werkzeug.utils import secure_filename
import os

import psycopg2 as psy

import qr_read,circular_gen

# upload folder
UPLOAD_FOLDER = "./server_pdf/"
ALLOWED_EXTENSIONS = { 'pdf' } 

#db connection
con = psy.connect("postgres://wrgwkwjx:SD6vNeZjEMxeBaTLcHmnOmAZklWKWzBk@tiny.db.elephantsql.com/wrgwkwjx")
# flask server
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
 
#check if the circular is in db
@app.route("/check")
def check():
    args = request.args.to_dict()

    if(args['title'] and args['no'] and args['date']):
        # check if it's in db
        cur = con.cursor()
        cur.execute("Select * from circular where num = {} AND title = '{}' AND date = '{}' AND rno = {}".format(args['no'],args['title'],args['date'],args['rno']))
        val = cur.fetchone()

        if cur.rowcount!=0: 
            return {"value":True}
        cur.close()
        return {"title":args['title'],"no":args['no'],"date":args['date'],"value":False}
    return {"value":False}

# check if the file extension is pdf
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# upload the file 
@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return {"value":False}
            #return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file')
            return {"value2":False}
            #return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

            return redirect(url_for('upload_file',filename=filename))
    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''

@app.route("/generateQR")
def generate():
    fname = request.args.get("fname",None)
    no = request.args.get("no",None)
    title = request.args.get("title",None)
    date = request.args.get("date",None)
    

    if(fname or True): #temp
        #generate rno
        rno = circular_gen.gen_rno(title,no,date)
        print("rno generated is ",rno)

        cur = con.cursor()
        q = "Select * from circular Where num = {} AND title = '{}' AND date = '{}' AND rno = {};".format(no,title,date,rno)
        print(q)
        cur.execute(q)
        if(cur.rowcount == 0):
            cur = con.cursor()
            #add the values to db
            q2 = "INSERT INTO circular(num,date,title,rno) VALUES({},'{}','{}',{});".format(no,date,title,rno)
            cur.execute(q2)
            con.commit()
        else:
            print("error")
            return {"error":"already exists"}

        
        #generate qr 
        qr = circular_gen.gen_qr(rno,app.config['UPLOAD_FOLDER']+fname[:-4]+"_qr.jpg")
        circular_gen.add_qr(app.config['UPLOAD_FOLDER']+fname)
    
        # delete uploaded circular
        #os.remove(app.config['UPLOAD_FOLDER']+fname)

        return send_from_directory(app.config['UPLOAD_FOLDER'], fname[:-4]+'_output.pdf')

    return {"error":"file doesn't exist"}
       
@app.route("/test")
def test():
    return "works"

@app.route("/login")
def login():
    key = request.args.get("key",None)

    if(key == "key"): # password of instituion
        return {"value":True}
    print(key)
    return {"value":False}


@app.route("/decodeQR")
def decode():
    fname = request.args.get("fname",None)

    if(fname):
        #decode QR code
        value = qr_read.readpdf(app.config['UPLOAD_FOLDER']+fname)
        
        #delete the pdf 
        #os.remove(app.config['UPLOAD_FOLDER']+fname)

        return {"value":value}

    return {"value":None}

@app.route("/viewpdf")
def view():
    return send_from_directory(app.config['UPLOAD_FOLDER'], 'output.pdf')


if __name__ == "__main__":
    app.secret_key = 'super secret key'
    app.run(host = '0.0.0.0',port = 5080)
