import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../model/booking_status_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';

/// A beautifully designed filter bottom sheet for booking status filtering.
/// Matches the design with chip-based status selection and Clear/Apply buttons.
class BookingStatusFilterBottomSheetNew extends StatefulWidget {
  final List<String> selectedStatuses;
  final Function(List<String>) onApply;

  const BookingStatusFilterBottomSheetNew({
    Key? key,
    required this.selectedStatuses,
    required this.onApply,
  }) : super(key: key);

  @override
  State<BookingStatusFilterBottomSheetNew> createState() =>
      _BookingStatusFilterBottomSheetNewState();
}

class _BookingStatusFilterBottomSheetNewState
    extends State<BookingStatusFilterBottomSheetNew> {
  Future<List<BookingStatusResponse>>? future;
  List<BookingStatusResponse> bookingStatusList = [];
  Set<String> selectedStatuses = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedStatuses = Set.from(widget.selectedStatuses);
    init();
  }

  void init() async {
    setState(() => isLoading = true);

    if (cachedBookingStatusDropdown.validate().isNotEmpty) {
      bookingStatusList = cachedBookingStatusDropdown.validate();
      _syncSelectionState();
      setState(() => isLoading = false);
    } else {
      try {
        bookingStatusList = await bookingStatus(list: []);
        if (bookingStatusList.isEmpty) {
          // Fallback to hardcoded statuses for dummy data mode
          bookingStatusList = _getDefaultStatusList();
        }
        _syncSelectionState();
        setState(() => isLoading = false);
      } catch (e) {
        // Use hardcoded statuses as fallback when API fails
        bookingStatusList = _getDefaultStatusList();
        _syncSelectionState();
        setState(() => isLoading = false);
      }
    }
  }

  /// Returns a hardcoded list of booking statuses for fallback/dummy mode
  List<BookingStatusResponse> _getDefaultStatusList() {
    return [
      BookingStatusResponse(id: 1, value: 'pending', label: 'Pending'),
      BookingStatusResponse(id: 2, value: 'accept', label: 'Accepted'),
      BookingStatusResponse(id: 3, value: 'on_going', label: 'On Going'),
      BookingStatusResponse(id: 4, value: 'in_progress', label: 'In Progress'),
      BookingStatusResponse(id: 5, value: 'hold', label: 'Hold'),
      BookingStatusResponse(id: 6, value: 'cancelled', label: 'Cancelled'),
      BookingStatusResponse(id: 7, value: 'rejected', label: 'Rejected'),
      BookingStatusResponse(id: 8, value: 'failed', label: 'Failed'),
      BookingStatusResponse(id: 9, value: 'completed', label: 'Completed'),
      BookingStatusResponse(
          id: 10, value: 'pending_approval', label: 'Pending Approval'),
      BookingStatusResponse(id: 11, value: 'waiting', label: 'Waiting'),
    ];
  }

  void _syncSelectionState() {
    for (var status in bookingStatusList) {
      status.isSelected = selectedStatuses.contains(status.value);
    }
  }

  void _toggleStatus(BookingStatusResponse status) {
    setState(() {
      if (selectedStatuses.contains(status.value)) {
        selectedStatuses.remove(status.value);
        status.isSelected = false;
      } else {
        selectedStatuses.add(status.value.validate());
        status.isSelected = true;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      selectedStatuses.clear();
      for (var status in bookingStatusList) {
        status.isSelected = false;
      }
    });
    widget.onApply([]);
    finish(context);
  }

  void _applyFilters() {
    widget.onApply(selectedStatuses.toList());
    finish(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          // Title and Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.lblFilterBy,
                  style: boldTextStyle(size: 18),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: context.iconColor,
                    size: 24,
                  ),
                  onPressed: () => finish(context),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: grey,
            height: 1,
            thickness: 1.5,
          ),

          // Booking Status Label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(
              language.bookingStatus,
              style: boldTextStyle(size: 18),
            ),
          ),

          // Status Chips
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: bookingStatusList.map((status) {
                  final isSelected = selectedStatuses.contains(status.value);
                  return _StatusChip(
                    label: status.value.validate().toBookingStatus(),
                    isSelected: isSelected,
                    onTap: () => _toggleStatus(status),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                // Clear Filter Button
                AppButton(
                  height: 15,
                  padding: EdgeInsets.all(8),
                  text: language.clearFilter,
                  textColor: context.primaryColor,
                  shapeBorder: RoundedRectangleBorder(
                    side: BorderSide(color: context.primaryColor),
                    borderRadius: radius(4),
                  ),
                  onTap: _clearFilters,
                ).expand(),
                12.width,
                // Apply Button
                AppButton(
                  height: 15,
                  padding: EdgeInsets.all(8),
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: radius(4),
                  ),
                  text: language.lblApply,
                  textColor: Colors.white,
                  color: context.primaryColor,
                  onTap: _applyFilters,
                ).expand(),
              ],
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Individual status chip widget with beautiful styling
class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFE8F3EC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Color(0xFFE8F3EC),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: boldTextStyle(
            size: 13,
          ),
        ),
      ),
    );
  }
}
