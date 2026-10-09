
Conversation with Gemini
-- ============================================================

-- schema.sql — ร้านค้าออนไลน์ (ปรับปรุง FK Actions และ Default Values)

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

-- เปลี่ยน ENUM และ DEFAULT ให้ตรงกับข้อมูลใหม่

tier ENUM('Classic', 'Silver', 'Gold', 'Premium') NOT NULL DEFAULT 'Classic',

referred_by INT DEFAULT NULL,

FOREIGN KEY (referred_by) REFERENCES customer(cust_id) ON DELETE SET NULL ON UPDATE CASCADE

);



CREATE TABLE product (

product_id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(100) NOT NULL UNIQUE,

category ENUM('เสื้อ', 'กางเกง', 'รองเท้า') NOT NULL,

price DECIMAL(10,2) NOT NULL CHECK (price >= 0),

stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0) -- ป้องกันสต็อกติดลบจากการตัดสต็อก

);



CREATE TABLE shop_order (

order_id INT AUTO_INCREMENT PRIMARY KEY,

cust_id INT NOT NULL,

order_date DATE NOT NULL DEFAULT (CURRENT_DATE), -- กำหนดวันที่ปัจจุบันอัตโนมัติ

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

('Bae Suzy', 'suzy@example.com', 'กวางจู', 'Premium');



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

(5, '2026-09-30', 'จัดส่งแล้ว');

(6, '2026-09-30', 'ยกเลิก');



INSERT INTO order_line (order_id, product_id, qty, unit_price) VALUES

(1, 1, 1, 1200.00),

(2, 6, 1, 3900.00),

(3, 4, 2, 1500.00),

(4, 3, 1, 3500.00),

(5, 7, 1, 3700.00);



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

(5, 'พร้อมเพย์', 3700.00, '2026-09-30'); errorเพราะอะไรและต้องแก้ไขอะไรบ้าง 

จากรูปภาพสกรีนช็อตและโค้ดที่คุณให้มา Error [1452] Cannot add or update a child row: a foreign key constraint fails เกิดจากการที่คุณพยายามเพิ่มข้อมูลลงในตาราง payment (และตารางลูกอื่นๆ เช่น order_line) โดยอ้างอิง order_id 1 ถึง 5 ซึ่ง ไม่มีอยู่จริงในตาราง shop_order   
PNG
+ 1

สาเหตุหลักมาจากคำสั่ง INSERT INTO shop_order มีข้อผิดพลาด ทำให้การบันทึกข้อมูลเข้า shop_order ล้มเหลวตั้งแต่แรก ดังนี้ครับ:

❌ จุดที่ทำให้เกิด Error
มีเครื่องหมาย ; ผิดตำแหน่งและ Syntax ผิดพลาด:
ในคำสั่ง INSERT INTO shop_order ตรงบรรทัดที่ 5 จบประโยคด้วยเครื่องหมาย ; ไปแล้ว ทำให้บรรทัดที่ 6 (6, '2026-09-30', 'ยกเลิก'); กลายเป็นคำสั่งที่ผิดโครงสร้าง (Syntax Error)

ข้อมูล cust_id อ้างอิงตัวตนที่ไม่มีอยู่จริง:
แม้ว่าคุณจะเปลี่ยนเครื่องหมาย ; เป็น , เพื่อให้รันได้ แต่คำสั่งนี้ก็จะล้มเหลวอยู่ดี เพราะคุณพยายามเพิ่ม Order สำหรับ cust_id = 6 ซึ่งในตาราง customer ที่คุณ Insert ไว้ มีลูกค้าแค่ 5 คน (ID 1-5) การอ้างถึงคนที่ไม่มีอยู่จริงจึงทำให้ติด Foreign Key ทำให้ Insert ตาราง shop_order ไม่เข้าเลย

เมื่อตาราง shop_order ว่างเปล่า การรันคำสั่ง Insert ต่อมาใน order_line และ payment ที่ต้องใช้ order_id 1, 2, 3, 4, 5 จึงพังทั้งหมดและแจ้ง Error ตามรูป   
PNG

✅ วิธีแก้ไข
1. แก้ไขคำสั่ง INSERT INTO shop_order
ให้ลบข้อมูลบรรทัดที่ 6 ทิ้งไป (หรือถ้าต้องการเก็บไว้ ต้องเพิ่ม Customer คนที่ 6 ในตารางบนก่อน) และตรวจสอบให้บรรทัดสุดท้ายจบด้วย ; ตามปกติ:

SQL
INSERT INTO shop_order (cust_id, order_date, status) VALUES
(1, '2026-09-29', 'ชำระเงินแล้ว'),
(2, '2026-09-29', 'จัดส่งแล้ว'),
(3, '2026-09-29', 'รอดำเนินการ'),
(4, '2026-09-30', 'ชำระเงินแล้ว'),
(5, '2026-09-30', 'จัดส่งแล้ว');
-- ลบข้อมูล (6, '2026-09-30', 'ยกเลิก'); ออก
2. รันสคริปต์ใหม่ทั้งหมดตั้งแต่ต้น (สำคัญมาก)
เนื่องจากระบบพยายาม Insert ไปแล้วแต่ล้มเหลว ค่า AUTO_INCREMENT ของตาราง shop_order อาจจะถูกข้ามและไม่เริ่มที่เลข 1 แล้ว (อาจจะเริ่มที่ 6 หรือมากกว่า) หากคุณกลับไปแก้ไขแค่ Insert แล้วรันเลย ก็จะยังคง Error อยู่

แนะนำให้คลุมดำแล้วรันใหม่ทั้งหมดตั้งแต่คำสั่ง DROP TABLE บนสุด เพื่อเป็นการรีเซ็ตตารางและรีเซ็ตค่ารันนิ่งนัมเบอร์ (order_id) ให้กลับมาเริ่มที่ 1 ใหม่อีกครั้งครับ

ฉันเป็น AI ที่ทำงานตามข้อความโต้ตอบ คำถามนี้เกินความสามารถของฉัน

errorเพราะอะไรและต้องแก้ไขอะไรบ้าง 

จากรูปภาพที่คุณส่งมา Error [1062] Duplicate entry '1-1' for key 'review.PRIMARY' เกิดจากสาเหตุดังนี้ครับ:   
PNG

❌ สาเหตุของ Error
ตาราง review มีการตั้งค่า Primary Key ร่วมกันระหว่าง cust_id และ product_id (ลูกค้า 1 คน รีวิวสินค้า 1 ชิ้นได้แค่ครั้งเดียว)
Error นี้ฟ้องว่าในตาราง review มีข้อมูลของลูกค้ารหัส 1 (cust_id=1) ที่รีวิวสินค้ารหัส 1 (product_id=1) อยู่แล้ว การที่คุณกดรันคำสั่ง INSERT INTO review ซ้ำอีกครั้ง ระบบจึงมองว่าคุณกำลังพยายามใส่ข้อมูลที่ซ้ำซ้อนกับของเดิมที่มีอยู่แล้วครับ   
PNG

✅ วิธีแก้ไข
คุณสามารถเลือกทำตามวิธีใดวิธีหนึ่งดังต่อไปนี้ครับ:

วิธีที่ 1: ข้ามคำสั่งนี้ไปเลย (ถ้าข้อมูลเข้าครบแล้ว)
หากคุณเคยรันคำสั่งนี้ผ่านไปแล้วในรอบก่อนหน้า แปลว่าข้อมูลรีวิวทั้ง 5 รายการเข้าไปอยู่ในตารางเรียบร้อยแล้ว คุณสามารถข้ามไปรันคำสั่ง INSERT INTO payment บรรทัดถัดไปได้เลยครับ

วิธีที่ 2: รันสคริปต์ใหม่ทั้งหมดตั้งแต่ต้น (แนะนำสำหรับการทดสอบ)
หากคุณมีการแก้ไขข้อมูลและต้องการรีเซ็ตใหม่ทั้งหมด แนะนำให้:

เลื่อนขึ้นไปบนสุดของไฟล์

คลุมดำและรันตั้งแต่คำสั่ง DROP TABLE ... และ CREATE TABLE ... ทั้งหมดลงมา

จากนั้นค่อยรันคำสั่ง INSERT ใหม่ทั้งหมดรวดเดียว วิธีนี้จะเป็นการล้างตารางเก่าทิ้งและสร้างใหม่ ทำให้ไม่มีข้อมูลซ้ำตกค้างครับ

ขออันที่แก้สำเร็จแล้ว

นี่คือโค้ด SQL ที่แก้ไขข้อผิดพลาดทั้งหมดให้เรียบร้อยแล้วครับ คุณสามารถคัดลอกโค้ดทั้งหมดนี้ไปรันใหม่ตั้งแต่บรรทัดแรก (DROP TABLE) เพื่อเป็นการรีเซ็ตข้อมูลและป้องกันปัญหาข้อมูลซ้ำซ้อนครับ

SQL
-- ============================================================
--  schema.sql — ร้านค้าออนไลน์ (ปรับปรุง FK Actions และ Default Values)
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
('Bae Suzy', 'suzy@example.com', 'กวางจู', 'Premium');

INSERT INTO product (name, category, price, stock) VALUES
('Adidas Originals T-Shirt', 'เสื้อ', 1200.00, 20),
('Nike Sportswear Club Fleece', 'เสื้อ', 1800.00, 15),
('The North Face Windbreaker', 'เสื้อ', 3500.00, 10),
('Nike Dri-FIT Pants', 'กางเกง', 1500.00, 25),
('Adidas Track Pants', 'กางเกง', 2200.00, 18),
('New Balance 530', 'รองเท้า', 3900.00, 30),
('Nike Air Force 1', 'รองเท้า', 3700.00, 12),
('Adidas Ultraboost', 'รองเท้า', 6500.00, 8);

-- แก้ไข: ลบข้อมูลของลูกค้าคนที่ 6 ออก และปิดท้ายด้วย ; ให้ถูกต้อง
INSERT INTO shop_order (cust_id, order_date, status) VALUES
(1, '2026-09-29', 'ชำระเงินแล้ว'),
(2, '2026-09-29', 'จัดส่งแล้ว'),
(3, '2026-09-29', 'รอดำเนินการ'),
(4, '2026-09-30', 'ชำระเงินแล้ว'),
(5, '2026-09-30', 'จัดส่งแล้ว');

INSERT INTO order_line (order_id, product_id, qty, unit_price) VALUES
(1, 1, 1, 1200.00),
(2, 6, 1, 3900.00),
(3, 4, 2, 1500.00),
(4, 3, 1, 3500.00),
(5, 7, 1, 3700.00);

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
คำแนะนำเพิ่มเติม:
ในโปรแกรม DBeaver แนะนำให้กดปุ่ม Execute SQL Script (Alt + X) เพื่อให้โปรแกรมรันโค้ดทั้งหมดรวดเดียวตั้งแต่ต้นจนจบ จะช่วยให้ลำดับการสร้างตารางและการรันนิ่งรหัสต่างๆ (Auto Increment) เรียงกันอย่างสมบูรณ์แบบครับ

จากภาพ "สกรีนช็อต 2026-10-09 220201.png" ข้อผิดพลาด ERROR: Could not open requirements file: [Errno 2] No such file or directory: 'requirements.txt' เกิดจากระบบไม่พบไฟล์ชื่อ requirements.txt ในโฟลเดอร์ปัจจุบันที่คุณกำลังเปิดใช้งานอยู่ (คือ C:\Users\LENOVO\Desktop\Project_DB\Project_DB)   
PNG
+ 1

วิธีแก้ไขที่อาจเป็นไปได้มีดังนี้:

ตรวจสอบตำแหน่งที่อยู่ไฟล์: โฟลเดอร์ใน Terminal ของคุณซ้อนกันอยู่ 2 ชั้น (Project_DB\Project_DB) ไฟล์ requirements.txt อาจจะอยู่ในโฟลเดอร์ชั้นนอก หากเป็นเช่นนั้น ให้พิมพ์คำสั่ง cd .. ใน Terminal แล้วกด Enter เพื่อถอยกลับไปโฟลเดอร์ชั้นนอก จากนั้นจึงรันคำสั่ง pip install -r requirements.txt ใหม่อีกครั้ง   
PNG
+ 1

ตรวจสอบการสะกดชื่อไฟล์: ตรวจสอบในแถบไฟล์ทางซ้ายมือของ VS Code ว่าสะกดชื่อไฟล์ถูกต้องหรือไม่ (มีตัว s หรือเผลอตั้งชื่อซ้อนเป็น .txt.txt หรือไม่)

ตรวจสอบการมีอยู่ของไฟล์: หากคุณเพิ่งเริ่มโปรเจกต์และยังไม่ได้สร้างไฟล์นี้ คุณต้องสร้างไฟล์ชื่อ requirements.txt ขึ้นมาเองในโฟลเดอร์ที่ถูกต้อง และใส่ชื่อไลบรารีที่ต้องการติดตั้ง (เช่น flask, pymysql) ลงไปในไฟล์ก่อนรันคำสั่งครับ

INSERT INTO shop_order (cust_id, order_date, status) VALUES

(1, '2026-09-29', 'ชำระเงินแล้ว'),

(2, '2026-09-29', 'จัดส่งแล้ว'),

(3, '2026-09-29', 'รอดำเนินการ'),

(4, '2026-09-30', 'ชำระเงินแล้ว'),

(5, '2026-09-30', 'จัดส่งแล้ว'); ทำcust id 6 ให้เป็นยกเลิก และให้เมคเซนต์

การที่จะเพิ่มคำสั่งซื้อของ cust_id = 6 เป็น 'ยกเลิก' ให้สมเหตุสมผล (Make sense) และ ไม่ติด Error Foreign Key แบบที่เคยเกิดขึ้น คุณจำเป็นต้อง เพิ่มข้อมูลลูกค้าคนที่ 6 ลงในตาราง customer ก่อน ครับ ไม่อย่างนั้นระบบจะฟ้องว่าไม่มีลูกค้าคนนี้อยู่ในระบบ

เพื่อให้ดูสมจริง ผมจะเพิ่มข้อมูลลูกค้าคนที่ 6 ลงไป และเพิ่มรายการสินค้าในตะกร้า (order_line) ให้ด้วย เพื่อให้เห็นภาพว่า "ลูกค้ากดสั่งสินค้าลงตะกร้าแล้ว แต่กดยกเลิกในภายหลัง" (จึงยังไม่มีข้อมูลโผล่ในตาราง payment)

นี่คือโค้ดที่คุณต้องนำไปอัปเดตครับ:

1. อัปเดตตาราง customer (เพิ่มลูกค้าคนที่ 6)
เพิ่มลูกค้าคนที่ 6 (เช่น Han So-hee) ต่อท้ายข้อมูลเดิม

SQL
INSERT INTO customer (name, email, address, tier) VALUES
('IU', 'iu@example.com', 'โซล', 'Classic'),
('Kim Soo-hyun', 'kimsoohyun@example.com', 'โซล', 'Silver'),
('Park Bo-gum', 'parkbogum@example.com', 'โซล', 'Silver'),
('Song Joong-ki', 'songjoongki@example.com', 'แดจอน', 'Gold'),
('Bae Suzy', 'suzy@example.com', 'กวางจู', 'Premium'),
('Han So-hee', 'hansohee@example.com', 'ปูซาน', 'Classic'); -- เพิ่มลูกค้าคนที่ 6
2. อัปเดตตาราง shop_order (เพิ่มออเดอร์ที่ 6 เป็นยกเลิก)
ตอนนี้เรามี cust_id 6 แล้ว สามารถเพิ่มคำสั่งซื้อสถานะ 'ยกเลิก' ได้เลยโดยไม่ติด Error

SQL
INSERT INTO shop_order (cust_id, order_date, status) VALUES
(1, '2026-09-29', 'ชำระเงินแล้ว'),
(2, '2026-09-29', 'จัดส่งแล้ว'),
(3, '2026-09-29', 'รอดำเนินการ'),
(4, '2026-09-30', 'ชำระเงินแล้ว'),
(5, '2026-09-30', 'จัดส่งแล้ว'),
(6, '2026-09-30', 'ยกเลิก'); -- ออเดอร์ของลูกค้าคนที่ 6 (Make sense เพราะมีตัวตนแล้ว)
3. อัปเดตตาราง order_line (ใส่สินค้าในออเดอร์ที่ยกเลิก)
เพื่อให้สมเหตุสมผล ว่าเขายกเลิกอะไรไป เราควรเพิ่มรายการสินค้าลงในออเดอร์ที่ 6 ด้วย

SQL
INSERT INTO order_line (order_id, product_id, qty, unit_price) VALUES
(1, 1, 1, 1200.00),
(2, 6, 1, 3900.00),
(3, 4, 2, 1500.00),
(4, 3, 1, 3500.00),
(5, 7, 1, 3700.00),
(6, 2, 1, 1800.00); -- ลูกค้าคนที่ 6 สั่งสินค้ารหัส 2 (Nike Sportswear) แต่ยกเลิก
หมายเหตุ: สำหรับตาราง payment (การชำระเงิน) ไม่ต้องเพิ่มข้อมูลของออเดอร์ที่ 6 เข้าไปนะครับ เพราะในเมื่อสถานะคำสั่งซื้อคือ "ยกเลิก" ก็แปลว่าลูกค้ายกเลิกไปก่อนที่จะมีการชำระเงินสำเร็จ (หรืออาจจะกดยกเลิกเองในหน้าตะกร้า) การไม่มีข้อมูลในตาราง Payment จึงสมเหตุสมผลที่สุดครับ

ขอโค้ดสมบูรณ์ พร้อม insert

คัดลอกโค้ด SQL ทั้งหมดด้านล่างนี้ไปรันใหม่รวดเดียวตั้งแต่บรรทัดแรก เพื่อรีเซ็ตโครงสร้างตารางและนำเข้าข้อมูลตัวอย่างทั้งหมดอย่างสมบูรณ์

SQL
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


