import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../profile/user_profile.dart';
import '../../tracking/request_history.dart';
import '../../tracking/rescue_job.dart';
import '../../tracking/widgets/rescue_cards.dart';
import '../../tracking/widgets/rescue_scaffold.dart';
import '../invoice_data.dart';
import 'invoice_pdf.dart';

/// Preview of the invoice PDF with Share, Save and Print.
class InvoicePdfScreen extends ConsumerStatefulWidget {
  const InvoicePdfScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<InvoicePdfScreen> createState() => _InvoicePdfScreenState();
}

class _InvoicePdfScreenState extends ConsumerState<InvoicePdfScreen> {
  Future<Uint8List>? _pdf;
  InvoiceData? _data;

  @override
  void initState() {
    super.initState();
    final customer = ref.read(userProfileProvider).name;
    final job = ref.read(rescueJobProvider);
    final past = ref
        .read(requestHistoryProvider.notifier)
        .byId(widget.requestId);
    _data = job != null && job.requestId == widget.requestId
        ? InvoiceData.fromJob(job, customerName: customer)
        : past != null && past.isCompleted
        ? InvoiceData.fromPast(past, customerName: customer)
        : null;
    if (_data != null) _pdf = buildInvoicePdf(_data!);
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _share() async {
    try {
      await Printing.sharePdf(bytes: await _pdf!, filename: _data!.fileName);
    } catch (_) {
      if (mounted) _snack('Couldn’t open sharing on this device.');
    }
  }

  /// Saves into the app's documents folder (the browser downloads on web).
  Future<void> _save() async {
    try {
      final bytes = await _pdf!;
      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: _data!.fileName);
        return;
      }
      final dir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/invoices',
      );
      await dir.create(recursive: true);
      final file = File('${dir.path}/${_data!.fileName}');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) _snack('Saved to ${file.path}');
    } catch (_) {
      if (mounted) _snack('Couldn’t save the invoice. Please try again.');
    }
  }

  Future<void> _print() async {
    try {
      await Printing.layoutPdf(name: _data!.fileName, onLayout: (_) => _pdf!);
    } catch (_) {
      if (mounted) _snack('Printing isn’t available on this device.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const RescueScaffold(
        body: EmptyState(
          icon: AppIcons.invoice,
          title: 'No invoice for this request',
          message: 'Invoices are created once a service is completed.',
        ),
      );
    }

    return RescueScaffold(
      bottom: Row(
        children: [
          Expanded(
            child: OutlineActionButton(
              label: 'Share',
              icon: AppIcons.share,
              onPressed: _share,
            ),
          ),
          Gap.h12,
          Expanded(
            child: OutlineActionButton(
              label: 'Save',
              icon: AppIcons.download,
              onPressed: _save,
            ),
          ),
          Gap.h12,
          Expanded(
            child: OutlineActionButton(
              label: 'Print',
              icon: Icons.print_outlined,
              onPressed: _print,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Invoice',
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          Gap.v8,
          Text('#${_data!.requestId}', style: AppTypography.caption),
          Gap.v12,
          if (_data!.isDemo)
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.warningFill,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning),
                  Gap.h12,
                  Expanded(
                    child: Text(
                      'Demo invoice from sample data. Not a tax invoice; no '
                      'payment was processed.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Gap.v16,
          ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: SizedBox(
              height: 520,
              child: PdfPreview(
                build: (_) => _pdf!,
                useActions: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                pdfFileName: _data!.fileName,
                loadingWidget: const Center(child: CircularProgressIndicator()),
                onError: (context, error) => const EmptyState(
                  icon: AppIcons.invoice,
                  title: 'Couldn’t show the preview',
                  message: 'You can still share or save the PDF.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
