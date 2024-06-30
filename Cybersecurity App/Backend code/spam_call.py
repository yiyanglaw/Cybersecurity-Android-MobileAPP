from flask import Flask, request, jsonify
import mysql.connector
from datetime import datetime
import pandas as pd

app = Flask(__name__)

# MySQL database connection
db = mysql.connector.connect(
    host="sql12.freesqldatabase.com",
    user="xxxxxxx",
    password="xxxxxxx",
    database="xxxxxxx"
)
cursor = db.cursor()

# Load the data for spam call numbers
spam_call_numbers = pd.read_csv('spam_call.csv')['Phone Number'].tolist()

@app.route('/spam_call/predict', methods=['POST'])
def predict_spam_call():
    phone_number = request.form['phone_number']
    if phone_number in spam_call_numbers:
        result = 'Spam Call'
    else:
        result = 'Safe Number'
    
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    query = "INSERT INTO spam_call_predictions (phone_number, result, created_at) VALUES (%s, %s, %s)"
    values = (phone_number, result, current_time)
    cursor.execute(query, values)
    db.commit()

    return result

@app.route('/spam_call/history', methods=['GET'])
def get_spam_call_history():
    query = "SELECT phone_number, result, created_at FROM spam_call_predictions ORDER BY created_at DESC"
    cursor.execute(query)
    predictions = cursor.fetchall()
    predictions_list = []
    for prediction in predictions:
        prediction_data = {
            'phone_number': prediction[0],
            'result': prediction[1],
            'created_at': prediction[2].strftime("%Y-%m-%d %H:%M:%S")
        }
        predictions_list.append(prediction_data)
    return jsonify(predictions_list)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000, debug=False)
