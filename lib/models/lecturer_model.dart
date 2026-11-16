class Lecturer {
  final String name, department, email, office;

  const Lecturer({
    required this.name,
    required this.department,
    required this.email,
    required this.office,
  });

  static const List<Lecturer> all = [
    Lecturer(
      name: 'Dr. A. Mokoena',
      department: 'Information Technology',
      email: 'a.mokoena@example.ac.za',
      office: 'Block B, Room 101',
    ),
    Lecturer(
      name: 'Mr. T. Dlamini',
      department: 'Information Technology',
      email: 't.dlamini@example.ac.za',
      office: 'Block B, Room 105',
    ),
    Lecturer(
      name: 'Ms. P. Nkosi',
      department: 'Software Engineering',
      email: 'p.nkosi@example.ac.za',
      office: 'Block C, Room 210',
    ),
    Lecturer(
      name: 'Prof. S. van Wyk',
      department: 'Computer Science',
      email: 's.vanwyk@example.ac.za',
      office: 'Block C, Room 301',
    ),
  ];

  static Lecturer? byName(String name) {
    for (final l in all) {
      if (l.name == name) return l;
    }
    return null;
  }
}