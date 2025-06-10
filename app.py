from flask import Flask, render_template, jsonify
import speedtest
import threading
import time

app = Flask(__name__)

# Global variable to store results and status
# Make sure to initialize it with 'N/A' or default values
# and a clear starting status.
test_results = {
    'download': 'N/A',
    'upload': 'N/A',
    'ping': 'N/A',
    'status': 'Ready to start test',
    'is_testing': False # New flag to indicate if a test is currently running
}

def run_speedtest_in_background():
    global test_results
    test_results['is_testing'] = True
    test_results['status'] = 'Locating best servers...'
    test_results['download'] = '...'
    test_results['upload'] = '...'
    test_results['ping'] = '...'

    # Add a small delay to make "Locating best servers..." visible
    time.sleep(1)

    s = speedtest.Speedtest()
    try:
        test_results['status'] = 'Finding best download server...'
        s.get_best_server()

        test_results['status'] = 'Performing download test...'
        download_result = s.download()
        test_results['download'] = f"{download_result/1024/1024:.2f}"

        test_results['status'] = 'Performing upload test...'
        upload_result = s.upload()
        test_results['upload'] = f"{upload_result/1024/1024:.2f}"

        test_results['status'] = 'Performing ping test...'
        ping_result = s.results.ping
        test_results['ping'] = f"{ping_result:.2f}"

        test_results['status'] = 'Test complete!'
    except speedtest.SpeedtestException as e:
        test_results['status'] = f"Error during test: {e}"
        test_results['download'] = 'Error'
        test_results['upload'] = 'Error'
        test_results['ping'] = 'Error'
    except Exception as e:
        test_results['status'] = f"An unexpected error occurred: {e}"
        test_results['download'] = 'Error'
        test_results['upload'] = 'Error'
        test_results['ping'] = 'Error'
    finally:
        # Ensure is_testing is set to False after test, even if it fails
        test_results['is_testing'] = False

@app.route('/')
def index():
    # Pass the initial test_results to the template
    return render_template('index.html', results=test_results)

@app.route('/run_test', methods=['POST']) # Change to POST as it modifies state
def run_test():
    global test_results
    # Only start a new test if one isn't already running
    if not test_results['is_testing']:
        # Reset results and status for a new test
        test_results = {
            'download': 'N/A',
            'upload': 'N/A',
            'ping': 'N/A',
            'status': 'Starting test...',
            'is_testing': True # Set to True immediately
        }
        thread = threading.Thread(target=run_speedtest_in_background)
        thread.start()
        return jsonify(success=True, message="Speed test started."), 202 # 202 Accepted
    else:
        return jsonify(success=False, message="Test already in progress."), 409 # 409 Conflict

@app.route('/status')
def get_status():
    global test_results
    return jsonify(test_results)


if __name__ == '__main__':
    app.run(debug=True)