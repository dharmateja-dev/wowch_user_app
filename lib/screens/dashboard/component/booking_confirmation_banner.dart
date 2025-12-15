import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:booking_system_flutter/utils/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

/// A banner component that shows when user has a confirmed booking.
/// Displays above categories in the home screen.
class BookingConfirmationBanner extends StatelessWidget {
  final String serviceName;
  final DateTime bookingDateTime;
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  const BookingConfirmationBanner({
    Key? key,
    required this.serviceName,
    required this.bookingDateTime,
    this.onClose,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.primaryContainer, // Light green background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with confirmation text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: context.onPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    8.width,
                    Text(
                      language.lblYourBookingIsConfirmed,
                      style: context.boldTextStyle(
                        size: 13,
                        color: DarkThemeColors
                            .onPrimaryContainer, // #121212 always
                      ),
                    ),
                  ],
                ),
                // Close button
                GestureDetector(
                  onTap: () {
                    _showRemoveConfirmationDialog(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: context.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: context.onSurface,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            12.height,
            // Service info row
            Row(
              children: [
                // Email/Booking icon
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: context.onSurface,
                    size: 20,
                  ),
                ),
                8.width,
                // Service name and date/time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: context.boldTextStyle(
                          size: 15,
                          color: DarkThemeColors
                              .onPrimaryContainer, // #121212 always,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Text(
                        DateFormat('MMMM d, yyyy hh:mm a')
                            .format(bookingDateTime),
                        style: context.primaryTextStyle(
                          weight: FontWeight.bold,
                          color: DarkThemeColors.onPrimaryContainer,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows custom confirmation dialog when user clicks close button
  void _showRemoveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return RemoveConfirmationDialog(
          onConfirm: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

/// Custom confirmation dialog matching the design in the image
class RemoveConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const RemoveConfirmationDialog({
    Key? key,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: context.dialogBackgroundColor,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              language.lblRemoveItem,
              style: context.boldTextStyle(
                size: 22,
                color: context.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            8.height,
            // Subtitle
            Text(
              language.lblRemoveItemConfirmation,
              style: context.primaryTextStyle(
                size: 15,
                color: context.subtitleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            24.height,
            // Sure button
            AppButton(
              text: language.lblSure,
              color: context.primary,
              textColor: context.onPrimary,
              width: double.infinity,
              height: 20,
              padding: EdgeInsets.symmetric(vertical: 11),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              onTap: onConfirm,
            ),
            16.height,
            // No, thanks
            GestureDetector(
              onTap: onCancel,
              child: Text(
                language.lblNoThanks,
                style:
                    context.boldTextStyle(size: 14, color: context.cancelText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
