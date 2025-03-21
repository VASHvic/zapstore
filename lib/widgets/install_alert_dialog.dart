import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zapstore/models/app.dart';
import 'package:zapstore/models/user.dart';
import 'package:zapstore/widgets/author_container.dart';
import 'package:zapstore/widgets/relevant_who_follow_container.dart';
import 'package:zapstore/widgets/sign_in_container.dart';

class InstallAlertDialog extends HookConsumerWidget {
  const InstallAlertDialog({
    super.key,
    required this.app,
  });

  final App app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trustedSignerNotifier = useState(false);
    final signedInUser = ref.watch(signedInUserProvider);

    return AlertDialog(
      elevation: 10,
      title: Text(
        'Are you sure you want to install ${app.name}?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'By installing this app you are trusting the signer now and for all future updates. Make sure you know who they are.'),
            Gap(20),
            if (app.signer.value != null)
              AuthorContainer(
                  user: app.signer.value!,
                  beforeText: 'Signed by',
                  oneLine: true),
            Gap(20),
            if (app.signer.value != null)
              signedInUser != null
                  ? RelevantWhoFollowContainer(
                      toNpub: app.signer.value!.npub,
                    )
                  : SignInButton(
                      label:
                          'Sign in to view the signer\'s reputable followers',
                      minimal: true,
                      requireNip55: true,
                    ),
            Gap(16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Switch(
                  value: trustedSignerNotifier.value,
                  onChanged: (value) {
                    trustedSignerNotifier.value = value;
                  },
                ),
                Gap(4),
                Expanded(
                  child: Text(
                    'Do not ask again for apps from ${app.signer.value!.name}',
                  ),
                )
              ],
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextButton(
            onPressed: () {
              app.install(alwaysTrustSigner: trustedSignerNotifier.value);
              // NOTE: can't use context.pop()
              Navigator.of(context).pop();
            },
            child: Text(
              '${trustedSignerNotifier.value ? 'Always trust' : 'Trust'} ${app.signer.value!.name} and install app',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // NOTE: can't use context.pop()
            Navigator.of(context).pop();
          },
          child: Text('Go back'),
        ),
      ],
    );
  }
}
