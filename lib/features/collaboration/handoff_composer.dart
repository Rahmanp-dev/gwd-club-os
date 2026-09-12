import 'package:flutter/material.dart';

import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_task.dart';
import '../../core/models/department.dart';
import '../../core/services/club_workspace_service.dart';

/// Raise a formal request for something you need from another department.
///
/// This is the cure for the "I messaged them, they never replied" failure mode:
/// a handoff has a named owning department, a date it is needed by, and a state
/// the requester can see without chasing anyone.
class HandoffComposer extends StatefulWidget {
  const HandoffComposer({
    super.key,
    required this.workspace,
    this.presetTask,
    this.presetDepartment,
  });

  final ClubWorkspaceService workspace;
  final ClubTask? presetTask;
  final DepartmentType? presetDepartment;

  @override
  State<HandoffComposer> createState() => _HandoffComposerState();
}

class _HandoffComposerState extends State<HandoffComposer> {
  late final TextEditingController _titleController;
  late final TextEditingController _needController;
  DepartmentType? _target;
  int _daysFromNow = 2;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.presetTask?.upstreamDependency ?? '');
    _needController = TextEditingController();
    _target = widget.presetDepartment ??
        widget.presetTask?.blockedByDepartment;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _needController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty && _target != null;

  void _submit() {
    if (!_isValid) return;
    widget.workspace.requestHandoff(
      title: _titleController.text.trim(),
      need: _needController.text.trim().isEmpty
          ? 'No extra detail provided.'
          : _needController.text.trim(),
      toDepartment: _target!,
      neededBy: DateTime.now().add(Duration(days: _daysFromNow)),
      taskId: widget.presetTask?.id,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.workspace.currentMember;
    final options = DepartmentType.values
        .where((d) => d != me?.department)
        .toList();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: GwdColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(GwdRadius.xxl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(
              title: 'Request a handoff',
              subtitle: 'Ask another department for what you need, with a date.',
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                    GwdSpace.xl, 0, GwdSpace.xl, GwdSpace.xl),
                children: [
                  _label('What do you need?'),
                  _field(
                    controller: _titleController,
                    hint: 'e.g. Final stage layout & podium position',
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: GwdSpace.xl),

                  _label('Who owns it?'),
                  Wrap(
                    spacing: GwdSpace.sm,
                    runSpacing: GwdSpace.sm,
                    children: options.map((dept) {
                      final selected = _target == dept;
                      return PressableScale(
                        onTap: () => setState(() => _target = dept),
                        child: AnimatedContainer(
                          duration: AppleDuration.fast,
                          curve: AppleCurves.standard,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: selected
                                ? dept.color
                                : GwdColors.surface,
                            borderRadius:
                                BorderRadius.circular(GwdRadius.md),
                            border: Border.all(
                              color: selected
                                  ? dept.color
                                  : GwdColors.hairline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(dept.icon,
                                  size: 14,
                                  color: selected
                                      ? Colors.white
                                      : dept.color),
                              const SizedBox(width: 6),
                              Text(
                                dept.shortName,
                                style: GwdType.caption.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : GwdColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: GwdSpace.xl),

                  _label('Needed by'),
                  Row(
                    children: [
                      for (final option in const [
                        (1, 'Tomorrow'),
                        (2, 'In 2 days'),
                        (5, 'In 5 days'),
                        (10, 'In 10 days'),
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: GwdSpace.sm),
                            child: PressableScale(
                              onTap: () =>
                                  setState(() => _daysFromNow = option.$1),
                              child: AnimatedContainer(
                                duration: AppleDuration.fast,
                                curve: AppleCurves.standard,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _daysFromNow == option.$1
                                      ? GwdColors.ink
                                      : GwdColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(GwdRadius.md),
                                  border: Border.all(
                                    color: _daysFromNow == option.$1
                                        ? GwdColors.ink
                                        : GwdColors.hairline,
                                  ),
                                ),
                                child: Text(
                                  option.$2,
                                  textAlign: TextAlign.center,
                                  style: GwdType.caption.copyWith(
                                    fontSize: 10,
                                    color: _daysFromNow == option.$1
                                        ? Colors.white
                                        : GwdColors.inkSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: GwdSpace.xl),

                  _label('Any detail they will need'),
                  _field(
                    controller: _needController,
                    hint: 'Dimensions, format, who to send it to…',
                    maxLines: 3,
                  ),
                  const SizedBox(height: GwdSpace.xxl),

                  PressableScale(
                    onTap: _isValid ? _submit : null,
                    haptic: HapticStrength.medium,
                    child: AnimatedOpacity(
                      opacity: _isValid ? 1 : 0.4,
                      duration: AppleDuration.fast,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: GwdColors.primaryRed,
                          borderRadius: BorderRadius.circular(GwdRadius.lg),
                          boxShadow: _isValid
                              ? GwdShadow.accent(GwdColors.primaryRed)
                              : null,
                        ),
                        child: Text(
                          'Send request',
                          style: GwdType.headline.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: GwdSpace.sm),
        child: Text(
          text.toUpperCase(),
          style: GwdType.eyebrow.copyWith(color: GwdColors.inkTertiary),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: GwdColors.surface,
          borderRadius: BorderRadius.circular(GwdRadius.md),
          border: Border.all(color: GwdColors.hairline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged == null ? null : (_) => onChanged(),
          textCapitalization: TextCapitalization.sentences,
          style: GwdType.callout.copyWith(color: GwdColors.ink),
          cursorColor: GwdColors.primaryRed,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: GwdType.callout.copyWith(color: GwdColors.inkTertiary),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
}
