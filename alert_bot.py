import os
import sys
import requests

def load_webhook_url():
    url = os.environ.get("DISCORD_WEBHOOK_URL")
    if url:
        return url
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("DISCORD_WEBHOOK_URL="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    return None

WEBHOOK_URL = load_webhook_url()

def send_alert(message):
    if not WEBHOOK_URL:
        print("Error: DISCORD_WEBHOOK_URL not found in environment or .env file.")
        sys.exit(1)
    payload = {
        "username": "AWS Health Monitor",
        "content": f"🚨 **SERVER ALERT** 🚨\n{message}"
    }
    response = requests.post(WEBHOOK_URL, json=payload, timeout=10)
    if response.status_code == 204:
        print("Alert sent to Discord successfully.")
    else:
        print(f"Failed to send alert. Status code: {response.status_code}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        alert_msg = " ".join(sys.argv[1:])
        send_alert(alert_msg)
    else:
        print("Usage: python3 alert_bot.py <message>")
