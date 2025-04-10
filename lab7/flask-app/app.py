from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)

client = MongoClient("mongodb://db:27017/")
db = client["test"]
users_collection = db["users"]

@app.route('/users', methods=['GET'])
def get_users():
    users = []
    for user in users_collection.find():
        # Convert ObjectId to string for JSON serialization
        user['_id'] = str(user['_id'])
        users.append(user)

    return jsonify(users)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3003)
