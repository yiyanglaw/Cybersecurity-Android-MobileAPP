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
import time

app = Flask(__name__)

# Database configuration
db_config = {
    host="sql12.freesqldatabase.com",
    user="xxxxxxx",
    password="xxxxxxx",
    database="xxxxxxx"
}

# Create a connection pool
connection_pool = mysql.connector.pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=3,
    **db_config
)

def get_db_connection():
    try:
        return connection_pool.get_connection()
    except mysql.connector.errors.PoolError as e:
        print(f"Error getting connection from pool: {e}")
        time.sleep(1)  # wait before retrying
        return get_db_connection()

def execute_db_operation(operation):
    max_retries = 3
    retry_delay = 1
    for attempt in range(max_retries):
        connection = None
        try:
            connection = get_db_connection()
            cursor = connection.cursor()
            result = operation(cursor)
            connection.commit()
            return result
        except mysql.connector.Error as err:
            print(f"Database error: {err}")
            if attempt < max_retries - 1:
                time.sleep(retry_delay)
                retry_delay *= 2
            else:
                raise
        finally:
            if connection and connection.is_connected():
                cursor.close()
                connection.close()


# Load the data for training
data = pd.read_csv('m_data2.csv')
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

# Function to preprocess URLs
def preprocess_url(url):
    # Remove common prefixes like "http://", "https://", and "www."
    url = re.sub(r'^https?://|www.', '', url)
    return url

@app.route('/malicious/predict_url', methods=['POST'])
def predict_malicious_url():
    url = request.form['url']
    url = preprocess_url(url)
    prediction = pipeline.predict([url])[0]
    result = 'Malicious URL' if prediction == 1 else 'Safe URL'
    
    def insert_prediction(cursor):
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        query = "INSERT INTO malicious_url_predictions (url, result, created_at) VALUES (%s, %s, %s)"
        values = (url[:255], result, current_time)
        cursor.execute(query, values)
    
    execute_db_operation(insert_prediction)
    
    return result

@app.route('/malicious/history', methods=['GET'])
def get_malicious_url_history():
    def fetch_history(cursor):
        query = "SELECT url, result, created_at FROM malicious_url_predictions ORDER BY created_at DESC LIMIT 50"
        cursor.execute(query)
        return cursor.fetchall()
    
    predictions = execute_db_operation(fetch_history)
    predictions_list = [
        {
            'url': prediction[0],
            'result': prediction[1],
            'created_at': prediction[2].strftime("%Y-%m-%d %H:%M:%S")
        }
        for prediction in predictions
    ]
    return jsonify(predictions_list)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000, debug=False)
