import '../models/product.dart';

class MockData {
  static const _shirtBase = 'https://images.unsplash.com/photo-';
  static const _pantBase = 'https://images.unsplash.com/photo-';

  static final List<Product> allProducts = [
    // ── Formal Shirts ──
    Product(
      id: 'shirt-001',
      name: 'Classic White Oxford Shirt',
      description:
          'A timeless white Oxford shirt crafted from premium 100% cotton. Features a button-down collar, single chest pocket, and a tailored fit that transitions seamlessly from boardroom to dinner. Wrinkle-resistant finish for all-day sharpness.',
      price: 1499,
      originalPrice: 2499,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1602810318383-e386cc2a3ccf?w=600&h=800&fit=crop',
        '${_shirtBase}1598033129183-c4f50588f46c?w=600&h=800&fit=crop',
        '${_shirtBase}1603252109303-2751441dd157?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['White', 'Off-White', 'Light Blue'],
      rating: 4.5,
      reviewCount: 234,
      isBestSeller: true,
      isFeatured: true,
    ),
    Product(
      id: 'shirt-002',
      name: 'Sky Blue Slim Fit Shirt',
      description:
          'Elevate your workwear with this sky blue slim-fit formal shirt. Made from breathable cotton-blend fabric with a spread collar and French cuffs. Perfect for making a sophisticated impression at any professional setting.',
      price: 1299,
      originalPrice: 1999,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1596755094514-f87e34085b2c?w=600&h=800&fit=crop',
        '${_shirtBase}1598033129183-c4f50588f46c?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Sky Blue', 'Royal Blue', 'Navy'],
      rating: 4.3,
      reviewCount: 189,
      isNew: true,
      isFeatured: true,
    ),
    Product(
      id: 'shirt-003',
      name: 'Charcoal Grey Business Shirt',
      description:
          'A distinguished charcoal grey formal shirt with subtle herringbone texture. Tailored from premium Egyptian cotton, featuring a semi-spread collar and barrel cuffs. An essential for the modern professional.',
      price: 1699,
      originalPrice: 2799,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1607345366928-199ea26cfe3e?w=600&h=800&fit=crop',
        '${_shirtBase}1603252109303-2751441dd157?w=600&h=800&fit=crop',
      ],
      sizes: ['M', 'L', 'XL', 'XXL'],
      colors: ['Charcoal', 'Dark Grey', 'Slate'],
      rating: 4.7,
      reviewCount: 312,
      isBestSeller: true,
      isFeatured: true,
    ),
    Product(
      id: 'shirt-004',
      name: 'Lavender Premium Dress Shirt',
      description:
          'Stand out with this elegant lavender dress shirt. Crafted from silky smooth Supima cotton with a cutaway collar. Features mother-of-pearl buttons and a contemporary fit that flatters every body type.',
      price: 1899,
      originalPrice: 2999,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1598033129183-c4f50588f46c?w=600&h=800&fit=crop',
        '${_shirtBase}1602810318383-e386cc2a3ccf?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Lavender', 'Lilac', 'Mauve'],
      rating: 4.4,
      reviewCount: 156,
    ),
    Product(
      id: 'shirt-005',
      name: 'Navy Pinstripe Formal Shirt',
      description:
          'Classic navy with subtle white pinstripes gives this shirt a boardroom-ready look. Cut from wrinkle-free fabric with a regular fit collar and adjustable cuffs. Pairs perfectly with grey or charcoal trousers.',
      price: 1599,
      originalPrice: 2199,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1603252109303-2751441dd157?w=600&h=800&fit=crop',
        '${_shirtBase}1607345366928-199ea26cfe3e?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Navy', 'Dark Blue'],
      rating: 4.2,
      reviewCount: 98,
      isNew: true,
    ),
    Product(
      id: 'shirt-006',
      name: 'Mint Green Linen Blend Shirt',
      description:
          'A refreshing mint green shirt in cotton-linen blend, ideal for summer formals. Features a mandarin collar, relaxed fit, and natural breathability. Perfect for garden parties and outdoor events.',
      price: 1399,
      originalPrice: 1799,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1596755094514-f87e34085b2c?w=600&h=800&fit=crop',
        '${_shirtBase}1602810318383-e386cc2a3ccf?w=600&h=800&fit=crop',
      ],
      sizes: ['M', 'L', 'XL'],
      colors: ['Mint', 'Sage', 'Olive'],
      rating: 4.1,
      reviewCount: 67,
    ),
    Product(
      id: 'shirt-007',
      name: 'Burgundy Executive Shirt',
      description:
          'Command attention with this rich burgundy executive shirt. Premium satin-finish cotton with a point collar and convertible cuffs. Deep color and luxurious feel for evening formal events.',
      price: 2099,
      originalPrice: 3299,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1607345366928-199ea26cfe3e?w=600&h=800&fit=crop',
        '${_shirtBase}1598033129183-c4f50588f46c?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Burgundy', 'Maroon', 'Wine'],
      rating: 4.6,
      reviewCount: 201,
      isBestSeller: true,
    ),
    Product(
      id: 'shirt-008',
      name: 'Pearl White Tuxedo Shirt',
      description:
          'The perfect accompaniment to your tuxedo. Pearl white with a pleated front bib, wing-tip collar, and French cuffs for cufflinks. Crafted from the finest mercerized cotton for a luminous finish.',
      price: 2499,
      originalPrice: 3999,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1602810318383-e386cc2a3ccf?w=600&h=800&fit=crop',
        '${_shirtBase}1603252109303-2751441dd157?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Pearl White', 'Ivory'],
      rating: 4.8,
      reviewCount: 87,
      isNew: true,
    ),
    // Extra shirts for pagination
    Product(
      id: 'shirt-009',
      name: 'Steel Grey Microcheck Shirt',
      description:
          'Subtle microchecks on a steel grey base create a distinguished pattern. Crafted from breathable cotton poplin with a classic fit. Perfect for business meetings and formal occasions.',
      price: 1599,
      originalPrice: 2399,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1607345366928-199ea26cfe3e?w=600&h=800&fit=crop',
        '${_shirtBase}1598033129183-c4f50588f46c?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Steel Grey', 'Silver'],
      rating: 4.3,
      reviewCount: 143,
    ),
    Product(
      id: 'shirt-010',
      name: 'Powder Blue Luxury Shirt',
      description:
          'A sophisticated powder blue shirt with subtle satin finish. Made from premium long-staple cotton for exceptional softness. Features a spread collar and single-needle tailoring.',
      price: 1799,
      originalPrice: 2699,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1596755094514-f87e34085b2c?w=600&h=800&fit=crop',
        '${_shirtBase}1602810318383-e386cc2a3ccf?w=600&h=800&fit=crop',
      ],
      sizes: ['M', 'L', 'XL', 'XXL'],
      colors: ['Powder Blue', 'Ice Blue'],
      rating: 4.5,
      reviewCount: 178,
      isFeatured: true,
    ),
    Product(
      id: 'shirt-011',
      name: 'Black Satin Finish Shirt',
      description:
          'Sleek and sophisticated black formal shirt with a luxurious satin finish. Features a slim fit cut, hidden button placket, and French cuffs. Ideal for black-tie events and evening galas.',
      price: 2299,
      originalPrice: 3499,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1607345366928-199ea26cfe3e?w=600&h=800&fit=crop',
        '${_shirtBase}1603252109303-2751441dd157?w=600&h=800&fit=crop',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'Onyx'],
      rating: 4.7,
      reviewCount: 256,
      isBestSeller: true,
    ),
    Product(
      id: 'shirt-012',
      name: 'Cream Herringbone Shirt',
      description:
          'A refined cream shirt with elegant herringbone weave pattern. Crafted from Egyptian cotton with a point collar and barrel cuffs. Versatile enough to pair with any formal trouser.',
      price: 1699,
      originalPrice: 2599,
      category: 'Formal Shirts',
      images: [
        '${_shirtBase}1598033129183-c4f50588f46c?w=600&h=800&fit=crop',
        '${_shirtBase}1602810318383-e386cc2a3ccf?w=600&h=800&fit=crop',
      ],
      sizes: ['M', 'L', 'XL'],
      colors: ['Cream', 'Ecru'],
      rating: 4.2,
      reviewCount: 89,
      isNew: true,
    ),

    // ── Formal Pants ──
    Product(
      id: 'pant-001',
      name: 'Classic Black Formal Trousers',
      description:
          'Indispensable black formal trousers with a flat front and medium crease. Tailored from premium wool-blend fabric with a comfort waistband. A versatile staple that anchors any formal outfit.',
      price: 1799,
      originalPrice: 2999,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36', '38'],
      colors: ['Black', 'Jet Black'],
      rating: 4.6,
      reviewCount: 445,
      isBestSeller: true,
      isFeatured: true,
    ),
    Product(
      id: 'pant-002',
      name: 'Navy Slim Fit Chinos',
      description:
          'Modern navy chinos with a slim, tapered fit. Made from stretch cotton twill for comfort and mobility. Features slant front pockets and welt back pockets. Dress them up with a blazer or down with a polo.',
      price: 1499,
      originalPrice: 2199,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
      ],
      sizes: ['28', '30', '32', '34', '36'],
      colors: ['Navy', 'Dark Navy', 'Indigo'],
      rating: 4.4,
      reviewCount: 321,
      isNew: true,
      isFeatured: true,
    ),
    Product(
      id: 'pant-003',
      name: 'Charcoal Wool Dress Pants',
      description:
          'Distinguished charcoal dress pants in pure Australian merino wool. Features a classic straight leg, double pleats, and a satin-lined waistband. Naturally wrinkle-resistant with a refined drape.',
      price: 2299,
      originalPrice: 3499,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36', '38', '40'],
      colors: ['Charcoal', 'Ash Grey', 'Graphite'],
      rating: 4.7,
      reviewCount: 278,
      isBestSeller: true,
      isFeatured: true,
    ),
    Product(
      id: 'pant-004',
      name: 'Beige Cotton Formal Trousers',
      description:
          'Light and comfortable beige formal trousers perfect for summer. Tailored from premium Pima cotton with a regular fit. Features a grip-stay waistband and permanent crease for a polished look.',
      price: 1299,
      originalPrice: 1999,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36'],
      colors: ['Beige', 'Khaki', 'Sand'],
      rating: 4.2,
      reviewCount: 134,
    ),
    Product(
      id: 'pant-005',
      name: 'Dark Grey Pleated Trousers',
      description:
          'Elegant dark grey trousers with double forward pleats for a classic silhouette. Crafted from Italian wool-blend fabric with a natural stretch. Extended tab closure and deep pockets for practicality.',
      price: 1999,
      originalPrice: 3199,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
      ],
      sizes: ['32', '34', '36', '38'],
      colors: ['Dark Grey', 'Slate', 'Pewter'],
      rating: 4.5,
      reviewCount: 198,
      isNew: true,
    ),
    Product(
      id: 'pant-006',
      name: 'Olive Green Smart Trousers',
      description:
          'Break from the conventional with these olive green smart trousers. Stretch cotton-lycra blend for all-day comfort. Tapered fit with a modern silhouette that pairs well with white or light blue shirts.',
      price: 1599,
      originalPrice: 2299,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
      ],
      sizes: ['28', '30', '32', '34', '36'],
      colors: ['Olive', 'Army Green', 'Moss'],
      rating: 4.0,
      reviewCount: 76,
    ),
    Product(
      id: 'pant-007',
      name: 'Tan Brown Tailored Pants',
      description:
          'Warm tan brown formal pants with a tailored regular fit. Made from premium cotton-twill with a subtle sheen. Hook-and-bar closure, hemmed bottom, and elegant topstitching detail throughout.',
      price: 1699,
      originalPrice: 2499,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36', '38'],
      colors: ['Tan', 'Camel', 'Cognac'],
      rating: 4.3,
      reviewCount: 112,
    ),
    Product(
      id: 'pant-008',
      name: 'Midnight Blue Suit Trousers',
      description:
          'Luxurious midnight blue suit trousers designed to be worn as part of a suit or as standalone formal wear. Super 120s wool fabric with a refined finish. Slim fit with tapered legs and curtain-lined waistband.',
      price: 2699,
      originalPrice: 4199,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36'],
      colors: ['Midnight Blue', 'Deep Navy'],
      rating: 4.8,
      reviewCount: 89,
      isBestSeller: true,
      isNew: true,
    ),
    // Extra pants for pagination
    Product(
      id: 'pant-009',
      name: 'Light Grey Wool Trousers',
      description:
          'Sophisticated light grey trousers in premium Australian wool blend. Features a modern slim fit with natural stretch for all-day comfort. Perfect for spring and summer formal occasions.',
      price: 1899,
      originalPrice: 2799,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36', '38'],
      colors: ['Light Grey', 'Silver Grey'],
      rating: 4.4,
      reviewCount: 167,
    ),
    Product(
      id: 'pant-010',
      name: 'Espresso Brown Dress Pants',
      description:
          'Rich espresso brown formal trousers with a classic regular fit. Tailored from premium Italian cotton-blend fabric with a subtle texture. Features extended waistband and deep pockets.',
      price: 1799,
      originalPrice: 2699,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36'],
      colors: ['Espresso', 'Chocolate'],
      rating: 4.3,
      reviewCount: 94,
      isNew: true,
    ),
    Product(
      id: 'pant-011',
      name: 'Burgundy Slim Trousers',
      description:
          'Bold burgundy trousers for the fashion-forward professional. Slim tapered fit in stretch cotton twill. Features a clean front with hidden clasp closure. Stand out at any formal event.',
      price: 1699,
      originalPrice: 2599,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
      ],
      sizes: ['28', '30', '32', '34'],
      colors: ['Burgundy', 'Wine'],
      rating: 4.1,
      reviewCount: 72,
    ),
    Product(
      id: 'pant-012',
      name: 'Ink Blue Tailored Chinos',
      description:
          'Deep ink blue chinos with a tailored fit. Made from premium stretch cotton with a soft peached finish. Perfect for smart-casual dress code with a polished look.',
      price: 1599,
      originalPrice: 2299,
      category: 'Formal Pants',
      images: [
        '${_pantBase}1624378439575-d8705ad7ae80?w=600&h=800&fit=crop',
        '${_pantBase}1594938298603-c8148c4dae35?w=600&h=800&fit=crop',
      ],
      sizes: ['30', '32', '34', '36', '38'],
      colors: ['Ink Blue', 'Deep Teal'],
      rating: 4.4,
      reviewCount: 108,
      isFeatured: true,
    ),
  ];

  static List<Product> get formalShirts =>
      allProducts.where((p) => p.category == 'Formal Shirts').toList();

  static List<Product> get formalPants =>
      allProducts.where((p) => p.category == 'Formal Pants').toList();

  static List<Product> get bestSellers =>
      allProducts.where((p) => p.isBestSeller).toList();

  static List<Product> get newArrivals =>
      allProducts.where((p) => p.isNew).toList();

  static List<Product> get featured =>
      allProducts.where((p) => p.isFeatured).toList();
}
