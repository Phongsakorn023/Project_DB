# ============================================================
#  db.py — ชั้นติดต่อฐานข้อมูล  ★★★ นิสิตเขียน SQL ในไฟล์นี้ ★★★
#  มองหาคำว่า  # TODO  ทุกฟังก์ชัน — ใช้ %s เป็น placeholder เสมอ (กัน SQL injection)
# ============================================================
import mysql.connector
import config


def get_connection():
    return mysql.connector.connect(
        host=config.DB_HOST, user=config.DB_USER, password=config.DB_PASSWORD,
        database=config.DB_NAME, port=config.DB_PORT)


def run_query(sql, params=None):
    """รัน SELECT คืนผลเป็น list ของ dict"""
    conn = get_connection(); cur = conn.cursor(dictionary=True)
    cur.execute(sql, params or ()); rows = cur.fetchall()
    cur.close(); conn.close(); return rows


def run_command(sql, params=None):
    """รัน INSERT / UPDATE / DELETE แล้ว commit"""
    conn = get_connection(); cur = conn.cursor()
    cur.execute(sql, params or ()); conn.commit()
    out = {"new_id": cur.lastrowid, "affected": cur.rowcount}
    cur.close(); conn.close(); return out


def _todo(name):
    raise NotImplementedError(f"TODO: ยังไม่ได้เขียนฟังก์ชัน {name} ใน db.py")


# ---------- ลูกค้า (customer) ----------

    # """ค้นหา ลูกค้า ตามเงื่อนไข (name, email, tier)
    # คำใบ้: เริ่มจาก sql = "SELECT * FROM customer WHERE 1=1"
    # แล้วต่อเงื่อนไขเฉพาะ filter ที่มีค่า (ข้อความใช้ LIKE %s, อื่น ๆ ใช้ = %s)"""
    # # TODO: เขียน SQL ค้นหาแบบยืดหยุ่นตาม filters (ใช้ %s เสมอ)
    # """ค้นหา ลูกค้า ตามเงื่อนไข (name, email, tier)"""
    
def search_customers(filters):
    sql = "SELECT * FROM customer WHERE 1=1"
    params = []

    if filters.get("name"):
        sql += " AND name LIKE %s"
        params.append("%" + filters["name"] + "%")

    if filters.get("email"):
        sql += " AND email LIKE %s"
        params.append("%" + filters["email"] + "%")

    if filters.get("tier"):
        sql += " AND tier = %s"
        params.append(filters["tier"])
    return run_query(sql, params)


def get_customer(cust_id):
    """ดึง ลูกค้า 1 รายการตาม cust_id (ใช้ตอนเปิดฟอร์มแก้ไข)"""
    # TODO: SELECT * FROM customer WHERE cust_id = %s แล้วคืนแถวเดียว
    # _todo("get_customer")
    rows = run_query("SELECT * FROM customer WHERE cust_id = %s", (cust_id,))
    return rows[0] if rows else None



def create_customer(data):
    return run_command(
        "INSERT INTO customer (name, email, address, tier) "
        "VALUES (%s, %s, %s, %s)",
        (data["name"], data["email"], data["address"], data["tier"])
    )


#     # """แก้ไข ลูกค้า ตาม cust_id"""
#     # # TODO: UPDATE customer SET ... WHERE cust_id=%s
#     # # _todo("update_customer")

def update_customer(cust_id, data):
     return run_command(
        "UPDATE member SET name=%s,  email=%s, "
        "address=%s, tier=%s WHERE cust_id=%s",
        (data["name"],data["email"],
         data["address"], data["tier"], cust_id))


    # """ลบ ลูกค้า ตาม cust_id"""
    # # TODO: DELETE FROM customer WHERE cust_id=%s
    # _todo("delete_customer")
    
def delete_customer(cust_id):    
    return run_command("DELETE FROM customer WHERE cust_id=%s", (cust_id,)) 


# ---------- สินค้า (product) ----------
 
    """ค้นหา สินค้า ตามเงื่อนไข (name, category)
    คำใบ้: เริ่มจาก sql = "SELECT * FROM product WHERE 1=1"
    แล้วต่อเงื่อนไขเฉพาะ filter ที่มีค่า (ข้อความใช้ LIKE %s, อื่น ๆ ใช้ = %s)"""
    # TODO: เขียน SQL ค้นหาแบบยืดหยุ่นตาม filters (ใช้ %s เสมอ)
    # _todo("search_products")

def search_products(filters): 
 
    sql = "SELECT * FROM product WHERE 1=1"
    params = []

    if filters.get("name"):
     sql += " AND name LIKE %s"
     params.append("%" + filters["name"] + "%")

    if filters.get("category"):
     sql += " AND category = %s"
     params.append(filters["category"])
    return run_query(sql, params)
    

    # """ดึง สินค้า 1 รายการตาม product_id (ใช้ตอนเปิดฟอร์มแก้ไข)"""
    # # TODO: SELECT * FROM product WHERE product_id = %s แล้วคืนแถวเดียว
    # # _todo("get_product")

def get_product(product_id):
    rows = run_query(
        "SELECT * FROM product WHERE product_id = %s",
        (product_id,))
    return rows[0] if rows else None 




    # """เพิ่ม สินค้า ใหม่ — data มีคีย์: name, category, price, stock"""
    # # TODO: INSERT INTO product (...) VALUES (%s, ...)
    # _todo("create_product")
def create_product(data):
    return run_command(
        "INSERT INTO product (name, category, price, stock) "
        "VALUES (%s, %s, %s, %s)",
        (data["name"], data["category"], data["price"], data["stock"])
    )



    # """แก้ไข สินค้า ตาม product_id"""
    # # TODO: UPDATE product SET ... WHERE product_id=%s
    # _todo("update_product")
def update_product(product_id, data):
    return run_command(
        "UPDATE product SET name=%s, category=%s, "
        "price=%s, stock=%s WHERE product_id=%s",
        (data["name"], data["category"],
         data["price"], data["stock"], product_id)
    )



    # """ลบ สินค้า ตาม product_id"""
    # # TODO: DELETE FROM product WHERE product_id=%s
    # _todo("delete_product")
def delete_product(product_id):    
    return run_command(
        "DELETE FROM product WHERE product_id = %s",
        (product_id,)
    )
    
# ---------- ออเดอร์ (shop_order) ----------

    # """ค้นหา ออเดอร์ ตามเงื่อนไข (cust_id, status)
    # คำใบ้: เริ่มจาก sql = "SELECT * FROM shop_order WHERE 1=1"
    # แล้วต่อเงื่อนไขเฉพาะ filter ที่มีค่า (ข้อความใช้ LIKE %s, อื่น ๆ ใช้ = %s)"""
    # # TODO: เขียน SQL ค้นหาแบบยืดหยุ่นตาม filters (ใช้ %s เสมอ)
    # _todo("search_orders")
def search_orders(filters):
    sql = "SELECT * FROM shop_order WHERE 1=1"
    params = []

    # ค้นหาตามรหัสลูกค้า (ตัวเลข ใช้ = %s)
    if filters.get("cust_id"):
        sql += " AND cust_id = %s"
        params.append(filters["cust_id"])

    # ค้นหาตามสถานะ เช่น pending, shipped
    if filters.get("status"):
        sql += " AND status = %s"
        params.append(filters["status"])
        
    return run_query(sql, params)



    # """ดึง ออเดอร์ 1 รายการตาม order_id (ใช้ตอนเปิดฟอร์มแก้ไข)"""
    # # TODO: SELECT * FROM shop_order WHERE order_id = %s แล้วคืนแถวเดียว
    # _todo("get_order")
def get_order(order_id):
    ows = run_query(
        "SELECT * FROM shop_order WHERE order_id = %s",
        (order_id,))
    return ows[0] if ows else None


    # """เพิ่ม ออเดอร์ ใหม่ — data มีคีย์: cust_id, order_date, status"""
    # # TODO: INSERT INTO shop_order (...) VALUES (%s, ...)
    # _todo("create_order")
def create_order(data):
    return run_command(
        "INSERT INTO shop_order (cust_id, order_date, status) "
        "VALUES (%s, %s, %s)",
        (data["cust_id"], data["order_date"], data["status"]))



    # """แก้ไข ออเดอร์ ตาม order_id"""
    # # # TODO: UPDATE shop_order SET ... WHERE order_id=%s
    # # _todo("update_order")
def update_order(order_id, data):
    return run_command(
        "UPDATE shop_order SET cust_id=%s, order_date=%s, status=%s "
        "WHERE order_id=%s",
        (data["cust_id"], data["order_date"], data["status"], order_id))


    # """ลบ ออเดอร์ ตาม order_id"""
    # # TODO: DELETE FROM shop_order WHERE order_id=%s
    # _todo("delete_order")
def delete_order(order_id):
    return run_command(
        "DELETE FROM shop_order WHERE order_id =%s",
        (order_id,)
    )


# ============================================================
#  REPORT (รายงาน — ใช้ JOIN + GROUP BY + subquery)
# ============================================================

    # """ตัวเลขสรุปบนการ์ด dashboard — คืน dict เช่น {"customers": 10, ...}
    # คำใบ้: ใช้ COUNT(*) หลายครั้ง"""
    # # TODO: นับจำนวนรวมต่าง ๆ เพื่อแสดงบนการ์ด
    # _todo("report_summary")
def report_summary():
    customers = run_query("SELECT COUNT(*) AS customers FROM customer")[0]["customers"]
    products  = run_query("SELECT COUNT(*) AS products  FROM product")[0]["products"]
    orders    = run_query("SELECT COUNT(*) AS orders    FROM shop_order")[0]["orders"]
    reviews   = run_query("SELECT COUNT(*) AS reviews   FROM review")[0]["reviews"]
    return { "customers": customers,"products": products,"orders": orders,"reviews": reviews}    

    # """📈 สินค้าขายดี (Best Sellers)
    # คำใบ้: JOIN order_line→product, GROUP BY product, SUM(qty), ORDER BY DESC, LIMIT 5"""
    # # TODO: เขียน SQL รายงานนี้ (เขียน JOIN แบบ explicit INNER JOIN ... ON ...)
    # _todo("report_best_selling")
def report_best_selling():
    return run_query(
        "SELECT p.product_id, p.name, SUM(ol.qty) AS total_qty "
        "FROM order_line AS ol "
        "INNER JOIN product AS p ON ol.product_id = p.product_id "
        "GROUP BY p.product_id, p.name "
        "ORDER BY total_qty DESC "
        "LIMIT 5")    

    # """🏅 ลูกค้าที่ซื้อมากกว่าค่าเฉลี่ย (Above Average)
    # คำใบ้: JOIN shop_order→order_line, GROUP BY customer, HAVING SUM(qty*unit_price) > (subquery AVG)"""
    # # TODO: เขียน SQL รายงานนี้ (เขียน JOIN แบบ explicit INNER JOIN ... ON ...)
    # _todo("report_customers_above_avg")
def report_customers_above_avg():
    return run_query(
        "SELECT c.cust_id, c.name, SUM(ol.qty * ol.unit_price) AS total_spent "
        "FROM customer AS c "
        "INNER JOIN shop_order AS so ON c.cust_id = so.cust_id "
        "INNER JOIN order_line AS ol ON so.order_id = ol.order_id "
        "GROUP BY c.cust_id, c.name "
        "HAVING total_spent > ("
        "  SELECT AVG(per_cust.total) "
        "  FROM ("
        "    SELECT SUM(ol2.qty * ol2.unit_price) AS total "
        "    FROM shop_order AS so2 "
        "    INNER JOIN order_line AS ol2 ON so2.order_id = ol2.order_id "
        "    GROUP BY so2.cust_id"
        "  ) AS per_cust"
        ") "
        "ORDER BY total_spent DESC")    


    # """⭐ สินค้าคะแนนรีวิวเฉลี่ย ≥ 4 (HAVING)
    # คำใบ้: JOIN review→product, GROUP BY product, HAVING AVG(rating) >= 4"""
    # # TODO: เขียน SQL รายงานนี้ (เขียน JOIN แบบ explicit INNER JOIN ... ON ...)
    # _todo("report_high_rated")
def report_high_rated():
    return run_query(
        "SELECT p.product_id, p.name, AVG(r.rating) AS avg_rating, COUNT(*) AS review_count "
        "FROM review AS r "
        "INNER JOIN product AS p ON r.product_id = p.product_id "
        "GROUP BY p.product_id, p.name "
        "HAVING avg_rating >= 4 "
        "ORDER BY avg_rating DESC"
    )
