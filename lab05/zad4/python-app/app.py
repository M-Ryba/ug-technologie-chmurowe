from flask import Flask
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--port', type=int, default=3000, help='Port to run the app on')
args = parser.parse_args()
port = args.port

app = Flask(__name__)

@app.route('/')
def hello_world():
    return sys.version

app.run(host='0.0.0.0', port=port)
