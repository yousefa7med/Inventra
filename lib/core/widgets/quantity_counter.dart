import 'dart:developer';

import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityCounter extends StatefulWidget {
  final int quantity;
  final int? maxQuantity;
  final ValueChanged<int> onChanged;
  final TextEditingController controller;
  const QuantityCounter({
    super.key,
    required this.quantity,
    this.maxQuantity,
    required this.onChanged,
    required this.controller,
  });

  @override
  State<QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<QuantityCounter> {
  late int uiQuantity;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    uiQuantity = widget.quantity;
    log(widget.quantity.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (uiQuantity > 1) {
              widget.onChanged(uiQuantity - 1);
              widget.controller.text = (uiQuantity - 1).toString();
              uiQuantity--;
            }

            // widget.quantity > 1 ? () => widget.onChanged(widget.quantity - 1) : },
          },
          icon: const Icon(Icons.remove),
          color: AppColors.red,
        ),
        SizedBox(
          width: 50,
          child: TextFormField(
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                if ((int.tryParse(newValue.text) ?? int.parse(oldValue.text)) >
                    (widget.maxQuantity ?? 0)) {
                  return oldValue;
                }
                return newValue;
              }),
            ],
            controller: widget.controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(71, 117, 118, 130),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            onChanged: (value) {
              uiQuantity = int.tryParse(value) ?? 1;
              if (uiQuantity >= 1 &&
                  uiQuantity <= (widget.maxQuantity ?? double.infinity)) {
                widget.onChanged(uiQuantity);
              }
            },
          ),
        ),
        IconButton(
          onPressed: () {
            print(widget.maxQuantity);
            if (uiQuantity < (widget.maxQuantity ?? double.infinity)) {
              widget.onChanged(uiQuantity + 1);
              widget.controller.text = (uiQuantity + 1).toString();
              uiQuantity++;
            }
          },
          icon: const Icon(Icons.add),
          color: AppColors.success,
        ),
      ],
    );
  }
}
