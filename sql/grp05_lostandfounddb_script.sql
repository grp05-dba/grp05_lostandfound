-- 1. CATEGORIES
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 2. ITEMS
CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location_found VARCHAR(255),
    date_found DATE,
    time_found TIME,
    status VARCHAR(50) DEFAULT 'unclaimed' CHECK (status IN ('unclaimed', 'claimed', 'archived'))
);

-- 3. LOST_REPORTS
CREATE TABLE lost_reports (
    report_id SERIAL PRIMARY KEY,
    report_code VARCHAR(50) UNIQUE NOT NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location_lost VARCHAR(255),
    date_lost DATE,
    time_lost TIME,
    full_name VARCHAR(150) NOT NULL,
    student_number VARCHAR(50),
    email VARCHAR(150) NOT NULL,
    phone_number VARCHAR(50),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. CLAIMS
CREATE TABLE claims (
    claim_id SERIAL PRIMARY KEY,
    claim_code VARCHAR(50) UNIQUE NOT NULL,
    item_id INT REFERENCES items(item_id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    student_number VARCHAR(50),
    email VARCHAR(150) NOT NULL,
    phone_number VARCHAR(50),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. POTENTIAL_MATCHES
CREATE TABLE potential_matches (
    match_id SERIAL PRIMARY KEY,
    report_id INT REFERENCES lost_reports(report_id) ON DELETE CASCADE,
    item_id INT REFERENCES items(item_id) ON DELETE CASCADE
);