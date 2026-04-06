class IdeaModel {
  const IdeaModel({
    required this.id,
    required this.ownerName,
    required this.ownerId,
    required this.ownerDept,
    required this.title,
    required this.description,
    required this.technologiesRequired,
    required this.skillsRequired,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String ownerName;
  final String ownerId;
  final String ownerDept;
  final String title;
  final String description;
  final List<String> technologiesRequired;
  final List<String> skillsRequired;
  final String status;
  final DateTime createdAt;

  static List<IdeaModel> dummyIdeas() {
    return <IdeaModel>[
      IdeaModel(
        id: 'idea_001',
        ownerName: 'Arun Kumar',
        ownerId: 'user_001',
        ownerDept: 'SE',
        title: 'AI-Based FYP Partner Matching Platform',
        description:
            'A smart mobile-first platform that recommends potential FYP teammates based on skills, interests, and project goals.',
        technologiesRequired: <String>['Flutter', 'FastAPI', 'PostgreSQL'],
        skillsRequired: <String>['Flutter', 'Machine Learning', 'UI/UX'],
        status: 'open',
        createdAt: DateTime(2026, 3, 31),
      ),
      IdeaModel(
        id: 'idea_002',
        ownerName: 'Ayesha Khan',
        ownerId: 'user_002',
        ownerDept: 'CS',
        title: 'Campus Event Discovery and Ticketing App',
        description:
            'A polished cross-platform app for browsing events, booking tickets, and managing attendance across student societies.',
        technologiesRequired: <String>['Flutter', 'Firebase'],
        skillsRequired: <String>['React', 'Firebase', 'UI/UX'],
        status: 'open',
        createdAt: DateTime(2026, 3, 28),
      ),
      IdeaModel(
        id: 'idea_003',
        ownerName: 'Maham Raza',
        ownerId: 'user_004',
        ownerDept: 'AI',
        title: 'Real-Time Sign Language Recognition Assistant',
        description:
            'An AI-powered assistant that translates sign language gestures into readable text for daily communication support.',
        technologiesRequired: <String>['PyTorch', 'Flutter'],
        skillsRequired: <String>['Deep Learning', 'Python', 'Mobile Dev'],
        status: 'open',
        createdAt: DateTime(2026, 3, 26),
      ),
      IdeaModel(
        id: 'idea_004',
        ownerName: 'Bilal Ahmed',
        ownerId: 'user_005',
        ownerDept: 'SE',
        title: 'Cloud-Based Inventory Forecasting Dashboard',
        description:
            'A full-stack dashboard that predicts stock usage, highlights risk trends, and helps small businesses manage inventory smarter.',
        technologiesRequired: <String>['Node.js', 'MySQL', 'Flutter'],
        skillsRequired: <String>['APIs', 'Databases', 'System Design'],
        status: 'closed',
        createdAt: DateTime(2026, 3, 24),
      ),
      IdeaModel(
        id: 'idea_005',
        ownerName: 'Sara Noor',
        ownerId: 'user_006',
        ownerDept: 'CS',
        title: 'Phishing Detection Toolkit for Students',
        description:
            'A lightweight toolkit and educational mobile app that helps students recognize phishing attempts and unsafe links.',
        technologiesRequired: <String>['Flutter', 'FastAPI'],
        skillsRequired: <String>['Cybersecurity', 'Python', 'Mobile Dev'],
        status: 'archived',
        createdAt: DateTime(2026, 3, 20),
      ),
    ];
  }
}
