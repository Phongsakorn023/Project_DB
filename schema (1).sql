-- ============================================================
--  schema.sql — ร้านค้าออนไลน์ (นิสิตออกแบบและเขียนเอง)
--  กติกา: 1 ออเดอร์มีหลายสินค้า (M:N: order × product ผ่าน order_line),
--         รีวิว = M:N (customer × product), การชำระเงิน 1:M จาก shop_order
-- ============================================================
/*
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS shop_orderr;
DROP TABLE IF EXIST  review;
DROP TABLE IF EXISTS payment;
*/


CREATE TABLE customer (
    cust_id INT AUTO_INCREMENT PRIMARY KEY
    name  VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(120) UNIQUE,
    address VARCHAR(255),
    tier ENUM('ทั่วไป','VIP','VVIP')
    referred_by INT DEFAULT NULL, 
    FOREIGN KEY (referred_by) REFERENCES customer(cust_id) ON DELETE SET NULL

    -- TODO: name, email, address, tier  
);
   

    
CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY
    
    name VARCHAR(100) not NULL UNIQUE
    category VARCHAR(100),
    price DECIMAL(10,2),
    stock INT
-- TODO: name, category, price, stock
);

CREATE TABLE shop_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    cust_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
    -- TODO: cust_id (FK), order_date, status
);

CREATE TABLE order_line (         -- M:N: shop_order × product

    order_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES shop_order(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
    -- TODO: order_id (FK), product_id (FK), qty, unit_price ; PRIMARY KEY (order_id, product_id)
    order_id INT, product_id INT
);
CREATE TABLE review (
    cust_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    comment VARCHAR(255),
    review_date DATE NOT NULL,
    PRIMARY KEY (cust_id, product_id),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);
    
          -- M:N: customer × product
    -- TODO: cust_id (FK), product_id (FK), rating, comment, review_date ; PRIMARY KEY (cust_id, product_id)
    cust_id INT, product_id INT
);
CREATE TABLE payment (         
    
    CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    method VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    paid_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES shop_order(order_id)
);

      -- 1:M จาก shop_order
    payment_id INT AUTO_INCREMENT PRIMARY KEY
    -- TODO: order_id (FK), method, amount, paid_date
);
-- TODO: INSERT ข้อมูลตัวอย่างทุกตาราง

-- insert customer

INSERT INTO customer (name, email, address, tier)
VALUES
INSERT INTO customer (name, email, address, tier)
VALUES
('IU', 'iu@example.com', 'โซล', 'VIP'),
('Kim Soo-hyun', 'kimsoohyun@example.com', 'โซล', 'VIP'),
('Park Bo-gum', 'parkbogum@example.com', 'โซล', 'VIP'),
('Song Joong-ki', 'songjoongki@example.com', 'แดจอน', 'VIP'),
('Bae Suzy', 'suzy@example.com', 'กวางจู', 'ทั่วไป');

-- INSERT product

('IU Album', 'เพลง', 599.00, 20),
('Kim Soo-hyun Drama Box Set', 'ซีรีส์', 899.00, 10),
('Park Bo-gum Photo Book', 'หนังสือ', 499.00, 15),
('Song Joong-ki Poster', 'ของสะสม', 299.00, 25),
('Suzy Album', 'เพลง', 599.00, 18);

-- insert shop_order
INSERT INTO shop_order (cust_id, order_date, status)
VALUES
(1, '2026-09-29', 'ชำระเงินแล้ว'),
(2, '2026-09-29', 'จัดส่งแล้ว'),
(3, '2026-09-29', 'รอดำเนินการ'),
(4, '2026-09-30', 'ชำระเงินแล้ว'),
(5, '2026-09-30', 'จัดส่งแล้ว');

-- insert order_line 

INSERT INTO order_line (order_id, product_id, qty, unit_price)
VALUES
(1, 1, 1, 599.00),
(2, 2, 1, 899.00),
(3, 3, 2, 499.00),
(4, 4, 1, 299.00),
(5, 5, 1, 599.00);

-- insert review 

INSERT INTO review (cust_id, product_id, rating, comment, review_date)
VALUES
(1, 1, 5, 'ชอบมาก', '2026-09-29'),
(2, 2, 5, 'สินค้าน่าสนใจ', '2026-09-29'),
(3, 3, 4, 'คุณภาพดี', '2026-09-29'),
(4, 4, 5, 'ของสะสมสวยมาก', '2026-09-30'),
(5, 5, 5, 'ชอบเพลงมาก', '2026-09-30');

-- insert payment 

INSERT INTO payment (order_id, method, amount, paid_date)
VALUES
(1, 'โอนเงิน', 599.00, '2026-09-29'),
(2, 'บัตรเครดิต', 899.00, '2026-09-29'),
(3, 'พร้อมเพย์', 998.00, '2026-09-29'),
(4, 'โอนเงิน', 299.00, '2026-09-30'),
(5, 'พร้อมเพย์', 599.00, '2026-09-30');