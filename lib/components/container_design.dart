import 'package:flutter/material.dart';

class ContainerDesign extends StatelessWidget {
  final Widget? child;
  const ContainerDesign({super.key, this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}
