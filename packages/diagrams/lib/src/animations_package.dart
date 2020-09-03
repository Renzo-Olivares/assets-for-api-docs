import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const String _openContainerTransform = 'open_container_transform';
const double _kAnimationFrameRate = 60.0;
const Map<String, List<int>> pressSteps = <String, List<int>>{
  _openContainerTransform: <int>[0],
};

final List<GlobalKey> _containerKeys = <GlobalKey>[
  GlobalKey(),
  GlobalKey(),
];

class AnimationsPackageDiagram extends StatefulWidget
    implements DiagramMetadata {
  const AnimationsPackageDiagram(this.name, {Key key}) : super(key: key);

  @override
  final String name;

  @override
  _AnimationsPackageDiagramState createState() =>
      _AnimationsPackageDiagramState();
}

class _AnimationsPackageDiagramState extends State<AnimationsPackageDiagram> {
  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (widget.name) {
      case _openContainerTransform:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Open Container Transform Demo'),
          ),
          body: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute<void>(builder: (BuildContext context) {
                return Scaffold(
                  body: OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder:
                        (BuildContext context, VoidCallback openBuilder) {
                      return Container(
                        height: 200,
                        width: 400,
                        color: Colors.green,
                        child: Center(
                          key: _containerKeys[1],
                          child: const Text('Open Container'),
                        ),
                      );
                    },
                    closedBuilder:
                        (BuildContext context, VoidCallback openBuilder) {
                      return InkWell(
                        key: _containerKeys[0],
                        onTap: openBuilder,
                        child: Container(
                          key: UniqueKey(),
                          height: 200,
                          width: 400,
                          child: const Center(
                            child: Text('Closed Container'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              });
            },
          ),
        );
        break;
      default:
        returnWidget = const Text('Error');
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(480, 720)),
      child: returnWidget,
    );
  }
}

class AnimationsPackageDiagramStep
    extends DiagramStep<AnimationsPackageDiagram> {
  AnimationsPackageDiagramStep(DiagramController controller)
      : super(controller);

  String _testName;
  int _stepCount = 0;

  @override
  final String category = 'animations-package';

  @override
  Future<List<AnimationsPackageDiagram>> get diagrams async =>
      <AnimationsPackageDiagram>[
        AnimationsPackageDiagram(
          _openContainerTransform,
          key: UniqueKey(),
        ),
      ];

  Future<void> tapIcons(DiagramController controller, Duration now) async {
    RenderBox target;
    if (now.inMilliseconds % 2000 == 0) {
      final int targetIcon = pressSteps[_testName][_stepCount];
      _stepCount += 1;
      target = _containerKeys[targetIcon].currentContext.findRenderObject()
          as RenderBox;
      final Offset targetOffset =
          target.localToGlobal(target.size.center(Offset.zero));
      final TestGesture gesture = await controller.startGesture(targetOffset);
      Future<void>.delayed(const Duration(seconds: 3), gesture.up);
    }
  }

  @override
  Future<File> generateDiagram(AnimationsPackageDiagram diagram) async {
    _stepCount = 0;
    controller.builder = (BuildContext context) => diagram;
    _testName = diagram.name;
    return await controller.drawAnimatedDiagramToFiles(
//        end: Duration(seconds: pressSteps[_testName].length * 2),
        end: const Duration(seconds: 5),
        frameRate: _kAnimationFrameRate,
        name: _testName,
        category: category,
        gestureCallback: tapIcons);
  }
}
