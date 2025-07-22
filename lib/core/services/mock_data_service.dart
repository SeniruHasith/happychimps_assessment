class MockDataService {
  static List<Map<String, dynamic>> getDummyProducts() {
    return [
      {
        'id': 1,
        'name': 'Anggurku Fresh Indonesian Grapes',
        'description': 'Fresh grapes from Indonesia',
        'price': 22.0,
        'imageUrl': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2573&q=80',
        'rating': 4.5,
        'isRecommended': true,
        'discount': 10,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'name': 'Fresh Red Strawberries',
        'description': 'Sweet and juicy strawberries',
        'price': 18.0,
        'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2574&q=80',
        'rating': 4.8,
        'isRecommended': true,
        'discount': 15,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 3,
        'name': 'Organic Bananas',
        'description': 'Fresh organic bananas',
        'price': 12.0,
        'imageUrl': 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2539&q=80',
        'rating': 4.3,
        'isRecommended': true,
        'discount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 4,
        'name': 'Fresh Oranges',
        'description': 'Sweet and juicy oranges',
        'price': 15.0,
        'imageUrl': 'https://images.unsplash.com/photo-1557800636-894a64c1696f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2565&q=80',
        'rating': 4.6,
        'isRecommended': true,
        'discount': 20,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 5,
        'name': 'Fresh Apples',
        'description': 'Crisp and sweet apples',
        'price': 16.0,
        'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2574&q=80',
        'rating': 4.7,
        'isRecommended': true,
        'discount': 5,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 6,
        'name': 'Fresh Mangoes',
        'description': 'Sweet and ripe mangoes',
        'price': 25.0,
        'imageUrl': 'https://images.unsplash.com/photo-1553279768-865429fa0078?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2574&q=80',
        'rating': 4.9,
        'isRecommended': true,
        'discount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  static List<Map<String, dynamic>> getPromotions() {
    return [
      {
        'id': 1,
        'title': 'Summer Sale',
        'description': 'Get up to 50% off on fresh fruits',
        'imageUrl': 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2580&q=80',
      },
      {
        'id': 2,
        'title': 'Fresh Arrivals',
        'description': 'Check out our new seasonal fruits',
        'imageUrl': 'https://images.unsplash.com/photo-1519996529931-28324d5a630e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2574&q=80',
      },
      {
        'id': 3,
        'title': 'Organic Collection',
        'description': 'Discover our organic fruit selection',
        'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2574&q=80',
      },
    ];
  }
} 