
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/ai_api.dart';
import '../../models/chat.dart';
import '../../utils/theme.dart';
import '../../utils/extensions.dart';
import '../../widgets/common/section_header.dart';

const _starters = [
  'What is my biggest privacy risk right now?',
  'Explain my Gmail permissions in simple terms',
  'How do I improve my privacy score?',
  'What data is being shared with third parties?',
  'Should I be worried about my breach exposure?',
];

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});
  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _api = AiApi();
  bool _loading = false;
  List<ChatMessage> _messages = [
    ChatMessage(
      id: '0',
      role: 'assistant',
      content: "Hi! I'm your PrivacyOS AI assistant. I have context on your connected accounts, permissions, breaches, and privacy score. Ask me anything about your digital privacy.",
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages = [
        ..._messages,
        ChatMessage(id: '${DateTime.now().millisecondsSinceEpoch}', role: 'user', content: msg, timestamp: DateTime.now()),
      ];
      _loading = true;
    });
    _scrollToBottom();
    try {
      final history = _messages.take(_messages.length - 1).takeLast(10)
          .map((m) => {'role': m.role, 'content': m.content}).toList();
      final reply = await _api.chat(msg, history);
      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(id: '${DateTime.now().millisecondsSinceEpoch}r', role: 'assistant', content: reply, timestamp: DateTime.now()),
        ];
      });
    } catch (e) {
      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(id: 'err', role: 'assistant', content: 'Sorry, I am temporarily unavailable. Please try again.', timestamp: DateTime.now()),
        ];
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'AI Privacy Assistant',
          subtitle: 'Ask anything about your privacy posture',
          action: TextButton.icon(
            onPressed: () => setState(() => _messages = [_messages.first]),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Clear'),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_loading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _messages.length) return const _TypingIndicator();
                    return _Bubble(message: _messages[i]);
                  },
                ),
              ),
              if (_messages.length <= 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: _starters.map((s) => GestureDetector(
                      onTap: () => _send(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ),
                    )).toList(),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, color: AppColors.brand, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ask about your privacy...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _loading ? null : () => _send(),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: _loading ? AppColors.surface2 : AppColors.brand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _loading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white, size: 16,
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI responses are based on your actual privacy data. Set ANTHROPIC_API_KEY for full capability.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: AppColors.brand.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brand.withOpacity(0.3)),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: AppColors.brandLight, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.brand : AppColors.surface2,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 14),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 13, height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, color: AppColors.textMuted, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: AppColors.brand.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: AppColors.brand.withOpacity(0.3))),
          child: const Icon(Icons.smart_toy_outlined, color: AppColors.brandLight, size: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14), bottomRight: Radius.circular(14), bottomLeft: Radius.circular(2)),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.3;
                final val = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
                final opacity = val < 0.5 ? val * 2 : 2 - val * 2;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: 0.3 + opacity * 0.7,
                    child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.brand, shape: BoxShape.circle)),
                  ),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}
