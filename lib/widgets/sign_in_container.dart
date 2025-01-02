import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purplebase/purplebase.dart' as base;
import 'package:zapstore/main.data.dart';
import 'package:zapstore/models/settings.dart';
import 'package:zapstore/models/user.dart';
import 'package:zapstore/navigation/app_initializer.dart';
import 'package:zapstore/utils/extensions.dart';
import 'package:zapstore/widgets/rounded_image.dart';

class SignInButton extends ConsumerWidget {
  final bool minimal;
  final String label;
  SignInButton({super.key, this.minimal = false, this.label = 'Sign in'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.settings
        .watchOne('_', alsoWatch: (_) => {_.user})
        .model
        ?.user
        .value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!minimal) RoundedImage(url: user?.avatarUrl, size: 46),
            if (!minimal) Gap(10),
            if (user != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.nameOrNpub,
                        // softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Gap(4),
                      Icon(Icons.verified, color: Colors.lightBlue, size: 18),
                    ],
                  ),
                  // if (user.following.isNotEmpty)
                  //   Text('${user.following.length} contacts'),
                ],
              ),
          ],
        ),
        Gap(10),
        ElevatedButton(
          onPressed: () async {
            if (user == null) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SignInContainer(),
                ),
              );
            } else {
              ref.settings.findOneLocalById('_')!.user.value = null;
            }
          },
          child: Text(user == null ? label : 'Sign out'),
        ),
      ],
    );
  }
}

class SignInContainer extends HookConsumerWidget {
  const SignInContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isTextFieldEmpty = useState(true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (amberSigner.isAvailable)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AsyncButtonBuilder(
                    loadingWidget: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(),
                    ),
                    builder: (context, child, callback, buttonState) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: SizedBox(
                          child: ElevatedButton(
                            onPressed: callback,
                            style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: Colors.transparent,
                                backgroundColor: Colors.transparent),
                            child: child,
                          ),
                        ),
                      );
                    },
                    onPressed: () async {
                      if (!amberSigner.isAvailable) {
                        Navigator.of(context).pop();
                      }
                      final signedInNpub = await amberSigner.getPublicKey();
                      if (signedInNpub == null) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context.showError(
                              title: "Could not sign in",
                              description: "Signer did not respond");
                        }
                        return;
                      }

                      var user = await ref.users.findOne(signedInNpub);

                      // If user was not found on relays, we create a
                      // local user to represent this new npub
                      user ??= User.fromJson({
                        'id': signedInNpub.hexKey,
                        'kind': 0,
                        'pubkey': signedInNpub.hexKey,
                        'created_at':
                            DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        'content': '{}',
                        'tags': [],
                      }).init().saveLocal();

                      final settings = ref.settings.findOneLocalById('_')!;
                      settings.signInMethod = SignInMethod.nip55;
                      settings.user.value = user;
                      settings.saveLocal();

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Sign in with Amber'),
                  ),
                  Gap(10),
                  Text('or'),
                  Gap(10),
                ],
              ),
            Text('Input an npub or nostr address\n(read-only):'),
            TextField(
              autocorrect: false,
              controller: controller,
              onChanged: (value) {
                isTextFieldEmpty.value = value.isEmpty;
              },
            ),
            Gap(10),
            AsyncButtonBuilder(
              disabled: isTextFieldEmpty.value,
              loadingWidget: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(),
              ),
              onPressed: () async {
                try {
                  final input = controller.text.trim();
                  if (input.startsWith('nsec')) {
                    controller.clear();
                    throw Exception('Never give away your nsec!');
                  }
                  final user = await ref.users.findOne(input);

                  final settings = ref.settings.findOneLocalById('_')!;
                  settings.signInMethod = SignInMethod.pubkey;
                  settings.user.value = user;
                  settings.saveLocal();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } on Exception catch (e, stack) {
                  if (context.mounted) {
                    context.showError(
                        title: e.toString(),
                        description: stack.toString().substringMax(200));
                  }
                }
              },
              builder: (context, child, callback, buttonState) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: SizedBox(
                    child: ElevatedButton(
                      onPressed: callback,
                      style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent),
                      child: child,
                    ),
                  ),
                );
              },
              child: Text('Sign in with public key'),
            )
          ],
        ),
      ],
    );
  }
}
