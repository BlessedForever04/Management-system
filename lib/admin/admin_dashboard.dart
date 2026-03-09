import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'dart:math' as math;
// import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/controller/task_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _refreshDashboard(BuildContext context) async {
    final controller = TaskController();
    await controller.getAllTask();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dashboard refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = TaskController().tasks;
    final statusData = <_StatusData>[
      const _StatusData(label: 'Done', count: 5, color: Color(0xFF22C55E)),
      const _StatusData(
        label: 'In Progress',
        count: 7,
        color: Color(0xFF3B82F6),
      ),
      const _StatusData(label: 'Review', count: 2, color: Color(0xFFF59E0B)),
      const _StatusData(label: 'Todo', count: 3, color: Color(0xFFD1D5DB)),
    ];
    final criticalAlerts = <_AlertItem>[
      const _AlertItem(
        title: 'HR Management System',
        subtitle: '174 past deadline',
      ),
      const _AlertItem(
        title: '8 tasks overdue',
        subtitle: 'Tap to view and resolve',
      ),
    ];
    final upcomingDeadlines = <_DeadlineItem>[
      const _DeadlineItem(
        title: 'Payroll Integration',
        subtitle: 'HR Management System',
        due: '434d ago',
        accent: Color(0xFFFF4D57),
        initials: 'PP',
      ),
      const _DeadlineItem(
        title: 'Reporting Dashboard',
        subtitle: 'HR Management System',
        due: '334d ago',
        accent: Color(0xFFF3B200),
        initials: 'AK',
      ),
      const _DeadlineItem(
        title: 'User Acceptance Testing',
        subtitle: 'HR Management System',
        due: '174d ago',
        accent: Color(0xFFFF4D57),
        initials: 'TW',
      ),
      const _DeadlineItem(
        title: 'Checkout Flow Optimization',
        subtitle: 'E-Commerce Platform Redesign',
        due: '154d ago',
        accent: Color(0xFFF3B200),
        initials: 'SC',
      ),
      const _DeadlineItem(
        title: 'Performance Optimization',
        subtitle: 'E-Commerce Platform Redesign',
        due: '124d ago',
        accent: Color(0xFFF3B200),
        initials: 'AK',
      ),
    ];
    final teamMembers = <_TeamMemberItem>[
      const _TeamMemberItem(name: 'Sarah', tasks: '2 tasks', initials: 'SC'),
      const _TeamMemberItem(name: 'Marcus', tasks: '2 tasks', initials: 'MJ'),
      const _TeamMemberItem(name: 'Priya', tasks: '3 tasks', initials: 'PP'),
      const _TeamMemberItem(name: 'Tom', tasks: '1 task', initials: 'TW'),
    ];
    final recentActivity = <_ActivityItem>[
      const _ActivityItem(
        initials: 'AK',
        message: 'Alex submitted "Performance Optimization" for review',
        project: 'E-Commerce Platform Redesign',
        when: '15 day ago',
      ),
      const _ActivityItem(
        initials: 'PP',
        message: 'Priya completed "Authentication Module"',
        project: 'Mobile Banking App v2',
        when: '1 month ago',
      ),
      const _ActivityItem(
        initials: 'JP',
        message: 'Project "AI Analytics Dashboard" created',
        project: 'DataViz Ltd.',
        when: '1 month ago',
      ),
      const _ActivityItem(
        initials: 'MJ',
        message: 'Marcus started "Transaction History UI"',
        project: 'Mobile Banking App v2',
        when: '1 month ago',
      ),
      const _ActivityItem(
        initials: 'PP',
        message: 'Priya submitted "Payroll Integration" for review',
        project: 'HR Management System',
        when: '2 months ago',
      ),
    ];
    final totalStatusCount = statusData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );
    final completionPercent =
        ((statusData.first.count / totalStatusCount) * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color.fromARGB(223, 57, 27, 255),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(223, 57, 27, 255),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const _DashboardBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(223, 57, 27, 255),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      "Manthan Agrawal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      "Sunday, 22 Jan 2026",
                      style: TextStyle(color: Colors.white),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      children: [
                        Expanded(
                          child: _TopStatCard(
                            icon: Icons.folder_open,
                            count: '4',
                            label: 'Projects',
                            iconColor: const Color(0xFFF3B200),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TopStatCard(
                            icon: Icons.edit_note,
                            count: '4',
                            label: 'Active',
                            iconColor: const Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TopStatCard(
                            icon: Icons.task_alt,
                            count: '14',
                            label: 'Tasks',
                            iconColor: const Color(0xFF4ADE80),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TopStatCard(
                            icon: Icons.warning_amber_rounded,
                            count: '8',
                            label: 'Overdue',
                            iconColor: const Color(0xFFFACC15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: const Color(0xFFE6C3C5).withValues(alpha: 0.9),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFF4D57),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Critical Alerts',
                              style: TextStyle(
                                color: Color(0xFFBE2D34),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...criticalAlerts.map((item) => _AlertTile(item: item)),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 2),
              //Task overview
              Padding(
                padding: EdgeInsets.all(20),
                child: Card(
                  color: Colors.white,
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Task Overview",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFFF1F3FF),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(14),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color: Color(0xFF4F46E5),
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Analytics",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4F46E5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 170,
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: CustomPaint(
                                      painter: _DonutChartPainter(statusData),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: statusData
                                      .map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 9,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: item.color,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    item.label,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${item.count}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFE5E7EB), height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Completion',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.withValues(alpha: 0.85),
                              ),
                            ),
                            Text(
                              '$completionPercent%',
                              style: const TextStyle(
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 8),
                        // if (tasks.isEmpty)
                        //   const Text("No tasks available")
                        // else
                        //   Column(
                        //     children: tasks
                        //         .take(3)
                        //         .map(
                        //           (task) => Card(
                        //             margin: const EdgeInsets.only(bottom: 8),
                        //             child: ListTile(
                        //               dense: true,
                        //               title: Text(task.title),
                        //               subtitle: Text(task.priority),
                        //             ),
                        //           ),
                        //         )
                        //         .toList(),
                        //   ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      "Active Projects",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text("See all >"),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "E-Commerce Platform Redesign",
                  subtitle: 'ShopNow Inc.',
                  dueText: '9d over',
                  status: '2/5 tasks',
                  progress: 0.78,
                  teamMembers: ['SC', 'TW', 'MJ', 'AK'],
                  accentColor: Color(0xFF2F59F7),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "Mobile Banking App v2",
                  subtitle: 'TrustBank Corp.',
                  dueText: '36d left',
                  status: '1/3 tasks',
                  progress: 0.35,
                  teamMembers: ['SC', 'JP', 'PP', 'TW'],
                  accentColor: Color(0xFF0FA885),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "HR Management System",
                  subtitle: 'Internal',
                  dueText: '174d over',
                  status: '2/5 tasks',
                  progress: 0.92,
                  teamMembers: ['PP', 'TW', 'SC', 'AK'],
                  accentColor: Color(0xFFE91E63),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProjectCard(
                  title: "AI Analytics Dashboard",
                  subtitle: 'DataViz Ltd.',
                  dueText: '66d left',
                  status: '0/4 tasks',
                  progress: 0.08,
                  teamMembers: ['SC', 'PP'],
                  accentColor: Color(0xFF8B5CF6),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Text(
                      "Upcoming Deadlines",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text("See all >"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: upcomingDeadlines
                        .map((item) => _DeadlineTile(item: item))
                        .toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Row(
                  children: [
                    const Text(
                      'Team',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all >'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (_, index) =>
                      _TeamMemberCard(member: teamMembers[index], index: index),
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemCount: teamMembers.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 18),
                child: Row(
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _refreshDashboard(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.refresh,
                        size: 14,
                        color: Colors.blueGrey.withValues(alpha: 0.85),
                      ),
                      label: Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.blueGrey.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 86),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: recentActivity
                          .map((item) => _ActivityTile(item: item))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusData {
  final String label;
  final int count;
  final Color color;

  const _StatusData({
    required this.label,
    required this.count,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_StatusData> segments;

  _DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, item) => sum + item.count);
    if (total == 0) return;

    final strokeWidth = size.width * 0.20;
    final radius = (math.min(size.width, size.height) / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle = (segment.count / total) * (2 * math.pi);
      paint.color = segment.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _TopStatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color iconColor;

  const _TopStatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF5F3EEA),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 3),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertItem {
  final String title;
  final String subtitle;

  const _AlertItem({required this.title, required this.subtitle});
}

class _DeadlineItem {
  final String title;
  final String subtitle;
  final String due;
  final Color accent;
  final String initials;

  const _DeadlineItem({
    required this.title,
    required this.subtitle,
    required this.due,
    required this.accent,
    required this.initials,
  });
}

class _TeamMemberItem {
  final String name;
  final String tasks;
  final String initials;

  const _TeamMemberItem({
    required this.name,
    required this.tasks,
    required this.initials,
  });
}

class _ActivityItem {
  final String initials;
  final String message;
  final String project;
  final String when;

  const _ActivityItem({
    required this.initials,
    required this.message,
    required this.project,
    required this.when,
  });
}

class _AlertTile extends StatelessWidget {
  final _AlertItem item;

  const _AlertTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD4D6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4D57), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.blueGrey.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final _DeadlineItem item;

  const _DeadlineTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: item.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: item.accent.withValues(alpha: 0.15),
                child: Text(
                  item.initials,
                  style: TextStyle(
                    color: item.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.due,
                style: TextStyle(
                  color: const Color(0xFFFF4D57).withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final _TeamMemberItem member;
  final int index;

  const _TeamMemberCard({required this.member, required this.index});

  @override
  Widget build(BuildContext context) {
    final avatarColors = [
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
    ];

    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarColors[index % avatarColors.length],
                child: Text(
                  member.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            member.tasks,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blueGrey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF8B5CF6),
            child: Text(
              item.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.project,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.when,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav();

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.dashboard_outlined,
      Icons.assignment_outlined,
      Icons.check_box_outlined,
      Icons.bar_chart_outlined,
      Icons.person_outline,
    ];

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == 0;
          return Icon(
            items[index],
            size: 20,
            color: isSelected
                ? const Color.fromARGB(223, 57, 27, 255)
                : Colors.blueGrey.withValues(alpha: 0.6),
          );
        }),
      ),
    );
  }
}
