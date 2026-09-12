import 'club_role.dart';
import 'department.dart';

class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.yearAndMajor,
    required this.totalVerifiedPoints,
    required this.reliabilityRate,
    required this.badges,
    required this.corporateSkillsEarned,
  });

  final String id;
  final String name;
  final ClubRole role;
  final DepartmentType department;
  final String yearAndMajor;
  final int totalVerifiedPoints;
  final double reliabilityRate;
  final List<String> badges;
  final Map<String, int> corporateSkillsEarned;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'department': department.name,
        'yearAndMajor': yearAndMajor,
        'totalVerifiedPoints': totalVerifiedPoints,
        'reliabilityRate': reliabilityRate,
        'badges': badges,
        'corporateSkillsEarned': corporateSkillsEarned,
      };

  factory MemberProfile.fromJson(Map<String, dynamic> json) => MemberProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        role: ClubRole.values.byName(json['role'] as String),
        department: DepartmentType.values.byName(json['department'] as String),
        yearAndMajor: json['yearAndMajor'] as String,
        totalVerifiedPoints: (json['totalVerifiedPoints'] as num).toInt(),
        reliabilityRate: (json['reliabilityRate'] as num).toDouble(),
        badges: List<String>.from(json['badges'] as List),
        corporateSkillsEarned: Map<String, int>.from(
            json['corporateSkillsEarned'] as Map? ?? {}),
      );
}
