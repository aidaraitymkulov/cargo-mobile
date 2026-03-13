import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cargo_mobile/core/theme/app_theme.dart';
import 'package:cargo_mobile/models/branch/branch.dart';

/// Дропдаун выбора филиала.
/// Открывается прямо под полем через Overlay — перекрывает контент снизу, не двигает лейаут.
class BranchDropdownField extends StatefulWidget {
  const BranchDropdownField({
    super.key,
    required this.branchesAsync,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onRetry,
  });

  final AsyncValue<List<Branch>> branchesAsync;
  final Branch? value;
  final void Function(Branch?) onChanged;
  final bool enabled;
  final VoidCallback? onRetry;

  @override
  State<BranchDropdownField> createState() => _BranchDropdownFieldState();
}

class _BranchDropdownFieldState extends State<BranchDropdownField> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final branches = widget.branchesAsync.value;
    if (branches == null) return;

    final activeBranches = branches.where((b) => b.isActive).toList();
    if (activeBranches.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // Прозрачная подложка — закрывает дропдаун при тапе мимо
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: activeBranches.length,
                    itemBuilder: (ctx, index) {
                      final branch = activeBranches[index];
                      final isSelected = widget.value?.id == branch.id;
                      return ListTile(
                        title: Text(
                          branch.address,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppTheme.primary)
                            : null,
                        onTap: () {
                          widget.onChanged(branch);
                          _closeDropdown();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  Widget _buildSuffixIcon() {
    if (widget.branchesAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }
    if (widget.branchesAsync.hasError) {
      return IconButton(
        icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
        onPressed: widget.onRetry,
      );
    }
    return AnimatedRotation(
      turns: _isOpen ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.branchesAsync.hasError;

    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<Branch>(
        validator: (_) => widget.value == null ? 'Выберите филиал' : null,
        builder: (state) {
          return GestureDetector(
            onTap: _toggleDropdown,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Филиал',
                errorText: hasError
                    ? 'Не удалось загрузить филиалы'
                    : state.errorText,
                suffixIcon: _buildSuffixIcon(),
              ),
              isEmpty: widget.value == null,
              isFocused: _isOpen,
              child: Text(
                widget.value?.address ??
                    (widget.branchesAsync.isLoading ? 'Загрузка...' : ''),
                style: TextStyle(
                  color: widget.value != null
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
