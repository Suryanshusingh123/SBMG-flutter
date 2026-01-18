import 'package:flutter/material.dart';

class BottomSheetPicker<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemBuilder;
  final T? selectedItem;
  final Function(T) onSelected;
  final bool isLoading;
  final String? searchHint;
  final bool showSearch;
  final String? resetButtonText;
  final VoidCallback? onReset;

  const BottomSheetPicker({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.selectedItem,
    required this.onSelected,
    this.isLoading = false,
    this.searchHint,
    this.showSearch = true,
    this.resetButtonText,
    this.onReset,
  });

  @override
  State<BottomSheetPicker<T>> createState() => _BottomSheetPickerState<T>();

  static void show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemBuilder,
    required T? selectedItem,
    required Function(T) onSelected,
    bool isLoading = false,
    String? searchHint,
    bool showSearch = false,
    String? resetButtonText,
    VoidCallback? onReset,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetPicker<T>(
        title: title,
        items: items,
        itemBuilder: itemBuilder,
        selectedItem: selectedItem,
        onSelected: onSelected,
        isLoading: isLoading,
        searchHint: searchHint,
        showSearch: showSearch,
        resetButtonText: resetButtonText,
        onReset: onReset,
      ),
    );
  }
}

class _BottomSheetPickerState<T> extends State<BottomSheetPicker<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void didUpdateWidget(BottomSheetPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered items when items change
    if (widget.items != oldWidget.items) {
      _filterItems();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final itemText = widget.itemBuilder(item).toLowerCase();
        return itemText.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: screenHeight * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title and close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (widget.resetButtonText != null && widget.onReset != null)
                    TextButton(
                      onPressed: () {
                        widget.onReset!();
                        Navigator.pop(context);
                      },
                      child: Text(
                        widget.resetButtonText!,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),

            // Search bar
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: widget.searchHint ?? 'Search...',
                    hintStyle: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF009B56)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

            // Content
            Expanded(
              child: widget.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF009B56),
                      ),
                    )
                  : _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_filteredItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No items available',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: _filteredItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = widget.selectedItem == item;

        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 0,
              ),
              title: Text(
                widget.itemBuilder(item),
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Color(0xFF009B56),
                      size: 24,
                    )
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
              onTap: () {
                final selectedItem = item;
                final selectedCallback = widget.onSelected;
                Navigator.pop(context);
                // Delay to ensure bottom sheet has closed
                Future.delayed(const Duration(milliseconds: 100), () {
                  selectedCallback(selectedItem);
                });
              },
            ),
            // Add divider after each item except the last one
            if (index < _filteredItems.length - 1)
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
        );
      }).toList(),
    );
  }
}
