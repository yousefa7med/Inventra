import 'package:Inventra/core/constants/app_strings.dart';
import 'package:Inventra/core/navigations/navigations.dart';
import 'package:Inventra/core/utilities/app_colors.dart';
import 'package:Inventra/core/utilities/app_text_style.dart';
import 'package:Inventra/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen barcode scanner.
///
/// Pops a [String] barcode on successful scan, or `null` when the user
/// cancels. Open it via:
/// ```dart
/// final code = await AppNavigation.pushName<String>(
///   context: context,
///   route: AppRoutes.barcodeScannerView,
/// );
/// ```
class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  late final MobileScannerController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue?.trim();
    if (code == null || code.isEmpty) return;
    _handled = true;
    AppNavigation.pop<String>(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.scanBarcode,
        actions: [
          IconButton(
            tooltip: AppStrings.cancel,
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () => AppNavigation.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            placeholderBuilder: (context) => const ScannerLoadingBody(),
            errorBuilder: (context, error) {
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                return const ScannerPermissionDeniedBody();
              }
              return const ScannerErrorBody();
            },
          ),
          const ScannerHintLabel(),
          ScannerControlsBar(controller: _controller),
        ],
      ),
    );
  }
}

class ScannerHintLabel extends StatelessWidget {
  const ScannerHintLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24.h,
      left: 0,
      right: 0,
      child: Text(
        AppStrings.pointCameraAtBarcode,
        textAlign: TextAlign.center,
        style: AppTextStyle.medium16.copyWith(color: AppColors.white),
      ),
    );
  }
}

class ScannerControlsBar extends StatelessWidget {
  const ScannerControlsBar({super.key, required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScannerTorchButton(controller: controller),
          Gap(24.w),
          ScannerCameraSwitchButton(controller: controller),
        ],
      ),
    );
  }
}

class ScannerTorchButton extends StatelessWidget {
  const ScannerTorchButton({super.key, required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        if (state.torchState == TorchState.unavailable) {
          return const SizedBox.shrink();
        }
        final isOn = state.torchState == TorchState.on;
        return IconButton.filled(
          tooltip: isOn ? AppStrings.flashOff : AppStrings.flashOn,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
          ),
          icon: Icon(isOn ? Icons.flash_off : Icons.flash_on),
          onPressed: controller.toggleTorch,
        );
      },
    );
  }
}

class ScannerCameraSwitchButton extends StatelessWidget {
  const ScannerCameraSwitchButton({super.key, required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        if ((state.availableCameras ?? 1) <= 1) {
          return const SizedBox.shrink();
        }
        return IconButton.filled(
          tooltip: AppStrings.switchCamera,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.cameraswitch),
          onPressed: controller.switchCamera,
        );
      },
    );
  }
}

class ScannerLoadingBody extends StatelessWidget {
  const ScannerLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.black87,
      child: Center(child: CircularProgressIndicator(color: AppColors.white)),
    );
  }
}

class ScannerPermissionDeniedBody extends StatelessWidget {
  const ScannerPermissionDeniedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.black87,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: AppColors.white,
                size: 48,
              ),
              Gap(16.h),
              Text(
                AppStrings.cameraPermissionDenied,
                textAlign: TextAlign.center,
                style: AppTextStyle.medium16.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerErrorBody extends StatelessWidget {
  const ScannerErrorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.black87,
      child: Center(
        child: Text(
          AppStrings.scannerInitError,
          textAlign: TextAlign.center,
          style: AppTextStyle.medium16.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
