import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stackwallet/notifications/show_flush_bar.dart';
import 'package:stackwallet/utilities/assets.dart';
import 'package:stackwallet/utilities/clipboard_interface.dart';
import 'package:stackwallet/utilities/constants.dart';
import 'package:stackwallet/utilities/enums/coin_enum.dart';
import 'package:stackwallet/utilities/enums/flush_bar_type.dart';
import 'package:stackwallet/utilities/logger.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/utilities/theme/stack_colors.dart';
import 'package:stackwallet/utilities/util.dart';
import 'package:stackwallet/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackwallet/widgets/icon_widgets/x_icon.dart';
import 'package:stackwallet/widgets/rounded_white_container.dart';
import 'package:stackwallet/widgets/stack_dialog.dart';
import 'package:stackwallet/widgets/stack_text_field.dart';
import 'package:stackwallet/widgets/textfield_icon_button.dart';

class GenerateUriQrCodeView extends StatefulWidget {
  const GenerateUriQrCodeView({
    Key? key,
    required this.coin,
    required this.receivingAddress,
    this.clipboard = const ClipboardWrapper(),
  }) : super(key: key);

  static const String routeName = "/generateUriQrCodeView";

  final Coin coin;
  final String receivingAddress;
  final ClipboardInterface clipboard;

  @override
  State<GenerateUriQrCodeView> createState() => _GenerateUriQrCodeViewState();
}

class _GenerateUriQrCodeViewState extends State<GenerateUriQrCodeView> {
  final _qrKey = GlobalKey();

  late TextEditingController amountController;
  late TextEditingController noteController;

  final _amountFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();

  Future<void> _capturePng(bool shouldSaveInsteadOfShare) async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // if (shouldSaveInsteadOfShare) {
      //   await DocumentFileSavePlus.saveFile(
      //       pngBytes,
      //       "receive_qr_code_${DateTime.now().toLocal().toIso8601String()}.png",
      //       "image/png");
      // } else {
      final tempDir = await getTemporaryDirectory();
      final file = await File("${tempDir.path}/qrcode.png").create();
      await file.writeAsBytes(pngBytes);

      await Share.shareFiles(["${tempDir.path}/qrcode.png"],
          text: "Receive URI QR Code");
      // }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    amountController = TextEditingController();
    noteController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();

    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");
    return Scaffold(
      backgroundColor: Theme.of(context).extension<StackColors>()!.background,
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () async {
            if (FocusScope.of(context).hasFocus) {
              FocusScope.of(context).unfocus();
              await Future<void>.delayed(const Duration(milliseconds: 70));
            }
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          "Generate QR code",
          style: STextStyles.navBarTitle(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (buildContext, constraints) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 12,
              right: 12,
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RoundedWhiteContainer(
                          child: Text(
                            "The new QR code with your address, amount and note will appear in the pop up window.",
                            style: STextStyles.itemSubtitle(context),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Amount (Optional)",
                          style: STextStyles.smallMed12(context),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Constants.size.circularBorderRadius,
                          ),
                          child: TextField(
                            autocorrect: Util.isDesktop ? false : true,
                            enableSuggestions: Util.isDesktop ? false : true,
                            controller: amountController,
                            focusNode: _amountFocusNode,
                            style: STextStyles.field(context),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: standardInputDecoration(
                              "Amount",
                              _amountFocusNode,
                              context,
                            ).copyWith(
                              suffixIcon: amountController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: UnconstrainedBox(
                                        child: Row(
                                          children: [
                                            TextFieldIconButton(
                                              child: const XIcon(),
                                              onTap: () async {
                                                setState(() {
                                                  amountController.text = "";
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Note (Optional)",
                          style: STextStyles.smallMed12(context),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Constants.size.circularBorderRadius,
                          ),
                          child: TextField(
                            autocorrect: Util.isDesktop ? false : true,
                            enableSuggestions: Util.isDesktop ? false : true,
                            controller: noteController,
                            focusNode: _noteFocusNode,
                            style: STextStyles.field(context),
                            onChanged: (_) => setState(() {}),
                            decoration: standardInputDecoration(
                              "Note",
                              _noteFocusNode,
                              context,
                            ).copyWith(
                              suffixIcon: noteController.text.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: UnconstrainedBox(
                                        child: Row(
                                          children: [
                                            TextFieldIconButton(
                                              child: const XIcon(),
                                              onTap: () async {
                                                setState(() {
                                                  noteController.text = "";
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        // SizedBox()
                        // Spacer(),
                        const SizedBox(
                          height: 8,
                        ),
                        TextButton(
                          style: Theme.of(context)
                              .extension<StackColors>()!
                              .getPrimaryEnabledButtonColor(context),
                          onPressed: () {
                            final amountString = amountController.text;
                            final noteString = noteController.text;

                            if (amountString.isNotEmpty &&
                                Decimal.tryParse(amountString) == null) {
                              showFloatingFlushBar(
                                type: FlushBarType.warning,
                                message: "Invalid amount",
                                context: context,
                              );
                              return;
                            }

                            String query = "";

                            if (amountString.isNotEmpty) {
                              query += "amount=$amountString";
                            }
                            if (noteString.isNotEmpty) {
                              if (query.isNotEmpty) {
                                query += "&";
                              }
                              query += "message=$noteString";
                            }

                            final uri = Uri(
                              scheme: widget.coin.uriScheme,
                              host: widget.receivingAddress,
                              query: query.isNotEmpty ? query : null,
                            );

                            final uriString =
                                uri.toString().replaceFirst("://", ":");

                            Logging.instance.log(
                                "Generated receiving QR code for: $uriString",
                                level: LogLevel.Info);

                            showDialog<dynamic>(
                              context: context,
                              useSafeArea: false,
                              barrierDismissible: true,
                              builder: (_) {
                                final width =
                                    MediaQuery.of(context).size.width / 2;
                                return StackDialogBase(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Center(
                                        child: Text(
                                          "New QR code",
                                          style:
                                              STextStyles.pageTitleH2(context),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Center(
                                        child: RepaintBoundary(
                                          key: _qrKey,
                                          child: SizedBox(
                                            width: width + 20,
                                            height: width + 20,
                                            child: QrImage(
                                                data: uriString,
                                                size: width,
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .extension<StackColors>()!
                                                    .popupBG,
                                                foregroundColor: Theme.of(
                                                        context)
                                                    .extension<StackColors>()!
                                                    .accentColorDark),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Center(
                                        child: SizedBox(
                                          width: width,
                                          child: TextButton(
                                            onPressed: () async {
                                              // TODO: add save button as well
                                              await _capturePng(true);
                                            },
                                            style: Theme.of(context)
                                                .extension<StackColors>()!
                                                .getSecondaryEnabledButtonColor(
                                                    context),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: SvgPicture.asset(
                                                    Assets.svg.share,
                                                    width: 14,
                                                    height: 14,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      "Share",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: STextStyles.button(
                                                              context)
                                                          .copyWith(
                                                        color: Theme.of(context)
                                                            .extension<
                                                                StackColors>()!
                                                            .buttonTextSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Generate QR Code",
                            style: STextStyles.button(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
