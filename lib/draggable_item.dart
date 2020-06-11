import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DraggableItem extends StatefulWidget {
  final Widget child;
  final double draggingWidth;
  final double ghostOpacity;
  final int sizeAnimationDuration;
  final bool dragOnLongPress;
  final int id;
  final CrossAxisAlignment verticalAlignment;
  final Function(DraggableItem reordered, DraggableItem receiver, bool placedBeforeReceiver) onReorder;

  DraggableItem(
      {this.child,
      this.draggingWidth,
      this.ghostOpacity = 0.3,
      this.sizeAnimationDuration = 300,
      this.dragOnLongPress,
      this.onReorder,
      this.verticalAlignment,
      this.id,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DraggableItem();
}

class _DraggableItem extends State<DraggableItem> with TickerProviderStateMixin {
  DraggableItem _hoveredDraggableAbove;
  DraggableItem _hoveredDraggableBelow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.verticalAlignment,
          children: <Widget>[
            AnimatedSize(
              duration: (_hoveredDraggableAbove == null && _hoveredDraggableBelow == null)
                  ? Duration(milliseconds: 1)
                  : Duration(milliseconds: widget.sizeAnimationDuration),
              vsync: this,
              alignment: Alignment.bottomCenter,
              child: _hoveredDraggableAbove != null
                  ? Opacity(
                      opacity: widget.ghostOpacity,
                      child: _hoveredDraggableAbove.child,
                    )
                  : Container(),
            ),
            widget.dragOnLongPress
                ? LongPressDraggable<DraggableItem>(
                    data: widget,
                    axis: Axis.vertical,
                    child: widget.child,
                    feedback: Container(
                      width: widget.draggingWidth ?? MediaQuery.of(context).size.width,
                      child: Material(
                        child: widget.child,
                        color: Colors.transparent,
                      ),
                    ),
                    childWhenDragging: Container(),
                  )
                : Draggable<DraggableItem>(
                    data: widget,
                    axis: Axis.vertical,
                    child: widget.child,
                    feedback: Container(
                      width: widget.draggingWidth ?? MediaQuery.of(context).size.width,
                      child: Material(
                        child: widget.child,
                        color: Colors.transparent,
                      ),
                    ),
                    childWhenDragging: Container(),
                  ),
            AnimatedSize(
              duration: (_hoveredDraggableAbove == null && _hoveredDraggableBelow == null)
                  ? Duration(milliseconds: 1)
                  : Duration(milliseconds: widget.sizeAnimationDuration),
              vsync: this,
              alignment: Alignment.topCenter,
              child: _hoveredDraggableBelow != null
                  ? Opacity(
                      opacity: widget.ghostOpacity,
                      child: _hoveredDraggableBelow.child,
                    )
                  : Container(),
            ),
          ],
        ),
        Positioned.fill(
          child: Column(
            children: <Widget>[
              Expanded(
                child: DragTarget<DraggableItem>(
                  builder: (context, candidateData, rejectedData) {
                    if (candidateData != null && candidateData.isNotEmpty) {}
                    return Container();
                  },
                  onWillAccept: (incoming) {
                    if (incoming != widget) {
                      setState(() {
                        _hoveredDraggableAbove = incoming;
                      });
                      return true;
                    }
                    return false;
                  },
                  onLeave: (incoming) {
                    setState(() {
                      _hoveredDraggableAbove = null;
                    });
                  },
                  onAccept: (incoming) {
                    setState(() {
                      if (widget.onReorder != null) widget.onReorder(incoming, widget, true);
                      _hoveredDraggableAbove = null;
                    });
                  },
                ),
              ),
              Expanded(
                child: DragTarget<DraggableItem>(
                  builder: (context, candidateData, rejectedData) {
                    if (candidateData != null && candidateData.isNotEmpty) {}
                    return Container();
                  },
                  onWillAccept: (incoming) {
                    if (incoming != widget) {
                      setState(() {
                        _hoveredDraggableBelow = incoming;
                      });
                      return true;
                    }
                    return false;
                  },
                  onLeave: (incoming) {
                    setState(() {
                      _hoveredDraggableBelow = null;
                    });
                  },
                  onAccept: (incoming) {
                    if (widget.onReorder != null) widget.onReorder(incoming, widget, false);
                    setState(() {
                      _hoveredDraggableBelow = null;
                    });
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
