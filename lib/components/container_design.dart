import 'package:flutter/material.dart';

class ContainerDesign extends StatelessWidget {
  final Widget? child;
  const ContainerDesign({super.key, this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}
