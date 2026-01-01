import base64
import os
import sqlite3
from datetime import datetime

from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

DB_NAME = "database.db"
FLUTTER_WEB_APP_DIR = 'templates'

# Ensure the directory exists
UPLOAD_FOLDER = 'static/profile_images'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


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
            room TEXT,
            department TEXT,      -- New Field
            profile_image TEXT    -- New Field (Stores Base64 string or URL)
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
    staff_id = data.get("staff_id")

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT staff_name, staff_id, room, department FROM users WHERE staff_id=?", (staff_id,))
    user = cursor.fetchone()
    conn.close()

    if user:
        # Get the image string from the file system
        image_path = f"static/profile_images/{staff_id}.jpg"
        encoded_image = ""
        if os.path.exists(image_path):
            with open(image_path, "rb") as img_file:
                encoded_image = base64.b64encode(img_file.read()).decode('utf-8')

        return jsonify(
            {"success": True, "staff_name": user[0], "staff_id": user[1], "room": user[2], "department": user[3] or "",
             "profile_image": encoded_image  # Now sending the actual data
             })

    return jsonify({"success": False, "message": "User not found"}), 401


@app.route('/signup-page')
def signup_page():
    return render_template('signup.html')


@app.route("/auth/register_web", methods=["POST"])
def register_web():
    # Use request.form for HTML submissions
    staff_name = request.form.get("staff_name")
    staff_id = request.form.get("staff_id")
    room = request.form.get("room", "")

    conn = get_db()
    cursor = conn.cursor()

    # Check if user exists
    cursor.execute("SELECT * FROM users WHERE staff_id=?", (staff_id,))
    user = cursor.fetchone()

    if not user:
        cursor.execute("INSERT INTO users (staff_name, staff_id, room) VALUES (?, ?, ?)", (staff_name, staff_id, room))
        conn.commit()
        message = "Success! You can now log in using the app."
        return jsonify({"success": True, "message": "Account created!"})
    else:
        message = "User already exists with this ID."
        return jsonify({"success": False, "message": "User already exists with this ID."})

    conn.close()

    # Return a simple success message or redirect
    return jsonify({"success": False, "message": "Error"})


@app.route("/auth/update_profile", methods=["POST"])
def update_profile():
    data = request.json
    staff_id = data.get("staff_id")
    dept = data.get("department")
    room = data.get("room")
    image_b64 = data.get("profile_image")  # The string from Flutter

    print(data)
    image_url = None

    if image_b64 and len(image_b64) > 100:  # Check if it's a real image string
        try:
            # 1. Decode the Base64 string
            header, encoded = image_b64.split(",", 1) if "," in image_b64 else (None, image_b64)
            image_data = base64.b64decode(encoded)

            # 2. Define filename: staff_id.jpg
            filename = f"{staff_id}.jpg"
            filepath = os.path.join(UPLOAD_FOLDER, filename)

            # 3. Save the file to the directory
            with open(filepath, "wb") as f:
                f.write(image_data)

            # 4. Create the URL to be stored in the DB
            image_url = f"/static/profile_images/{filename}"
        except Exception as e:
            print(f"Image Save Error: {e}")

    # 5. Update Database
    conn = get_db()
    cursor = conn.cursor()

    # If image_url is None, we keep the old one in the DB
    if image_url:
        cursor.execute("UPDATE users SET department=?, room=?, profile_image=? WHERE staff_id=?",
                       (dept, room, image_url, staff_id))
    else:
        cursor.execute("UPDATE users SET department=?, room=? WHERE staff_id=?", (dept, room, staff_id))

    conn.commit()
    conn.close()

    return jsonify({"success": True, "image_url": image_url})


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
def translate_sugar_to_numbers(text):
    """
    Converts Arabic sugar descriptions to numeric spoon counts for ESP32.
    """
    if not text:
        return "0"

    # Mapping Dictionary
    sugar_map = {
        "سادة": "0",
        "ع الريحة": "0.5",
        "مظبوط": "2",
        "زيادة": "3"
    }

    # Replace Arabic words with numbers
    translated_text = text
    for arabic, numeric in sugar_map.items():
        translated_text = translated_text.replace(arabic, numeric)

    return translated_text


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
        data["staff_name"], data["staff_id"], data["office_boy_id"], data["delivery_room"], data.get("notes", ""), 0.0,
        "PENDING", datetime.now().isoformat()))

    order_id = cursor.lastrowid

    for item in data["items"]:
        cursor.execute("""
        INSERT INTO order_items (order_id, product_name, quantity, price)
        VALUES (?, ?, ?, ?)
        """, (order_id, item["name"], item["qty"], item["price"]))

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

    cursor.execute("SELECT * FROM orders WHERE staff_id=? AND status='PENDING'", (staff_id,))
    orders = []

    for order in cursor.fetchall():
        cursor.execute("SELECT * FROM order_items WHERE order_id=?", (order["id"],))
        items = [dict(row) for row in cursor.fetchall()]

        orders.append({"order": dict(order), "items": items})

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

    # 1. Fetch the rows and convert them to dictionaries
    orders = [dict(row) for row in cursor.fetchall()]
    conn.close()

    # 2. Loop through each order and translate the 'notes' field
    for order in orders:
        if "notes" in order and order["notes"]:
            # Apply translation here
            order["notes"] = translate_sugar_to_numbers(order["notes"])

    # 3. Return the modified list to the ESP32
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
    cursor.execute("UPDATE orders SET status=? WHERE id=?", (status, order_id))
    conn.commit()
    conn.close()

    return jsonify({"success": True})


# =====================================================
# ADD SAMPLE PRODUCTS (RUN ONCE)
# =====================================================
@app.route("/seed", methods=["GET"])
def seed_products():
    products = [("Coffee", "Drink", 10), ("Tea", "Drink", 8), ("Water", "Drink", 5), ("Sandwich", "Food", 25),
                ("Croissant", "Food", 20)]

    conn = get_db()
    cursor = conn.cursor()

    for p in products:
        cursor.execute("INSERT INTO products (name, category, price) VALUES (?, ?, ?)", p)

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
app.run(host="0.0.0.0", port=5000, debug=False)
