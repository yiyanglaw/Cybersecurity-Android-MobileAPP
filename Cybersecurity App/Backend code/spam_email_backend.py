from flask import Flask, request, jsonify
import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.metrics import accuracy_score, f1_score
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
import re
import mysql.connector
from mysql.connector import pooling
from datetime import datetime
import time

app = Flask(__name__)

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

def get_db_connection():
    return connection_pool.get_connection()

nltk.download('stopwords')
nltk.download('punkt')
nltk.download('wordnet')

data = pd.read_csv('email_s.csv')
data['Message'] = data['Message'].fillna('')
data['Spam'] = data['Category'].apply(lambda x: 1 if x == 'spam' else 0)
X_train, X_test, y_train, y_test = train_test_split(data.Message, data.Spam, test_size=0.25)

lemmatizer = WordNetLemmatizer()

def preprocess_text(text):
    text = re.sub(r'\b\w{1,2}\b', '', text)
    text = re.sub(r'\d+', '', text)
    text = re.sub(r'\s+', ' ', text)
    text = text.lower()
    words = word_tokenize(text)
    words = [lemmatizer.lemmatize(word) for word in words if word not in stopwords.words('english')]
    return ' '.join(words)

data['Message'] = data['Message'].apply(preprocess_text)

pipeline = Pipeline([
    ('vectorizer', TfidfVectorizer()),
    ('nb', MultinomialNB())
])

parameters = {
    'vectorizer__ngram_range': [(1, 1), (1, 2)],
    'vectorizer__max_df': [0.75, 0.85, 1.0],
    'nb__alpha': [0.1, 0.5, 1.0]
}

grid_search = GridSearchCV(pipeline, parameters, cv=5, scoring='f1')
grid_search.fit(X_train, y_train)

best_model = grid_search.best_estimator_
y_pred = best_model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)

print(f'Accuracy: {accuracy:.4f}')
print(f'F1 Score: {f1:.4f}')

def execute_db_operation(operation):
    max_retries = 3
    retry_delay = 1

    for attempt in range(max_retries):
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
            if 'connection' in locals() and connection.is_connected():
                cursor.close()
                connection.close()

@app.route('/email/predict_spam', methods=['POST'])
def predict_spam_email():
    text = request.form['text']
    processed_text = preprocess_text(text)
    prediction = best_model.predict([processed_text])[0]
    result = 'Spam' if prediction == 1 else 'Ham (Not Spam)'
    
    def insert_prediction(cursor):
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        query = "INSERT INTO email_spam_predictions (text, result, created_at) VALUES (%s, %s, %s)"
        values = (text[:255], result, current_time)
        cursor.execute(query, values)

    execute_db_operation(insert_prediction)
    
    return result

@app.route('/email/history', methods=['GET'])
def get_email_spam_history():
    def fetch_history(cursor):
        query = "SELECT text, result, created_at FROM email_spam_predictions ORDER BY created_at DESC LIMIT 50"
        cursor.execute(query)
        return cursor.fetchall()

    predictions = execute_db_operation(fetch_history)
    predictions_list = [
        {
            'text': prediction[0],
            'result': prediction[1],
            'created_at': prediction[2].strftime("%Y-%m-%d %H:%M:%S")
        }
        for prediction in predictions
    ]
    return jsonify(predictions_list)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10001, debug=False)
