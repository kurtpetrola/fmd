// dorm_image_options.dart

class DormImageOptions {
  static const List<Map<String, String>> availableImages = [
    {
      'path': 'assets/images/dorm_male.jpg',
      'label': 'Male Dormitory',
      'category': 'Gender-Specific'
    },
    {
      'path': 'assets/images/dorm_male_budget.png',
      'label': 'Male Dormitory Budget',
      'category': 'Gender-Specific Budget'
    },
    {
      'path': 'assets/images/dorm_male_luxury.png',
      'label': 'Male Dormitory Luxury',
      'category': 'Gender-Specific Luxury'
    },
    {
      'path': 'assets/images/dorm_female.png',
      'label': 'Female Dormitory',
      'category': 'Gender-Specific'
    },
    {
      'path': 'assets/images/dorm_female_budget.png',
      'label': 'Female Dormitory Budget',
      'category': 'Gender-Specific Budget'
    },
    {
      'path': 'assets/images/dorm_female_luxury.png',
      'label': 'Female Dormitory Luxury Option 1',
      'category': 'Gender-Specific Luxury'
    },
    {
      'path': 'assets/images/dorm_female_luxury1.png',
      'label': 'Female Dormitory Luxury Option 2',
      'category': 'Gender-Specific Luxury'
    },
    {
      'path': 'assets/images/dorm_general.png',
      'label': 'General/Mixed Dormitory',
      'category': 'General'
    },
    {
      'path': 'assets/images/dorm_general_budget.png',
      'label': 'General/Mixed Dormitory Budget',
      'category': 'General Budget'
    },
    {
      'path': 'assets/images/dorm_general_luxury.png',
      'label': 'General/Mixed Dormitory Luxury',
      'category': 'General Luxury'
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
      'path': 'assets/images/dorm_default.png',
      'label': 'Default/Standard',
      'category': 'General'
    },
  ];

  static String getDefaultImage() {
    return 'assets/images/dorm_default.png';
  }
}
