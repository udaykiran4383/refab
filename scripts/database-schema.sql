-- ReFab Database Schema

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('tailor', 'logistics', 'warehouse', 'customer', 'volunteer', 'admin')),
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pickup requests table
CREATE TABLE pickup_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tailor_id UUID REFERENCES users(id),
    logistics_id UUID REFERENCES users(id),
    fabric_type VARCHAR(100) NOT NULL,
    estimated_weight DECIMAL(10,2) NOT NULL,
    pickup_address TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'scheduled', 'in_progress', 'completed', 'cancelled')),
    photos JSONB,
    notes TEXT,
    scheduled_date TIMESTAMP,
    completed_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory items table
CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pickup_id UUID REFERENCES pickup_requests(id),
    fabric_category VARCHAR(100) NOT NULL,
    quality_grade VARCHAR(10) NOT NULL CHECK (quality_grade IN ('A', 'B', 'C')),
    actual_weight DECIMAL(10,2) NOT NULL,
    warehouse_location VARCHAR(100),
    status VARCHAR(50) DEFAULT 'processing' CHECK (status IN ('processing', 'graded', 'ready', 'used')),
    processed_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    images JSONB,
    materials_used JSONB,
    environmental_impact DECIMAL(5,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    shipping_address TEXT NOT NULL,
    payment_id VARCHAR(255),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_date TIMESTAMP
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id),
    product_id UUID REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- Volunteer hours table
CREATE TABLE volunteer_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    volunteer_id UUID REFERENCES users(id),
    task_category VARCHAR(100) NOT NULL,
    hours_logged DECIMAL(5,2) NOT NULL,
    description TEXT,
    supervisor_id UUID REFERENCES users(id),
    is_verified BOOLEAN DEFAULT false,
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_pickup_requests_tailor_id ON pickup_requests(tailor_id);
CREATE INDEX idx_pickup_requests_status ON pickup_requests(status);
CREATE INDEX idx_pickup_requests_created_at ON pickup_requests(created_at);
CREATE INDEX idx_inventory_items_status ON inventory_items(status);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_volunteer_hours_volunteer_id ON volunteer_hours(volunteer_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Insert sample data
INSERT INTO users (email, name, phone, role, address) VALUES
('admin@refab.com', 'Admin User', '+91-9876543210', 'admin', 'Mumbai, Maharashtra'),
('tailor1@example.com', 'Priya Sharma', '+91-9876543211', 'tailor', 'Andheri, Mumbai'),
('logistics1@example.com', 'Raj Kumar', '+91-9876543212', 'logistics', 'Bandra, Mumbai'),
('customer1@example.com', 'Amit Patel', '+91-9876543213', 'customer', 'Powai, Mumbai'),
('volunteer1@example.com', 'Sneha Singh', '+91-9876543214', 'volunteer', 'Thane, Mumbai');

INSERT INTO products (name, description, category, price, stock_quantity, images, environmental_impact) VALUES
('Eco Tote Bag', 'Handmade tote bag from recycled cotton', 'Bags', 299.00, 50, '["bag1.jpg"]', 2.5),
('Recycled Toy Bear', 'Soft toy made from recycled fabric', 'Toys', 199.00, 30, '["toy1.jpg"]', 1.8),
('Wall Hanging', 'Decorative wall hanging from fabric scraps', 'Home Decor', 149.00, 25, '["wall1.jpg"]', 1.2),
('Cotton Scarf', 'Stylish scarf from upcycled cotton', 'Clothing', 249.00, 40, '["scarf1.jpg"]', 2.0),
('Laptop Sleeve', 'Protective sleeve from recycled materials', 'Accessories', 399.00, 20, '["sleeve1.jpg"]', 3.0);
