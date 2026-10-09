-- ============================================================
--  schema.sql — ร้านค้าออนไลน์ (ปรับปรุง FK Actions, Default Values และออเดอร์ยกเลิก)
-- ============================================================

-- 1. ลบตารางเก่าทิ้งตามลำดับความสัมพันธ์ (ตารางลูกไปตารางแม่)
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS shop_order;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;

-- 2. สร้างตารางพร้อมกำหนด PK, FK และ constraints ให้ครบถ้วน
CREATE TABLE customer (
    cust_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(120) UNIQUE,
    address VARCHAR(255),
    tier ENUM('Classic', 'Silver', 'Gold', 'Premium') NOT NULL DEFAULT 'Classic',
    referred_by INT DEFAULT NULL,
    FOREIGN KEY (referred_by) REFERENCES customer(cust_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category ENUM('เสื้อ', 'กางเกง', 'รองเท้า') NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE shop_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('รอดำเนินการ', 'ชำระเงินแล้ว', 'จัดส่งแล้ว', 'ยกเลิก') NOT NULL DEFAULT 'รอดำเนินการ',
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE order_line (        
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL CHECK (qty > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES shop_order(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE review (
    cust_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment VARCHAR(255),
    review_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (cust_id, product_id),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE payment (  
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    method ENUM('โอนเงิน', 'บัตรเครดิต', 'พร้อมเพย์', 'เงินสด') NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    paid_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (order_id) REFERENCES shop_order(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 3. INSERT ข้อมูลตัวอย่างสำหรับทดสอบ
-- ============================================================

INSERT INTO customer (name, email, address, tier) VALUES
('IU', 'iu@example.com', 'โซล', 'Classic'),
('Kim Soo-hyun', 'kimsoohyun@example.com', 'โซล', 'Silver'),
('Park Bo-gum', 'parkbogum@example.com', 'โซล', 'Silver'),
('Song Joong-ki', 'songjoongki@example.com', 'แดจอน', 'Gold'),
('Bae Suzy', 'suzy@example.com', 'กวางจู', 'Premium'),
('Han So-hee', 'hansohee@example.com', 'ปูซาน', 'Classic');

INSERT INTO product (name, category, price, stock) VALUES
('Adidas Originals T-Shirt', 'เสื้อ', 1200.00, 20),
('Nike Sportswear Club Fleece', 'เสื้อ', 1800.00, 15),
('The North Face Windbreaker', 'เสื้อ', 3500.00, 10),
('Nike Dri-FIT Pants', 'กางเกง', 1500.00, 25),
('Adidas Track Pants', 'กางเกง', 2200.00, 18),
('New Balance 530', 'รองเท้า', 3900.00, 30),
('Nike Air Force 1', 'รองเท้า', 3700.00, 12),
('Adidas Ultraboost', 'รองเท้า', 6500.00, 8);

INSERT INTO shop_order (cust_id, order_date, status) VALUES
(1, '2026-09-29', 'ชำระเงินแล้ว'),
(2, '2026-09-29', 'จัดส่งแล้ว'),
(3, '2026-09-29', 'รอดำเนินการ'),
(4, '2026-09-30', 'ชำระเงินแล้ว'),
(5, '2026-09-30', 'จัดส่งแล้ว'),
(6, '2026-09-30', 'ยกเลิก');

INSERT INTO order_line (order_id, product_id, qty, unit_price) VALUES
(1, 1, 1, 1200.00),
(2, 6, 1, 3900.00),
(3, 4, 2, 1500.00),
(4, 3, 1, 3500.00),
(5, 7, 1, 3700.00),
(6, 2, 1, 1800.00);

INSERT INTO review (cust_id, product_id, rating, comment, review_date) VALUES
(1, 1, 5, 'เสื้อเนื้อผ้าดีมาก ใส่สบาย', '2026-09-29'),
(2, 6, 5, 'รองเท้าคุณภาพดี เดินไม่ปวดเท้า คุ้มราคา', '2026-09-29'),
(3, 4, 4, 'กางเกงทรงสวย พอดีตัว', '2026-09-29'),
(4, 3, 5, 'เสื้อกันลมได้ดีเยี่ยม สินค้าแท้แน่นอน', '2026-09-30'),
(5, 7, 5, 'รองเท้าสวยถูกใจมากครับ', '2026-09-30');

INSERT INTO payment (order_id, method, amount, paid_date) VALUES
(1, 'โอนเงิน', 1200.00, '2026-09-29'),
(2, 'บัตรเครดิต', 3900.00, '2026-09-29'),
(3, 'พร้อมเพย์', 3000.00, '2026-09-29'),
(4, 'เงินสด', 3500.00, '2026-09-30'),
(5, 'พร้อมเพย์', 3700.00, '2026-09-30');