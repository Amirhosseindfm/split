class GroupMemberInfo {
  final String userId;
  final String name;
  final String phone;

  const GroupMemberInfo({
    required this.userId,
    required this.name,
    required this.phone,
  });
}

class GroupSummary {
  final String id;
  final String name;
  final String category;
  final List<GroupMemberInfo> members;

  const GroupSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.members,
  });
}

const groupCategories = ['سفر', 'خانه', 'دوستان', 'دانشگاه', 'خانواده', 'سایر'];
