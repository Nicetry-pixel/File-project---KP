-- ==========================================
-- 1. СОЗДАНИЕ ТАБЛИЦ (DDL)
-- ==========================================

-- Таблица ролей
USE `electrical store`;
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Таблица пользователей (пароли в открытом виде, как вы просили)
USE `electrical store`;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    role_id INT NOT NULL,
    hire_date DATE,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);
USE `electrical store`;
-- Поставщики
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    inn VARCHAR(12),
    kpp VARCHAR(9),
    payment_terms TEXT,
    delivery_terms TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
USE `electrical store`;
-- Категории
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);
USE `electrical store`;
-- Товары
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    category_id INT,
    brand VARCHAR(100),
    description TEXT,
    purchase_price DECIMAL(10,2) NOT NULL,
    retail_price DECIMAL(10,2) NOT NULL,
    warranty_months INT DEFAULT 12,
    voltage VARCHAR(20),
    power_watt INT,
    is_certified TINYINT(1) DEFAULT 0,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);
USE `electrical store`;
-- Склад
CREATE TABLE stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT DEFAULT 0,
    reserved_quantity INT DEFAULT 0,
    min_stock_level INT DEFAULT 0,
    location VARCHAR(50),
    last_inventory_date DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
USE `electrical store`;
-- Заказы
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_name VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20),
    customer_email VARCHAR(100),
    seller_id INT,
    status ENUM('new', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'new',
    total_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    payment_method ENUM('cash', 'card', 'online', 'bank_transfer') DEFAULT 'card',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE SET NULL
);
USE `electrical store`;
-- Позиции заказов
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);
USE `electrical store`;
-- Поставки
CREATE TABLE supplies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supply_number VARCHAR(50) NOT NULL UNIQUE,
    supplier_id INT NOT NULL,
    merchandiser_id INT,
    total_cost DECIMAL(12,2) DEFAULT 0,
    status ENUM('ordered', 'in_transit', 'received', 'cancelled') DEFAULT 'ordered',
    invoice_file VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    received_at TIMESTAMP NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE RESTRICT,
    FOREIGN KEY (merchandiser_id) REFERENCES users(id) ON DELETE SET NULL
);
USE `electrical store`;
-- Позиции поставок
CREATE TABLE supply_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supply_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    quality_status ENUM('pending', 'passed', 'failed') DEFAULT 'pending',
    FOREIGN KEY (supply_id) REFERENCES supplies(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- ==========================================
-- 2. НАПОЛНЕНИЕ ДАННЫМИ (DML)
-- ==========================================

-- Роли
INSERT INTO roles (id, name) VALUES
(1, 'администратор'),
(2, 'товаровед'),
(3, 'клиент'),
(4, 'продавец'),
(5, 'менеджер');

-- Пользователи (Реалистичные логины и пароли)
INSERT INTO users (id, login, password, full_name, email, phone, role_id, hire_date, is_active) VALUES
-- Администраторы
(1, 'i.ivanov', 'Ivanov_A!2020', 'Иванов Иван Иванович', 'i.ivanov@electro.ru', '+7 (999) 123-45-67', 1, '2020-01-15', 1),
(5, 'd.kuznetsov', 'Kuznetsov_D#21', 'Кузнецов Дмитрий Александрович', 'd.kuznetsov@electro.ru', '+7 (999) 000-00-05', 1, '2021-05-15', 1),
(6, 'e.popova', 'PopovaE_1990', 'Попова Елена Владимировна', 'e.popova@electro.ru', '+7 (999) 000-00-06', 1, '2022-01-20', 1),
-- Продавцы
(2, 's.petrov', 'PetrovS_88', 'Петров Сергей Николаевич', 's.petrov@electro.ru', '+7 (999) 234-56-78', 4, '2021-03-10', 1),
-- Менеджеры
(4, 'a.smirnov', 'Smirnov_Mngr', 'Смирнов Алексей Дмитриевич', 'a.smirnov@electro.ru', '+7 (999) 456-78-90', 5, '2019-11-20', 1),
-- Товароведы
(3, 'm.sidorova', 'SidorovaM_22', 'Сидорова Мария Алексеевна', 'm.sidorova@electro.ru', '+7 (999) 345-67-89', 2, '2022-06-01', 1),
(7, 's.vasiliev', 'VasilievS_1', 'Васильев Сергей Петрович', 's.vasiliev@electro.ru', '+7 (999) 000-00-07', 2, '2021-06-10', 1),
(8, 'm.sokolov', 'SokolovM_21', 'Соколов Михаил Андреевич', 'm.sokolov@electro.ru', '+7 (999) 000-00-08', 2, '2021-07-22', 1),
(9, 'a.mikhailov', 'MikhailovA_2', 'Михайлов Артем Игоревич', 'a.mikhailov@electro.ru', '+7 (999) 000-00-09', 2, '2022-02-14', 1),
(10, 'i.novikov', 'NovikovI_22', 'Новиков Илья Дмитриевич', 'i.novikov@electro.ru', '+7 (999) 000-00-10', 2, '2022-03-30', 1),
(11, 'k.fedorov', 'FedorovK_22', 'Федоров Кирилл Алексеевич', 'k.fedorov@electro.ru', '+7 (999) 000-00-11', 2, '2022-08-05', 1),
(12, 'n.morozov', 'MorozovN_23', 'Морозов Никита Сергеевич', 'n.morozov@electro.ru', '+7 (999) 000-00-12', 2, '2023-01-15', 1),
(13, 'm.volkov', 'VolkovM_23', 'Волков Матвей Андреевич', 'm.volkov@electro.ru', '+7 (999) 000-00-13', 2, '2023-04-20', 1),
(14, 'r.alekseev', 'AlekseevR_23', 'Алексеев Роман Павлович', 'r.alekseev@electro.ru', '+7 (999) 000-00-14', 2, '2023-09-01', 1),
-- Клиенты (40 человек, реалистичные данные)
(15, 'ekaterina.l', 'Lebedeva_1995', 'Лебедева Екатерина Викторовна', 'ekaterina.l@mail.ru', '+7 (999) 111-11-15', 3, '2023-01-10', 1),
(16, 'anna_sem', 'Semenova!88', 'Семенова Анна Павловна', 'anna.sem@mail.ru', '+7 (999) 111-11-16', 3, '2023-01-12', 1),
(17, 'daria.egorova', 'EgorovaD_00', 'Егорова Дарья Максимовна', 'd.egorova@mail.ru', '+7 (999) 111-11-17', 3, '2023-01-15', 1),
(18, 'alina_pavlova', 'Pavlova_Alina', 'Павлова Алина Олеговна', 'alina.p@mail.ru', '+7 (999) 111-11-18', 3, '2023-01-20', 1),
(19, 'ksenia.k', 'Kozlova1999', 'Козлова Ксения Игоревна', 'ksenia.k@mail.ru', '+7 (999) 111-11-19', 3, '2023-02-01', 1),
(20, 'nastya_step', 'Stepanova_20', 'Степанова Анастасия Андреевна', 'a.stepanova@mail.ru', '+7 (999) 111-11-20', 3, '2023-02-05', 1),
(21, 'vika.nikol', 'NikolaevaV', 'Николаева Виктория Сергеевна', 'vika.n@mail.ru', '+7 (999) 111-11-21', 3, '2023-02-10', 1),
(22, 'polina_orlova', 'OrlovaPolina', 'Орлова Полина Дмитриевна', 'p.orlova@mail.ru', '+7 (999) 111-11-22', 3, '2023-02-15', 1),
(23, 'sofia.andreeva', 'AndreevaS_01', 'Андреева София Алексеевна', 'sofia.a@mail.ru', '+7 (999) 111-11-23', 3, '2023-02-20', 1),
(24, 'lera.makarova', 'MakarovaLera', 'Макарова Валерия Петровна', 'lera.m@mail.ru', '+7 (999) 111-11-24', 3, '2023-03-01', 1),
(25, 'tanya.nikitina', 'NikitinaT_95', 'Никитина Татьяна Владимировна', 't.nikitina@mail.ru', '+7 (999) 111-11-25', 3, '2023-03-05', 1),
(26, 'olga.zakh', 'Zakharova_Olga', 'Захарова Ольга Николаевна', 'o.zakharova@mail.ru', '+7 (999) 111-11-26', 3, '2023-03-10', 1),
(27, 'natalia.z', 'ZaitsevaN_1990', 'Зайцева Наталья Степановна', 'n.zaitseva@mail.ru', '+7 (999) 111-11-27', 3, '2023-03-15', 1),
(28, 'julia.sol', 'Solovieva_Julia', 'Соловьева Юлия Андреевна', 'j.solovieva@mail.ru', '+7 (999) 111-11-28', 3, '2023-03-20', 1),
(29, 'sveta.b', 'Borisova_Sveta', 'Борисова Светлана Валентиновна', 's.borisova@mail.ru', '+7 (999) 111-11-29', 3, '2023-04-01', 1),
(30, 'margo.yakovleva', 'YakovlevaM', 'Яковлева Маргарита Егоровна', 'm.yakovleva@mail.ru', '+7 (999) 111-11-30', 3, '2023-04-05', 1),
(31, 'luda.grig', 'GrigorievaL_98', 'Григорьева Людмила Дмитриевна', 'l.grigorieva@mail.ru', '+7 (999) 111-11-31', 3, '2023-04-10', 1),
(32, 'irina.romanova', 'Romanova_Irina', 'Романова Ирина Сергеевна', 'i.romanova@mail.ru', '+7 (999) 111-11-32', 3, '2023-04-15', 1),
(33, 'elena.vorobieva', 'VorobievaE', 'Воробьева Елена Игоревна', 'e.vorobieva@mail.ru', '+7 (999) 111-11-33', 3, '2023-04-20', 1),
(34, 'oksana.sergeeva', 'Sergeeva_Oxana', 'Сергеева Оксана Павловна', 'o.sergeeva@mail.ru', '+7 (999) 111-11-34', 3, '2023-05-01', 1),
(35, 'nadezhda.k', 'KuzminaN_93', 'Кузьмина Надежда Олеговна', 'n.kuzmina@mail.ru', '+7 (999) 111-11-35', 3, '2023-05-05', 1),
(36, 'veronika.frolova', 'FrolovaV_2000', 'Фролова Вероника Максимовна', 'v.frolova@mail.ru', '+7 (999) 111-11-36', 3, '2023-05-10', 1),
(37, 'larisa.a', 'AlexandrovaL', 'Александрова Лариса Викторовна', 'l.alexandrova@mail.ru', '+7 (999) 111-11-37', 3, '2023-05-15', 1),
(38, 'galina.d', 'Dmitrieva_Gl', 'Дмитриева Галина Андреевна', 'g.dmitrieva@mail.ru', '+7 (999) 111-11-38', 3, '2023-05-20', 1),
(39, 'tamara.koroleva', 'KorolevaT_87', 'Королева Тамара Артемовна', 't.koroleva@mail.ru', '+7 (999) 111-11-39', 3, '2023-06-01', 1),
(40, 'lidia.guseva', 'GusevaLidia', 'Гусева Лидия Денисовна', 'l.guseva@mail.ru', '+7 (999) 111-11-40', 3, '2023-06-05', 1),
(41, 'raisa.kiseleva', 'Kiseleva_1992', 'Киселева Раиса Романовна', 'r.kiseleva@mail.ru', '+7 (999) 111-11-41', 3, '2023-06-10', 1),
(42, 'nina.ilina', 'Ilyina_Nina', 'Ильина Нина Александровна', 'n.ilyina@mail.ru', '+7 (999) 111-11-42', 3, '2023-06-15', 1),
(43, 'zoya.maksimova', 'MaksimovaZoya', 'Максимова Зоя Егоровна', 'z.maksimova@mail.ru', '+7 (999) 111-11-43', 3, '2023-06-20', 1),
(44, 'vera.polyakova', 'Polyakova_Vera', 'Полякова Вера Валерьевна', 'v.polyakova@mail.ru', '+7 (999) 111-11-44', 3, '2023-07-01', 1),
(45, 'klavdia.s', 'SorokinaK_89', 'Сорокина Клавдия Ильинична', 'k.sorokina@mail.ru', '+7 (999) 111-11-45', 3, '2023-07-05', 1),
(46, 'tamara.vinogradova', 'VinogradovaT', 'Виноградова Тамара Антоновна', 't.vinogradova@mail.ru', '+7 (999) 111-11-46', 3, '2023-07-10', 1),
(47, 'valentina.k', 'Kovaleva_V_85', 'Ковалева Валентина Михайловна', 'v.kovaleva@mail.ru', '+7 (999) 111-11-47', 3, '2023-07-15', 1),
(48, 'ekaterina.belova', 'Belova_Katya', 'Белова Екатерина Тимофеевна', 'e.belova@mail.ru', '+7 (999) 111-11-48', 3, '2023-07-20', 1),
(49, 'anna.medvedeva', 'Medvedeva_Anna', 'Медведева Анна Артуровна', 'a.medvedeva@mail.ru', '+7 (999) 111-11-49', 3, '2023-08-01', 1),
(50, 'maria.antonova', 'Antonova_Maria', 'Антонова Мария Руслановна', 'm.antonova@mail.ru', '+7 (999) 111-11-50', 3, '2023-08-05', 1),
(51, 'daria.t', 'TarasovaD_99', 'Тарасова Дарья Дмитриевна', 'd.tarasova@mail.ru', '+7 (999) 111-11-51', 3, '2023-08-10', 1),
(52, 'alina.zhukova', 'Zhukova_Alina', 'Жукова Алина Александровна', 'a.zhukova@mail.ru', '+7 (999) 111-11-52', 3, '2023-08-15', 1),
(53, 'ksenia.krylova', 'KrylovaK_2001', 'Крылова Ксения Сергеевна', 'k.krylova@mail.ru', '+7 (999) 111-11-53', 3, '2023-08-20', 1),
(54, 'sofia.tihonova', 'Tihonova_Sofia', 'Тихонова София Максимовна', 's.tihonova@mail.ru', '+7 (999) 111-11-54', 3, '2023-09-01', 1);

-- 3. Поставщики
INSERT INTO suppliers (id, company_name, contact_person, phone, email, address, inn, kpp, payment_terms, delivery_terms, is_active) VALUES
(1, 'ООО "ЭлектроСнаб"', 'Алексей Смирнов', '+7 (495) 111-22-33', 'sales@electrosnab.ru', 'г. Москва, ул. Ленина, д. 10, оф. 5', '7701234567', '770101001', 'Оплата по счету, 100% предоплата', 'Самовывоз или доставка ТК', 1),
(2, 'АО "ЭнергоТрейд"', 'Дмитрий Волков', '+7 (812) 444-55-66', 'info@energotrade.ru', 'г. Санкт-Петербург, пр. Невский, д. 25', '7809876543', '780901001', 'Отсрочка платежа 14 дней', 'Доставка до склада покупателя', 1),
(3, 'ИП Кузнецов В.А.', 'Виктор Кузнецов', '+7 (903) 777-88-99', 'kuznetsov@mail.ru', 'г. Екатеринбург, ул. Мира, д. 5', '660112233445', '', 'Наличный расчет', 'Самовывоз', 1);

-- 4. Категории
INSERT INTO categories (id, name, parent_id, description) VALUES
(1, 'Электрооборудование', NULL, 'Основная категория электрооборудования'),
(2, 'Кабельная продукция', NULL, 'Провода, кабели, гофра'),
(3, 'Освещение', NULL, 'Лампы, светильники, прожекторы'),
(4, 'Генераторы', 1, 'Бензиновые и дизельные генераторы'),
(5, 'Стабилизаторы', 1, 'Стабилизаторы напряжения'),
(6, 'Кабель силовой', 2, 'Кабели ВВГ, АВВГ и др.'),
(7, 'Светодиодные лампы', 3, 'LED лампы различных цоколей');

-- 5. Товары
INSERT INTO products (id, sku, name, category_id, brand, description, purchase_price, retail_price, warranty_months, voltage, power_watt, is_certified, created_by) VALUES
(1, 'GEN-5KW-01', 'Генератор бензиновый 5 кВт', 4, 'Huter', 'Бензиновый генератор мощностью 5 кВт, 220В, ручной стартер', 25000.00, 35000.00, 12, '220V', 5000, 1, 1),
(2, 'STB-10KW-01', 'Стабилизатор напряжения 10 кВт', 5, 'Ресанта', 'Стабилизатор напряжения для дома, 10 кВт', 15000.00, 22000.00, 24, '220V', 10000, 1, 1),
(3, 'CBL-VVG-3X25', 'Кабель ВВГнг 3х2.5', 6, 'Кабель-М', 'Кабель силовой медный, 3 жилы, сечение 2.5 мм2', 50.00, 120.00, 0, '220V', 0, 1, 1),
(4, 'LED-E27-10W', 'Лампа светодиодная E27 10Вт', 7, 'Philips', 'Светодиодная лампа, цоколь E27, 10Вт, 6500К', 80.00, 150.00, 24, '220V', 10, 1, 1),
(5, 'LED-E14-7W', 'Лампа светодиодная E14 7Вт', 7, 'Osram', 'Светодиодная лампа, цоколь E14, 7Вт, 4000К', 60.00, 110.00, 24, '220V', 7, 1, 1),
(6, 'CBL-VVG-3X4', 'Кабель ВВГнг 3х4', 6, 'Кабель-М', 'Кабель силовой медный, 3 жилы, сечение 4 мм2', 85.00, 180.00, 0, '220V', 0, 1, 1);

-- 6. Остатки на складе
INSERT INTO stock (product_id, quantity, reserved_quantity, min_stock_level, location, last_inventory_date) VALUES
(1, 15, 2, 5, 'Склад А, Зона 1, Стеллаж 3', '2023-10-01'),
(2, 8, 0, 3, 'Склад А, Зона 1, Стеллаж 4', '2023-10-01'),
(3, 5000, 500, 1000, 'Склад А, Зона 2, Бухта 12', '2023-10-01'),
(4, 1200, 50, 200, 'Склад Б, Зона 1, Коробка 45', '2023-10-02'),
(5, 800, 0, 150, 'Склад Б, Зона 1, Коробка 46', '2023-10-02'),
(6, 3000, 0, 500, 'Склад А, Зона 2, Бухта 13', '2023-10-01');

-- 7. Заказы
INSERT INTO orders (id, order_number, customer_name, customer_phone, customer_email, seller_id, status, total_amount, discount_amount, payment_method, created_at) VALUES
(1, 'ORD-2023-0001', 'Кузнецов Сергей Петрович', '+7 (912) 345-67-89', 'sergey.k@mail.ru', 2, 'delivered', 35150.00, 0.00, 'card', '2023-10-05 10:30:00'),
(2, 'ORD-2023-0002', 'Попова Елена Владимировна', '+7 (923) 456-78-90', 'elena.popova@gmail.com', 2, 'processing', 22000.00, 500.00, 'online', '2023-10-06 14:15:00'),
(3, 'ORD-2023-0003', 'ООО "СтройМонтаж"', '+7 (495) 987-65-43', 'info@stroymontazh.ru', 2, 'shipped', 54000.00, 2000.00, 'bank_transfer', '2023-10-07 09:00:00');

-- 8. Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount, total_price) VALUES
(1, 1, 1, 35000.00, 0.00, 35000.00),
(1, 4, 1, 150.00, 0.00, 150.00),
(2, 2, 1, 22000.00, 500.00, 21500.00),
(3, 3, 300, 120.00, 0.00, 36000.00),
(3, 6, 100, 180.00, 0.00, 18000.00);

-- 9. Поставки
INSERT INTO supplies (id, supply_number, supplier_id, merchandiser_id, total_cost, status, invoice_file, created_at, received_at) VALUES
(1, 'SUP-2023-001', 1, 3, 250000.00, 'received', 'invoice_001.pdf', '2023-09-15 11:00:00', '2023-09-20 16:00:00'),
(2, 'SUP-2023-002', 2, 3, 150000.00, 'in_transit', 'invoice_002.pdf', '2023-10-01 10:00:00', NULL),
(3, 'SUP-2023-003', 3, 3, 85000.00, 'ordered', NULL, '2023-10-08 15:30:00', NULL);

-- 10. Позиции поставок
INSERT INTO supply_items (supply_id, product_id, quantity, unit_cost, total_cost, quality_status) VALUES
(1, 1, 10, 25000.00, 250000.00, 'passed'),
(2, 2, 10, 15000.00, 150000.00, 'pending'),
(3, 3, 1000, 50.00, 50000.00, 'pending'),
(3, 4, 500, 80.00, 40000.00, 'pending');