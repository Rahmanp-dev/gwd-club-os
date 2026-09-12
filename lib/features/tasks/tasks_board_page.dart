import 'package:flutter/material.dart';
import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_role.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import 'new_task_sheet.dart';
import 'task_detail_sheet.dart';

class TasksBoardPage extends StatefulWidget {
  const TasksBoardPage({
    super.key,
    required this.tasks,
    required this.events,
    required this.viewerRole,
    this.initialDepartment,
    required this.onSubmitProof,
    required this.onVerifyTask,
    required this.onReportBlocker,
    required this.onResolveBlocker,
    required this.onAcceptTask,
    required this.onCreateTask,
  });

  final List<ClubTask> tasks;
  final List<ClubEvent> events;
  final ClubRole viewerRole;
  final DepartmentType? initialDepartment;
  final void Function(String taskId, String proof) onSubmitProof;
  final void Function(String taskId, ClubRole verifierRole, String verifierName)
      onVerifyTask;
  final void Function(
          String taskId, String blockerReason, DepartmentType? blockedBy)
      onReportBlocker;
  final void Function(String taskId) onResolveBlocker;
  final void Function(String taskId) onAcceptTask;
  final void Function(ClubTask task) onCreateTask;

  @override
  State<TasksBoardPage> createState() => _TasksBoardPageState();
}

class _TasksBoardPageState extends State<TasksBoardPage> {
  late DepartmentType? _selectedDepartment;
  TaskStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.initialDepartment;
  }

  void _showNewTaskSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewTaskSheet(
        events: widget.events,
        creatorRole: widget.viewerRole,
        onCreateTask: widget.onCreateTask,
      ),
    );
  }

  void _showTaskDetail(ClubTask task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        task: task,
        viewerRole: widget.viewerRole,
        onSubmitProof: widget.onSubmitProof,
        onVerifyTask: widget.onVerifyTask,
        onReportBlocker: widget.onReportBlocker,
        onResolveBlocker: widget.onResolveBlocker,
        onAcceptTask: widget.onAcceptTask,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.tasks.where((task) {
      if (_selectedDepartment != null && task.department != _selectedDepartment) {
        return false;
      }
      if (_selectedStatus != null && task.status != _selectedStatus) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchAssignee = task.assigneeName.toLowerCase().contains(query);
        final matchSkill =
            task.corporateValueSkill.toLowerCase().contains(query);
        if (!matchTitle && !matchAssignee && !matchSkill) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: GwdColors.canvasLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interconnected Tasks',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: GwdColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cross-department deliverables & proof verification',
                          style: TextStyle(
                              color: GwdColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  AppleBouncy(
                    scaleFactor: 0.92,
                    onTap: _showNewTaskSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: GwdColors.obsidian,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Add Task',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search tasks, assignees, corporate skills...',
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: GwdColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: GwdColors.line)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: GwdColors.line)),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Departments'),
                    selected: _selectedDepartment == null,
                    onSelected: (_) =>
                        setState(() => _selectedDepartment = null),
                    selectedColor: GwdColors.obsidian,
                    labelStyle: TextStyle(
                      color: _selectedDepartment == null
                          ? Colors.white
                          : GwdColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...DepartmentType.values.map((dept) {
                    final isSelected = _selectedDepartment == dept;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(dept.shortName),
                        selected: isSelected,
                        onSelected: (val) => setState(
                            () => _selectedDepartment = val ? dept : null),
                        selectedColor: dept.color,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : GwdColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Statuses'),
                    selected: _selectedStatus == null,
                    onSelected: (_) => setState(() => _selectedStatus = null),
                  ),
                  const SizedBox(width: 8),
                  ...TaskStatus.values.map((status) {
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status.label),
                        selected: isSelected,
                        onSelected: (val) => setState(
                            () => _selectedStatus = val ? status : null),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Showing ${filtered.length} tasks',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GwdColors.textSecondary),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No tasks found matching filter',
                              style: TextStyle(
                                  color: GwdColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return AppleStaggerItem(
                          index: index,
                          offsetY: 16,
                          child: AppleBouncy(
                            scaleFactor: 0.97,
                            onTap: () => _showTaskDetail(task),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: task.status == TaskStatus.blocked
                                      ? GwdColors.coral.withValues(alpha: 0.5)
                                      : GwdColors.line,
                                  width: task.status == TaskStatus.blocked
                                      ? 1.5
                                      : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Row(
                                     children: [
                                       Flexible(
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             Container(
                                               padding: const EdgeInsets.symmetric(
                                                   horizontal: 7, vertical: 3.5),
                                               decoration: BoxDecoration(
                                                 color: task.department.color
                                                     .withValues(alpha: 0.12),
                                                 borderRadius:
                                                     BorderRadius.circular(8),
                                               ),
                                               child: Text(
                                                 task.department.shortName
                                                     .toUpperCase(),
                                                 style: TextStyle(
                                                   color: task.department.color,
                                                   fontSize: 9.5,
                                                   fontWeight: FontWeight.w800,
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(width: 6),
                                             Flexible(
                                               child: Container(
                                                 padding: const EdgeInsets.symmetric(
                                                     horizontal: 7, vertical: 3.5),
                                                 decoration: BoxDecoration(
                                                   color: task.status.color
                                                       .withValues(alpha: 0.12),
                                                   borderRadius:
                                                       BorderRadius.circular(8),
                                                 ),
                                                 child: Text(
                                                   task.status.label.toUpperCase(),
                                                   style: TextStyle(
                                                     color: task.status.color,
                                                     fontSize: 9.5,
                                                     fontWeight: FontWeight.w800,
                                                   ),
                                                   maxLines: 1,
                                                   overflow: TextOverflow.ellipsis,
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                       const SizedBox(width: 8),
                                       Container(
                                         padding: const EdgeInsets.symmetric(
                                             horizontal: 7, vertical: 3),
                                         decoration: BoxDecoration(
                                           color: const Color(0xFFF1F5F9),
                                           borderRadius:
                                               BorderRadius.circular(6),
                                         ),
                                         child: Text(
                                           '${task.points} PTS',
                                           style: const TextStyle(
                                             fontSize: 10.5,
                                             fontWeight: FontWeight.w800,
                                             color: GwdColors.textPrimary,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(height: 10),
                                   Text(
                                     task.title,
                                     style: const TextStyle(
                                       fontWeight: FontWeight.w700,
                                       fontSize: 14,
                                       color: GwdColors.textPrimary,
                                       height: 1.3,
                                     ),
                                   ),
                                   const SizedBox(height: 8),
                                   Row(
                                     children: [
                                       const Icon(Icons.person_outline,
                                           size: 14,
                                           color: GwdColors.textSecondary),
                                       const SizedBox(width: 4),
                                       Expanded(
                                         child: Text(
                                           '${task.assigneeName} (${task.assigneeRole.shortBadge})',
                                           style: const TextStyle(
                                               color: GwdColors.textSecondary,
                                               fontSize: 11.5),
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                         ),
                                       ),
                                       const SizedBox(width: 8),
                                       const Icon(Icons.schedule,
                                           size: 13,
                                           color: GwdColors.textSecondary),
                                       const SizedBox(width: 4),
                                       Text(
                                         task.dueLabel,
                                         style: const TextStyle(
                                             color: GwdColors.textSecondary,
                                             fontSize: 11.5),
                                       ),
                                     ],
                                   ),
                                  if (task.blocker != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFECDD3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.warning_amber_rounded,
                                              size: 14,
                                              color: GwdColors.coral),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Blocked: ${task.blocker!}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF9F1239)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (task.proof != null &&
                                      task.status == TaskStatus.submitted) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF5FF),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFE9D5FF)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.upload_file_outlined,
                                              size: 14,
                                              color: GwdColors.purple),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Proof: ${task.proof!}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B21A8)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
