import json
from flask import Flask, jsonify, request
from numpy import single
app = Flask(__name__)
from codemix import *
from flask_cors import CORS, cross_origin

@app.route('/', methods=["GET"])
def Welcome():
    # return "Welcome to CodeMix Generator!!"
    s1 = "Hello world"
    return s1

@app.route('/generate', methods=["POST"])
def generateCodeMix():
    #it takes the input in json format basically convert it to dictionary
    dt = request.data
    inp = json.loads(dt)

    output = []
    status = 201
    message = None
    try:
        if inp == None:
            raise Exception("No Input given")
        #loop the input which is a list of source and target lines and give each src and target to the python function
        src = inp['src']
        target = inp['target']
        outputText = generateCmg(src, target)
        output = outputText
       
    except Exception as e:
        message = str(e)
        status = 503

    result = {"output": output, "status": status, "message": message}
    return result , status

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=3000)
    app.config['CORS_HEADERS'] = 'Content-Type'
    cors = CORS(app)