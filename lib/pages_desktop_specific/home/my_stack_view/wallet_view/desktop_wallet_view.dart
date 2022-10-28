import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackwallet/pages_desktop_specific/home/my_stack_view/wallet_view/desktop_wallet_summary.dart';
import 'package:stackwallet/pages_desktop_specific/home/my_stack_view/wallet_view/receive/desktop_receive.dart';
import 'package:stackwallet/pages_desktop_specific/home/my_stack_view/wallet_view/send/desktop_send.dart';
import 'package:stackwallet/providers/providers.dart';
import 'package:stackwallet/services/event_bus/events/global/wallet_sync_status_changed_event.dart';
import 'package:stackwallet/utilities/assets.dart';
import 'package:stackwallet/utilities/constants.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/utilities/theme/stack_colors.dart';
import 'package:stackwallet/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackwallet/widgets/custom_buttons/blue_text_button.dart';
import 'package:stackwallet/widgets/desktop/desktop_app_bar.dart';
import 'package:stackwallet/widgets/desktop/desktop_scaffold.dart';
import 'package:stackwallet/widgets/desktop/secondary_button.dart';
import 'package:stackwallet/widgets/rounded_white_container.dart';

class DesktopWalletView extends ConsumerStatefulWidget {
  const DesktopWalletView({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  static const String routeName = "/desktopWalletView";

  final String walletId;

  @override
  ConsumerState<DesktopWalletView> createState() => _DesktopWalletViewState();
}

class _DesktopWalletViewState extends ConsumerState<DesktopWalletView> {
  late final String walletId;

  Future<void> onBackPressed() async {
    // TODO log out and close wallet before popping back
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    walletId = widget.walletId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getManager(walletId)));
    final coin = manager.coin;
    final managerProvider = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getManagerProvider(walletId)));

    return DesktopScaffold(
      appBar: DesktopAppBar(
        background: Theme.of(context).extension<StackColors>()!.popupBG,
        leading: Row(
          children: [
            const SizedBox(
              width: 32,
            ),
            AppBarIconButton(
              size: 32,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .textFieldDefaultBG,
              shadows: const [],
              icon: SvgPicture.asset(
                Assets.svg.arrowLeft,
                width: 18,
                height: 18,
                color: Theme.of(context)
                    .extension<StackColors>()!
                    .topNavIconPrimary,
              ),
              onPressed: onBackPressed,
            ),
            const SizedBox(
              width: 15,
            ),
            SvgPicture.asset(
              Assets.svg.iconFor(coin: coin),
              width: 32,
              height: 32,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              manager.walletName,
              style: STextStyles.desktopH3(context),
            ),
          ],
        ),
        trailing: Row(
          children: const [
            NetworkInfoButton(),
            SizedBox(
              width: 32,
            ),
            WalletKeysButton(),
            SizedBox(
              width: 32,
            ),
          ],
        ),
        isCompactHeight: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            RoundedWhiteContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SvgPicture.asset(
                    Assets.svg.iconFor(coin: coin),
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  DesktopWalletSummary(
                    walletId: walletId,
                    managerProvider: managerProvider,
                    initialSyncStatus: ref.watch(managerProvider
                            .select((value) => value.isRefreshing))
                        ? WalletSyncStatus.syncing
                        : WalletSyncStatus.synced,
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Text(
                  //           "TODO: balance",
                  //           style: STextStyles.desktopH3(context),
                  //         ),
                  //         const SizedBox(
                  //           width: 8,
                  //         ),
                  //         Container(
                  //           color: Colors.red,
                  //           width: 20,
                  //           height: 20,
                  //         ),
                  //       ],
                  //     ),
                  //     Text(
                  //       "todo: fiat balance",
                  //       style:
                  //           STextStyles.desktopTextExtraSmall(context).copyWith(
                  //         color: Theme.of(context)
                  //             .extension<StackColors>()!
                  //             .textSubtitle1,
                  //       ),
                  //     )
                  //   ],
                  // ),
                  const Spacer(),
                  SecondaryButton(
                    width: 180,
                    height: 56,
                    onPressed: () {
                      // todo: go to wallet initiated exchange
                    },
                    label: "Exchange",
                    icon: Container(
                      color: Colors.red,
                      width: 20,
                      height: 20,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 450,
                    child: MyWallet(
                      walletId: walletId,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: RecentDesktopTransactions(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWallet extends StatefulWidget {
  const MyWallet({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  final String walletId;

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My wallet",
          style: STextStyles.desktopTextExtraSmall(context).copyWith(
            color: Theme.of(context)
                .extension<StackColors>()!
                .textFieldActiveSearchIconLeft,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).extension<StackColors>()!.popupBG,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                Constants.size.circularBorderRadius,
              ),
            ),
          ),
          child: SendReceiveTabMenu(
            onChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).extension<StackColors>()!.popupBG,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                Constants.size.circularBorderRadius,
              ),
            ),
          ),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              Padding(
                key: const Key("desktopSendViewPortKey"),
                padding: const EdgeInsets.all(20),
                child: DesktopSend(
                  walletId: widget.walletId,
                ),
              ),
              Padding(
                key: const Key("desktopReceiveViewPortKey"),
                padding: const EdgeInsets.all(20),
                child: DesktopReceive(
                  walletId: widget.walletId,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class SendReceiveTabMenu extends StatefulWidget {
  const SendReceiveTabMenu({
    Key? key,
    this.initialIndex = 0,
    this.onChanged,
  }) : super(key: key);

  final int initialIndex;
  final void Function(int)? onChanged;

  @override
  State<SendReceiveTabMenu> createState() => _SendReceiveTabMenuState();
}

class _SendReceiveTabMenuState extends State<SendReceiveTabMenu> {
  late int _selectedIndex;

  void _onChanged(int newIndex) {
    if (_selectedIndex != newIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
      widget.onChanged?.call(_selectedIndex);
    }
  }

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _onChanged(0),
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Send",
                    style: STextStyles.desktopTextExtraSmall(context).copyWith(
                      color: _selectedIndex == 0
                          ? Theme.of(context)
                              .extension<StackColors>()!
                              .accentColorBlue
                          : Theme.of(context)
                              .extension<StackColors>()!
                              .textSubtitle1,
                    ),
                  ),
                  const SizedBox(
                    height: 19,
                  ),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? Theme.of(context)
                              .extension<StackColors>()!
                              .accentColorBlue
                          : Theme.of(context)
                              .extension<StackColors>()!
                              .background,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _onChanged(1),
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Receive",
                    style: STextStyles.desktopTextExtraSmall(context).copyWith(
                      color: _selectedIndex == 1
                          ? Theme.of(context)
                              .extension<StackColors>()!
                              .accentColorBlue
                          : Theme.of(context)
                              .extension<StackColors>()!
                              .textSubtitle1,
                    ),
                  ),
                  const SizedBox(
                    height: 19,
                  ),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? Theme.of(context)
                              .extension<StackColors>()!
                              .accentColorBlue
                          : Theme.of(context)
                              .extension<StackColors>()!
                              .background,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RecentDesktopTransactions extends StatefulWidget {
  const RecentDesktopTransactions({Key? key}) : super(key: key);

  @override
  State<RecentDesktopTransactions> createState() =>
      _RecentDesktopTransactionsState();
}

class _RecentDesktopTransactionsState extends State<RecentDesktopTransactions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent transactions",
              style: STextStyles.desktopTextExtraSmall(context).copyWith(
                color: Theme.of(context)
                    .extension<StackColors>()!
                    .textFieldActiveSearchIconLeft,
              ),
            ),
            BlueTextButton(
              text: "See all",
              onTap: () {
                // todo: show all txns
              },
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: RoundedWhiteContainer(
            padding: const EdgeInsets.all(0),
            child: Container(),
          ),
        ),
      ],
    );
  }
}

class NetworkInfoButton extends StatelessWidget {
  const NetworkInfoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.svg.network,
              width: 24,
              height: 24,
              color:
                  Theme.of(context).extension<StackColors>()!.accentColorGreen,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              "Synchronised",
              style: STextStyles.desktopMenuItemSelected(context),
            )
          ],
        ),
      ),
    );
  }
}

class WalletKeysButton extends StatelessWidget {
  const WalletKeysButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.svg.key,
              width: 20,
              height: 20,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .buttonTextSecondary,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              "Wallet keys",
              style: STextStyles.desktopMenuItemSelected(context),
            )
          ],
        ),
      ),
    );
  }
}
