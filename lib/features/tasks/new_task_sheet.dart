import 'package:flutter/material.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/models/club_role.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';

class NewTaskSheet extends StatefulWidget {
  const NewTaskSheet({
    super.key,
    required this.events,
    required this.creatorRole,
    required this.onCreateTask,
  });

  final List<ClubEvent> events;
  final ClubRole creatorRole;
  final void Function(ClubTask task) onCreateTask;

  @override
  State<NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<NewTaskSheet> {
  final _titleController = TextEditingController();
  final _assigneeNameController = TextEditingController(text: 'Sneha Kapoor');
  final _dueLabelController = TextEditingController(text: 'Friday · 5:00 PM');
  final _dodController = TextEditingController();
  final _skillController = TextEditingController(text: 'Campaign ROI & Growth');

  DepartmentType _department = DepartmentType.marketing;
  ClubRole _assigneeRole = ClubRole.marketingLead;
  int _points = 5;
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    if (widget.events.isNotEmpty) {
      _selectedEventId = widget.events.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _assigneeNameController.dispose();
    _dueLabelController.dispose();
    _dodController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _onDepartmentChanged(DepartmentType? dept) {
    if (dept == null) return;
    setState(() {
      _department = dept;
      _assigneeRole = dept.leadRole;
      _assigneeNameController.text = dept.leadRole.defaultName;
      if (dept.corporateSkills.isNotEmpty) {
        _skillController.text = dept.corporateSkills.first;
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final dod = _dodController.text.trim();
    if (title.isEmpty || dod.isEmpty) return;

    final taskId = 'task-custom-${DateTime.now().millisecondsSinceEpoch}';

    final task = ClubTask(
      id: taskId,
      eventId: _selectedEventId,
      title: title,
      department: _department,
      assigneeRole: _assigneeRole,
      assigneeName: _assigneeNameController.text.trim(),
      creatorRole: widget.creatorRole,
      points: _points,
      dueLabel: _dueLabelController.text.trim(),
      dueDate: DateTime.now().add(const Duration(days: 4)),
      definitionOfDone: dod,
      status: TaskStatus.requested,
      corporateValueSkill: _skillController.text.trim(),
    );

    widget.onCreateTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GwdColors.primaryIndigo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_task, color: GwdColors.primaryIndigo, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Club Task',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GwdColors.textPrimary, letterSpacing: -0.4),
                      ),
                      Text('Assign deliverable with DoD & skill points', style: TextStyle(fontSize: 12, color: GwdColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          const Divider(height: 1, color: GwdColors.line),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'e.g. Design 4K LED stage backdrop motion graphic',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<DepartmentType>(
                          initialValue: _department,
                          decoration: const InputDecoration(labelText: 'Department'),
                          items: DepartmentType.values.map((d) {
                            return DropdownMenuItem(value: d, child: Text(d.displayName, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: _onDepartmentChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _points,
                          decoration: const InputDecoration(labelText: 'Effort Points'),
                          items: const [
                            DropdownMenuItem(value: 3, child: Text('3 Pts (Small)')),
                            DropdownMenuItem(value: 5, child: Text('5 Pts (Deliverable)')),
                            DropdownMenuItem(value: 8, child: Text('8 Pts (High Impact)')),
                            DropdownMenuItem(value: 13, child: Text('13 Pts (Major Milestone)')),
                          ],
                          onChanged: (p) {
                            if (p != null) setState(() => _points = p);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ClubRole>(
                          initialValue: _assigneeRole,
                          decoration: const InputDecoration(labelText: 'Assignee Role'),
                          items: ClubRole.values.map((r) {
                            return DropdownMenuItem(value: r, child: Text(r.title, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: (r) {
                            if (r != null) {
                              setState(() {
                                _assigneeRole = r;
                                _assigneeNameController.text = r.defaultName;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _assigneeNameController,
                          decoration: const InputDecoration(labelText: 'Assignee Name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (widget.events.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedEventId,
                      decoration: const InputDecoration(labelText: 'Linked Event / Workshop'),
                      items: widget.events.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (id) => setState(() => _selectedEventId = id),
                    ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _dueLabelController,
                    decoration: const InputDecoration(
                      labelText: 'Due Timeline / Date',
                      hintText: 'e.g. T-5 Days or Saturday · 6:00 PM',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _dodController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Definition of Done (DoD)',
                      hintText: 'What exact verifiable deliverable or outcome completes this work?',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Campus-to-Corporate Skill Awarded',
                      hintText: 'e.g. High-Stakes Negotiation, Live Stage Tech, Storyboarding',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: GwdColors.primaryIndigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Create & Assign Task', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
