import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:theuniversedecides/theme/app_colors.dart';

class SnackBarCustom {
  static OverlayEntry? _overlayEntry;
  static GlobalKey<_AcrylicSnackBarState>? _overlayKey;
  static String? _currentMessage;

  static void buildErrorMessage(String message, {BuildContext? context}) {
    final ctx = context;
    if (ctx == null) {
      return;
    }

    if (_currentMessage == message && _overlayEntry != null) {
      return;
    }

    hideCurrentSnackBar();

    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _currentMessage = message;
    _overlayKey = GlobalKey<_AcrylicSnackBarState>();
    _overlayEntry = OverlayEntry(
      builder: (context) => _AcrylicSnackBar(
        key: _overlayKey,
        message: message,
        onClosed: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          _overlayKey = null;
          _currentMessage = null;
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void hideCurrentSnackBar() {
    _overlayKey?.currentState?.disposeTimer();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayKey = null;
    _currentMessage = null;
  }
}

class _AcrylicSnackBar extends StatefulWidget {
  const _AcrylicSnackBar({
    super.key,
    required this.message,
    required this.onClosed,
  });

  final String message;
  final VoidCallback onClosed;

  @override
  State<_AcrylicSnackBar> createState() => _AcrylicSnackBarState();
}

class _AcrylicSnackBarState extends State<_AcrylicSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _offset = Tween(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _timer = Timer(const Duration(seconds: 4), _close);
  }

  void disposeTimer() {
    _timer?.cancel();
  }

  Future<void> _close() async {
    if (!mounted) {
      return;
    }

    _timer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onClosed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top + 12;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 0),
          child: SlideTransition(
            position: _offset,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 640),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.acrylicSurface,
                          AppColors.acrylicSurfaceStrong,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.acrylicBorder,
                        width: 1.1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.acrylicAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.cloud_off_rounded,
                              color: AppColors.whiteStrong,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.whiteStrong,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _close,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.whiteStrong,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
