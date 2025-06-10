from flask import Flask, render_template, jsonify
import speedtest
import threading
import time

app = Flask(__name__)

# Global variable to store results and status
test_results = {
    'download': 'N/A',
    'upload': 'N/A',
    'ping': 'N/A',
    'status': 'Ready to start test',
    'is_testing': False
}

def run_speedtest_in_background():
    global test_results
    test_results['is_testing'] = True
    test_results['status'] = 'Locating best servers...'
    test_results['download'] = '...'
    test_results['upload'] = '...'
    test_results['ping'] = '...'

    time.sleep(1) # Add a small delay to make "Locating best servers..." visible

    s = speedtest.Speedtest()
    try:
        test_results['status'] = 'Finding best download server...'
        s.get_best_server() # Essential for accurate results

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
        test_results['is_testing'] = False

@app.route('/')
def index():
    return render_template('index.html', results=test_results)

@app.route('/run_test', methods=['POST'])
def run_test():
    global test_results
    if not test_results['is_testing']:
        # Reset results and status for a new test
        test_results = {
            'download': 'N/A',
            'upload': 'N/A',
            'ping': 'N/A',
            'status': 'Starting test...',
            'is_testing': True
        }
        thread = threading.Thread(target=run_speedtest_in_background)
        thread.start()
        return jsonify(success=True, message="Speed test started."), 202
    else:
        return jsonify(success=False, message="Test already in progress."), 409

@app.route('/status')
def get_status():
    global test_results
    return jsonify(test_results)

# --- NEW ENDPOINT FOR RESET ---
@app.route('/reset', methods=['POST'])
def reset_results():
    global test_results
    # Reset to initial state
    test_results = {
        'download': 'N/A',
        'upload': 'N/A',
        'ping': 'N/A',
        'status': 'Ready to start test',
        'is_testing': False
    }
    return jsonify(success=True, message="Results reset successfully."), 200 # 200 OK
# --- END NEW ENDPOINT ---

if __name__ == '__main__':
    app.run(debug=True)