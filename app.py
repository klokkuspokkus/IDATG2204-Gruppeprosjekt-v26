from flask import Flask, render_template, request, jsonify
import mysql.connector
import os
from datetime import datetime, date

app = Flask(__name__)

DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'host.docker.internal'),
    'port': int(os.environ.get('DB_PORT', 3306)),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': os.environ.get('DB_NAME', 'idatg2204_prosjekt'),
    'charset': 'utf8mb4'
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

def execute_query(sql, params=None):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(sql, params or ())
        results = cursor.fetchall()
        for row in results:
            for k, v in row.items():
                if isinstance(v, (datetime, date)):
                    row[k] = str(v)
                elif hasattr(v, 'total_seconds'):  # timedelta
                    row[k] = str(v)
        return results, None
    except Exception as e:
        return None, str(e)
    finally:
        cursor.close()
        conn.close()

# ── Queries ───────────────────────────────────────────────────────────────────

QUERIES = {
    "q1": {
        "title": "Unresolved incidents older than N days – grouped by building",
        "description": "Lists all unresolved incidents (not resolved/closed) older than a given number of days, grouped by building.",
        "params": [
            {"name": "days", "label": "Number of days", "type": "number", "default": 1}
        ],
        "sql": """
            SELECT building.name AS building_name,
                   COUNT(incident.id) AS unresolved_count
            FROM incident
            INNER JOIN incident_location ON incident.id = incident_location.incident_id
            INNER JOIN building ON incident_location.building_id = building.id
            WHERE incident.status NOT IN ('resolved', 'closed')
              AND incident.reported_at < NOW() - INTERVAL %s DAY
            GROUP BY incident_location.building_id, building.name
        """,
        "param_order": ["days"]
    },
    "q2": {
        "title": "Maintenance workload per technician for a given week",
        "description": "Shows estimated and actual hours per technician for the 7-day period starting on the given date.",
        "params": [
            {"name": "start_date", "label": "Start date (Monday)", "type": "date", "default": "2026-04-14"}
        ],
        "sql": """
            SELECT technician.tech_id AS tech_id,
                   user.name AS tech_name,
                   SUM(TIME_TO_SEC(mt.estimated_duration) / 3600) AS estimated_hours,
                   SUM(TIMESTAMPDIFF(SECOND, mt.start_time, mt.end_time) / 3600) AS actual_hours_completed
            FROM technician
            INNER JOIN user ON technician.tech_id = user.id
            INNER JOIN technician_work tw ON technician.tech_id = tw.tech_id
            INNER JOIN maintenance_task mt ON tw.task_id = mt.id
            WHERE mt.start_time BETWEEN %s AND DATE_ADD(%s, INTERVAL 6 DAY)
              AND mt.start_time IS NOT NULL
            GROUP BY user.name, technician.tech_id
            ORDER BY estimated_hours DESC
        """,
        "param_order": ["start_date", "start_date"]
    },
    "q3": {
        "title": "Incidents that required multiple maintenance tasks",
        "description": "Retrieves all incident IDs that have more than one distinct maintenance task linked to them.",
        "params": [],
        "sql": """
            SELECT incident.id AS incident_id,
                   incident.category,
                   incident.status,
                   incident.description,
                   COUNT(DISTINCT maintenance_task.id) AS task_count
            FROM incident
            INNER JOIN maintenance_task ON incident.id = maintenance_task.incident_id
            GROUP BY incident.id, incident.category, incident.status, incident.description
            HAVING COUNT(DISTINCT maintenance_task.id) > 1
            ORDER BY task_count DESC
        """,
        "param_order": []
    },
    "q4": {
        "title": "Average resolution time per incident category",
        "description": "Shows average time from report to the resolved/closed status entry per category, using incident_history.",
        "params": [],
        "sql": """
            SELECT incident.category,
                   SEC_TO_TIME(AVG(TIMESTAMPDIFF(SECOND, incident.reported_at, incident_history.time_to))) AS average_resolution_time,
                   COUNT(*) AS amount_in_category
            FROM incident
            INNER JOIN incident_history ON incident.id = incident_history.incident_id
            WHERE incident_history.status_type IN ('closed', 'resolved')
            GROUP BY incident.category
            ORDER BY average_resolution_time ASC
        """,
        "param_order": []
    },
    "q5": {
        "title": "Resources that are over-utilized within a given time period",
        "description": "Finds resources used on more than one task within the selected date range, indicating over-utilization.",
        "params": [
            {"name": "start_date", "label": "Start date", "type": "date", "default": "2026-04-01"},
            {"name": "end_date",   "label": "End date",   "type": "date", "default": "2026-04-30"}
        ],
        "sql": """
            SELECT r.id AS resource_id,
                   r.type AS resource_type,
                   r.description AS resource_desc,
                   b.name AS building,
                   COUNT(ru.task_id) AS usage_count,
                   GROUP_CONCAT(ru.task_id ORDER BY ru.task_id SEPARATOR ', ') AS task_ids
            FROM resource_usage ru
            INNER JOIN resource r ON ru.resource_id = r.id
            INNER JOIN building b ON r.building_id = b.id
            WHERE ru.start_usage_time BETWEEN %s AND %s
            GROUP BY r.id, r.type, r.description, b.name
            HAVING COUNT(ru.task_id) > 1
            ORDER BY usage_count DESC
        """,
        "param_order": ["start_date", "end_date"]
    },
    "q6": {
        "title": "Incidents reopened after being marked as resolved",
        "description": "Shows incidents that were resolved but later had a new reported/verified/assigned entry in their history.",
        "params": [],
        "sql": """
            SELECT DISTINCT incident.id AS incident_id,
                   incident.description,
                   incident.category,
                   incident.status AS current_status,
                   MIN(ih1.time_from) AS first_resolved,
                   MIN(ih2.time_from) AS reopened_at
            FROM incident
            INNER JOIN incident_history ih1
                ON incident.id = ih1.incident_id
                AND ih1.status_type = 'resolved'
            INNER JOIN incident_history ih2
                ON incident.id = ih2.incident_id
                AND ih2.status_type IN ('reported', 'verified', 'assigned')
                AND ih2.time_from > ih1.time_from
            GROUP BY incident.id, incident.description, incident.category, incident.status
            ORDER BY reopened_at
        """,
        "param_order": []
    },
    "q7": {
        "title": "Technicians and total hours worked per week",
        "description": "Shows total scheduled availability hours per technician, based on the availability table.",
        "params": [],
        "sql": """
            SELECT technician.tech_id,
                   user.name AS technician_name,
                   technician.role,
                   SUM(TIMESTAMPDIFF(SECOND, availability.start_time, availability.end_time) / 3600) AS scheduled_hours
            FROM technician
            INNER JOIN availability ON technician.tech_id = availability.tech_id
            INNER JOIN user ON technician.tech_id = user.id
            GROUP BY technician.tech_id, user.name, technician.role
            ORDER BY scheduled_hours DESC
        """,
        "param_order": []
    },
    "q8": {
        "title": "All incidents reported by a specific user",
        "description": "Retrieves all incidents reported by users matching the given name or email (partial match).",
        "params": [
            {"name": "name",  "label": "Name (partial)",  "type": "text", "default": "Nicolai"},
            {"name": "email", "label": "Email (partial)", "type": "text", "default": ""}
        ],
        "sql": """
            SELECT incident.*,
                   user.name AS reporter_name,
                   user.email AS reporter_email
            FROM incident
            INNER JOIN user ON user.id = incident.user_id
            WHERE user.name LIKE %s
               OR user.email LIKE %s
            ORDER BY incident.reported_at DESC
        """,
        "param_order": ["name", "email"]
    },
    "q9": {
        "title": "Task assignments that overlap in time for the same technician",
        "description": "Finds pairs of tasks assigned to the same technician whose time windows overlap.",
        "params": [],
        "sql": """
            SELECT user.name AS technician,
                   tw1.tech_id,
                   mt1.id AS task1_id,
                   mt1.start_time AS t1_start,
                   mt1.end_time AS t1_end,
                   mt1.type AS t1_type,
                   mt2.id AS task2_id,
                   mt2.start_time AS t2_start,
                   mt2.end_time AS t2_end,
                   mt2.type AS t2_type
            FROM technician_work tw1
            INNER JOIN technician_work tw2
                ON tw1.tech_id = tw2.tech_id
                AND tw1.task_id < tw2.task_id
            INNER JOIN maintenance_task mt1 ON mt1.id = tw1.task_id
            INNER JOIN maintenance_task mt2 ON mt2.id = tw2.task_id
            INNER JOIN technician ON tw1.tech_id = technician.tech_id
            INNER JOIN user ON technician.tech_id = user.id
            WHERE mt1.start_time < mt2.end_time
              AND mt2.start_time < mt1.end_time
              AND mt1.start_time IS NOT NULL
              AND mt2.start_time IS NOT NULL
            ORDER BY user.name, mt1.start_time
        """,
        "param_order": []
    },
    "q10": {
        "title": "Incidents and tasks for a specific building within a date range",
        "description": "Shows incident count per building within the given date range.",
        "params": [
            {"name": "start_date", "label": "Start date", "type": "date", "default": "2026-04-01"},
            {"name": "end_date",   "label": "End date",   "type": "date", "default": "2026-04-30"}
        ],
        "sql": """
            SELECT building.name AS building_name,
                   COUNT(*) AS number_of_incidents
            FROM incident
            INNER JOIN incident_location ON incident.id = incident_location.incident_id
            INNER JOIN building ON building.id = incident_location.building_id
            WHERE incident.reported_at > %s
              AND incident.reported_at < %s
            GROUP BY building.id, building.name
            ORDER BY number_of_incidents DESC
        """,
        "param_order": ["start_date", "end_date"]
    }
}

@app.route('/')
def index():
    return render_template('index.html', queries=QUERIES)

@app.route('/api/run/<query_id>', methods=['POST'])
def run_query(query_id):
    if query_id not in QUERIES:
        return jsonify({"error": "Unknown query"}), 404
    q = QUERIES[query_id]
    data = request.json or {}
    params = [data.get(p) for p in q["param_order"]]
    # Wrap wildcard params for LIKE queries (q8)
    if query_id == "q8":
        params = [f"%{v}%" if v else "%%" for v in params]
    results, error = execute_query(q["sql"], params)
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"results": results, "count": len(results)})

@app.route('/api/custom', methods=['POST'])
def custom_query():
    data = request.json or {}
    sql = data.get('sql', '').strip()
    if not sql:
        return jsonify({"error": "No SQL provided"}), 400
    if not sql.upper().startswith('SELECT'):
        return jsonify({"error": "Only SELECT queries are allowed"}), 403
    results, error = execute_query(sql)
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"results": results, "count": len(results)})

@app.route('/api/health')
def health():
    try:
        conn = get_db()
        conn.close()
        return jsonify({"status": "ok", "db": "connected"})
    except Exception as e:
        return jsonify({"status": "error", "db": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
