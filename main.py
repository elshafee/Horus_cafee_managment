import os
import sqlite3
from datetime import datetime

from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

DB_NAME = "database.db"
FLUTTER_WEB_APP_DIR = 'templates'


# =====================================================
# DATABASE
# =====================================================
def get_db():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_db()
    cursor = conn.cursor()

    # USERS
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_name TEXT,
        staff_id TEXT UNIQUE,
        room TEXT
    )
    """)

    # PRODUCTS
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        price REAL
    )
    """)

    # ORDERS
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_name TEXT,
        staff_id TEXT,
        office_boy_id INTEGER,
        delivery_room TEXT,
        notes TEXT,
        total_cost REAL,
        status TEXT,
        created_at TEXT
    )
    """)

    # ORDER ITEMS
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        product_name TEXT,
        quantity INTEGER,
        price REAL
    )
    """)

    conn.commit()
    conn.close()


init_db()


# =====================================================
# AUTH
# =====================================================
@app.route("/auth/login", methods=["POST"])
def login():
    data = request.json
    staff_name = data["staff_name"]
    staff_id = data["staff_id"]
    room = data.get("room", "")

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users WHERE staff_id=?", (staff_id,))
    user = cursor.fetchone()

    if not user:
        cursor.execute(
            "INSERT INTO users (staff_name, staff_id, room) VALUES (?, ?, ?)",
            (staff_name, staff_id, room)
        )
        conn.commit()

    conn.close()

    return jsonify({
        "success": True,
        "staff_name": staff_name,
        "staff_id": staff_id,
        "room": room
    })


# =====================================================
# PRODUCTS
# =====================================================
@app.route("/products", methods=["GET"])
def get_products():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM products")
    products = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return jsonify(products)


# =====================================================
# CREATE ORDER
# =====================================================
@app.route("/order", methods=["POST"])
def create_order():
    data = request.json

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    INSERT INTO orders 
    (staff_name, staff_id, office_boy_id, delivery_room, notes, total_cost, status, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        data["staff_name"],
        data["staff_id"],
        data["office_boy_id"],
        data["delivery_room"],
        data.get("notes", ""),
        0.0,
        "PENDING",
        datetime.now().isoformat()
    ))

    order_id = cursor.lastrowid

    for item in data["items"]:
        cursor.execute("""
        INSERT INTO order_items (order_id, product_name, quantity, price)
        VALUES (?, ?, ?, ?)
        """, (
            order_id,
            item["name"],
            item["qty"],
            item["price"]
        ))

    conn.commit()
    conn.close()

    return jsonify({"success": True, "order_id": order_id})


# =====================================================
# ORDERS FOR USER
# =====================================================
@app.route("/orders/<staff_id>", methods=["GET"])
def user_orders(staff_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM orders WHERE staff_id=?", (staff_id,))
    orders = []

    for order in cursor.fetchall():
        cursor.execute("SELECT * FROM order_items WHERE order_id=?", (order["id"],))
        items = [dict(row) for row in cursor.fetchall()]

        orders.append({
            "order": dict(order),
            "items": items
        })

    conn.close()
    return jsonify(orders)


# =====================================================
# OFFICE BOY – GET PENDING ORDERS
# =====================================================
@app.route("/orders/active/<int:office_boy_id>", methods=["GET"])
def active_orders(office_boy_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    SELECT * FROM orders 
    WHERE office_boy_id=? 
    AND status IN ('PENDING', 'ACCEPTED')
    ORDER BY created_at ASC
    """, (office_boy_id,))

    orders = [dict(row) for row in cursor.fetchall()]
    conn.close()

    return jsonify(orders)


# =====================================================
# UPDATE ORDER STATUS (ESP32)
# =====================================================
@app.route("/order/status", methods=["POST"])
def update_order_status():
    data = request.json
    order_id = data["order_id"]
    status = data["status"]  # ACCEPTED / DELIVERED

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE orders SET status=? WHERE id=?",
        (status, order_id)
    )
    conn.commit()
    conn.close()

    return jsonify({"success": True})


# =====================================================
# ADD SAMPLE PRODUCTS (RUN ONCE)
# =====================================================
@app.route("/seed", methods=["GET"])
def seed_products():
    products = [
        ("Coffee", "Drink", 10),
        ("Tea", "Drink", 8),
        ("Water", "Drink", 5),
        ("Sandwich", "Food", 25),
        ("Croissant", "Food", 20)
    ]

    conn = get_db()
    cursor = conn.cursor()

    for p in products:
        cursor.execute(
            "INSERT INTO products (name, category, price) VALUES (?, ?, ?)", p
        )

    conn.commit()
    conn.close()
    return "Products added"



# Flutter home page requesting
@app.route('/')
def render_page():
    return render_template('index.html')


#  Flutter rendering page
@app.route('/web/')
def render_page_web():
    return render_template('index.html')


# Flutter rendering data path
@app.route('/web/<path:name>')
def return_flutter_doc(name):
    datalist = str(name).split('/')
    current_dir = FLUTTER_WEB_APP_DIR
    if len(datalist) > 1:
        for i in range(0, len(datalist) - 1):
            current_dir += '/' + datalist[i]
    return send_from_directory(current_dir, datalist[-1])


# Fluter asset data
@app.route('/assets/<path:filename>')
def serve_assets(filename):
    return send_from_directory(os.path.join(FLUTTER_WEB_APP_DIR, 'assets'), filename)


# =====================================================
# RUN SERVER
# =====================================================
app.run(
    host="0.0.0.0",
    port=5000,
    debug=False
)
