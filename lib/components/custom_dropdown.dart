import 'package:flutter/material.dart';

typedef DropdownItemBuilder<T> = Widget Function(
    BuildContext context, T item, bool selected);

enum DropdownDirection { automatic, down, up }

class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.buttonHeight = 48.0,
    this.buttonWidth,
    this.minButtonWidth = 80.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.itemHeight = 48.0,
    this.dropdownMaxHeight = 320.0,
    this.constrainToButtonWidth = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.elevation = 6.0,
    this.boxShadow,
    this.backgroundColor,
    this.menuBackgroundColor,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeOutCubic,
    this.dropdownOffset = const Offset(0, 10),
    this.direction = DropdownDirection.automatic,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.leading,
    this.trailing,
    this.showCaret = true,
    this.caretIcon,
    this.textStyle,
    this.hintStyle,
    this.itemTextAlignment = Alignment.centerLeft,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 6.0),
  }) : super(key: key);

  final List<T> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final Widget? hint;

  final double buttonHeight;
  final double? buttonWidth;
  final double minButtonWidth;
  final EdgeInsets padding;

  final double itemHeight;
  final double dropdownMaxHeight;
  final bool constrainToButtonWidth;
  final BorderRadius borderRadius;
  final double elevation;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final Color? menuBackgroundColor;
  final EdgeInsets menuPadding;

  final Duration animationDuration;
  final Curve animationCurve;
  final Offset dropdownOffset;
  final DropdownDirection direction;

  final DropdownItemBuilder<T>? itemBuilder;
  final DropdownItemBuilder<T>? selectedItemBuilder;

  final Widget? leading;
  final Widget? trailing;
  final bool showCaret;
  final Widget? caretIcon;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Alignment itemTextAlignment;

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _opacityAnim = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(_opacityAnim);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _toggleDropdown() => _isOpen ? _close() : _open();

  void _open() {
    _createOverlay();
    _controller.forward();
    setState(() => _isOpen = true);
  }

  void _close() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() => _isOpen = false);
      }
    });
  }

  RenderBox? get _buttonRenderBox =>
      _buttonKey.currentContext?.findRenderObject() as RenderBox?;

  Size _buttonSize() =>
      _buttonRenderBox?.size ??
      Size(widget.minButtonWidth, widget.buttonHeight);

  Offset _buttonPosition() =>
      _buttonRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

  void _createOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay<T>(parentState: this),
    );
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  Widget _buildButtonChild() {
    if (widget.selectedItemBuilder != null && widget.value != null) {
      return widget.selectedItemBuilder!(context, widget.value as T, true);
    }

    final textStyle = widget.textStyle ?? Theme.of(context).textTheme.bodyLarge;
    final hintStyle = widget.hintStyle ??
        Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]);

    final label = widget.value != null
        ? Text(widget.value.toString(), style: textStyle)
        : (widget.hint ?? Text('', style: hintStyle));

    return Row(
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 8),
        ],
        Expanded(child: label),
        if (widget.trailing != null) ...[
          const SizedBox(width: 8),
          widget.trailing!,
        ],
        if (widget.showCaret) ...[
          const SizedBox(width: 8),
          widget.caretIcon ??
              Transform.rotate(
                angle: _isOpen ? 3.1415 : 0,
                child: const Icon(Icons.arrow_drop_down),
              ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: _toggleDropdown,
      child: Container(
        constraints: BoxConstraints(
          minWidth: widget.minButtonWidth,
          maxWidth: widget.buttonWidth ?? double.infinity,
        ),
        height: widget.buttonHeight,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: _buildButtonChild(),
      ),
    );
  }
}

class _DropdownOverlay<T> extends StatelessWidget {
  final _CustomDropdownState<T> parentState;

  const _DropdownOverlay({required this.parentState});

  @override
  Widget build(BuildContext context) {
    final parent = parentState;

    final buttonPos = parent._buttonPosition();
    final buttonSize = parent._buttonSize();

    final screen = MediaQuery.of(context).size;
    final availableDown = screen.height - (buttonPos.dy + buttonSize.height);

    final openDown = parent.widget.direction == DropdownDirection.down ||
        (parent.widget.direction == DropdownDirection.automatic &&
            availableDown > parent.widget.itemHeight * 3);

    final menuWidth = parent.widget.constrainToButtonWidth
        ? buttonSize.width
        : screen.width - 32;

    final menuHeight = (parent.widget.items.length * parent.widget.itemHeight) +
        parent.widget.menuPadding.vertical;

    final finalMenuHeight =
        menuHeight.clamp(60.0, parent.widget.dropdownMaxHeight).toDouble();

    final left = buttonPos.dx;
    final top = openDown
        ? buttonPos.dy + buttonSize.height + parent.widget.dropdownOffset.dy
        : buttonPos.dy - finalMenuHeight - parent.widget.dropdownOffset.dy;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => parent._close(),
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: FadeTransition(
                opacity: parent._opacityAnim,
                child: ScaleTransition(
                  scale: parent._scaleAnim,
                  alignment:
                      openDown ? Alignment.topCenter : Alignment.bottomCenter,
                  child: Material(
                    type: MaterialType.card,
                    elevation: parent.widget.elevation,
                    borderRadius: parent.widget.borderRadius,
                    child: _menu(finalMenuHeight, parent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu(double height, _CustomDropdownState<T> parent) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: ClipRRect(
        borderRadius: parent.widget.borderRadius,
        child: Container(
          color: parent.widget.menuBackgroundColor ?? Colors.white,
          padding: parent.widget.menuPadding,
          child: ListView.builder(
            itemCount: parent.widget.items.length,
            itemBuilder: (ctx, i) {
              final item = parent.widget.items[i];
              final selected = parent.widget.value == item;

              final custom =
                  parent.widget.itemBuilder?.call(ctx, item, selected) ??
                      _defaultItem(item, selected);

              return InkWell(
                onTap: () {
                  parent.widget.onChanged(item); // Update selected
                  parent._close(); // Auto-close dropdown
                },
                child: Container(
                  height: parent.widget.itemHeight,
                  alignment: parent.widget.itemTextAlignment,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: custom,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _defaultItem(T item, bool selected) {
    return Row(
      children: [
        Expanded(child: Text(item.toString())),
        if (selected) const Icon(Icons.check, size: 18),
      ],
    );
  }
}
