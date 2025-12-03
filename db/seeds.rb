# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Admin User
puts "Creating admin user..."
unless AdminUser.exists?(email: 'admin@ironandmotion.com')
  AdminUser.create!(
    email: 'admin@ironandmotion.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
end
puts "✓ Admin user created (admin@ironandmotion.com / password123)"

# Categories
puts "\nCreating categories..."
categories_data = {
  'Free Weights' => {
    description: 'Traditional weight training equipment including dumbbells, barbells, and weight plates',
    subcategories: [ 'Dumbbells', 'Barbells', 'Weight Plates', 'Kettlebells' ]
  },
  'Cardio Equipment' => {
    description: 'Cardiovascular training machines for endurance and heart health',
    subcategories: [ 'Treadmills', 'Exercise Bikes', 'Ellipticals', 'Rowing Machines' ]
  },
  'Strength Machines' => {
    description: 'Guided resistance training equipment for targeted muscle development',
    subcategories: []
  },
  'Accessories' => {
    description: 'Essential training accessories and small equipment',
    subcategories: [ 'Resistance Bands', 'Yoga Mats', 'Foam Rollers' ]
  },
  'Recovery Equipment' => {
    description: 'Tools and equipment for post-workout recovery and injury prevention',
    subcategories: []
  }
}

categories = {}
categories_data.each do |name, data|
  category = Category.find_by(name: name)
  if category.nil?
    category = Category.create!(
      name: name,
      description: data[:description]
    )
  end
  categories[name] = category

  # Create subcategories
  data[:subcategories].each do |subcat_name|
    subcat = Category.find_by(name: subcat_name)
    if subcat.nil?
      Category.create!(
        name: subcat_name,
        parent_category: category,
        description: "#{subcat_name} - part of #{name}"
      )
    end
  end
end
puts "✓ Created #{Category.count} categories"

# Products (Requirement 1.2: 10+ products)
puts "\nCreating products..."
products_data = [
  {
    name: 'Premium Hex Dumbbells - 50 lb Pair',
    description: 'Professional-grade hexagonal dumbbells with knurled chrome handles for superior grip. Rubber coating protects floors and reduces noise. Perfect for home gyms and commercial facilities. Each dumbbell features precision-balanced weight distribution for optimal performance during strength training exercises.',
    price: 189.99,
    category: Category.find_by(name: 'Dumbbells'),
    stock_status: :in_stock,
    stock_quantity: 15,
    on_sale: true,
    is_new: false,
    specification: 'Material: Cast iron with rubber coating | Handle: Chrome-plated steel with diamond knurling | Weight tolerance: ±2% | Hex head prevents rolling'
  },
  {
    name: 'Olympic Barbell - 45 lb',
    description: 'Competition-grade Olympic barbell engineered for serious lifters. Features dual knurl marks for proper hand placement, medium-depth knurling for secure grip without tearing hands, and precision-machined sleeves that spin smoothly on bronze bushings. Rated for 1000 lb capacity. Ideal for squats, deadlifts, bench press, and Olympic lifts.',
    price: 299.99,
    category: Category.find_by(name: 'Barbells'),
    stock_status: :in_stock,
    stock_quantity: 8,
    on_sale: false,
    is_new: true,
    specification: 'Length: 86" | Diameter: 28mm shaft, 2" sleeves | Weight capacity: 1000 lb | Finish: Black oxide | Sleeve rotation: Bronze bushings'
  },
  {
    name: 'Commercial Treadmill Pro X500',
    description: 'State-of-the-art commercial treadmill with 4.0 HP motor, 22" x 60" running surface, and advanced cushioning system to reduce joint impact. Features 15 preset programs, heart rate monitoring, and Bluetooth connectivity. Built-in tablet holder and premium sound system. Maximum user weight 400 lb.',
    price: 2499.99,
    category: Category.find_by(name: 'Treadmills'),
    stock_status: :in_stock,
    stock_quantity: 3,
    on_sale: false,
    is_new: true,
    specification: 'Motor: 4.0 HP continuous duty | Speed: 0-12 mph | Incline: 0-15% | Display: 10" touchscreen | Programs: 15 preset + custom | Warranty: 5 years parts, 2 years labor'
  },
  {
    name: 'Adjustable Weight Bench - Heavy Duty',
    description: 'Versatile 7-position weight bench supports flat, incline, and decline exercises. Commercial-grade steel frame with 2" thick high-density foam padding. Adjustable seat and back pad for precise positioning. Non-slip rubber feet protect floors. Weight capacity 600 lb. Essential for any home gym.',
    price: 349.99,
    category: Category.find_by(name: 'Strength Machines'),
    stock_status: :in_stock,
    stock_quantity: 12,
    on_sale: true,
    is_new: false,
    specification: 'Frame: 2" x 3" steel | Padding: 2" high-density foam | Positions: 7 (flat, 4 incline, 2 decline) | Weight capacity: 600 lb | Dimensions: 54" L x 28" W x 48" H'
  },
  {
    name: 'Competition Kettlebell Set - 16kg, 20kg, 24kg',
    description: 'Professional competition-style kettlebells with uniform 35mm handle diameter across all weights for consistent technique. Single-piece cast steel construction eliminates weak points. Color-coded for easy weight identification. Flat base prevents wobbling. Includes storage rack. Perfect for CrossFit, functional fitness, and strength training.',
    price: 449.99,
    category: Category.find_by(name: 'Kettlebells'),
    stock_status: :in_stock,
    stock_quantity: 6,
    on_sale: false,
    is_new: false,
    specification: 'Materials: Single-piece cast steel | Handle diameter: 35mm (uniform) | Finish: Powder-coated | Base: Flat for stability | Set includes: 16kg, 20kg, 24kg + rack'
  },
  {
    name: 'Resistance Band Set - Premium Quality',
    description: 'Complete set of 5 resistance bands with varying resistance levels from 10 to 50 pounds. Made from 100% natural latex for superior durability and elasticity. Includes door anchor, ankle straps, handles, and carrying bag. Perfect for home workouts, physical therapy, and travel fitness.',
    price: 49.99,
    category: Category.find_by(name: 'Resistance Bands'),
    stock_status: :in_stock,
    stock_quantity: 45,
    on_sale: true,
    is_new: false,
    specification: 'Material: 100% natural latex | Resistance levels: 10, 20, 30, 40, 50 lb | Length: 48" | Accessories: Door anchor, ankle straps, handles, carrying bag'
  },
  {
    name: 'Premium Yoga Mat - Extra Thick',
    description: 'Eco-friendly yoga mat made from non-toxic TPE material. Extra-thick 8mm cushioning provides superior comfort and joint protection. Non-slip textured surface ensures stability during poses. Lightweight and includes carrying strap. Moisture-resistant and easy to clean. Available in multiple colors.',
    price: 69.99,
    category: Category.find_by(name: 'Yoga Mats'),
    stock_status: :in_stock,
    stock_quantity: 30,
    on_sale: false,
    is_new: true,
    specification: 'Material: TPE (eco-friendly) | Thickness: 8mm | Dimensions: 72" L x 24" W | Weight: 2.2 lb | Features: Non-slip texture, moisture-resistant, includes carrying strap'
  },
  {
    name: 'High-Density Foam Roller - 36 inch',
    description: 'Professional-grade foam roller for myofascial release and muscle recovery. High-density molded foam maintains firmness even with daily use. Textured surface with three zones for targeted muscle therapy. Ideal for post-workout recovery, physical therapy, and improving flexibility. Includes exercise guide.',
    price: 39.99,
    category: Category.find_by(name: 'Foam Rollers'),
    stock_status: :in_stock,
    stock_quantity: 25,
    on_sale: false,
    is_new: false,
    specification: 'Material: High-density EVA foam | Length: 36" | Diameter: 6" | Weight capacity: 500 lb | Surface: Textured 3-zone design | Includes: Exercise guide'
  },
  {
    name: 'Spin Bike Pro - Indoor Cycling',
    description: 'Studio-quality spin bike with 40 lb flywheel for smooth, quiet operation. Fully adjustable seat and handlebars accommodate users of all heights. Belt drive system requires minimal maintenance. Built-in monitor tracks time, speed, distance, and calories. Commercial-grade construction supports riders up to 330 lb.',
    price: 799.99,
    category: Category.find_by(name: 'Exercise Bikes'),
    stock_status: :in_stock,
    stock_quantity: 5,
    on_sale: true,
    is_new: true,
    specification: 'Flywheel: 40 lb | Drive: Belt (low maintenance) | Resistance: Friction pad | Display: LCD monitor | Adjustments: 4-way seat, 2-way handlebars | Max user weight: 330 lb'
  },
  {
    name: 'Bumper Plate Set - 260 lb Olympic',
    description: 'Complete Olympic bumper plate set made from virgin rubber for maximum durability. Color-coded according to IWF standards. Solid steel insert with precision-machined 2" opening fits all Olympic bars. Low bounce design protects floors. Set includes: pair each of 45, 35, 25, 15, and 10 lb plates.',
    price: 599.99,
    category: Category.find_by(name: 'Weight Plates'),
    stock_status: :low_stock,
    stock_quantity: 4,
    on_sale: false,
    is_new: false,
    specification: 'Material: Virgin rubber | Insert: Solid steel | Diameter: 17.7" (450mm) | Opening: 2" Olympic | Color-coded: IWF standard | Total weight: 260 lb (10-45 lb pairs)'
  },
  {
    name: 'Rowing Machine - Water Resistance',
    description: 'Premium water resistance rowing machine delivers authentic rowing experience with self-regulating resistance. Handcrafted solid wood frame with clear-coated finish. Ergonomic seat and multi-grip handlebar. Folds vertically for easy storage. Performance monitor tracks stroke rate, time, distance, and calories. Maximum user weight 350 lb.',
    price: 1299.99,
    category: Category.find_by(name: 'Rowing Machines'),
    stock_status: :in_stock,
    stock_quantity: 7,
    on_sale: false,
    is_new: true,
    specification: 'Frame: Solid ash wood | Resistance: Water (self-regulating) | Monitor: LCD with stroke rate, time, distance, calories | Seat: Ergonomic padded | Storage: Vertical folding | Max user weight: 350 lb'
  },
  {
    name: 'Power Rack with Pull-Up Bar',
    description: 'Heavy-duty power rack built for serious strength training. 11-gauge steel construction with powder-coat finish. Adjustable safety bars and J-hooks with UHMW plastic liners protect your barbell. Includes multi-grip pull-up bar and band pegs. Weight capacity 1000 lb. Bolt-down or freestanding installation options.',
    price: 899.99,
    category: Category.find_by(name: 'Strength Machines'),
    stock_status: :in_stock,
    stock_quantity: 4,
    on_sale: false,
    is_new: true,
    specification: 'Frame: 11-gauge steel, 3" x 3" uprights | Height: 90" | Width: 48" | Depth: 48" | Weight capacity: 1000 lb | Features: Pull-up bar, safety bars, J-hooks, band pegs | Installation: Bolt-down or freestanding'
  }
]

products_data.each do |product_data|
  product = Product.find_by(name: product_data[:name])
  if product.nil?
    Product.create!(
      name: product_data[:name],
      description: product_data[:description],
      price: product_data[:price],
      category: product_data[:category],
      stock_status: product_data[:stock_status],
      stock_quantity: product_data[:stock_quantity],
      on_sale: product_data[:on_sale],
      is_new: product_data[:is_new],
      specification: product_data[:specification]
    )
  end
end
puts "✓ Created #{Product.count} products (images must be uploaded via admin panel)"

# Static Pages (Requirement 1.4)
puts "\nCreating static pages..."

about_content = <<~HTML
  <h2>Welcome to Iron &amp; Motion</h2>
  <p>For over a decade, Iron &amp; Motion has been the premier destination for fitness enthusiasts, athletes, and gym owners seeking top-quality equipment and exceptional service.</p>

  <h3>Our Story</h3>
  <p>Founded in 2013, Iron &amp; Motion began as a small specialty fitness store in Toronto. Our founder, a former competitive powerlifter, recognized the need for a retailer that truly understood the demands of serious training. What started as a passion project has grown into one of Canada's most trusted fitness equipment suppliers.</p>

  <h3>Our Mission</h3>
  <p>We believe that quality equipment is essential for achieving fitness goals safely and effectively. Our mission is to provide:</p>
  <ul>
    <li>Premium-quality fitness equipment from leading manufacturers</li>
    <li>Expert advice from experienced fitness professionals</li>
    <li>Competitive pricing without compromising on quality</li>
    <li>Exceptional customer service before, during, and after your purchase</li>
  </ul>

  <h3>Why Choose Iron &amp; Motion?</h3>
  <p><strong>Expertise:</strong> Our team includes certified personal trainers, former athletes, and equipment specialists who can guide you to the right products for your goals.</p>
  <p><strong>Quality:</strong> We carefully curate our product selection, partnering only with manufacturers known for durability, safety, and performance.</p>
  <p><strong>Service:</strong> From product selection to delivery and setup, we're committed to making your experience seamless and satisfying.</p>

  <h3>Our Commitment</h3>
  <p>Every product we sell is backed by our satisfaction guarantee. We stand behind the quality of our equipment and the expertise of our recommendations. Your fitness journey is our priority.</p>
HTML

contact_content = <<~HTML
  <h2>Get in Touch</h2>
  <p>We're here to help you find the perfect equipment for your fitness goals. Whether you have questions about a product, need advice on building a home gym, or want to discuss commercial equipment solutions, our team is ready to assist.</p>

  <h3>Contact Information</h3>
  <p><strong>Email:</strong> <a href="mailto:info@ironandmotion.com">info@ironandmotion.com</a><br>
  <strong>Phone:</strong> 1-800-555-IRON (4766)<br>
  <strong>Hours:</strong> Monday-Friday 9:00 AM - 6:00 PM EST</p>

  <h3>Our Location</h3>
  <p>Iron &amp; Motion Fitness Equipment<br>
  1250 Fitness Avenue<br>
  Toronto, ON M5V 3A1<br>
  Canada</p>

  <h3>Showroom Visits</h3>
  <p>Visit our Toronto showroom to see and test our equipment in person. We recommend scheduling an appointment to ensure one of our specialists is available to assist you.</p>

  <h3>Commercial Inquiries</h3>
  <p>For gym owners and commercial facility managers, contact our commercial sales team at <a href="mailto:commercial@ironandmotion.com">commercial@ironandmotion.com</a> for volume pricing and customized solutions.</p>

  <h3>Customer Support</h3>
  <p>Need help with an existing order or product? Contact our support team at <a href="mailto:support@ironandmotion.com">support@ironandmotion.com</a></p>
HTML

unless StaticPage.exists?(slug: 'about-us')
  StaticPage.create!(
    slug: 'about-us',
    title: 'About Us',
    content: about_content,
    published: true
  )
end

unless StaticPage.exists?(slug: 'contact-us')
  StaticPage.create!(
    slug: 'contact-us',
    title: 'Contact Us',
    content: contact_content,
    published: true
  )
end

puts "✓ Created #{StaticPage.count} static pages"

puts "\n✅ Database seeding complete!"
puts "\nNext steps:"
puts "1. Visit http://localhost:3000/admin"
puts "2. Log in with admin@ironandmotion.com / password123"
puts "3. Upload product images via the Products admin interface"
puts "4. Test all admin features"
