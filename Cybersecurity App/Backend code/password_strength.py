import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.base import BaseEstimator, TransformerMixin
from xgboost import XGBClassifier
import re
import zxcvbn
import joblib
import mysql.connector
from datetime import datetime

app = Flask(__name__)

# MySQL database connection
db = mysql.connector.connect(
    host="sql12.freesqldatabase.com",
    user="xxxxxxx",
    password="xxxxxxx",
    database="xxxxxxx"
)
cursor = db.cursor()

class PasswordFeatureExtractor(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        features = []
        for password in X:
            length = len(password)
            uppercase = sum(1 for c in password if c.isupper())
            lowercase = sum(1 for c in password if c.islower())
            digits = sum(1 for c in password if c.isdigit())
            special = sum(1 for c in password if not c.isalnum())
            
            sequential = len(re.findall(r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz|012|123|234|345|456|567|678|789)', password.lower()))
            repeated = len(re.findall(r'(.)\1{2,}', password))
            
            zxcvbn_score = zxcvbn.zxcvbn(password)['score']
            
            char_set = set(password)
            entropy = len(password) * np.log2(len(char_set)) if char_set else 0
            
            features.append([length, uppercase, lowercase, digits, special, sequential, repeated, zxcvbn_score, entropy])
        return np.array(features)

# Load the trained model
model = joblib.load('password_strength_model.joblib')

@app.route('/predict', methods=['POST'])
def predict():
    password = request.json['password']
    prediction = model.predict([password])[0]
    strength_map = {0: 'Weak', 1: 'Medium', 2: 'Strong'}
    result = strength_map[prediction]
    
    # Store the prediction in the database
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    query = "INSERT INTO password_strength_predictions (password, strength, created_at) VALUES (%s, %s, %s)"
    values = (password, result, current_time)
    cursor.execute(query, values)
    db.commit()
    
    return jsonify({'strength': result})

@app.route('/password_strength/history', methods=['GET'])
def get_password_strength_history():
    query = "SELECT password, strength, created_at FROM password_strength_predictions ORDER BY created_at DESC"
    cursor.execute(query)
    predictions = cursor.fetchall()
    predictions_list = []
    for prediction in predictions:
        prediction_data = {
            'password': prediction[0],
            'strength': prediction[1],
            'created_at': prediction[2].strftime("%Y-%m-%d %H:%M:%S")
        }
        predictions_list.append(prediction_data)
    return jsonify(predictions_list)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000, debug=False)