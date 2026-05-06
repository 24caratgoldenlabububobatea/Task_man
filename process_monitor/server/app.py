from flask import Flask, request, render_template, redirect, jsonify
import mysql.connector
import threading
import time

app = Flask(__name__)

def get_db():
    return mysql.connector.connect(
        host="172.20.128.29",
        user="Jonathan",
        password="amongusishot34",
        database="cpu_p",
        auth_plugin="mysql_native_password"
    )

@app.route("/")
def index():
    return redirect("/dashboard")

@app.route("/cpu", methods=["POST"])
def cpu():
    data = request.json

    if not data:
        return jsonify({"status": "error", "message": "No JSON received"}), 400

    client_id = data.get("client_id")
    cpu_usage = data.get("cpu_usage")

    if client_id is None or cpu_usage is None:
        return jsonify({"status": "error", "message": "Missing data"}), 400

    db = get_db()
    cursor = db.cursor()

    try:
        # Insert user or update last_seen
        cursor.execute(
            """
            INSERT INTO users (client_id)
            VALUES (%s)
            ON DUPLICATE KEY UPDATE last_seen = NOW()
            """,
            (client_id,)
        )

        # Get user id
        cursor.execute(
            "SELECT id FROM users WHERE client_id=%s",
            (client_id,)
        )

        result = cursor.fetchone()

        if not result:
            return jsonify({"status": "error", "message": "User lookup failed"})

        user_id = result[0]

        # Insert CPU metric
        cursor.execute(
            """
            INSERT INTO cpu_metrics (user_id, cpu_usage)
            VALUES (%s, %s)
            """,
            (user_id, cpu_usage)
        )

        db.commit()

        return jsonify({"status": "ok"})

    except Exception as e:
        db.rollback()
        return jsonify({"status": "error", "message": str(e)})

    finally:
        cursor.close()
        db.close()


# -----------------------------
# Dashboard
# -----------------------------
@app.route("/dashboard")
def dashboard():
    db = get_db()
    cursor = db.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id, client_id FROM users")
        users = cursor.fetchall()

        chart_data = []

        for user in users:
            cursor.execute(
                """
                SELECT timestamp, cpu_usage
                FROM cpu_metrics
                WHERE user_id=%s
                ORDER BY timestamp
                """,
                (user["id"],)
            )

            metrics = cursor.fetchall()

            chart_data.append({
                "client_id": user["client_id"],
                "timestamps": [str(m["timestamp"]) for m in metrics],
                "cpu_usage_values": [float(m["cpu_usage"]) for m in metrics]
            })

        return render_template("dashboard.html", chart_data=chart_data)

    except Exception as e:
        return f"Dashboard error: {str(e)}"

    finally:
        cursor.close()
        db.close()


# -----------------------------
# Cleanup inactive users
# -----------------------------
def cleanup():
    while True:
        try:
            db = get_db()
            cursor = db.cursor()

            cursor.execute(
                """
                DELETE FROM users
                WHERE last_seen < NOW() - INTERVAL 10 MINUTE
                """
            )

            db.commit()

            cursor.close()
            db.close()

        except Exception as e:
            print("Cleanup error:", e)

        time.sleep(67)


# Start cleanup thread
threading.Thread(target=cleanup, daemon=True).start()


# -----------------------------
# Run server
# -----------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)