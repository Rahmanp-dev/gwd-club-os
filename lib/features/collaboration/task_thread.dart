import 'package:flutter/material.dart';

import '../../app/theme/apple_motion.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_role.dart';
import '../../core/models/club_task.dart';
import '../../core/models/collaboration.dart';
import '../../core/models/department.dart';
import '../../core/services/club_workspace_service.dart';
import '../auth/sign_in_page.dart';

/// The conversation attached to one deliverable.
///
/// Threads are where cross-department work actually gets unblocked, so this is
/// deliberately first-class rather than a comments afterthought: `@Name` pings
/// a real person, and any message can be pinned as **the decision** so nobody
/// has to re-read the thread to find what was agreed.
class TaskThread extends StatefulWidget {
  const TaskThread({
    super.key,
    required this.task,
    required this.workspace,
    this.maxHeight,
  });

  final ClubTask task;
  final ClubWorkspaceService workspace;
  final double? maxHeight;

  @override
  State<TaskThread> createState() => _TaskThreadState();
}

class _TaskThreadState extends State<TaskThread> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _markAsDecision = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.workspace
        .postMessage(widget.task.id, text, isDecision: _markAsDecision);
    _controller.clear();
    setState(() => _markAsDecision = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.workspace,
      builder: (context, _) {
        final messages = widget.workspace.messagesFor(widget.task.id);
        final canPin = widget.workspace.currentMember?.role.canVerifyTasks ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionHeader(
              title: 'Thread',
              subtitle: messages.isEmpty
                  ? 'No messages yet — type @Name to pull someone in.'
                  : '${messages.length} message${messages.length == 1 ? '' : 's'}',
            ),
            if (messages.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.maxHeight ?? 320,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: messages.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: GwdSpace.sm),
                  itemBuilder: (context, i) => FluidReveal(
                    index: i,
                    offsetY: 10,
                    child: _MessageBubble(
                      message: messages[i],
                      workspace: widget.workspace,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: GwdSpace.md),
            _buildComposer(context, canPin),
          ],
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context, bool canPin) {
    return Container(
      decoration: BoxDecoration(
        color: GwdColors.surfaceSunken,
        borderRadius: BorderRadius.circular(GwdRadius.lg),
        border: Border.all(color: GwdColors.hairline),
      ),
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 6),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: GwdType.callout.copyWith(color: GwdColors.ink),
            cursorColor: GwdColors.primaryRed,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'Add an update, or @Name to ask someone',
              hintStyle:
                  GwdType.callout.copyWith(color: GwdColors.inkTertiary),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          Row(
            children: [
              if (canPin)
                PressableScale(
                  onTap: () =>
                      setState(() => _markAsDecision = !_markAsDecision),
                  child: AnimatedContainer(
                    duration: AppleDuration.fast,
                    curve: AppleCurves.standard,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: _markAsDecision
                          ? GwdColors.primaryRed
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(GwdRadius.sm),
                      border: Border.all(
                        color: _markAsDecision
                            ? GwdColors.primaryRed
                            : GwdColors.hairline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin_outlined,
                          size: 12,
                          color: _markAsDecision
                              ? Colors.white
                              : GwdColors.inkSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Decision',
                          style: GwdType.caption.copyWith(
                            fontSize: 10,
                            color: _markAsDecision
                                ? Colors.white
                                : GwdColors.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final enabled = value.text.trim().isNotEmpty;
                  return PressableScale(
                    onTap: enabled ? _send : null,
                    haptic: HapticStrength.light,
                    child: AnimatedOpacity(
                      opacity: enabled ? 1 : 0.35,
                      duration: AppleDuration.fast,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: GwdColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded,
                            size: 17, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.workspace});

  final CollabMessage message;
  final ClubWorkspaceService workspace;

  @override
  Widget build(BuildContext context) {
    final author = workspace.memberById(message.authorId);
    final isMe = workspace.currentMemberId == message.authorId;
    final accent = message.isDecision
        ? GwdColors.success
        : (author?.department.color ?? GwdColors.inkSecondary);

    return Container(
      padding: const EdgeInsets.all(GwdSpace.md),
      decoration: BoxDecoration(
        color: message.isDecision
            ? GwdColors.successSoft
            : (isMe ? GwdColors.rubyLight.withValues(alpha: 0.5) : GwdColors.surface),
        borderRadius: BorderRadius.circular(GwdRadius.lg),
        border: Border.all(
          color: message.isDecision
              ? GwdColors.success.withValues(alpha: 0.3)
              : GwdColors.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (author != null) ...[
                MemberAvatar(member: author, size: 24, showRoleRing: false),
                const SizedBox(width: GwdSpace.sm),
              ],
              Expanded(
                child: Text(
                  isMe ? 'You' : message.authorName,
                  style: GwdType.caption.copyWith(color: GwdColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (message.isDecision) ...[
                const GwdChip(
                  label: 'DECISION',
                  color: GwdColors.success,
                  icon: Icons.push_pin_rounded,
                  dense: true,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                relativeTime(message.createdAt),
                style: GwdType.caption
                    .copyWith(color: GwdColors.inkTertiary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: GwdSpace.sm),
          _MentionText(body: message.body, accent: accent),
        ],
      ),
    );
  }
}

/// Renders `@Name` fragments in the department accent colour so a ping is
/// visible at a glance while scanning a thread.
class _MentionText extends StatelessWidget {
  const _MentionText({required this.body, required this.accent});

  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'@([A-Za-z][A-Za-z.\-]*)');
    var index = 0;

    for (final match in pattern.allMatches(body)) {
      if (match.start > index) {
        spans.add(TextSpan(text: body.substring(index, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: GwdType.callout.copyWith(
          color: GwdColors.primaryRed,
          fontWeight: FontWeight.w700,
        ),
      ));
      index = match.end;
    }
    if (index < body.length) {
      spans.add(TextSpan(text: body.substring(index)));
    }

    return RichText(
      text: TextSpan(
        style: GwdType.callout.copyWith(color: GwdColors.ink),
        children: spans,
      ),
    );
  }
}
