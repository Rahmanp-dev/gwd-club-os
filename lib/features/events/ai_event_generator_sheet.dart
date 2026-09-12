import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme/gwd_theme.dart';
import '../../core/models/club_event.dart';
import '../../core/services/ai_event_architect.dart';

class AiEventGeneratorSheet extends StatefulWidget {
  const AiEventGeneratorSheet({
    super.key,
    required this.onGenerate,
  });

  final void Function({
    required String title,
    required String themeTagline,
    required EventCategory category,
    required DateTime targetDate,
    required String venue,
    required int expectedFootfall,
    required String budgetLabel,
    String? customInstructions,
  }) onGenerate;

  @override
  State<AiEventGeneratorSheet> createState() => _AiEventGeneratorSheetState();
}

class _AiEventGeneratorSheetState extends State<AiEventGeneratorSheet> {
  final _titleController = TextEditingController();
  final _taglineController = TextEditingController();
  final _venueController = TextEditingController();
  final _footfallController = TextEditingController(text: '350');
  final _budgetController = TextEditingController(text: '₹50,000 / \$600');
  final _instructionsController = TextEditingController();

  EventCategory _category = EventCategory.flagship;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 20));
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _applyPreset(0);
  }

  void _applyPreset(int index) {
    final preset = AiEventArchitectService.flagshipPresets[index];
    setState(() {
      _titleController.text = preset['title'] as String;
      _taglineController.text = preset['themeTagline'] as String;
      _category = preset['category'] as EventCategory;
      _venueController.text = preset['venue'] as String;
      _footfallController.text = (preset['expectedFootfall'] as int).toString();
      _budgetController.text = preset['budgetLabel'] as String;
      _targetDate = DateTime.now().add(Duration(days: preset['daysOffset'] as int));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _taglineController.dispose();
    _venueController.dispose();
    _footfallController.dispose();
    _budgetController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 900)); // Smooth AI simulation

    if (!mounted) return;
    widget.onGenerate(
      title: title,
      themeTagline: _taglineController.text.trim(),
      category: _category,
      targetDate: _targetDate,
      venue: _venueController.text.trim(),
      expectedFootfall: int.tryParse(_footfallController.text.trim()) ?? 300,
      budgetLabel: _budgetController.text.trim(),
      customInstructions: _instructionsController.text.trim(),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GwdColors.primaryRed, GwdColors.rubyDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'AI Event Architect',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: GwdColors.obsidian,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: GwdColors.rubyLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: GwdColors.primaryRed.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'IN DEV',
                              style: TextStyle(
                                color: GwdColors.primaryRed,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Autonomous multi-department sprint planner · Coming Soon',
                        style: TextStyle(fontSize: 11.5, color: GwdColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: GwdColors.obsidian),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: GwdColors.line),
          // Prominent Dev Status Banner
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: GwdColors.primaryRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.construction_rounded, color: GwdColors.primaryRed, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature Under Development (Coming Soon)',
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Our synchronized task auto-synthesizer is currently in active development. You can test-drive prototype presets below.',
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Flagship Presets',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GwdColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        AiEventArchitectService.flagshipPresets.length,
                        (index) {
                          final preset = AiEventArchitectService.flagshipPresets[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: const Icon(Icons.bolt_rounded, size: 16, color: GwdColors.primaryRed),
                              label: Text(
                                preset['title'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GwdColors.obsidian,
                                ),
                              ),
                              onPressed: () => _applyPreset(index),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: GwdColors.line),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'e.g. GWD Campus Tech Fest 2026',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _taglineController,
                    decoration: const InputDecoration(
                      labelText: 'Theme / Tagline',
                      hintText: 'e.g. Bridging Academia to Corporate Engineering',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<EventCategory>(
                          initialValue: _category,
                          decoration: const InputDecoration(labelText: 'Event Category'),
                          items: EventCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat.label, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _targetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _targetDate = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Target Date'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM d, yyyy').format(_targetDate),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.calendar_today, size: 16, color: GwdColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _venueController,
                          decoration: const InputDecoration(labelText: 'Venue / Auditorium'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _footfallController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Expected Footfall'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _budgetController,
                    decoration: const InputDecoration(labelText: 'Budget Estimate'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Special AI Directives (Optional)',
                      hintText: 'e.g. Include drone video shoot & top FinTech speaker outreach',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: GwdColors.line),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: GwdColors.primaryRed, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'When officially launched, AI Architect will automatically synthesize 12 synchronized tasks with DoD checklists, point weights, and career skills across all departments.',
                            style: TextStyle(color: GwdColors.textPrimary, fontSize: 12, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isGenerating ? null : _handleGenerate,
                      style: FilledButton.styleFrom(
                        backgroundColor: GwdColors.obsidian,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isGenerating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Text('Synthesizing Blueprint (Dev Mode)...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: GwdColors.primaryRed, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Test Dev Prototype (Coming Soon)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
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
