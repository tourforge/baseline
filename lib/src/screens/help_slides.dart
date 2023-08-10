import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class HelpSlide extends StatelessWidget {
  const HelpSlide({
    super.key,
    this.onSlideEnter,
    this.onSlideLeave,
    this.image,
    required this.children,
  });

  final void Function()? onSlideEnter;
  final void Function()? onSlideLeave;
  final Widget? image;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 12.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (image != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    child: Material(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(24.0)),
                      type: MaterialType.card,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        child: image,
                      ),
                    ),
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSlidesController {
  late final _HelpSlidesScreenState _state;

  /// Progresses to the next slide if one exists.
  void nextSlide() {
    _state._controller.nextPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void finish() {
    if (_state.widget.onDone != null) {
      _state.widget.onDone!();
    }
    if (_state.widget.slides[_state._currentPage].onSlideLeave != null) {
      _state.widget.slides[_state._currentPage].onSlideLeave!();
    }
  }
}

class HelpSlidesScreen extends StatefulWidget {
  const HelpSlidesScreen({
    super.key,
    this.controller,
    this.onDone,
    this.title = "Help",
    this.dismissible = false,
    required this.slides,
  });

  final String title;
  final bool dismissible;
  final List<HelpSlide> slides;
  final void Function()? onDone;
  final HelpSlidesController? controller;

  @override
  State<StatefulWidget> createState() => _HelpSlidesScreenState();
}

class _HelpSlidesScreenState extends State<HelpSlidesScreen> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();

    widget.controller?._state = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.dismissible
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
              title: Text(widget.title),
            )
          : null,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          onPageChanged: _onPageChanged,
          children: widget.slides,
        ),
      ),
    );
  }

  void _onPageChanged(int newPage) {
    if (newPage != _currentPage) {
      if (widget.slides[_currentPage].onSlideLeave != null) {
        widget.slides[_currentPage].onSlideLeave!();
      }

      _currentPage = newPage;

      if (widget.slides[_currentPage].onSlideEnter != null) {
        widget.slides[_currentPage].onSlideEnter!();
      }
    }
  }
}
