class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.registrationId,
    required this.department,
    required this.section,
    required this.batch,
    required this.skills,
    required this.technologies,
    required this.interests,
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioLink,
    this.resumeLink,
    this.bio,
    required this.completionPercentage,
    required this.isLocked,
    required this.isProfilePublic,
  });

  final String id;
  final String name;
  final String email;
  final String registrationId;
  final String department;
  final String section;
  final String batch;
  final List<String> skills;
  final List<String> technologies;
  final List<String> interests;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? portfolioLink;
  final String? resumeLink;
  final String? bio;
  final int completionPercentage;
  final bool isLocked;
  final bool isProfilePublic;

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      registrationId: json['registrationId'] as String? ?? '',
      department: json['department'] as String? ?? '',
      section: json['section'] as String? ?? '',
      batch: json['batch'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? const <String>[]),
      technologies: List<String>.from(
        json['technologies'] as List? ?? const <String>[],
      ),
      interests: List<String>.from(
        json['interests'] as List? ?? const <String>[],
      ),
      githubUrl: json['githubUrl'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      portfolioLink: json['portfolioLink'] as String?,
      resumeLink: json['resumeLink'] as String?,
      bio: json['bio'] as String?,
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      isProfilePublic: json['isProfilePublic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'registrationId': registrationId,
      'department': department,
      'section': section,
      'batch': batch,
      'skills': skills,
      'technologies': technologies,
      'interests': interests,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'portfolioLink': portfolioLink,
      'resumeLink': resumeLink,
      'bio': bio,
      'completionPercentage': completionPercentage,
      'isLocked': isLocked,
      'isProfilePublic': isProfilePublic,
    };
  }

  static StudentModel dummyStudent() {
    return const StudentModel(
      id: 'user_001',
      name: 'Arun Kumar',
      email: 'bscs2380145@szabist.pk',
      registrationId: '2380145',
      department: 'SE',
      section: 'B',
      batch: '2023',
      skills: <String>['Flutter', 'Python', 'Machine Learning'],
      technologies: <String>['Flutter', 'FastAPI', 'PostgreSQL'],
      interests: <String>['AI/ML', 'Mobile Dev'],
      githubUrl: 'https://github.com/arunkumar231105',
      linkedinUrl: 'https://www.linkedin.com/in/arun-kumar-b578a128b',
      portfolioLink: 'https://arunkumar.dev',
      resumeLink: 'https://drive.google.com/file/dummy',
      bio: 'Final year SE student passionate about AI and mobile development.',
      completionPercentage: 85,
      isLocked: false,
      isProfilePublic: true,
    );
  }

  static List<StudentModel> dummyList() {
    return <StudentModel>[
      dummyStudent(),
      const StudentModel(
        id: 'user_002',
        name: 'Ayesha Khan',
        email: 'bscs2280002@szabist.pk',
        registrationId: '2280002',
        department: 'CS',
        section: 'A',
        batch: '2022',
        skills: <String>['UI/UX', 'React', 'Firebase'],
        technologies: <String>['Flutter', 'Firebase', 'Figma'],
        interests: <String>['Product Design', 'Mobile Apps'],
        githubUrl: 'https://github.com/ayeshakhan-dev',
        linkedinUrl: 'https://www.linkedin.com/in/ayesha-khan-dev',
        portfolioLink: 'https://ayeshakhan.design',
        resumeLink: 'https://drive.google.com/file/ayesha-dummy',
        bio: 'CS student focused on polished mobile experiences and design.',
        completionPercentage: 92,
        isLocked: false,
        isProfilePublic: true,
      ),
      const StudentModel(
        id: 'user_003',
        name: 'Hamza Ali',
        email: 'bsee2180101@szabist.pk',
        registrationId: '2180101',
        department: 'EE',
        section: 'C',
        batch: '2021',
        skills: <String>['Embedded Systems', 'C++', 'Circuit Design'],
        technologies: <String>['Arduino', 'ESP32', 'MATLAB'],
        interests: <String>['IoT', 'Automation'],
        githubUrl: 'https://github.com/hamzaali-ee',
        linkedinUrl: 'https://www.linkedin.com/in/hamza-ali-ee',
        portfolioLink: null,
        resumeLink: 'https://drive.google.com/file/hamza-dummy',
        bio: 'Electrical engineering student building smart hardware systems.',
        completionPercentage: 78,
        isLocked: true,
        isProfilePublic: false,
      ),
      const StudentModel(
        id: 'user_004',
        name: 'Maham Raza',
        email: 'bsai2380044@szabist.pk',
        registrationId: '2380044',
        department: 'AI',
        section: 'A',
        batch: '2023',
        skills: <String>['Deep Learning', 'Data Analysis', 'Python'],
        technologies: <String>['TensorFlow', 'PyTorch', 'Pandas'],
        interests: <String>['Computer Vision', 'Generative AI'],
        githubUrl: 'https://github.com/mahamraza-ai',
        linkedinUrl: 'https://www.linkedin.com/in/maham-raza-ai',
        portfolioLink: 'https://maham-ai.dev',
        resumeLink: 'https://drive.google.com/file/maham-dummy',
        bio: 'AI student interested in vision models and intelligent systems.',
        completionPercentage: 88,
        isLocked: false,
        isProfilePublic: true,
      ),
      const StudentModel(
        id: 'user_005',
        name: 'Bilal Ahmed',
        email: 'bsse2280068@szabist.pk',
        registrationId: '2280068',
        department: 'SE',
        section: 'D',
        batch: '2022',
        skills: <String>['Backend Development', 'APIs', 'Databases'],
        technologies: <String>['FastAPI', 'Node.js', 'MySQL'],
        interests: <String>['System Design', 'Cloud Computing'],
        githubUrl: 'https://github.com/bilalahmed-se',
        linkedinUrl: 'https://www.linkedin.com/in/bilal-ahmed-se',
        portfolioLink: 'https://bilalbuilds.dev',
        resumeLink: 'https://drive.google.com/file/bilal-dummy',
        bio: 'Software engineering student who enjoys scalable backend systems.',
        completionPercentage: 81,
        isLocked: true,
        isProfilePublic: true,
      ),
      const StudentModel(
        id: 'user_006',
        name: 'Sara Noor',
        email: 'bscs2380091@szabist.pk',
        registrationId: '2380091',
        department: 'CS',
        section: 'B',
        batch: '2023',
        skills: <String>['Cybersecurity', 'Networking', 'Linux'],
        technologies: <String>['Wireshark', 'Burp Suite', 'Docker'],
        interests: <String>['Ethical Hacking', 'Network Security'],
        githubUrl: 'https://github.com/saranoor-sec',
        linkedinUrl: 'https://www.linkedin.com/in/sara-noor-sec',
        portfolioLink: null,
        resumeLink: 'https://drive.google.com/file/sara-dummy',
        bio: 'CS student exploring practical cybersecurity and secure systems.',
        completionPercentage: 74,
        isLocked: false,
        isProfilePublic: false,
      ),
    ];
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? registrationId,
    String? department,
    String? section,
    String? batch,
    List<String>? skills,
    List<String>? technologies,
    List<String>? interests,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioLink,
    String? resumeLink,
    String? bio,
    int? completionPercentage,
    bool? isLocked,
    bool? isProfilePublic,
    bool clearGithubUrl = false,
    bool clearLinkedinUrl = false,
    bool clearPortfolioLink = false,
    bool clearResumeLink = false,
    bool clearBio = false,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      registrationId: registrationId ?? this.registrationId,
      department: department ?? this.department,
      section: section ?? this.section,
      batch: batch ?? this.batch,
      skills: skills ?? this.skills,
      technologies: technologies ?? this.technologies,
      interests: interests ?? this.interests,
      githubUrl: clearGithubUrl ? null : (githubUrl ?? this.githubUrl),
      linkedinUrl: clearLinkedinUrl ? null : (linkedinUrl ?? this.linkedinUrl),
      portfolioLink:
          clearPortfolioLink ? null : (portfolioLink ?? this.portfolioLink),
      resumeLink: clearResumeLink ? null : (resumeLink ?? this.resumeLink),
      bio: clearBio ? null : (bio ?? this.bio),
      completionPercentage:
          completionPercentage ?? this.completionPercentage,
      isLocked: isLocked ?? this.isLocked,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
    );
  }
}
