import 'package:flutter/material.dart';

import '../../utilities/text_styles.dart';

class CheckboxTextButton extends StatefulWidget {
  const CheckboxTextButton({
    super.key,
    required this.label,
    this.onChanged,
    this.initialValue = false,
  });

  final String label;
  final void Function(bool)? onChanged;
  final bool initialValue;

  @override
  State<CheckboxTextButton> createState() => _CheckboxTextButtonState();
}

class _CheckboxTextButtonState extends State<CheckboxTextButton> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _value = !_value;
        });
        widget.onChanged?.call(_value);
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 26,
              child: IgnorePointer(
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: _value,
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                widget.label,
                style: STextStyles.w500_14(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
