class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String szabistDomain = '@szabist.pk';
  static const int minPasswordLength = 8;
  static const int maxBioLength = 300;
  static const int maxRequestMsg = 200;
  static const int maxIdeaTitle = 100;
  static const int maxIdeaDesc = 500;
  static const int maxActiveIdeas = 2;
  static const int maxPendingReqs = 5;

  static const List<String> departments = ['SE', 'CS', 'AI'];
  static const List<String> batches = ['2020', '2021', '2022', '2023', '2024'];
  static const List<String> skills = [
    'Flutter',
    'React',
    'Python',
    'Java',
    'Node.js',
    'SQL',
    'Machine Learning',
    'UI/UX',
    'Firebase',
    'Docker',
    'C++',
    'TypeScript',
    'Laravel',
  ];
  static const List<String> technologies = [
    'Flutter',
    'React Native',
    'Django',
    'FastAPI',
    'Node.js',
    'PostgreSQL',
    'MongoDB',
    'Firebase',
    'Next.js',
    'Spring Boot',
    'GraphQL',
    'Redis',
  ];
  static const List<String> interests = [
    'AI/ML',
    'Web Dev',
    'Mobile Dev',
    'Data Science',
    'Cybersecurity',
    'Cloud',
    'Game Dev',
    'Blockchain',
    'IoT',
  ];
}
