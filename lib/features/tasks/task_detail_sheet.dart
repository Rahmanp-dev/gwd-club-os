import 'package:flutter/material.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_role.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import '../../core/services/club_workspace_service.dart';
import '../collaboration/task_thread.dart';

class TaskDetailSheet extends StatefulWidget {
  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.viewerRole,
    required this.onSubmitProof,
    required this.onVerifyTask,
    required this.onReportBlocker,
    required this.onResolveBlocker,
    required this.onAcceptTask,
    this.workspace,
  });

  final ClubTask task;
  final ClubRole viewerRole;
  final ClubWorkspaceService? workspace;
  final void Function(String taskId, String proof) onSubmitProof;
  final void Function(String taskId, ClubRole verifierRole, String verifierName) onVerifyTask;
  final void Function(String taskId, String blockerReason, DepartmentType? blockedBy) onReportBlocker;
  final void Function(String taskId) onResolveBlocker;
  final void Function(String taskId) onAcceptTask;

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final _proofController = TextEditingController();
  final _blockerController = TextEditingController();
  DepartmentType? _blockingDept;

  @override
  void dispose() {
    _proofController.dispose();
    _blockerController.dispose();
    super.dispose();
  }

  void _showProofDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deliverable Proof Vault', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit verifiable evidence of outcome (Google Drive folder, Figma link, Frame.io cut, signed MoU, or terminal log).',
              style: TextStyle(fontSize: 12, color: GwdColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _proofController,
              decoration: const InputDecoration(
                hintText: 'https://drive.google.com/... or detail log',
                labelText: 'Proof URL / Output Specification',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final text = _proofController.text.trim();
              if (text.isNotEmpty) {
                widget.onSubmitProof(widget.task.id, text);
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: GwdColors.purple),
            child: const Text('Deposit Proof'),
          ),
        ],
      ),
    );
  }

  void _showBlockerDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Flag Cross-Department Blocker', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silence is not a status. Name what is holding you back and which lead must clear the runway.',
                style: TextStyle(fontSize: 12, color: GwdColors.textSecondary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DepartmentType>(
                decoration: const InputDecoration(labelText: 'Blocking Department (Optional)'),
                items: DepartmentType.values.map((d) {
                  return DropdownMenuItem(value: d, child: Text(d.displayName, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (d) => setDialogState(() => _blockingDept = d),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _blockerController,
                decoration: const InputDecoration(
                  labelText: 'Blocker Explanation',
                  hintText: 'e.g. Awaiting stage lighting positions from Event Ops',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final reason = _blockerController.text.trim();
                if (reason.isNotEmpty) {
                  widget.onReportBlocker(widget.task.id, reason, _blockingDept);
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: GwdColors.coral),
              child: const Text('Flag Blocker'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPactOfDeliveryDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.handshake, color: GwdColors.primaryRed),
            SizedBox(width: 8),
            Text('Pact of Delivery', style: TextStyle(fontWeight: FontWeight.w900, color: GwdColors.obsidian)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GwdColors.rubyLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GwdColors.primaryRed.withValues(alpha: 0.3)),
              ),
              child: Text(
                'I, ${widget.task.assigneeName}, solemnly commit to delivering "${widget.task.title}" by ${widget.task.dueLabel} under GWD Global supervision. I understand that my peers depend on this outcome.',
                style: const TextStyle(fontSize: 12, color: GwdColors.obsidian, height: 1.35, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'By signing, this commitment is logged to your Execution Reliability Score.',
              style: TextStyle(fontSize: 11, color: GwdColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Decline')),
          FilledButton.icon(
            onPressed: () {
              widget.onAcceptTask(widget.task.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: GwdColors.primaryRed),
            icon: const Icon(Icons.draw, size: 16),
            label: const Text('Sign Delivery Pact'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isOwner = task.assigneeRole == widget.viewerRole;
    final canVerify = widget.viewerRole.canVerifyTasks && task.status == TaskStatus.submitted;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: task.department.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.department.displayName.toUpperCase(),
                    style: TextStyle(color: task.department.color, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: task.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.status.label.toUpperCase(),
                    style: TextStyle(color: task.status.color, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
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
                  Text(
                    task.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GwdColors.textPrimary, letterSpacing: -0.4),
                  ),
                  const SizedBox(height: 16),

                  // Meta Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin, size: 16, color: GwdColors.primaryIndigo),
                            const SizedBox(width: 8),
                            Text('Assigned to: ${task.assigneeName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: GwdColors.obsidian, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                task.assigneeRole.shortBadge,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: GwdColors.textSecondary),
                            const SizedBox(width: 8),
                            Text('Due: ${task.dueLabel}', style: const TextStyle(fontSize: 12, color: GwdColors.textSecondary)),
                            const Spacer(),
                            const Icon(Icons.stars, size: 16, color: GwdColors.amber),
                            const SizedBox(width: 4),
                            Text('${task.points} Effort/Skill XP', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scope of Work (SoW)
                  const Text('Scope of Work (SoW) Mandate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GwdColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: Text(
                      task.scopeOfWork.isNotEmpty ? task.scopeOfWork : 'Execute technical deliverable matching tier-1 corporate standards with full changelog and verifiable proof.',
                      style: const TextStyle(fontSize: 13, height: 1.4, color: GwdColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Inter-lead Handshake & Downstream Impact
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.call_split, size: 14, color: GwdColors.primaryIndigo),
                                  SizedBox(width: 4),
                                  Text('Downstream Impact', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.downstreamImpact.isNotEmpty ? task.downstreamImpact : 'Unblocks Marketing & Production handshakes for summit release.',
                                style: const TextStyle(fontSize: 11, color: GwdColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.input, size: 14, color: GwdColors.emerald),
                                  SizedBox(width: 4),
                                  Text('Upstream Input', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.upstreamDependency.isNotEmpty ? task.upstreamDependency : 'College administration and executive budget approval.',
                                style: const TextStyle(fontSize: 11, color: GwdColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Definition of Done (DoD)
                  const Text('Definition of Done (DoD)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GwdColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: Text(task.definitionOfDone, style: const TextStyle(fontSize: 13, height: 1.4, color: GwdColors.textPrimary)),
                  ),

                  const SizedBox(height: 18),

                  // Pre-Fed Skill
                  const Text('Campus-to-Corporate Skill Awarded', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GwdColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined, color: GwdColors.emerald, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.corporateValueSkill,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (task.proof != null) ...[
                    const SizedBox(height: 20),
                    const Text('Deposited Proof in Vault', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GwdColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attachment, color: GwdColors.purple, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(task.proof!, style: const TextStyle(fontSize: 13, color: Color(0xFF6B21A8), height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (task.status == TaskStatus.blocked) ...[
                    const SizedBox(height: 20),
                    const Text('Active Blocker Explanation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GwdColors.coral)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Text(task.blocker ?? 'Blocker unspecified.', style: const TextStyle(fontSize: 13, color: Color(0xFF9F1239))),
                    ),
                  ],

                  if (task.status == TaskStatus.verified) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: GwdColors.emerald, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Verified by ${task.verifiedByName ?? 'Executive Board'} (${task.verifiedByRole?.shortBadge ?? 'EXEC'}). +${task.points} Skill Points deposited.',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Actions
                  if (task.status == TaskStatus.requested && isOwner)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _showPactOfDeliveryDialog,
                        style: FilledButton.styleFrom(backgroundColor: GwdColors.primaryIndigo),
                        icon: const Icon(Icons.draw),
                        label: const Text('Accept & Sign Delivery Pact', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),

                  if (task.status == TaskStatus.inProgress) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showBlockerDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: GwdColors.coral,
                              side: const BorderSide(color: GwdColors.coral),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.report_problem_outlined, size: 18),
                            label: const Text('Flag Blocker', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _showProofDialog,
                            style: FilledButton.styleFrom(
                              backgroundColor: GwdColors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.upload_file_outlined, size: 18),
                            label: const Text('Deposit Proof', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (task.status == TaskStatus.blocked)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () {
                          widget.onResolveBlocker(task.id);
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(backgroundColor: GwdColors.obsidian),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark Blocker Resolved', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),

                  if (canVerify)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () {
                          widget.onVerifyTask(task.id, widget.viewerRole, widget.viewerRole.defaultName);
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(backgroundColor: GwdColors.emerald),
                        icon: const Icon(Icons.verified_outlined),
                        label: Text('Verify Outcome & Credit ${task.points} XP', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),

                  if (widget.workspace != null) ...[
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: GwdColors.hairline),
                    const SizedBox(height: 16),
                    TaskThread(
                      task: task,
                      workspace: widget.workspace!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
