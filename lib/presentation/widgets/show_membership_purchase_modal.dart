import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/membership/membership_provider.dart';
import '../widgets/membership_purchase_modal.dart';
import '../../data/models/membership_model.dart';

Future<void> showMembershipPurchaseModal(
  BuildContext context,
  WidgetRef ref, {
  required String studentId,
  required Color campusColor,
}) async {
  try {
    final membershipOptions = await ref
        .read(membershipProvider.notifier)
        .getAvailableMemberships();

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MembershipPurchaseModal(
          studentId: studentId,
          campusColor: campusColor,
          membershipOptions: membershipOptions,
          onPurchase:
              (
                MembershipPurchaseOption option,
                String paymentMethod,
                String? phoneNumber,
              ) async {
                try {
                  await ref
                      .read(membershipProvider.notifier)
                      .purchaseMembership(
                        membershipId: option.membershipId,
                        membershipName: option.displayName,
                        amount: option.priceNok,
                        paymentMethod: paymentMethod,
                        phoneNumber: phoneNumber,
                      );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Membership purchase initiated! Complete payment to activate.',
                        ),
                        backgroundColor: AppColors.green9,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Purchase failed: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load membership options: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
