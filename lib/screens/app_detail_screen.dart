import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zapstore/main.data.dart';
import 'package:zapstore/models/app.dart';
import 'package:zapstore/models/release.dart';
import 'package:zapstore/utils/extensions.dart';
import 'package:zapstore/widgets/install_button.dart';
import 'package:zapstore/widgets/release_card.dart';
import 'package:zapstore/widgets/signer_and_developer_row.dart';
import 'package:zapstore/widgets/versioned_app_header.dart';

class AppDetailScreen extends HookConsumerWidget {
  final App model;
  AppDetailScreen({
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ScrollController();

    final state = ref.apps.watchOne(model.id!,
        alsoWatch: (_) =>
            {_.releases, _.releases.artifacts, _.signer, _.developer});

    // TODO: Why this? and not remote just above?
    useFuture(useMemoized(() =>
        ref.apps.findOne(model.id!, remote: true, params: {'includes': true})));

    // TODO: Hack to refresh on install changes
    final _ = ref.watch(installedAppProvider);

    final app = state.model ?? model;

    return RefreshIndicator(
      onRefresh: () => ref.apps.findOne(model.id!),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      VersionedAppHeader(app: app),
                      Gap(16),
                      if (app.images.isNotEmpty)
                        Scrollbar(
                          controller: scrollController,
                          interactive: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              height: 320,
                              child: Row(
                                children: [
                                  for (final i in app.images)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: CachedNetworkImage(
                                        imageUrl: i,
                                        errorWidget: (_, __, ___) =>
                                            Container(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Divider(height: 24),
                      MarkdownBody(
                        styleSheet: MarkdownStyleSheet(
                          h1: TextStyle(fontWeight: FontWeight.bold),
                          h2: TextStyle(fontWeight: FontWeight.bold),
                          p: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w300),
                        ),
                        selectable: false,
                        data: app.content,
                      ),
                      Gap(10),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SignerAndDeveloperRow(app: app),
                      ),
                      Gap(20),
                      if (app.repository == null)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('This app is not open source',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      Gap(10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            if (app.repository != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(child: Text('Source ')),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          launchUrl(Uri.parse(app.repository!));
                                        },
                                        child: AutoSizeText(
                                          app.repository!,
                                          minFontSize: 11,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('License'),
                                  Text((app.license == null ||
                                          app.license == 'NOASSERTION')
                                      ? 'Unknown'
                                      : app.license!)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('App ID'),
                                  Text(app.identifier!)
                                ],
                              ),
                            ),
                            if (app.latestMetadata != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('APK package SHA-256'),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: app.latestMetadata!.hash!));
                                          context.showInfo(
                                              'Copied APK package SHA-256 to the clipboard');
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${app.latestMetadata!.hash!.substring(0, 6)}...${app.latestMetadata!.hash!.substring(58, 64)}',
                                              maxLines: 1,
                                            ),
                                            Gap(6),
                                            Icon(Icons.copy_rounded, size: 18)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (app.latestMetadata?.apkSignatureHash != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('APK certificate SHA-256'),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: app.latestMetadata!
                                                  .apkSignatureHash!));
                                          context.showInfo(
                                              'Copied APK certificate SHA-256 to the clipboard');
                                          app
                                              .packageCertificateMatches()
                                              .then((match) {
                                            if (match != null && !match) {
                                              context.showError(
                                                  'APK certificate mismatch!\nPlease report');
                                            }
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${app.latestMetadata!.apkSignatureHash!.substring(0, 6)}...${app.latestMetadata!.apkSignatureHash!.substring(58, 64)}',
                                              maxLines: 1,
                                            ),
                                            Gap(6),
                                            Icon(Icons.copy_rounded, size: 18)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Divider(height: 60),
                      Text(
                        'Latest release'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Gap(10),
                      if (app.releases.ordered.isNotEmpty)
                        ReleaseCard(release: app.releases.ordered.first),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: Center(
              child: InstallButton(app: app, disabled: !app.signer.isPresent),
            ),
          ),
        ],
      ),
    );
  }
}
