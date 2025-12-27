import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NumberKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onDeleteLongPressed;
  final VoidCallback? onDecimalPressed;
  final String decimalSeparator;
  final bool showDoubleZero;
  final bool compact;

  const NumberKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDeletePressed,
    this.onDeleteLongPressed,
    this.onDecimalPressed,
    this.decimalSeparator = '.',
    this.showDoubleZero = true,
    this.compact = false,
  });

  double get _spacing => compact ? 4 : 8;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(compact ? 8 : 12),
      child: Column(
        children: [
          Expanded(child: _buildRow(context, ['1', '2', '3'])),
          SizedBox(height: _spacing),
          Expanded(child: _buildRow(context, ['4', '5', '6'])),
          SizedBox(height: _spacing),
          Expanded(child: _buildRow(context, ['7', '8', '9'])),
          SizedBox(height: _spacing),
          Expanded(child: _buildBottomRow(context)),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _NumberButton(
              label: key,
              onPressed: () {
                HapticFeedback.lightImpact();
                onKeyPressed(key);
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        // 왼쪽: 소수점 또는 00
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: onDecimalPressed != null
                ? _NumberButton(
                    label: decimalSeparator,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onDecimalPressed!();
                    },
                  )
                : showDoubleZero
                ? _NumberButton(
                    label: '00',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onKeyPressed('00');
                    },
                  )
                : const SizedBox(), // 빈 공간
          ),
        ),
        // 중앙: 0
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _NumberButton(
              label: '0',
              onPressed: () {
                HapticFeedback.lightImpact();
                onKeyPressed('0');
              },
            ),
          ),
        ),
        // 오른쪽: 삭제
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ActionButton(
              icon: PhosphorIconsThin.backspace,
              onPressed: () {
                HapticFeedback.mediumImpact();
                onDeletePressed();
              },
              onLongPressed: () {
                HapticFeedback.heavyImpact();
                onDeleteLongPressed?.call();
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 숫자 버튼
class _NumberButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NumberButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}

/// 액션 버튼 (삭제)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 26,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
