// dorm_image_options.dart

class DormImageOptions {
  static const List<Map<String, String>> availableImages = [
    {
      'path': 'assets/images/dorm_male.jpg',
      'label': 'Male Dormitory',
      'category': 'Gender-Specific'
    },
    {
      'path': 'assets/images/dorm_female.png',
      'label': 'Female Dormitory',
      'category': 'Gender-Specific'
    },
    {
      'path': 'assets/images/dorm_general.png',
      'label': 'General/Mixed Dormitory',
      'category': 'General'
    },
    {
      'path': 'assets/images/dorm_luxury.jpg',
      'label': 'Luxury Dormitory',
      'category': 'Premium'
    },
    {
      'path': 'assets/images/dorm_budget.png',
      'label': 'Budget-Friendly',
      'category': 'Economy'
    },
    {
      'path': 'assets/images/dorm_default.jpeg',
      'label': 'Default/Standard',
      'category': 'General'
    },
  ];

  static String getDefaultImage() {
    return 'assets/images/dorm_default.jpeg';
  }
}
