import 'package:flutter/material.dart';
import 'package:lightbulb_animation/utils/style.dart';
import 'package:flutter_glow/flutter_glow.dart';

class LightBulb extends StatefulWidget {
  const LightBulb({Key? key}) : super(key: key);

  @override
  State<LightBulb> createState() => _LightBulbState();
}

class _LightBulbState extends State<LightBulb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;
  late Animation<double> _sizeTween;
  double _dragHeight = 0.0;
  late double _maxDragHeight;
  bool _isDragged = false;
  Color? finalColor;

  @override
  void initState() {
    super.initState();

    // Animation controller with a duration of 500 milliseconds
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Color tween animation
    _colorTween = ColorTween(
      begin: Style.dullshade,
      end: Style.mainshade,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            Curves.easeInOut, // Use a smoother curve (e.g., Curves.easeInOut)
      ),
    );

    // Size tween animation
    _sizeTween = Tween<double>(begin: 150, end: 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // Apply elastic effect to the rope container
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Calculate the maximum drag height based on the available vertical space
    final initialSize = _sizeTween.value;
    _maxDragHeight =
        (MediaQuery.of(context).size.height / 2) - (initialSize / 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        _controller.stop();
        _controller.reset();
        _controller.forward();
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          // Calculate the updated drag height
          double newDragHeight = _dragHeight + details.delta.dy;

          // Limit the drag height within the available space
          _dragHeight = newDragHeight.clamp(0, _maxDragHeight);
        });
      },
      onVerticalDragEnd: (_) {
        _controller.stop();
        setState(() {
          finalColor = Style.mainshade;
          // Reset the drag height
          _dragHeight = 300.0;
          _isDragged = true;
        });
      },
      onTap: () {
        _controller.animateTo(0.0, curve: Curves.easeOut);
        setState(() {
          finalColor = Style.dullshade;
          _dragHeight = 0.0;
          _isDragged = false;
        });
        //_controller.reverse();
      },
      child: Column(
        children: [
          Container(
            width: 3,
            height: _sizeTween.value + _dragHeight - 50,
            color: Style.ropeColor, // Customize the thread color as desired
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final color = _isDragged ? finalColor : _colorTween.value;
              return LayoutBuilder(builder: (context, constraints) {
                return SizedBox(
                  width: 100,
                  height: _sizeTween.value + _dragHeight,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 0,
                        left: MediaQuery.of(context).size.width / 2,
                        child: CustomPaint(
                          painter: RopePainter(
                            color: Style.ropeColor,
                            height: _sizeTween.value + _dragHeight,
                            stretchFactor: _dragHeight / _maxDragHeight,
                          ),
                        ),
                      ),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationX(3.14), // Rotate around the X-axis by 180 degrees
                        child: GlowIcon(
                          Icons.lightbulb,
                          size: 60,
                          color: color,
                          blurRadius: _isDragged ? 10 : 0,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        child: ClipPath(
                          clipper: TrapezoidClipper(),
                          child: Positioned(
                            top: 5,
                            width: 200,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: double.infinity,
                              //padding: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                gradient: _isDragged
                                    ? LinearGradient(
                                        colors: [
                                          Style.mainshade.withOpacity(0.6),
                                          Style.mainshade.withOpacity(0.3),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}

class RopePainter extends CustomPainter {
  final Color color;
  final double height;
  final double stretchFactor;

  RopePainter({
    required this.color,
    required this.height,
    required this.stretchFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final startY = size.height / 2;
    final endY = startY + height;

    final controlPointOffset = size.height * stretchFactor;

    final path = Path();
    path.moveTo(size.width / 2, startY);
    path.cubicTo(
      size.width / 2 - controlPointOffset,
      startY,
      size.width / 2 - controlPointOffset,
      endY,
      size.width / 2,
      endY,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RopePainter oldDelegate) {
    return height != oldDelegate.height ||
        stretchFactor != oldDelegate.stretchFactor;
  }
}

class TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(size.width * 0.305, size.height * 0.41);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.695, size.height * 0.41);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
