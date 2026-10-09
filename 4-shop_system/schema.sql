
-- ============================================================
-- schema.sql : ไฟล์กำหนดโครงสร้างฐานข้อมูลร้านค้าออนไลน์
-- ใช้สร้างตาราง กำหนดความสัมพันธ์ และเพิ่มข้อมูลตัวอย่าง
-- ============================================================


-- 1. ลบตารางเก่าก่อนสร้างใหม่
-- ต้องลบตารางลูกก่อนตารางแม่ เพราะตารางลูกมี Foreign Key อ้างอิงอยู่

DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS shop_order;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;


-- 2. ตาราง customer : เก็บข้อมูลลูกค้า
CREATE TABLE customer (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    -- รหัสลูกค้า เพิ่มเลขอัตโนมัติ และเป็น Primary Key

    name VARCHAR(100) NOT NULL UNIQUE,
    -- ชื่อลูกค้า ห้ามเป็นค่าว่าง และห้ามซ้ำกัน

    email VARCHAR(120) UNIQUE,
    -- อีเมล ห้ามซ้ำกัน แต่สามารถเป็น NULL ได้

    address VARCHAR(255),
    -- ที่อยู่ลูกค้า ไม่บังคับกรอก

    tier ENUM('ทั่วไป', 'VIP', 'VVIP')
        NOT NULL DEFAULT 'ทั่วไป',
    -- ระดับสมาชิก เลือกได้ 3 ระดับ
    -- ถ้าไม่ระบุ จะกำหนดเป็น 'ทั่วไป'

    referred_by INT DEFAULT NULL,
    -- รหัสลูกค้าที่แนะนำลูกค้าคนนี้เข้ามา
    -- เป็น NULL ได้ หากไม่มีผู้แนะนำ

    FOREIGN KEY (referred_by)
        REFERENCES customer(cust_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
    -- Foreign Key อ้างอิงรหัสลูกค้าจากตารางเดียวกัน
    -- ลบผู้แนะนำแล้วเปลี่ยน referred_by เป็น NULL
    -- หากรหัสที่อ้างอิงเปลี่ยน ให้ปรับค่าตามอัตโนมัติ

);


-- 3. ตาราง product : เก็บข้อมูลสินค้า
CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    -- รหัสสินค้า เพิ่มอัตโนมัติและไม่ซ้ำกัน

    name VARCHAR(100) NOT NULL UNIQUE,
    -- ชื่อสินค้า ห้ามว่างและห้ามซ้ำกัน

    category ENUM('เสื้อ', 'กางเกง', 'รองเท้า') NOT NULL,
    -- ประเภทสินค้าที่อนุญาตให้เลือก

    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    -- ราคาสินค้า เก็บทศนิยม 2 ตำแหน่ง
    -- CHECK ป้องกันราคาติดลบ

    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
    -- จำนวนสินค้าคงเหลือ เริ่มต้นเป็น 0 หากไม่ระบุ
    -- CHECK ป้องกันการบันทึกสต็อกเป็นค่าติดลบ
);


-- 4. ตาราง shop_order : เก็บคำสั่งซื้อของลูกค้า
CREATE TABLE shop_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    -- รหัสคำสั่งซื้อ เพิ่มอัตโนมัติ

    cust_id INT NOT NULL,
    -- รหัสลูกค้าที่เป็นเจ้าของคำสั่งซื้อนี้

    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    -- วันที่สั่งซื้อ หากไม่ระบุให้ใช้วันที่ปัจจุบัน

    status ENUM(
        'รอดำเนินการ',
        'ชำระเงินแล้ว',
        'จัดส่งแล้ว',
        'ยกเลิก'
    ) NOT NULL DEFAULT 'รอดำเนินการ',
    -- สถานะคำสั่งซื้อ เลือกได้จาก 4 สถานะ
    -- ค่าเริ่มต้นคือ 'รอดำเนินการ'

    FOREIGN KEY (cust_id)
        REFERENCES customer(cust_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    -- คำสั่งซื้อต้องอ้างอิงลูกค้าที่มีอยู่จริง
    -- RESTRICT ป้องกันการลบลูกค้าที่ยังมีคำสั่งซื้อ
    -- CASCADE ปรับรหัสลูกค้าตาม หากรหัสที่อ้างอิงเปลี่ยน
);


-- 5. ตาราง order_line : เก็บรายละเอียดสินค้าในคำสั่งซื้อ
CREATE TABLE order_line (
    order_id INT NOT NULL,
    -- รหัสคำสั่งซื้อที่รายละเอียดนี้สังกัดอยู่

    product_id INT NOT NULL,
    -- รหัสสินค้าที่ถูกสั่งซื้อ

    qty INT NOT NULL CHECK (qty > 0),
    -- จำนวนสินค้าที่สั่ง ต้องมากกว่า 0

    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    -- ราคาต่อหน่วย ณ เวลาที่สั่งซื้อ
    -- เก็บราคาไว้ในรายการสั่งซื้อโดยตรง

    PRIMARY KEY (order_id, product_id),
    -- Composite Primary Key ใช้ 2 คอลัมน์ร่วมกันเป็นกุญแจหลัก
    -- ป้องกันสินค้ารหัสเดิมซ้ำในคำสั่งซื้อเดียวกัน

    FOREIGN KEY (order_id)
        REFERENCES shop_order(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- เมื่อลบคำสั่งซื้อ ให้ลบรายละเอียดของคำสั่งซื้อนั้นด้วย

    FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
    -- ห้ามลบสินค้าที่ยังมีรายการสั่งซื้ออ้างอิงอยู่
);


-- 6. ตาราง review : เก็บรีวิวสินค้าจากลูกค้า
CREATE TABLE review (
    cust_id INT NOT NULL,
    -- รหัสลูกค้าที่เขียนรีวิว

    product_id INT NOT NULL,
    -- รหัสสินค้าที่ถูกรีวิว

    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    -- คะแนนรีวิว ต้องอยู่ระหว่าง 1 ถึง 5

    comment VARCHAR(255),
    -- ข้อความรีวิว ไม่บังคับกรอก

    review_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    -- วันที่รีวิว หากไม่ระบุให้ใช้วันที่ปัจจุบัน

    PRIMARY KEY (cust_id, product_id),
    -- ลูกค้าหนึ่งคนมีรีวิวได้หนึ่งรายการต่อสินค้าหนึ่งชิ้น

    FOREIGN KEY (cust_id)
        REFERENCES customer(cust_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- เมื่อลบลูกค้า รีวิวของลูกค้าคนนั้นจะถูกลบด้วย

    FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    -- เมื่อลบสินค้า รีวิวที่อ้างอิงสินค้านั้นจะถูกลบด้วย
);


-- 7. ตาราง payment : เก็บข้อมูลการชำระเงิน
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    -- รหัสการชำระเงิน เพิ่มอัตโนมัติ

    order_id INT NOT NULL,
    -- รหัสคำสั่งซื้อที่ชำระเงิน

    method ENUM('โอนเงิน', 'บัตรเครดิต', 'พร้อมเพย์', 'เงินสด') NOT NULL,
    -- วิธีชำระเงินที่อนุญาตให้เลือก

    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    -- จำนวนเงินที่ชำระ ต้องไม่ติดลบ

    paid_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    -- วันที่ชำระเงิน หากไม่ระบุให้ใช้วันที่ปัจจุบัน

    FOREIGN KEY (order_id)
        REFERENCES shop_order(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    -- หากลบคำสั่งซื้อ ข้อมูลการชำระเงินที่เกี่ยวข้องจะถูกลบด้วย
);


-- ============================================================
-- 8. เพิ่มข้อมูลตัวอย่างสำหรับทดลองใช้งาน
-- INSERT ใช้เพิ่มข้อมูลลงในตาราง
-- ============================================================


-- เพิ่มข้อมูลลูกค้า 5 คน
-- ระบุเฉพาะคอลัมน์ที่ต้องการใส่ข้อมูล
-- cust_id ไม่ต้องใส่ เพราะ AUTO_INCREMENT สร้างให้
INSERT INTO customer (name, email, address, tier) VALUES
('IU', 'iu@example.com', 'โซล', 'VIP'),
('Kim Soo-hyun', 'kimsoohyun@example.com', 'โซล', 'VIP'),
('Park Bo-gum', 'parkbogum@example.com', 'โซล', 'VIP'),
('Song Joong-ki', 'songjoongki@example.com', 'แดจอน', 'VIP'),
('Bae Suzy', 'suzy@example.com', 'กวางจู', 'ทั่วไป');


-- เพิ่มข้อมูลสินค้า 8 รายการ
INSERT INTO product (name, category, price, stock) VALUES
('Adidas Originals T-Shirt', 'เสื้อ', 1200.00, 20),
('Nike Sportswear Club Fleece', 'เสื้อ', 1800.00, 15),
('The North Face Windbreaker', 'เสื้อ', 3500.00, 10),
('Nike Dri-FIT Pants', 'กางเกง', 1500.00, 25),
('Adidas Track Pants', 'กางเกง', 2200.00, 18),
('New Balance 530', 'รองเท้า', 3900.00, 30),
('Nike Air Force 1', 'รองเท้า', 3700.00, 12),
('Adidas Ultraboost', 'รองเท้า', 6500.00, 8);


-- เพิ่มคำสั่งซื้อ 5 รายการ
-- cust_id 1-5 ต้องมีอยู่ในตาราง customer ก่อน
INSERT INTO shop_order (cust_id, order_date, status) VALUES
(1, '2026-09-29', 'ชำระเงินแล้ว'),
(2, '2026-09-29', 'จัดส่งแล้ว'),
(3, '2026-09-29', 'รอดำเนินการ'),
(4, '2026-09-30', 'ชำระเงินแล้ว'),
(5, '2026-09-30', 'จัดส่งแล้ว');


-- เพิ่มรายละเอียดสินค้าในแต่ละคำสั่งซื้อ
-- order_id และ product_id ต้องมีอยู่จริง
INSERT INTO order_line (order_id, product_id, qty, unit_price) VALUES
(1, 1, 1, 1200.00),
(2, 6, 1, 3900.00),
(3, 4, 2, 1500.00),
(4, 3, 1, 3500.00),
(5, 7, 1, 3700.00);


-- เพิ่มรีวิวจากลูกค้า
-- คะแนนต้องอยู่ระหว่าง 1-5
INSERT INTO review (cust_id, product_id, rating, comment, review_date) VALUES
(1, 1, 5, 'เสื้อเนื้อผ้าดีมาก ใส่สบาย', '2026-09-29'),
(2, 6, 5, 'รองเท้าคุณภาพดี เดินไม่ปวดเท้า คุ้มราคา', '2026-09-29'),
(3, 4, 4, 'กางเกงทรงสวย พอดีตัว', '2026-09-29'),
(4, 3, 5, 'เสื้อกันลมได้ดีเยี่ยม สินค้าแท้แน่นอน', '2026-09-30'),
(5, 7, 5, 'รองเท้าสวยถูกใจมากครับ', '2026-09-30');


-- เพิ่มข้อมูลการชำระเงินของแต่ละคำสั่งซื้อ
-- order_id ต้องตรงกับคำสั่งซื้อที่มีอยู่จริง
INSERT INTO payment (order_id, method, amount, paid_date) VALUES
(1, 'โอนเงิน', 1200.00, '2026-09-29'),
(2, 'บัตรเครดิต', 3900.00, '2026-09-29'),
(3, 'พร้อมเพย์', 3000.00, '2026-09-29'),
(4, 'เงินสด', 3500.00, '2026-09-30'),
(5, 'พร้อมเพย์', 3700.00, '2026-09-30');