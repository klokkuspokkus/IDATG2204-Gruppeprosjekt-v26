from flask import Flask, render_template, request, jsonify, session
from functools import wraps
import mysql.connector
import os
from datetime import datetime, date

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-prod')

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

def execute_query(sql, params=None, fetch=True):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(sql, params or ())
        if fetch:
            results = cursor.fetchall()
            for row in results:
                for k, v in row.items():
                    if isinstance(v, (datetime, date)):
                        row[k] = str(v)
                    elif hasattr(v, 'total_seconds'):
                        row[k] = str(v)
            return results, None
        else:
            conn.commit()
            return {"last_insert_id": cursor.lastrowid, "rows_affected": cursor.rowcount}, None
    except Exception as e:
        conn.rollback()
        return None, str(e)
    finally:
        cursor.close()
        conn.close()

def execute_write(sql, params=None):
    return execute_query(sql, params, fetch=False)

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({"error": "Login required"}), 401
        return f(*args, **kwargs)
    return decorated_function

def role_required(roles):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'role_name' not in session or session['role_name'] not in roles:
                return jsonify({"error": "Insufficient privileges"}), 403
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def get_current_user():
    if 'user_id' in session:
        return {
            "id": session['user_id'],
            "email": session['email'],
            "role_id": session['role_id'],
            "role_name": session['role_name']
        }
    return None

# ── Authentication ────────────────────────────────────────────────────────────

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json or {}
    email = data.get('email', '').strip()
    if not email:
        return jsonify({"error": "Email is required"}), 400
    
    results, error = execute_query(
        "SELECT u.id, u.name, u.email, u.role_id, r.name AS role_name "
        "FROM user u JOIN role r ON u.role_id = r.id WHERE u.email = %s",
        (email,)
    )
    if error:
        return jsonify({"error": error}), 500
    if not results:
        return jsonify({"error": "User not found"}), 404
    
    user = results[0]
    session['user_id'] = user['id']
    session['email'] = user['email']
    session['role_id'] = user['role_id']
    session['role_name'] = user['role_name']
    session['user_name'] = user['name']
    
    return jsonify({"message": "Login successful", "user": {
        "id": user['id'],
        "name": user['name'],
        "email": user['email'],
        "role_name": user['role_name']
    }})

@app.route('/api/logout', methods=['POST'])
@login_required
def logout():
    session.clear()
    return jsonify({"message": "Logged out"})

@app.route('/api/me')
def get_me():
    user = get_current_user()
    if not user:
        return jsonify({"user": None, "role_name": "public"})
    return jsonify({"user": user, "role_name": user['role_name']})

# ── Public Stats ───────────────────────────────────────────────────────────────

@app.route('/api/stats')
def public_stats():
    try:
        results, error = execute_query(
            "SELECT "
            "COUNT(*) AS total_incidents, "
            "SUM(CASE WHEN status NOT IN ('resolved', 'closed') THEN 1 ELSE 0 END) AS open_incidents, "
            "SUM(CASE WHEN status IN ('resolved', 'closed') THEN 1 ELSE 0 END) AS closed_incidents, "
            "SUM(CASE WHEN severity_level = 'Critical' THEN 1 ELSE 0 END) AS critical_count, "
            "SUM(CASE WHEN severity_level = 'High' THEN 1 ELSE 0 END) AS high_count "
            "FROM incident"
        )
        if error:
            return jsonify({"error": error, "stats": None}), 500
        return jsonify({"stats": results[0] if results else {}})
    except Exception as e:
        return jsonify({"error": str(e), "stats": None}), 500

# ── User Management ────────────────────────────────────────────────────────────

@app.route('/api/users', methods=['GET'])
@login_required
@role_required(['administrator'])
def list_users():
    results, error = execute_query(
        "SELECT u.id, u.name, u.email, u.role_id, r.name AS role_name "
        "FROM user u JOIN role r ON u.role_id = r.id ORDER BY u.id"
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"users": results})

@app.route('/api/users', methods=['POST'])
@login_required
@role_required(['administrator'])
def create_user():
    data = request.json or {}
    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    role_id = data.get('role_id')
    
    if not name or not email or not role_id:
        return jsonify({"error": "Name, email, and role_id are required"}), 400
    
    result, error = execute_write(
        "INSERT INTO user (name, email, role_id) VALUES (%s, %s, %s)",
        (name, email, role_id)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "User created", "id": result['last_insert_id']}), 201

@app.route('/api/users/<int:user_id>', methods=['PUT'])
@login_required
@role_required(['administrator'])
def update_user(user_id):
    data = request.json or {}
    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    role_id = data.get('role_id')
    
    updates = []
    params = []
    if name:
        updates.append("name = %s")
        params.append(name)
    if email:
        updates.append("email = %s")
        params.append(email)
    if role_id:
        updates.append("role_id = %s")
        params.append(role_id)
    
    if not updates:
        return jsonify({"error": "No fields to update"}), 400
    
    params.append(user_id)
    result, error = execute_write(
        f"UPDATE user SET {', '.join(updates)} WHERE id = %s",
        tuple(params)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "User updated"})

@app.route('/api/users/<int:user_id>', methods=['DELETE'])
@login_required
@role_required(['administrator'])
def delete_user(user_id):
    if user_id == session['user_id']:
        return jsonify({"error": "Cannot delete yourself"}), 400
    
    result, error = execute_write("DELETE FROM user WHERE id = %s", (user_id,))
    if error:
        if "1451" in error or "foreign key constraint" in error.lower():
            return jsonify({"error": "Cannot delete user: user is linked to existing technician records and/or has reported incidents"}), 409
        return jsonify({"error": error}), 500
    return jsonify({"message": "User deleted"})

# ── Incidents ─────────────────────────────────────────────────────────────────

@app.route('/api/incidents', methods=['GET'])
@login_required
def list_incidents():
    role = session.get('role_name')
    user_id = session.get('user_id')
    
    if role in ['student', 'staff', 'public_user']:
        results, error = execute_query(
            "SELECT i.id, i.reported_at, i.severity_level, i.description, i.category, i.status, "
            "b.name AS building_name, il.floor_nr, il.room_nr "
            "FROM user_incidents_view i "
            "LEFT JOIN incident_location il ON i.id = il.incident_id "
            "LEFT JOIN building b ON il.building_id = b.id "
            "WHERE i.user_id = %s ORDER BY i.reported_at DESC",
            (user_id,)
        )
    elif role == 'technician':
        results, error = execute_query(
            "SELECT DISTINCT i.id, i.reported_at, i.severity_level, i.description, i.category, i.status, "
            "b.name AS building_name "
            "FROM incident i "
            "INNER JOIN maintenance_task mt ON mt.incident_id = i.id "
            "INNER JOIN technician_work tw ON mt.id = tw.task_id "
            "LEFT JOIN incident_location il ON i.id = il.incident_id "
            "LEFT JOIN building b ON il.building_id = b.id "
            "WHERE tw.tech_id = %s "
            "ORDER BY i.reported_at DESC",
            (user_id,)
        )
    else:
        results, error = execute_query(
            "SELECT i.id, i.reported_at, i.severity_level, i.description, i.category, i.status, "
            "b.name AS building_name, u.name AS reporter_name, u.email AS reporter_email "
            "FROM incident i "
            "LEFT JOIN incident_location il ON i.id = il.incident_id "
            "LEFT JOIN building b ON il.building_id = b.id "
            "LEFT JOIN user u ON i.user_id = u.id "
            "ORDER BY i.reported_at DESC"
        )
    
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"incidents": results})

@app.route('/api/incidents/<int:incident_id>', methods=['GET'])
@login_required
def get_incident(incident_id):
    results, error = execute_query(
        "SELECT i.*, b.name AS building_name, b.id AS building_id, il.floor_nr, il.room_nr, "
        "u.name AS reporter_name, u.email AS reporter_email "
        "FROM incident i "
        "LEFT JOIN incident_location il ON i.id = il.incident_id "
        "LEFT JOIN building b ON il.building_id = b.id "
        "LEFT JOIN user u ON i.user_id = u.id "
        "WHERE i.id = %s",
        (incident_id,)
    )
    if error:
        return jsonify({"error": error}), 500
    if not results:
        return jsonify({"error": "Incident not found"}), 404
    
    incident = results[0]
    role = session.get('role_name')
    
    if role in ['student', 'staff', 'public_user'] and incident['user_id'] != session.get('user_id'):
        return jsonify({"error": "Access denied"}), 403
    
    history, _ = execute_query(
        "SELECT * FROM incident_history WHERE incident_id = %s ORDER BY time_from",
        (incident_id,)
    )
    incident['history'] = history or []
    
    tasks, _ = execute_query(
        "SELECT mt.*, u.name AS tech_name FROM maintenance_task mt "
        "LEFT JOIN technician_work tw ON mt.id = tw.task_id "
        "LEFT JOIN user u ON tw.tech_id = u.id "
        "WHERE mt.incident_id = %s",
        (incident_id,)
    )
    incident['tasks'] = tasks or []
    
    return jsonify({"incident": incident})

@app.route('/api/incidents', methods=['POST'])
def create_incident():
    data = request.json or {}
    description = data.get('description', '').strip()
    category = data.get('category', '').strip()
    severity_level = data.get('severity_level', 'Medium')
    building_id = data.get('building_id')
    floor_nr = data.get('floor_nr')
    room_nr = data.get('room_nr')
    reporter_email = data.get('reporter_email', '').strip()
    
    if not description or not category:
        return jsonify({"error": "Description and category are required"}), 400
    
    if not building_id:
        return jsonify({"error": "Building is required"}), 400
    
    if floor_nr is not None and room_nr is not None:
        floor_check, floor_err = execute_query(
            "SELECT 1 FROM floor WHERE floor_nr = %s AND building_id = %s",
            (floor_nr, building_id)
        )
        if floor_err:
            return jsonify({"error": floor_err}), 500
        if not floor_check:
            return jsonify({"error": f"Floor {floor_nr} does not exist in this building"}), 400
        
        room_check, room_err = execute_query(
            "SELECT 1 FROM room WHERE room_nr = %s AND floor_nr = %s AND building_id = %s",
            (room_nr, floor_nr, building_id)
        )
        if room_err:
            return jsonify({"error": room_err}), 500
        if not room_check:
            return jsonify({"error": f"Room {room_nr} does not exist on floor {floor_nr} in this building"}), 400
    
    user_id = None
    if 'user_id' in session:
        user_id = session['user_id']
    elif reporter_email:
        results, _ = execute_query("SELECT id FROM user WHERE email = %s", (reporter_email,))
        if results:
            user_id = results[0]['id']
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        reported_at = datetime.now()
        cursor.execute(
            "INSERT INTO incident (user_id, reported_at, severity_level, description, category, status) "
            "VALUES (%s, %s, %s, %s, %s, 'reported')",
            (user_id, reported_at, severity_level, description, category)
        )
        incident_id = cursor.lastrowid
        
        if building_id:
            cursor.execute(
                "INSERT INTO incident_location (incident_id, building_id, floor_nr, room_nr) "
                "VALUES (%s, %s, %s, %s)",
                (incident_id, building_id, floor_nr, room_nr)
            )
        
        conn.commit()
        return jsonify({"message": "Incident created", "id": incident_id}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/incidents/<int:incident_id>', methods=['PUT'])
@login_required
@role_required(['manager', 'administrator'])
def update_incident(incident_id):
    data = request.json or {}
    status = data.get('status')
    severity_level = data.get('severity_level')
    description = data.get('description')
    category = data.get('category')
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT status, reported_at FROM incident WHERE id = %s", (incident_id,))
        result = cursor.fetchone()
        if not result:
            return jsonify({"error": "Incident not found"}), 404
        
        old_status = result['status']
        reported_at = result['reported_at']
        updates = []
        params = []
        
        if status:
            updates.append("status = %s")
            params.append(status)
        if severity_level:
            updates.append("severity_level = %s")
            params.append(severity_level)
        if description:
            updates.append("description = %s")
            params.append(description)
        if category:
            updates.append("category = %s")
            params.append(category)
        
        if not updates:
            return jsonify({"error": "No fields to update"}), 400
        
        params.append(incident_id)
        cursor.execute(f"UPDATE incident SET {', '.join(updates)} WHERE id = %s", tuple(params))
        
        if status and status != old_status:
            now = datetime.now()
            cursor.execute(
                "SELECT time_to FROM incident_history WHERE incident_id = %s ORDER BY time_from DESC LIMIT 1",
                (incident_id,)
            )
            last = cursor.fetchone()
            time_from = last['time_to'] if last else reported_at
            cursor.execute(
                "INSERT INTO incident_history (time_from, time_to, incident_id, status_type) "
                "VALUES (%s, %s, %s, %s)",
                (time_from, now, incident_id, old_status)
            )
        
        conn.commit()
        return jsonify({"message": "Incident updated"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/incidents/<int:incident_id>', methods=['DELETE'])
@login_required
@role_required(['manager', 'administrator'])
def delete_incident(incident_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("DELETE FROM incident_history WHERE incident_id = %s", (incident_id,))
        cursor.execute("DELETE FROM incident_location WHERE incident_id = %s", (incident_id,))
        cursor.execute("UPDATE maintenance_task SET incident_id = NULL WHERE incident_id = %s", (incident_id,))
        cursor.execute("DELETE FROM incident WHERE id = %s", (incident_id,))
        conn.commit()
        return jsonify({"message": "Incident deleted"})
    except mysql.connector.errors.IntegrityError as e:
        conn.rollback()
        return jsonify({"error": "Cannot delete incident: it is still referenced by other records"}), 409
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/incidents/<int:incident_id>/location', methods=['PUT'])
@login_required
@role_required(['manager', 'administrator'])
def update_incident_location(incident_id):
    data = request.json or {}
    building_id = data.get('building_id')
    floor_nr = data.get('floor_nr')
    room_nr = data.get('room_nr')
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id FROM incident_location WHERE incident_id = %s", (incident_id,))
        exists = cursor.fetchone()
        
        if exists:
            cursor.execute(
                "UPDATE incident_location SET building_id = %s, floor_nr = %s, room_nr = %s "
                "WHERE incident_id = %s",
                (building_id, floor_nr, room_nr, incident_id)
            )
        else:
            cursor.execute(
                "INSERT INTO incident_location (incident_id, building_id, floor_nr, room_nr) "
                "VALUES (%s, %s, %s, %s)",
                (incident_id, building_id, floor_nr, room_nr)
            )
        
        conn.commit()
        return jsonify({"message": "Location updated"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ── Maintenance Tasks ──────────────────────────────────────────────────────────

@app.route('/api/tasks', methods=['GET'])
@login_required
def list_tasks():
    role = session.get('role_name')
    user_id = session.get('user_id')
    
    if role == 'technician':
        results, error = execute_query(
            "SELECT mt.id, mt.incident_id, mt.type, mt.priority, mt.task_status, mt.estimated_duration, "
            "mt.start_time, mt.end_time, mt.incident_category, mt.severity_level, mt.incident_status, "
            "mt.building_name, mt.floor_nr, mt.room_nr, mt.technician_name "
            "FROM technician_tasks_view mt "
            "WHERE mt.tech_id = %s "
            "ORDER BY mt.start_time DESC",
            (user_id,)
        )
    elif role in ['manager', 'administrator']:
        results, error = execute_query(
            "SELECT mt.id, mt.incident_id, mt.type, mt.priority, mt.task_status, mt.estimated_duration, "
            "mt.start_time, mt.end_time, mt.incident_category, mt.severity_level, "
            "mt.building_name, mt.floor_nr, mt.room_nr, mt.assigned_technicians "
            "FROM manager_tasks_view mt "
            "ORDER BY mt.start_time DESC"
        )
    else:
        results, error = execute_query(
            "SELECT mt.id, mt.incident_id, mt.type, mt.priority, mt.task_status, mt.estimated_duration, "
            "mt.start_time, mt.end_time "
            "FROM maintenance_task mt "
            "ORDER BY mt.start_time DESC"
        )
    
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"tasks": results})

@app.route('/api/tasks/<int:task_id>', methods=['GET'])
@login_required
def get_task(task_id):
    results, error = execute_query(
        "SELECT mt.*, i.description AS incident_description, i.category, i.severity_level, "
        "b.name AS building_name, il.floor_nr, il.room_nr "
        "FROM maintenance_task mt "
        "INNER JOIN incident i ON mt.incident_id = i.id "
        "LEFT JOIN incident_location il ON i.id = il.incident_id "
        "LEFT JOIN building b ON il.building_id = b.id "
        "WHERE mt.id = %s",
        (task_id,)
    )
    if error:
        return jsonify({"error": error}), 500
    if not results:
        return jsonify({"error": "Task not found"}), 404
    
    task = results[0]
    
    history, _ = execute_query(
        "SELECT * FROM status_history WHERE task_id = %s ORDER BY time_started",
        (task_id,)
    )
    task['status_history'] = history or []
    
    technicians, _ = execute_query(
        "SELECT u.id, u.name, u.email FROM technician_work tw "
        "INNER JOIN user u ON tw.tech_id = u.id WHERE tw.task_id = %s",
        (task_id,)
    )
    task['technicians'] = technicians or []
    
    resources, _ = execute_query(
        "SELECT r.id, r.type, r.description FROM resource_requirement rr "
        "INNER JOIN resource r ON rr.resource_id = r.id WHERE rr.task_id = %s",
        (task_id,)
    )
    task['resources'] = resources or []
    
    skills, _ = execute_query(
        "SELECT s.id, s.name FROM skill_requirement sr "
        "INNER JOIN skill s ON sr.skill_id = s.id WHERE sr.task_id = %s",
        (task_id,)
    )
    task['required_skills'] = skills or []
    
    return jsonify({"task": task})

@app.route('/api/tasks', methods=['POST'])
@login_required
@role_required(['manager', 'administrator'])
def create_task():
    data = request.json or {}
    incident_id = data.get('incident_id')
    task_type = data.get('type')
    priority = data.get('priority', 'Medium')
    estimated_duration = data.get('estimated_duration')
    start_time = data.get('start_time')
    tech_ids = data.get('tech_ids', [])
    skill_ids = data.get('skill_ids', [])
    resource_ids = data.get('resource_ids', [])
    
    if not incident_id or not task_type:
        return jsonify({"error": "incident_id and type are required"}), 400
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            "INSERT INTO maintenance_task (incident_id, type, priority, task_status, estimated_duration, start_time) "
            "VALUES (%s, %s, %s, 'Not started', %s, %s)",
            (incident_id, task_type, priority, estimated_duration, start_time)
        )
        task_id = cursor.lastrowid
        
        for tech_id in tech_ids:
            cursor.execute(
                "INSERT INTO technician_work (tech_id, task_id) VALUES (%s, %s)",
                (tech_id, task_id)
            )
        
        for skill_id in skill_ids:
            cursor.execute(
                "INSERT INTO skill_requirement (task_id, skill_id) VALUES (%s, %s)",
                (task_id, skill_id)
            )
        
        for resource_id in resource_ids:
            cursor.execute(
                "INSERT INTO resource_requirement (resource_id, task_id) VALUES (%s, %s)",
                (resource_id, task_id)
            )
        
        conn.commit()
        return jsonify({"message": "Task created", "id": task_id}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
@login_required
@role_required(['manager', 'administrator'])
def update_task(task_id):
    data = request.json or {}
    role = session.get('role_name')
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT task_status, start_time FROM maintenance_task WHERE id = %s", (task_id,))
        result = cursor.fetchone()
        if not result:
            return jsonify({"error": "Task not found"}), 404
        
        old_status = result['task_status']
        updates = []
        params = []
        
        if role in ['manager', 'administrator']:
            if data.get('type'):
                updates.append("type = %s")
                params.append(data['type'])
            if data.get('priority'):
                updates.append("priority = %s")
                params.append(data['priority'])
            if data.get('estimated_duration'):
                updates.append("estimated_duration = %s")
                params.append(data['estimated_duration'])
            if data.get('start_time'):
                updates.append("start_time = %s")
                params.append(data['start_time'])
            if data.get('end_time'):
                updates.append("end_time = %s")
                params.append(data['end_time'])
        
        task_status = data.get('task_status')
        if task_status:
            updates.append("task_status = %s")
            params.append(task_status)
        
        if not updates:
            return jsonify({"error": "No fields to update"}), 400
        
        params.append(task_id)
        cursor.execute(f"UPDATE maintenance_task SET {', '.join(updates)} WHERE id = %s", tuple(params))
        
        if task_status and task_status != old_status:
            now = datetime.now()
            cursor.execute(
                "SELECT time_ended FROM status_history WHERE task_id = %s ORDER BY time_started DESC LIMIT 1",
                (task_id,)
            )
            last = cursor.fetchone()
            time_from = last['time_ended'] if last else result['start_time']
            if not time_from:
                time_from = now
            cursor.execute(
                "INSERT INTO status_history (task_id, time_started, time_ended, type) "
                "VALUES (%s, %s, %s, %s)",
                (task_id, time_from, now, old_status)
            )
        
        conn.commit()
        return jsonify({"message": "Task updated"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
@login_required
@role_required(['administrator'])
def delete_task(task_id):
    result, error = execute_write("DELETE FROM maintenance_task WHERE id = %s", (task_id,))
    if error:
        if "1451" in error or "foreign key constraint" in error.lower():
            return jsonify({"error": "Cannot delete task: one or more resource usage records are linked to this task. Remove them first."}), 409
        return jsonify({"error": error}), 500
    return jsonify({"message": "Task deleted"})

@app.route('/api/tasks/<int:task_id>/technicians', methods=['PUT'])
@login_required
@role_required(['manager', 'administrator'])
def update_task_technicians(task_id):
    data = request.json or {}
    tech_ids = data.get('tech_ids', [])
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("DELETE FROM technician_work WHERE task_id = %s", (task_id,))
        for tech_id in tech_ids:
            cursor.execute(
                "INSERT INTO technician_work (tech_id, task_id) VALUES (%s, %s)",
                (tech_id, task_id)
            )
        conn.commit()
        return jsonify({"message": "Technicians updated"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/tasks/<int:task_id>/resources', methods=['PUT'])
@login_required
@role_required(['manager', 'administrator'])
def update_task_resources(task_id):
    data = request.json or {}
    resource_ids = data.get('resource_ids', [])

    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("DELETE FROM resource_requirement WHERE task_id = %s", (task_id,))
        for resource_id in resource_ids:
            cursor.execute(
                "INSERT INTO resource_requirement (resource_id, task_id) VALUES (%s, %s)",
                (resource_id, task_id)
            )
        conn.commit()
        return jsonify({"message": "Resources updated"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ── Technician Availability ───────────────────────────────────────────────────

@app.route('/api/availability', methods=['GET'])
@login_required
def list_availability():
    role = session.get('role_name')
    user_id = session.get('user_id')
    
    if role == 'technician':
        results, error = execute_query(
            "SELECT * FROM availability WHERE tech_id = %s ORDER BY FIELD(day, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), start_time",
            (user_id,)
        )
    elif role in ['manager', 'administrator']:
        results, error = execute_query(
            "SELECT a.*, u.name AS tech_name FROM availability a "
            "INNER JOIN user u ON a.tech_id = u.id ORDER BY u.name, FIELD(day, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')"
        )
    else:
        return jsonify({"error": "Access denied"}), 403
    
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"availability": results})

@app.route('/api/availability', methods=['POST'])
@login_required
@role_required(['manager', 'administrator'])
def create_availability():
    data = request.json or {}
    tech_id = data.get('tech_id')
    day = data.get('day')
    start_time = data.get('start_time')
    end_time = data.get('end_time')
    
    if not all([tech_id, day, start_time, end_time]):
        return jsonify({"error": "tech_id, day, start_time, and end_time are required"}), 400
    
    result, error = execute_write(
        "INSERT INTO availability (tech_id, day, start_time, end_time) VALUES (%s, %s, %s, %s)",
        (tech_id, day, start_time, end_time)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "Availability created", "id": result['last_insert_id']}), 201

@app.route('/api/availability/<int:tech_id>/<day>', methods=['DELETE'])
@login_required
@role_required(['manager', 'administrator'])
def delete_availability(tech_id, day):
    result, error = execute_write(
        "DELETE FROM availability WHERE tech_id = %s AND day = %s",
        (tech_id, day)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "Availability deleted"})

# ── Resources ────────────────────────────────────────────────────────────────

@app.route('/api/resources', methods=['GET'])
@login_required
def list_resources():
    role = session.get('role_name')
    
    if role in ['student', 'staff']:
        return jsonify({"error": "Access denied"}), 403
    
    results, error = execute_query(
        "SELECT r.*, b.name AS building_name FROM resource r "
        "LEFT JOIN building b ON r.building_id = b.id "
        "ORDER BY r.type, b.name"
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"resources": results})

@app.route('/api/resources/<int:resource_id>', methods=['GET'])
@login_required
def get_resource(resource_id):
    role = session.get('role_name')
    if role in ['student', 'staff']:
        return jsonify({"error": "Access denied"}), 403
    
    results, error = execute_query(
        "SELECT r.*, b.name AS building_name FROM resource r "
        "INNER JOIN building b ON r.building_id = b.id WHERE r.id = %s",
        (resource_id,)
    )
    if error:
        return jsonify({"error": error}), 500
    if not results:
        return jsonify({"error": "Resource not found"}), 404
    
    resource = results[0]
    
    usage, _ = execute_query(
        "SELECT ru.*, mt.type AS task_type FROM resource_usage ru "
        "INNER JOIN maintenance_task mt ON ru.task_id = mt.id WHERE ru.resource_id = %s",
        (resource_id,)
    )
    resource['usage_history'] = usage or []
    
    return jsonify({"resource": resource})

@app.route('/api/resources', methods=['POST'])
@login_required
@role_required(['manager', 'administrator'])
def create_resource():
    data = request.json or {}
    building_id = data.get('building_id')
    floor_nr = data.get('floor_nr')
    room_nr = data.get('room_nr')
    resource_type = data.get('type')
    availability_status = data.get('availability_status', 'Available')
    description = data.get('description', '')
    
    if not all([building_id, floor_nr, room_nr, resource_type]):
        return jsonify({"error": "building_id, floor_nr, room_nr, and type are required"}), 400
    
    result, error = execute_write(
        "INSERT INTO resource (building_id, floor_nr, room_nr, type, availability_status, description) "
        "VALUES (%s, %s, %s, %s, %s, %s)",
        (building_id, floor_nr, room_nr, resource_type, availability_status, description)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "Resource created", "id": result['last_insert_id']}), 201

@app.route('/api/resources/<int:resource_id>', methods=['PUT'])
@login_required
@role_required(['manager', 'administrator'])
def update_resource(resource_id):
    data = request.json or {}
    updates = []
    params = []
    
    for field in ['building_id', 'floor_nr', 'room_nr', 'type', 'availability_status', 'description']:
        if field in data:
            updates.append(f"{field} = %s")
            params.append(data[field])
    
    if not updates:
        return jsonify({"error": "No fields to update"}), 400
    
    params.append(resource_id)
    result, error = execute_write(
        f"UPDATE resource SET {', '.join(updates)} WHERE id = %s",
        tuple(params)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "Resource updated"})

@app.route('/api/resources/<int:resource_id>', methods=['DELETE'])
@login_required
@role_required(['manager', 'administrator'])
def delete_resource(resource_id):
    result, error = execute_write("DELETE FROM resource WHERE id = %s", (resource_id,))
    if error:
        if "1451" in error or "foreign key constraint" in error.lower():
            return jsonify({"error": "Cannot delete resource: it is still required by or used in one or more tasks. Remove those associations first."}), 409
        return jsonify({"error": error}), 500
    return jsonify({"message": "Resource deleted"})

# ── Skills ─────────────────────────────────────────────────────────────────────

@app.route('/api/skills', methods=['GET'])
@login_required
def list_skills():
    results, error = execute_query("SELECT * FROM skill ORDER BY name")
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"skills": results})

@app.route('/api/skills', methods=['POST'])
@login_required
@role_required(['manager', 'administrator'])
def create_skill():
    data = request.json or {}
    name = data.get('name', '').strip()
    if not name:
        return jsonify({"error": "Skill name is required"}), 400
    
    result, error = execute_write("INSERT INTO skill (name) VALUES (%s)", (name,))
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "Skill created", "id": result['last_insert_id']}), 201

@app.route('/api/skills/<int:skill_id>', methods=['DELETE'])
@login_required
@role_required(['manager', 'administrator'])
def delete_skill(skill_id):
    result, error = execute_write("DELETE FROM skill WHERE id = %s", (skill_id,))
    if error:
        if "1451" in error or "foreign key constraint" in error.lower():
            return jsonify({"error": "Cannot delete skill: it is still required by one or more tasks. Remove those skill requirements first."}), 409
        return jsonify({"error": error}), 500
    return jsonify({"message": "Skill deleted"})

@app.route('/api/technicians', methods=['GET'])
@login_required
def list_technicians():
    results, error = execute_query(
        "SELECT t.*, u.name, u.email, t.role AS job_role "
        "FROM technician t INNER JOIN user u ON t.tech_id = u.id"
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"technicians": results})

@app.route('/api/technicians/<int:tech_id>/skills', methods=['GET', 'PUT'])
@login_required
@role_required(['manager', 'administrator'])
def manage_technician_skills(tech_id):
    if request.method == 'GET':
        results, error = execute_query(
            "SELECT s.* FROM skill s INNER JOIN technician_skill ts ON s.id = ts.skill_id WHERE ts.tech_id = %s",
            (tech_id,)
        )
        if error:
            return jsonify({"error": error}), 500
        return jsonify({"skills": results})
    
    data = request.json or {}
    skill_ids = data.get('skill_ids', [])
    
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("DELETE FROM technician_skill WHERE tech_id = %s", (tech_id,))
        for skill_id in skill_ids:
            cursor.execute(
                "INSERT INTO technician_skill (tech_id, skill_id) VALUES (%s, %s)",
                (tech_id, skill_id)
            )
        conn.commit()
        return jsonify({"message": "Skills updated"})
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# ── Buildings & Reference Data ────────────────────────────────────────────────

@app.route('/api/buildings', methods=['GET'])
def list_buildings():
    results, error = execute_query("SELECT * FROM building ORDER BY name")
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"buildings": results})

@app.route('/api/buildings/<int:building_id>', methods=['DELETE'])
@login_required
@role_required(['manager', 'administrator'])
def delete_building(building_id):
    result, error = execute_write("DELETE FROM building WHERE id = %s", (building_id,))
    if error:
        if "1451" in error or "foreign key constraint" in error.lower():
            return jsonify({"error": "Cannot delete building: it still has incidents, floors, or resources linked to it. Remove those associations first."}), 409
        return jsonify({"error": error}), 500
    return jsonify({"message": "Building deleted"})

@app.route('/api/buildings', methods=['POST'])
def create_building():
    data = request.json or {}
    name = data.get('name', '').strip()
    address = data.get('address', '').strip()
    
    if not name:
        return jsonify({"error": "Building name is required"}), 400
    
    result, error = execute_write(
        "INSERT INTO building (name, address) VALUES (%s, %s)",
        (name, address)
    )
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"message": "Building created", "id": result['last_insert_id']}), 201

@app.route('/api/roles', methods=['GET'])
@login_required
def list_roles():
    results, error = execute_query("SELECT * FROM role ORDER BY id")
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"roles": results})

# ── Predefined Queries (from original app) ────────────────────────────────────

QUERIES = {
    "q1": {
        "title": "Unresolved incidents older than N days – grouped by building",
        "params": [{"name": "days", "label": "Number of days", "type": "number", "default": 1}],
        "sql": """SELECT building.name AS building_name, COUNT(incident.id) AS unresolved_count
                  FROM incident INNER JOIN incident_location ON incident.id = incident_location.incident_id
                  INNER JOIN building ON incident_location.building_id = building.id
                  WHERE incident.status NOT IN ('resolved', 'closed')
                  AND incident.reported_at < NOW() - INTERVAL %s DAY
                  GROUP BY incident_location.building_id, building.name""",
        "param_order": ["days"]
    },
    "q2": {
        "title": "Maintenance workload per technician for a given week",
        "params": [{"name": "start_date", "label": "Start date (Monday)", "type": "date", "default": "2026-04-14"}],
        "sql": """SELECT technician.tech_id, user.name AS tech_name,
                  SUM(TIME_TO_SEC(mt.estimated_duration) / 3600) AS estimated_hours,
                  SUM(TIMESTAMPDIFF(SECOND, mt.start_time, mt.end_time) / 3600) AS actual_hours
                  FROM technician INNER JOIN user ON technician.tech_id = user.id
                  INNER JOIN technician_work tw ON technician.tech_id = tw.tech_id
                  INNER JOIN maintenance_task mt ON tw.task_id = mt.id
                  WHERE mt.start_time BETWEEN %s AND DATE_ADD(%s, INTERVAL 6 DAY)
                  AND mt.start_time IS NOT NULL GROUP BY user.name, technician.tech_id""",
        "param_order": ["start_date", "start_date"]
    },
    "q3": {
        "title": "Incidents that required multiple maintenance tasks",
        "params": [],
        "sql": """SELECT incident.id AS incident_id, incident.category, incident.status,
                  incident.description, COUNT(DISTINCT maintenance_task.id) AS task_count
                  FROM incident INNER JOIN maintenance_task ON incident.id = maintenance_task.incident_id
                  GROUP BY incident.id, incident.category, incident.status, incident.description
                  HAVING COUNT(DISTINCT maintenance_task.id) > 1 ORDER BY task_count DESC""",
        "param_order": []
    },
    "q4": {
        "title": "Average resolution time per incident category",
        "params": [],
        "sql": """SELECT incident.category, SEC_TO_TIME(AVG(TIMESTAMPDIFF(SECOND, incident.reported_at, incident_history.time_to))) AS avg_resolution_time,
                  COUNT(*) AS amount FROM incident
                  INNER JOIN incident_history ON incident.id = incident_history.incident_id
                  WHERE incident_history.status_type IN ('closed', 'resolved')
                  GROUP BY incident.category ORDER BY avg_resolution_time ASC""",
        "param_order": []
    },
    "q5": {
        "title": "Resources over-utilized within a date range",
        "params": [
            {"name": "start_date", "label": "Start date", "type": "date", "default": "2026-04-01"},
            {"name": "end_date", "label": "End date", "type": "date", "default": "2026-04-30"}
        ],
        "sql": """SELECT r.id AS resource_id, r.type, r.description AS resource_desc, b.name AS building,
                  COUNT(ru.task_id) AS usage_count, GROUP_CONCAT(ru.task_id ORDER BY ru.task_id SEPARATOR ', ') AS task_ids
                  FROM resource_usage ru INNER JOIN resource r ON ru.resource_id = r.id
                  INNER JOIN building b ON r.building_id = b.id
                  WHERE ru.start_usage_time BETWEEN %s AND %s
                  GROUP BY r.id, r.type, r.description, b.name HAVING COUNT(ru.task_id) > 1
                  ORDER BY usage_count DESC""",
        "param_order": ["start_date", "end_date"]
    },
    "q6": {
        "title": "Incidents reopened after being resolved",
        "params": [],
        "sql": """SELECT DISTINCT incident.id AS incident_id, incident.description, incident.category,
                  incident.status AS current_status, MIN(ih1.time_from) AS first_resolved, MIN(ih2.time_from) AS reopened_at
                  FROM incident INNER JOIN incident_history ih1 ON incident.id = ih1.incident_id AND ih1.status_type = 'resolved'
                  INNER JOIN incident_history ih2 ON incident.id = ih2.incident_id
                  AND ih2.status_type IN ('reported', 'verified', 'assigned') AND ih2.time_from > ih1.time_from
                  GROUP BY incident.id, incident.description, incident.category, incident.status ORDER BY reopened_at""",
        "param_order": []
    },
    "q7": {
        "title": "Technicians and scheduled hours per week",
        "params": [],
        "sql": """SELECT technician.tech_id, user.name AS technician_name, technician.role,
                  SUM(TIMESTAMPDIFF(SECOND, availability.start_time, availability.end_time) / 3600) AS scheduled_hours
                  FROM technician INNER JOIN availability ON technician.tech_id = availability.tech_id
                  INNER JOIN user ON technician.tech_id = user.id GROUP BY technician.tech_id, user.name, technician.role
                  ORDER BY scheduled_hours DESC""",
        "param_order": []
    },
    "q8": {
        "title": "Incidents reported by a specific user",
        "params": [
            {"name": "name", "label": "Name (partial)", "type": "text", "default": ""},
            {"name": "email", "label": "Email (partial)", "type": "text", "default": ""}
        ],
        "sql": """SELECT incident.*, user.name AS reporter_name, user.email AS reporter_email
                  FROM incident INNER JOIN user ON user.id = incident.user_id
                  WHERE user.name LIKE %s OR user.email LIKE %s ORDER BY incident.reported_at DESC""",
        "param_order": ["name", "email"]
    },
    "q9": {
        "title": "Task overlaps for the same technician",
        "params": [],
        "sql": """SELECT user.name AS technician, tw1.tech_id, mt1.id AS task1_id, mt1.start_time AS t1_start,
                  mt1.end_time AS t1_end, mt2.id AS task2_id, mt2.start_time AS t2_start, mt2.end_time AS t2_end
                  FROM technician_work tw1 INNER JOIN technician_work tw2 ON tw1.tech_id = tw2.tech_id AND tw1.task_id < tw2.task_id
                  INNER JOIN maintenance_task mt1 ON mt1.id = tw1.task_id INNER JOIN maintenance_task mt2 ON mt2.id = tw2.task_id
                  INNER JOIN technician ON tw1.tech_id = technician.tech_id INNER JOIN user ON technician.tech_id = user.id
                  WHERE mt1.start_time < mt2.end_time AND mt2.start_time < mt1.end_time
                  AND mt1.start_time IS NOT NULL AND mt2.start_time IS NOT NULL
                  ORDER BY user.name, mt1.start_time""",
        "param_order": []
    },
    "q10": {
        "title": "Incidents per building within date range",
        "params": [
            {"name": "start_date", "label": "Start date", "type": "date", "default": "2026-04-01"},
            {"name": "end_date", "label": "End date", "type": "date", "default": "2026-04-30"}
        ],
        "sql": """SELECT building.name AS building_name, COUNT(*) AS number_of_incidents
                  FROM incident INNER JOIN incident_location ON incident.id = incident_location.incident_id
                  INNER JOIN building ON building.id = incident_location.building_id
                  WHERE incident.reported_at > %s AND incident.reported_at < %s
                  GROUP BY building.id, building.name ORDER BY number_of_incidents DESC""",
        "param_order": ["start_date", "end_date"]
    }
}

@app.route('/api/run/<query_id>', methods=['POST'])
@login_required
def run_query(query_id):
    if query_id not in QUERIES:
        return jsonify({"error": "Unknown query"}), 404
    
    role = session.get('role_name')
    if role in ['student', 'staff', 'public_user']:
        return jsonify({"error": "Insufficient privileges for predefined queries"}), 403
    
    q = QUERIES[query_id]
    data = request.json or {}
    params = [data.get(p) for p in q["param_order"]]
    
    if query_id == "q8":
        params = [f"%{v}%" if v else "%%" for v in params]
    
    results, error = execute_query(q["sql"], params)
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"results": results, "count": len(results)})

@app.route('/api/custom', methods=['POST'])
@login_required
@role_required(['manager', 'administrator'])
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

# ── Health Check ───────────────────────────────────────────────────────────────

@app.route('/api/health')
def health():
    try:
        conn = get_db()
        conn.close()
        return jsonify({"status": "ok", "db": "connected"})
    except Exception as e:
        return jsonify({"status": "error", "db": str(e)}), 500

# ── Template Route ────────────────────────────────────────────────────────────

@app.route('/')
def index():
    user = get_current_user()
    return render_template('index.html', queries=QUERIES, current_user=user)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)