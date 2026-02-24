import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kPullDownWidth = 238;

class PullDown extends StatelessWidget {
  const PullDown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kPullDownWidth,
      child: Column(
        children: [
          PullDownMenuItem(
            title: 'Pull Down',
            icon: Icon(Icons.arrow_downward),
            onTap: () {},
          ),
          PullDownMenuItem(
            title: 'Pull Down',
            icon: Icon(Icons.arrow_downward),
            onTap: () {},
          ),
          PullDownMenuItem(
            title: 'Pull Down',
            icon: Icon(Icons.arrow_downward),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class PullDownMenuItem extends StatelessWidget {
  final Color? labelColor;

  final void Function() onTap;
  const PullDownMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.labelColor,
    required this.onTap,
  });

  final String title;
  final Widget icon;

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 20 / 17,
    letterSpacing: -0.43,
    color: Color(0xFF000000), // Labels - Vibrant/Primary
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 8),
        Text(title, style: _labelStyle),
      ],
    );
  }
}
