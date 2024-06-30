from flask import Flask, request, jsonify
import pandas as pd
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
    pool_size=3,  # Reduced pool size
    **db_config
)

# Load the data for illicit video URLs
illicit_video_urls = pd.read_csv('illicit_video.csv')['MovieURL'].tolist()

@app.route('/illicit_video/predict_url', methods=['POST'])
def predict_illicit_video_url():
    url = request.form['url']
    result = 'Illicit Video URL' if url in illicit_video_urls else 'Safe URL'

    # Store the prediction in the database
    try:
        connection = connection_pool.get_connection()
        cursor = connection.cursor()
        query = "INSERT INTO illicit_video_url_predictions (url, result, created_at) VALUES (%s, %s, %s)"
        values = (url, result, datetime.now())
        cursor.execute(query, values)
        connection.commit()
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        cursor.close()
        connection.close()
        print("Connection closed after predict_url")

    return result

@app.route('/illicit_video/history', methods=['GET'])
def get_illicit_video_url_history():
    try:
        connection = connection_pool.get_connection()
        cursor = connection.cursor(dictionary=True)
        query = "SELECT url, result, created_at FROM illicit_video_url_predictions ORDER BY created_at DESC LIMIT 50"
        cursor.execute(query)
        history = cursor.fetchall()
        for item in history:
            item['created_at'] = item['created_at'].strftime("%Y-%m-%d %H:%M:%S")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return jsonify([])
    finally:
        cursor.close()
        connection.close()
        print("Connection closed after get_illicit_video_url_history")

    return jsonify(history)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10004, debug=False)
