Python
from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

MAGIC_HEADER_URL = "https://magic-server-802314573716.europe-north1.run.app/magic-code"
FINAL_ANSWER_URL = "https://final-answer-802314573716.europe-north1.run.app/final-answer"

@app.route('/magic-header', methods=['GET'])
def get_magic_header():
    try:
        # Call the external API to get the magic header value
        response = requests.get(MAGIC_HEADER_URL)
        response.raise_for_status()
        data = response.json()

        # Extract the required field
        use_this_header = data.get("useThisHeaderToAuthenticateTowardsTheFinalEndpoint")
        if not use_this_header:
            return jsonify({"error": "Field useThisHeaderToAuthenticateTowardsTheFinalEndpoint not found"}), 400

        return jsonify({"useThisHeaderToAuthenticateTowardsTheFinalEndpoint": use_this_header})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/final-answer', methods=['GET'])
def get_final_answer():
    try:
        # Retrieve the authentication token from the first endpoint
        magic_header_response = requests.get(MAGIC_HEADER_URL)
        magic_header_response.raise_for_status()
        magic_header_data = magic_header_response.json()

        token = magic_header_data.get("useThisHeaderToAuthenticateTowardsTheFinalEndpoint")
        if not token:
            return jsonify({"error": "Authentication token not found"}), 400

        # Call the final API with the Bearer token
        headers = {"Authorization": f"Bearer {token}"}
        final_answer_response = requests.get(FINAL_ANSWER_URL, headers=headers)
        final_answer_response.raise_for_status()
        final_answer_data = final_answer_response.json()

        # Extract the required field
        final_answer = final_answer_data.get("finalAnswer")
        if not final_answer:
            return jsonify({"error": "Field finalAnswer not found"}), 400

        return jsonify({"finalAnswer": final_answer})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)