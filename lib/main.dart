import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const HubApp());

// Color System
class C {
  static const primary = Color(0xFF0284C7);
  static const primary2 = Color(0xFF0369A1);
  static const primaryDark = Color(0xFF075985);
  static const accent = Color(0xFF0EA5E9);
  static const cyan = Color(0xFF38BDF8);
  static const tint1 = Color(0xFFF0F9FF);
  static const tint2 = Color(0xFFE0F2FE);
  static const bg = Color(0xFFF8FAFC);
  static const cardBg = Colors.white;
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF475569);
  static const line = Color(0xFFBAE6FD);
}

// -----------------------------------------------------------------------------
// 3D MODEL ENGINE & CUSTOM PAINTER
// -----------------------------------------------------------------------------

class Vector3D {
  final double x, y, z;
  const Vector3D(this.x, this.y, this.z);

  Vector3D rotateX(double rad) {
    final c = math.cos(rad), s = math.sin(rad);
    return Vector3D(x, y * c - z * s, y * s + z * c);
  }

  Vector3D rotateY(double rad) {
    final c = math.cos(rad), s = math.sin(rad);
    return Vector3D(x * c + z * s, y, -x * s + z * c);
  }

  Vector3D rotateZ(double rad) {
    final c = math.cos(rad), s = math.sin(rad);
    return Vector3D(x * c - y * s, x * s + y * c, z);
  }

  Vector3D add(Vector3D v) => Vector3D(x + v.x, y + v.y, z + v.z);
  Vector3D sub(Vector3D v) => Vector3D(x - v.x, y - v.y, z - v.z);

  Vector3D cross(Vector3D v) => Vector3D(
        y * v.z - z * v.y,
        z * v.x - x * v.z,
        x * v.y - y * v.x,
      );

  double dot(Vector3D v) => x * v.x + y * v.y + z * v.z;

  double get length => math.sqrt(x * x + y * y + z * z);

  Vector3D get normalized {
    final l = length;
    return l == 0 ? const Vector3D(0, 0, 0) : Vector3D(x / l, y / l, z / l);
  }
}

class Polygon3D {
  final List<int> indices;
  final Color color;
  Polygon3D(this.indices, this.color);
}

class Model3DData {
  final String name;
  final List<Vector3D> vertices;
  final List<Polygon3D> faces;
  Model3DData(this.name, this.vertices, this.faces);

  static Model3DData createIcosahedron() {
    final phi = (1.0 + math.sqrt(5.0)) / 2.0;
    final scale = 1.2;
    final rawVerts = [
      Vector3D(-1, phi, 0), Vector3D(1, phi, 0), Vector3D(-1, -phi, 0), Vector3D(1, -phi, 0),
      Vector3D(0, -1, phi), Vector3D(0, 1, phi), Vector3D(0, -1, -phi), Vector3D(0, 1, -phi),
      Vector3D(phi, 0, -1), Vector3D(phi, 0, 1), Vector3D(-phi, 0, -1), Vector3D(-phi, 0, 1),
    ].map((v) => Vector3D(v.x * scale, v.y * scale, v.z * scale)).toList();

    final faceIndices = [
      [0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
      [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
      [3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
      [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
    ];

    final colors = [
      const Color(0xFF0284C7), const Color(0xFF0EA5E9), const Color(0xFF38BDF8), const Color(0xFF0284C7),
      const Color(0xFF0369A1), const Color(0xFF38BDF8), const Color(0xFF0EA5E9), const Color(0xFF0284C7),
      const Color(0xFF0369A1), const Color(0xFF0EA5E9), const Color(0xFF38BDF8), const Color(0xFF0284C7),
      const Color(0xFF0369A1), const Color(0xFF0EA5E9), const Color(0xFF38BDF8), const Color(0xFF0284C7),
      const Color(0xFF0369A1), const Color(0xFF0EA5E9), const Color(0xFF38BDF8), const Color(0xFF0284C7),
    ];

    return Model3DData('3D Crystal Node', rawVerts, [
      for (int i = 0; i < faceIndices.length; i++) Polygon3D(faceIndices[i], colors[i % colors.length])
    ]);
  }

  static Model3DData createOctahedron() {
    final s = 1.8;
    final verts = [
      Vector3D(0, s, 0), Vector3D(s, 0, 0), Vector3D(0, 0, s),
      Vector3D(-s, 0, 0), Vector3D(0, 0, -s), Vector3D(0, -s, 0),
    ];
    final faceIndices = [
      [0, 1, 2], [0, 2, 3], [0, 3, 4], [0, 4, 1],
      [5, 2, 1], [5, 3, 2], [5, 4, 3], [5, 1, 4],
    ];
    final colors = [
      const Color(0xFF0284C7), const Color(0xFF38BDF8), const Color(0xFF0EA5E9), const Color(0xFF0369A1),
      const Color(0xFF38BDF8), const Color(0xFF0284C7), const Color(0xFF0369A1), const Color(0xFF0EA5E9),
    ];
    return Model3DData('3D Prism Diamond', verts, [
      for (int i = 0; i < faceIndices.length; i++) Polygon3D(faceIndices[i], colors[i])
    ]);
  }

  static Model3DData createCyberCube() {
    final s = 1.4;
    final verts = [
      Vector3D(-s, -s, -s), Vector3D(s, -s, -s), Vector3D(s, s, -s), Vector3D(-s, s, -s),
      Vector3D(-s, -s, s), Vector3D(s, -s, s), Vector3D(s, s, s), Vector3D(-s, s, s),
    ];
    final faceIndices = [
      [0, 1, 2, 3], [5, 4, 7, 6], [4, 0, 3, 7], [1, 5, 6, 2], [4, 5, 1, 0], [3, 2, 6, 7]
    ];
    final colors = [
      const Color(0xFF0284C7), const Color(0xFF0EA5E9), const Color(0xFF38BDF8),
      const Color(0xFF0369A1), const Color(0xFF7DD3FC), const Color(0xFF0284C7)
    ];
    return Model3DData('3D Cyber Cube', verts, [
      for (int i = 0; i < faceIndices.length; i++) Polygon3D(faceIndices[i], colors[i])
    ]);
  }
}

class ThreeDModelPainter extends CustomPainter {
  final Model3DData model;
  final double rotX;
  final double rotY;
  final double rotZ;
  final bool isWireframe;
  final Color primaryColor;

  ThreeDModelPainter({
    required this.model,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    required this.isWireframe,
    this.primaryColor = C.cyan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fov = math.min(size.width, size.height) * 0.45;
    final cameraZ = 5.0;

    // Transform vertices
    final transformedVerts = <Vector3D>[];
    for (final v in model.vertices) {
      final r = v.rotateX(rotX).rotateY(rotY).rotateZ(rotZ);
      transformedVerts.add(r);
    }

    // Directional light vector
    final lightDir = const Vector3D(0.5, 0.8, 1.0).normalized;

    // Process faces with Z-sorting
    final faceRenderList = <({Polygon3D polygon, double avgZ, Vector3D normal})>[];

    for (final poly in model.faces) {
      if (poly.indices.length < 3) continue;

      final v0 = transformedVerts[poly.indices[0]];
      final v1 = transformedVerts[poly.indices[1]];
      final v2 = transformedVerts[poly.indices[2]];

      final edge1 = v1.sub(v0);
      final edge2 = v2.sub(v0);
      final normal = edge1.cross(edge2).normalized;

      double sumZ = 0;
      for (final idx in poly.indices) {
        sumZ += transformedVerts[idx].z;
      }
      final avgZ = sumZ / poly.indices.length;

      faceRenderList.add((polygon: poly, avgZ: avgZ, normal: normal));
    }

    faceRenderList.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    for (final item in faceRenderList) {
      final poly = item.polygon;
      final path = Path();
      final points = <Offset>[];

      for (int i = 0; i < poly.indices.length; i++) {
        final v = transformedVerts[poly.indices[i]];
        final z = cameraZ + v.z;
        if (z <= 0.1) continue;
        final scale = fov / z;
        final px = center.dx + v.x * scale;
        final py = center.dy - v.y * scale;
        final pt = Offset(px, py);
        points.add(pt);

        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();

      final diff = math.max(0.25, item.normal.dot(lightDir));
      final baseC = poly.color;
      final shadedColor = Color.fromARGB(
        (baseC.a * 255).round(),
        ((baseC.r * 255) * diff).clamp(0, 255).toInt(),
        ((baseC.g * 255) * diff).clamp(0, 255).toInt(),
        ((baseC.b * 255) * diff).clamp(0, 255).toInt(),
      );

      if (!isWireframe) {
        final fillPaint = Paint()
          ..color = shadedColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }

      final strokePaint = Paint()
        ..color = isWireframe ? primaryColor : Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isWireframe ? 1.8 : 1.0;
      canvas.drawPath(path, strokePaint);

      if (isWireframe) {
        final vertPaint = Paint()..color = Colors.white;
        for (final pt in points) {
          canvas.drawCircle(pt, 2.5, vertPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ThreeDModelPainter oldDelegate) =>
      oldDelegate.rotX != rotX ||
      oldDelegate.rotY != rotY ||
      oldDelegate.rotZ != rotZ ||
      oldDelegate.isWireframe != isWireframe ||
      oldDelegate.model != model;
}

// -----------------------------------------------------------------------------
// INTERACTIVE 3D MODEL VIEWER WIDGET
// -----------------------------------------------------------------------------

class ThreeDModelViewerWidget extends StatefulWidget {
  final double height;
  final String title;
  final bool showControls;

  const ThreeDModelViewerWidget({
    super.key,
    this.height = 280,
    this.title = 'Interactive 3D Hub Model',
    this.showControls = true,
  });

  @override
  State<ThreeDModelViewerWidget> createState() => _ThreeDModelViewerWidgetState();
}

class _ThreeDModelViewerWidgetState extends State<ThreeDModelViewerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  int _modelIndex = 0;
  bool _isWireframe = false;
  double _userRotX = 0.3;
  double _userRotY = 0.4;
  bool _autoRotate = true;

  final _models = [
    Model3DData.createIcosahedron(),
    Model3DData.createOctahedron(),
    Model3DData.createCyberCube(),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.line.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: C.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: GridPatternPainter()),
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _autoRotate = false;
                _userRotY += details.delta.dx * 0.01;
                _userRotX -= details.delta.dy * 0.01;
              });
            },
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                final angle = _anim.value * 2 * math.pi;
                final rotX = _autoRotate ? _userRotX + math.sin(angle) * 0.2 : _userRotX;
                final rotY = _autoRotate ? _userRotY + angle : _userRotY;

                return CustomPaint(
                  size: Size.infinite,
                  painter: ThreeDModelPainter(
                    model: _models[_modelIndex],
                    rotX: rotX,
                    rotY: rotY,
                    rotZ: angle * 0.2,
                    isWireframe: _isWireframe,
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.view_in_ar, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_models[_modelIndex].name} · Orbit with touch/drag',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (widget.showControls)
            Positioned(
              right: 12,
              bottom: 12,
              child: Wrap(
                spacing: 6,
                children: [
                  IconButton.filledTonal(
                    iconSize: 18,
                    tooltip: 'Toggle Wireframe',
                    style: IconButton.styleFrom(
                      backgroundColor: _isWireframe ? C.accent : Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _isWireframe = !_isWireframe),
                    icon: Icon(_isWireframe ? Icons.grid_4x4 : Icons.waves),
                  ),
                  IconButton.filledTonal(
                    iconSize: 18,
                    tooltip: 'Switch 3D Geometry',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _modelIndex = (_modelIndex + 1) % _models.length),
                    icon: const Icon(Icons.category),
                  ),
                  IconButton.filledTonal(
                    iconSize: 18,
                    tooltip: _autoRotate ? 'Pause Auto-Spin' : 'Play Auto-Spin',
                    style: IconButton.styleFrom(
                      backgroundColor: _autoRotate ? C.accent : Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _autoRotate = !_autoRotate),
                    icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// REUSABLE 3D PERSPECTIVE TILT CARD WIDGET
// -----------------------------------------------------------------------------

class Interactive3DCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color border;

  const Interactive3DCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
    this.border = C.line,
  });

  @override
  State<Interactive3DCard> createState() => _Interactive3DCardState();
}

class _Interactive3DCardState extends State<Interactive3DCard> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _hovering = false;

  void _onHover(PointerEvent details, Size size) {
    final px = details.localPosition.dx / size.width - 0.5;
    final py = details.localPosition.dy / size.height - 0.5;
    setState(() {
      _tiltY = px * 0.12;
      _tiltX = -py * 0.12;
    });
  }

  void _resetTilt() {
    setState(() {
      _hovering = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return MouseRegion(
          cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: (_) => setState(() => _hovering = true),
          onHover: (e) => _onHover(e, size),
          onExit: (_) => _resetTilt(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX)
              ..rotateY(_tiltY)
              ..setTranslationRaw(0.0, _hovering ? -4.0 : 0.0, 0.0),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovering ? C.primary : widget.border,
                width: _hovering ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovering
                      ? C.primary.withValues(alpha: 0.20)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: _hovering ? 18 : 8,
                  offset: Offset(0, _hovering ? 8 : 3),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper Widgets
Text t(String s, {double size = 14, FontWeight w = FontWeight.w400, Color color = C.text}) =>
    Text(s, style: TextStyle(fontSize: size, fontWeight: w, color: color));

Widget iconBox(IconData i, Color c) => Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Icon(i, color: Colors.white, size: 20),
    );

Widget pill(String s, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)),
      child: t(s, size: 11, w: FontWeight.w700, color: Colors.white),
    );

// -----------------------------------------------------------------------------
// MAIN APPLICATION ENTRY POINT
// -----------------------------------------------------------------------------

class HubApp extends StatelessWidget {
  const HubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIST University Student Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
        scaffoldBackgroundColor: C.bg,
        fontFamily: 'Roboto',
      ),
      home: const Shell(),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN SHELL SCREEN & RESPONSIVE CONTROLLERS
// -----------------------------------------------------------------------------

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _page = 0;
  int _sem = 4;
  String _day = 'Mon';
  String _tag = 'All';
  String _q = '';
  String _cat = 'Academic';

  final _ctrl = TextEditingController();
  final _taskInputCtrl = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _reg = <String>{'AI Hack Night'};
  final _tasks = <String>[
    'Submit ML lab record',
    'Read Deep Learning Ch. 5',
    'Register for AI Hack Night',
    'Renew library books',
  ];
  late List<bool> _done;

  final _alerts = <(String, String)>[
    (
      'Lab record submission — due Thu, 4 PM',
      'Submit your ML Lab records to the department office. Bring the signed cover sheet; late work loses 10% internal marks.'
    ),
    (
      'Scholarship briefing — Fri, 11 AM',
      'Merit scholarship briefing in Auditorium 2. Bring your ID card and last semester marksheet.'
    ),
    (
      'Wi-Fi maintenance — Sat, 2–4 AM',
      'Campus Wi-Fi will be offline for upgrades. Download study material beforehand.'
    ),
  ];

  final _tickets = <(String, String, bool)>[
    ('Hostel Wi-Fi not connecting', 'Facilities', false),
    ('Grade discrepancy in Data Mining', 'Academic', true),
  ];

  final Map<String, double> _simulatedMarks = {
    'Deep Learning': 94.0,
    'Data Structures': 89.0,
    'Computer Networks': 82.0,
    'AI Ethics': 95.0,
  };

  static const _nav = [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.calendar_month_outlined, 'Timetable'),
    (Icons.school_outlined, 'Results'),
    (Icons.event_outlined, 'Events'),
    (Icons.photo_library_outlined, 'Campus Gallery'),
    (Icons.support_agent, 'Helpdesk'),
  ];

  static const _svc = [
    (Icons.calendar_month, 'Timetable', 'Next: DL Lab, 10 AM', 'assets/images/service_lab.jpg'),
    (Icons.school, 'Results', 'Sem 4 published', 'assets/images/campus_hero.jpg'),
    (Icons.local_library, 'Library', '2 books issued', 'assets/images/service_library.jpg'),
    (Icons.payments, 'Fees', 'Paid · No dues', 'assets/images/campus_hero.jpg'),
    (Icons.event, 'Events', '4 upcoming', 'assets/images/event_hackathon.jpg'),
    (Icons.support_agent, 'Helpdesk', 'Raise a ticket', 'assets/images/service_lab.jpg'),
  ];

  static const _tt = {
    'Mon': [
      ('9:00 AM', 'Deep Learning', 'Lab 3', 'Dr. Rao'),
      ('11:00 AM', 'Data Structures', 'Room 204', 'Prof. Smith'),
      ('2:00 PM', 'Ethics in AI', 'Hall B', 'Dr. Mehta')
    ],
    'Tue': [
      ('10:00 AM', 'Computer Networks', 'Room 110', 'Prof. Jones'),
      ('1:00 PM', 'Statistics', 'Room 305', 'Dr. Ali')
    ],
    'Wed': [
      ('9:00 AM', 'Data Structures Lab', 'Lab 1', 'Prof. Smith'),
      ('12:00 PM', 'Deep Learning', 'Room 204', 'Dr. Rao'),
      ('3:00 PM', 'Seminar', 'Auditorium 2', 'Guest Speaker')
    ],
    'Thu': [
      ('11:00 AM', 'Computer Networks', 'Room 110', 'Prof. Jones'),
      ('2:00 PM', 'ML Lab', 'Lab 3', 'Dr. Rao')
    ],
    'Fri': [
      ('9:00 AM', 'Ethics in AI', 'Hall B', 'Dr. Mehta'),
      ('11:00 AM', 'Statistics', 'Room 305', 'Dr. Ali')
    ],
  };

  static const _res = {
    3: [
      ('Machine Learning', 'A', 92.0),
      ('Algorithms', 'A-', 88.0),
      ('Databases', 'B+', 81.0),
      ('Statistics', 'A', 90.0)
    ],
    4: [
      ('Deep Learning', 'A', 94.0),
      ('Data Structures', 'A-', 89.0),
      ('Computer Networks', 'B+', 82.0),
      ('AI Ethics', 'A', 95.0)
    ],
  };

  static const _ev = [
    (
      'AI Hack Night',
      '18',
      'OCT',
      'Innovation Lab, Block C',
      'Tech',
      'assets/images/event_hackathon.jpg',
      'Build cutting edge LLM agents and vision models in 24 hours. \$5,000+ prizes!'
    ),
    (
      'Football Trials',
      '21',
      'OCT',
      'Main Stadium Pitch',
      'Sports',
      'assets/images/event_sports.jpg',
      'Annual university varsity football selection trials for undergrads.'
    ),
    (
      'Library Digital Workshop',
      '24',
      'OCT',
      'Digital Media Wing',
      'Academic',
      'assets/images/service_library.jpg',
      'Master IEEE & ACM research database search & citation indexing.'
    ),
    (
      'Robotics & AI Expo',
      '28',
      'OCT',
      'Student Centre Hall',
      'Tech',
      'assets/images/service_lab.jpg',
      'Live demonstration of autonomous campus rovers and drone swarms.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _done = List<bool>.filled(_tasks.length, false);
    _done[2] = true;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _taskInputCtrl.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _page = i);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _snack(String m, {SnackBarAction? action}) {
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, action: action));
  }

  void _dialog(String title, String body, String action, {VoidCallback? run}) => showDialog(
        context: context,
        builder: (d) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Close')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: C.primary),
              onPressed: () {
                Navigator.pop(d);
                run?.call();
                _snack('$action ✓');
              },
              child: Text(action),
            ),
          ],
        ),
      );

  void _showImageLightbox(String imagePath, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) {
        final screenH = MediaQuery.sizeOf(ctx).height;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: BoxConstraints(maxWidth: 750, maxHeight: screenH * 0.85),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: C.cyan, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: screenH < 600 ? 200 : 320,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: C.primaryDark,
                        child: const Icon(Icons.image, size: 60, color: Colors.white54),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close, color: Colors.white70),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _open(String n) {
    switch (n) {
      case 'Timetable':
        _go(1);
      case 'Results':
        _go(2);
      case 'Events':
        _go(3);
      case 'Campus Gallery':
        _go(4);
      case 'Helpdesk':
        _go(5);
      case 'Library':
        _showImageLightbox(
          'assets/images/service_library.jpg',
          'SIST University Library',
          '2 Books Currently Issued:\n• Data Mining & Analytics (Due: Oct 12)\n• Computer Vision Principles (Due: Oct 15)',
        );
      default:
        _dialog('Fees & Dues', 'Semester 5 Tuition Fee: Paid ✓\nLibrary Dues: \$0.00\nNo outstanding balances found.', 'Download Official Receipt');
    }
  }

  void _submitTicket() {
    final s = _ctrl.text.trim();
    if (s.isEmpty) {
      _snack('Please describe your issue first');
      return;
    }
    setState(() => _tickets.insert(0, (s, _cat, false)));
    _ctrl.clear();
    _snack('Support ticket submitted successfully!');
  }

  void _addNewTask() {
    final txt = _taskInputCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _tasks.add(txt);
      _done.add(false);
    });
    _taskInputCtrl.clear();
    Navigator.pop(context);
    _snack('New task added!');
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: _taskInputCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Prepare for AI Midterm', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.primary),
            onPressed: _addNewTask,
            child: const Text('Add Task'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    final body = SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : (isMobile ? 12 : 20)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(_page),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _top(isDesktop),
                switch (_page) {
                  0 => _dash(isDesktop, isMobile),
                  1 => _timetable(),
                  2 => _results(isMobile),
                  3 => _events(isMobile),
                  4 => _gallery(isMobile),
                  _ => _help(),
                },
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : Drawer(child: _sidebarContent()),
      body: SafeArea(
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_sidebarContent(), Expanded(child: body)],
              )
            : body,
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _page,
              onDestinationSelected: _go,
              labelBehavior: isMobile ? NavigationDestinationLabelBehavior.onlyShowSelected : NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [for (final n in _nav) NavigationDestination(icon: Icon(n.$1), label: n.$2)],
            ),
    );
  }

  // ---------- RESPONSIVE SIDEBAR / DRAWER CONTENT ----------
  Widget _sidebarContent() => Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      t('SIST Hub', size: 20, w: FontWeight.w800, color: Colors.white),
                      t('Student Portal', size: 11, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mini 3D canvas snippet in sidebar
            const ThreeDModelViewerWidget(height: 140, title: '3D Hub', showControls: false),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  for (var i = 0; i < _nav.length; i++)
                    _NavTile(
                      icon: _nav[i].$1,
                      label: _nav[i].$2,
                      selected: _page == i,
                      onTap: () => _go(i),
                    ),
                ],
              ),
            ),

            // Profile Card
            GestureDetector(
              onTap: () => _showImageLightbox(
                'assets/images/student_avatar.jpg',
                'Tanuj · SIST Student',
                'ID: SIST-24-0417\nB.Tech CSE (Artificial Intelligence)\nSemester 5',
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/student_avatar.jpg',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => CircleAvatar(
                          backgroundColor: C.tint2,
                          child: t('T', w: FontWeight.w800, color: C.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t('Tanuj', w: FontWeight.w700, color: Colors.white),
                          t('SIST-24-0417', size: 11, color: Colors.white70),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _top(bool isDesktop) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            if (!isDesktop) ...[
              IconButton.filledTonal(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                tooltip: 'Open Menu',
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                _nav[_page].$2,
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 22,
                  fontWeight: FontWeight.w800,
                  color: C.text,
                ),
              ),
            ),
            Badge(
              isLabelVisible: _alerts.isNotEmpty,
              label: Text('${_alerts.length}'),
              child: IconButton.filledTonal(
                iconSize: 22,
                tooltip: 'Notifications',
                onPressed: () => _dialog(
                  'Notifications Center',
                  _alerts.isEmpty ? "You're all caught up!" : _alerts.map((a) => '• ${a.$1}').join('\n\n'),
                  'Mark all read',
                  run: () => setState(_alerts.clear),
                ),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
        ),
      );

  // ---------- DASHBOARD ----------
  Widget _dash(bool isDesktop, bool isMobile) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heroBanner(isMobile),
        const SizedBox(height: 20),
        ThreeDModelViewerWidget(height: isMobile ? 220 : 260, title: '3D Campus Spatial Node'),
        const SizedBox(height: 20),
        _quick(isMobile),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _announce(),
        const SizedBox(height: 20),
        _tasksCard(),
        const SizedBox(height: 20),
        _shuttle(),
      ],
    );

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: left),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: right),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 20), right],
          );
  }

  Widget _heroBanner(bool isMobile) {
    final h = DateTime.now().hour;
    final g = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: C.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/campus_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: C.primaryDark),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F172A).withValues(alpha: 0.90),
                    const Color(0xFF0369A1).withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),

          // Responsive Content Padding
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageLightbox(
                        'assets/images/student_avatar.jpg',
                        'Tanuj',
                        'Computer Science & Engineering (AI)',
                      ),
                      child: Container(
                        width: isMobile ? 48 : 58,
                        height: isMobile ? 48 : 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: C.cyan, width: 2.5),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/student_avatar.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => CircleAvatar(
                              backgroundColor: C.tint2,
                              child: t('T', size: 20, w: FontWeight.w800, color: C.accent),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t('$g, Tanuj', size: isMobile ? 20 : 24, w: FontWeight.w800, color: Colors.white),
                          t('SIST-24-0417 · B.Tech CSE (AI)', size: isMobile ? 12 : 13, color: Colors.white70),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final s in const [
                      ('8.9', 'CGPA'),
                      ('21', 'Credits'),
                      ('94%', 'Attendance'),
                      ('Dr. Rao', 'Advisor')
                    ])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            t(s.$1, size: isMobile ? 16 : 18, w: FontWeight.w800, color: Colors.white),
                            t(s.$2, size: 10, color: Colors.white70),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quick(bool isMobile) {
    final items = _svc.where((s) => s.$2.toLowerCase().contains(_q.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (ctx, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                t('Quick Services', size: 18, w: FontWeight.w700),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: C.line),
                    ),
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: t('Quick Services', size: 20, w: FontWeight.w700)),
              SizedBox(
                width: 200,
                child: TextField(
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: C.line),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 14),
        if (items.isEmpty)
          t('No matching service found for "$_q"', color: C.muted)
        else
          LayoutBuilder(
            builder: (ctx, c) {
              final n = c.maxWidth > 750 ? 3 : (c.maxWidth > 420 ? 2 : 1);
              final w = (c.maxWidth - 12 * (n - 1)) / n;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final s in items)
                    SizedBox(
                      width: w,
                      child: Interactive3DCard(
                        color: Colors.white,
                        onTap: () => _open(s.$2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                s.$4,
                                height: 75,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 75,
                                  color: C.tint1,
                                  child: Icon(s.$1, color: C.primary, size: 32),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                iconBox(s.$1, C.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      t(s.$2, size: 14, w: FontWeight.w700),
                                      t(s.$3, size: 11, color: C.muted),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _announce() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          t('Campus Updates', size: 18, w: FontWeight.w700),
          const SizedBox(height: 12),
          if (_alerts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.tint1, borderRadius: BorderRadius.circular(16)),
              child: t('All caught up! 🎉', color: C.muted),
            ),
          for (var i = 0; i < _alerts.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Interactive3DCard(
                color: C.tint2,
                border: C.accent,
                onTap: () => _dialog(_alerts[i].$1, _alerts[i].$2, 'Got it'),
                child: Row(
                  children: [
                    iconBox(Icons.campaign, C.accent),
                    const SizedBox(width: 10),
                    Expanded(child: t(_alerts[i].$1, w: FontWeight.w600, size: 13)),
                    IconButton(
                      iconSize: 20,
                      tooltip: 'Dismiss',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        final a = _alerts[i];
                        final at = i;
                        setState(() => _alerts.removeAt(i));
                        _snack(
                          'Update dismissed',
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => setState(() => _alerts.insert(at > _alerts.length ? _alerts.length : at, a)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _tasksCard() {
    final n = _done.where((d) => d).length;
    final allDone = _done.isNotEmpty && n == _done.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.line),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              t("Today's Tasks", size: 17, w: FontWeight.w700),
              Row(
                children: [
                  pill('$n/${_done.length}', allDone ? Colors.green : C.primary),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    iconSize: 18,
                    tooltip: 'Add Task',
                    onPressed: _showAddTaskDialog,
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _done.isEmpty ? 0 : n / _done.length,
              minHeight: 7,
              backgroundColor: C.tint1,
              color: allDone ? Colors.green : C.accent,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < _tasks.length; i++)
            CheckboxListTile(
              value: _done[i],
              onChanged: (v) => setState(() => _done[i] = v!),
              activeColor: C.primary,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _tasks[i],
                style: TextStyle(
                  fontSize: 13,
                  decoration: _done[i] ? TextDecoration.lineThrough : null,
                  color: _done[i] ? C.muted : C.text,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shuttle() => Interactive3DCard(
        onTap: () => _snack('Shuttle Route B: Next departure 8:15 AM from Main Campus Gate'),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: Color(0xFF2FA36B), shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  t('Shuttle Route B · Live Tracker', w: FontWeight.w600, size: 14),
                  t('Next departure in 12 mins (Main Gate)', size: 11, color: C.muted),
                ],
              ),
            ),
            const Icon(Icons.directions_bus, color: C.primary, size: 22),
          ],
        ),
      );

  // ---------- TIMETABLE ----------
  Widget _timetable() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final d in _tt.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: _day == d,
                      selectedColor: C.primary,
                      labelStyle: TextStyle(
                        color: _day == d ? Colors.white : C.text,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _day = d),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final c in _tt[_day]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Interactive3DCard(
                onTap: () => _dialog(
                  '${c.$2} Details',
                  'Time: ${c.$1}\nVenue: ${c.$3}\nInstructor: ${c.$4}\nAttendance required: 85%',
                  'Set Class Reminder',
                ),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: C.tint1, borderRadius: BorderRadius.circular(12)),
                      child: t(c.$1, size: 13, w: FontWeight.w800, color: C.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t(c.$2, size: 15, w: FontWeight.w700),
                          t('${c.$3} · ${c.$4}', size: 12, color: C.muted),
                        ],
                      ),
                    ),
                    pill('Class', C.accent),
                  ],
                ),
              ),
            ),
        ],
      );

  // ---------- RESULTS & INTERACTIVE GPA SIMULATOR ----------
  Widget _results(bool isMobile) {
    final rows = _res[_sem]!;
    double totalWeighted = 0;
    for (final r in rows) {
      final score = _simulatedMarks[r.$1] ?? r.$3;
      totalWeighted += score;
    }
    final gpa = (totalWeighted / rows.length) / 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(builder: (ctx, c) {
          if (c.maxWidth < 450) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 3, label: Text('Sem 3')),
                    ButtonSegment(value: 4, label: Text('Sem 4')),
                  ],
                  selected: {_sem},
                  onSelectionChanged: (s) => setState(() => _sem = s.first),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: C.accent),
                  onPressed: () => _snack('Official Marksheet PDF downloaded'),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download PDF'),
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 3, label: Text('Semester 3')),
                  ButtonSegment(value: 4, label: Text('Semester 4')),
                ],
                selected: {_sem},
                onSelectionChanged: (s) => setState(() => _sem = s.first),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: C.accent),
                onPressed: () => _snack('Official Marksheet PDF downloaded'),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Transcript'),
              ),
            ],
          );
        }),
        const SizedBox(height: 18),

        // Live Simulated GPA Header
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [C.primary, C.primaryDark]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                child: t(gpa.toStringAsFixed(2), size: isMobile ? 30 : 36, w: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    t('Semester $_sem Simulated GPA', size: isMobile ? 16 : 19, w: FontWeight.w700, color: Colors.white),
                    t('Adjust sliders to project target CGPA', size: 11, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        t('Interactive Grade Simulator', size: 17, w: FontWeight.w700),
        const SizedBox(height: 10),

        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Interactive3DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: t(r.$1, size: 15, w: FontWeight.w700)),
                      pill(
                        '${(_simulatedMarks[r.$1] ?? r.$3).toInt()}% · ${r.$2}',
                        C.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Slider(
                    value: _simulatedMarks[r.$1] ?? r.$3,
                    min: 50,
                    max: 100,
                    divisions: 50,
                    activeColor: C.accent,
                    label: '${(_simulatedMarks[r.$1] ?? r.$3).round()}%',
                    onChanged: (val) => setState(() => _simulatedMarks[r.$1] = val),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ---------- EVENTS & REGISTRATION ----------
  Widget _events(bool isMobile) {
    final list = _ev.where((e) => _tag == 'All' || e.$5 == _tag).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final g in const ['All', 'Tech', 'Sports', 'Academic'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(g, style: TextStyle(fontSize: 12, color: _tag == g ? Colors.white : C.text)),
                        selected: _tag == g,
                        selectedColor: C.primary,
                        onSelected: (_) => setState(() => _tag = g),
                      ),
                    ),
                ],
              ),
            ),
            pill('${_reg.length} Registered', C.accent),
          ],
        ),
        const SizedBox(height: 16),
        for (final e in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Interactive3DCard(
              onTap: () => _showImageLightbox(e.$6, e.$1, '${e.$4}\n\n${e.$7}'),
              child: LayoutBuilder(builder: (ctx, constraints) {
                if (constraints.maxWidth < 450) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              e.$6,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: C.tint1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                t(e.$1, size: 15, w: FontWeight.w700),
                                t(e.$4, size: 12, color: C.muted),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      t(e.$7, size: 12, color: C.muted),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _eventRegisterBtn(e.$1),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        e.$6,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: C.tint1),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t(e.$1, size: 16, w: FontWeight.w700),
                          t(e.$4, size: 12, color: C.muted),
                          const SizedBox(height: 4),
                          t(e.$7, size: 12, color: C.muted),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _eventRegisterBtn(e.$1),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _eventRegisterBtn(String title) {
    final registered = _reg.contains(title);
    return FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size(100, 40),
        backgroundColor: registered ? Colors.green : C.primary,
      ),
      onPressed: () {
        setState(() => registered ? _reg.remove(title) : _reg.add(title));
        _snack(registered ? 'Cancelled registration for $title' : "Successfully registered for $title!");
      },
      child: Text(registered ? '✓ Joined' : 'Register'),
    );
  }

  // ---------- CAMPUS GALLERY SCREEN ----------
  Widget _gallery(bool isMobile) {
    final galleryItems = [
      ('SIST Main Campus Architecture', 'assets/images/campus_hero.jpg', 'Modern glass facade library and central green lawn.'),
      ('AI & Robotics Research Lab', 'assets/images/service_lab.jpg', 'High performance compute cluster and humanoid robot rigs.'),
      ('Digital Knowledge Library', 'assets/images/service_library.jpg', 'Cozy individual study pods and digital citation hubs.'),
      ('AI Hackathon Arena', 'assets/images/event_hackathon.jpg', '24-hour hackathon floor with 200+ student developers.'),
      ('University Athletic Stadium', 'assets/images/event_sports.jpg', 'Varsity football field under night floodlights.'),
      ('Tanuj - Student Profile', 'assets/images/student_avatar.jpg', 'Computer Science student lead at SIST Innovation Hub.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        t('Campus Photo Gallery', size: isMobile ? 20 : 22, w: FontWeight.w800),
        const SizedBox(height: 4),
        t('Tap any picture to open high-definition lightbox', color: C.muted, size: 13),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (ctx, c) {
            final n = c.maxWidth > 850 ? 3 : (c.maxWidth > 500 ? 2 : 1);
            final w = (c.maxWidth - 14 * (n - 1)) / n;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final g in galleryItems)
                  SizedBox(
                    width: w,
                    child: Interactive3DCard(
                      onTap: () => _showImageLightbox(g.$2, g.$1, g.$3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              g.$2,
                              height: isMobile ? 140 : 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 140,
                                color: C.tint2,
                                child: const Icon(Icons.image, size: 40, color: C.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          t(g.$1, size: 14, w: FontWeight.w700),
                          t(g.$3, size: 11, color: C.muted),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ---------- HELPDESK SCREEN ----------
  Widget _help() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: C.line),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                t('Submit Support Ticket', size: 18, w: FontWeight.w700),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _cat,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Issue Category'),
                  items: [
                    for (final c in const ['Academic', 'Facilities', 'IT', 'Finance'])
                      DropdownMenuItem(value: c, child: Text(c))
                  ],
                  onChanged: (v) => setState(() => _cat = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Detailed Description of Issue',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 44),
                      backgroundColor: C.primary,
                    ),
                    onPressed: _submitTicket,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Submit Ticket'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          t('Your Tickets', size: 18, w: FontWeight.w700),
          const SizedBox(height: 12),
          for (var i = 0; i < _tickets.length; i++) _ticketItem(i),
        ],
      );

  Widget _ticketItem(int i) {
    final k = _tickets[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Interactive3DCard(
        onTap: () => setState(() => _tickets[i] = (k.$1, k.$2, !k.$3)),
        child: Row(
          children: [
            iconBox(Icons.confirmation_number, k.$3 ? Colors.green : C.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  t(k.$1, w: FontWeight.w600, size: 14),
                  t('${k.$2} · Tap to toggle status', size: 11, color: C.muted),
                ],
              ),
            ),
            pill(k.$3 ? 'Resolved' : 'Open', k.$3 ? Colors.green : C.accent),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAVIGATION TILE COMPONENT
// -----------------------------------------------------------------------------

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      height: 44,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white24,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: selected ? C.primary : Colors.white, size: 20),
                const SizedBox(width: 10),
                t(label, w: FontWeight.w600, size: 13, color: selected ? C.primary : Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}