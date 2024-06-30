# phishing_url.py

from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.pipeline import Pipeline
from sklearn.metrics import accuracy_score, f1_score
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.linear_model import SGDClassifier
import re
import mysql.connector
from mysql.connector import pooling
from datetime import datetime

app = Flask(__name__)

# Database configuration
db_config = {
    host="sql12.freesqldatabase.com",
    user="xxxxxxx",
    password="xxxxxxx",
    database="xxxxxxx"
}

connection_pool = mysql.connector.pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=5,
    **db_config
)

# Load the data for training
try:
    data = pd.read_csv('phishing2.csv')
    data.columns = ['url', 'label']
    data['label'] = data['label'].apply(lambda x: 1 if x == 'bad' else 0)

    # Preprocess the data
    X = data['url'].values
    y = data['label'].values

    # Split the data into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Define a custom transformer to convert URLs to character-level n-gram representations
    class URLToNgram(BaseEstimator, TransformerMixin):
        def __init__(self, ngram_range=(2, 3)):
            self.ngram_range = ngram_range
            self.vectorizer = CountVectorizer(analyzer='char', ngram_range=ngram_range)

        def fit(self, X, y=None):
            self.vectorizer.fit(X)
            return self

        def transform(self, X, y=None):
            return self.vectorizer.transform(X)

    # Define a pipeline for training the model
    pipeline = Pipeline([
        ('url_to_ngram', URLToNgram()),
        ('tfidf', TfidfTransformer()),
        ('clf', SGDClassifier(loss='log_loss', alpha=1e-5, penalty='elasticnet', max_iter=100))
    ])

    # Train the model
    pipeline.fit(X_train, y_train)

    # Make predictions on the test set
    y_pred = pipeline.predict(X_test)

    # Calculate accuracy and F1 score
    accuracy = accuracy_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)

    # Display the results
    print(f'Accuracy: {accuracy:.4f}')
    print(f'F1 Score: {f1:.4f}')

except Exception as e:
    print(f"Error during model training: {e}")
    # You might want to exit the script here or set up a flag to indicate the model isn't ready

# Function to preprocess URLs
def preprocess_url(url):
    # Remove common prefixes like "http://", "https://", and "www."
    url = re.sub(r'^https?://|www.', '', url)
    return url

@app.route('/phishing/predict_url', methods=['POST'])
def predict_phishing_url():
    try:
        url = request.form['url']
        url = preprocess_url(url)
        prediction = pipeline.predict([url])[0]
        result = 'Phishing URL' if prediction == 1 else 'Safe URL'

        # Store the prediction in the database
        connection = connection_pool.get_connection()
        cursor = connection.cursor()
        try:
            query = "INSERT INTO phishing_url_predictions (url, result, created_at) VALUES (%s, %s, %s)"
            values = (url, result, datetime.now())
            cursor.execute(query, values)
            connection.commit()
        except mysql.connector.Error as err:
            print(f"Database error: {err}")
        finally:
            cursor.close()
            connection.close()

        return jsonify({"result": result}), 200
    except Exception as e:
        print(f"Error in prediction: {e}")
        return jsonify({"error": "An error occurred during prediction"}), 500

@app.route('/phishing/history', methods=['GET'])
def get_phishing_url_history():
    try:
        connection = connection_pool.get_connection()
        cursor = connection.cursor(dictionary=True)
        try:
            query = "SELECT url, result, created_at FROM phishing_url_predictions ORDER BY created_at DESC LIMIT 50"
            cursor.execute(query)
            history = cursor.fetchall()
            for item in history:
                item['created_at'] = item['created_at'].strftime("%Y-%m-%d %H:%M:%S")
            return jsonify(history), 200
        except mysql.connector.Error as err:
            print(f"Database error: {err}")
            return jsonify({"error": "An error occurred while fetching history"}), 500
        finally:
            cursor.close()
            connection.close()
    except Exception as e:
        print(f"Error in getting history: {e}")
        return jsonify({"error": "An error occurred while processing the request"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10002, debug=False)
