
from flask import Flask, request, jsonify
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

@app.route('/report', methods=['POST'])
def submit_report():
    spam_emails = request.form['spam_emails']
    spam_sms = request.form['spam_sms']
    spam_calls = request.form['spam_calls']
    malicious_urls = request.form['malicious_urls']
    phishing_urls = request.form['phishing_urls']
    illicit_video_urls = request.form['illicit_video_urls']

    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    query = "INSERT INTO reports (spam_emails, spam_sms, spam_calls, malicious_urls, phishing_urls, illicit_video_urls, created_at) VALUES (%s, %s, %s, %s, %s, %s, %s)"
    values = (spam_emails, spam_sms, spam_calls, malicious_urls, phishing_urls, illicit_video_urls, current_time)
    cursor.execute(query, values)
    db.commit()

    return 'Report submitted successfully'

@app.route('/reports/<report_type>', methods=['GET'])
def get_reports(report_type):
    query = f"SELECT {report_type}, created_at FROM reports WHERE {report_type} IS NOT NULL AND {report_type} != ''"
    cursor.execute(query)
    reports = cursor.fetchall()

    reports_list = []
    for report in reports:
        report_data = {
            'value': report[0],
            'created_at': report[1].strftime("%Y-%m-%d %H:%M:%S")
        }
        reports_list.append(report_data)

    return jsonify(reports_list)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
