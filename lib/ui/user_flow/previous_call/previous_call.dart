import 'package:flutter/material.dart';

class _C {
  // A deep, premium dark slate with a subtle hint of green/cool undertone
  static const bg = Color(0xFF1E2235);

  // A sleek surface color for cards or containers to separate them from the background
  static const card = Color(0xFF181D24);

  // High contrast white/off-white for crisp text readability
  static const title = Color(0xFFFFFFFF);

  // Soft silver/gray to keep the hierarchy of your secondary text clear
  static const subtitle = Color(0xFF9CA3AF);

  // Your signature green remains vibrant against the dark canvas
  static const green = Color(0xFF22C55E);
}

class ContinueConversationCard extends StatelessWidget {
  final String listenerName;
  final String timeLabel;
  final VoidCallback? onRepeatCall;

  const ContinueConversationCard({
    super.key,
    this.listenerName = 'Sarah J.',
    this.timeLabel = 'yesterday',
    this.onRepeatCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── History icon ──────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: _C.green,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // ── Text column ───────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Continue your last conversation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.title,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You talked with $listenerName $timeLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _C.subtitle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Repeat call button ────────────────────────
          GestureDetector(
            onTap: onRepeatCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: _C.green,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _C.green.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Repeat Call',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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