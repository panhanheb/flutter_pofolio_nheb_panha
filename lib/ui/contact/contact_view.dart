import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/common.dart';
import '../../data/models/portfolio.dart';
import 'contact_view_model.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ContactViewModel>();
    final p = vm.profile;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(eyebrow: 'Contact', title: "Let's work together", lead: vm.lead),
        const SizedBox(height: 32),
        const _EmailCard(),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.send_outlined,
          label: 'Telegram',
          value: p.telegramHandle,
          url: p.telegramUrl,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: '${p.location} (${p.timezone})',
        ),
      ],
    );

    return Section(
      child: context.isLg
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: Reveal(child: left)),
                const SizedBox(width: 48),
                Expanded(
                  flex: 7,
                  child: Reveal(delay: Reveal.stagger(1), child: const ContactForm()),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Reveal(child: left),
                const SizedBox(height: 40),
                Reveal(delay: Reveal.stagger(1), child: const ContactForm()),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.trailing});
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      children: [
        IconTile(icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: pal.muted)),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: pal.text),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value, this.url});
  final IconData icon;
  final String label;
  final String value;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: url == null ? null : () => openUrl(url!),
      semanticLabel: url == null ? null : '$label $value',
      child: _InfoRow(
        icon: icon,
        label: label,
        value: value,
        trailing: url == null
            ? null
            : Icon(Icons.arrow_outward, size: 16, color: context.pal.muted),
      ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ContactViewModel>();
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: _InfoRow(
        icon: Icons.mail_outline,
        label: 'Email',
        value: vm.profile.email,
        trailing: AppButton(
          label: vm.copied ? 'Copied' : 'Copy',
          icon: vm.copied ? Icons.check : Icons.copy_outlined,
          kind: ButtonKind.secondary,
          compact: true,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: vm.profile.email));
            vm.markCopied();
          },
        ),
      ),
    );
  }
}

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  // Text controllers are UI plumbing; validation and sending live in the view model.
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit(ContactViewModel vm) async {
    final sent = await vm.submit(name: _name.text, email: _email.text, message: _message.text);
    if (sent && mounted) {
      _name.clear();
      _email.clear();
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final vm = context.watch<ContactViewModel>();
    final enabled = !vm.sending;

    final nameField = _Labeled(
      'Name',
      AppTextField(
        controller: _name,
        hint: 'Your name',
        maxLength: ContactViewModel.nameMax,
        enabled: enabled,
      ),
    );
    final emailField = _Labeled(
      'Email',
      AppTextField(
        controller: _email,
        hint: 'you@example.com',
        maxLength: ContactViewModel.emailMax,
        keyboardType: TextInputType.emailAddress,
        enabled: enabled,
      ),
    );

    return AppCard(
      padding: EdgeInsets.all(context.isSm ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.isSm)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 16),
                Expanded(child: emailField),
              ],
            )
          else ...[
            nameField,
            const SizedBox(height: 16),
            emailField,
          ],
          const SizedBox(height: 16),
          _Labeled(
            'What can I help with?',
            _TypeDropdown(
              types: vm.inquiryTypes,
              value: vm.type,
              enabled: enabled,
              onChanged: vm.selectType,
            ),
          ),
          const SizedBox(height: 16),
          _Labeled(
            'Message',
            AppTextField(
              controller: _message,
              hint: 'Tell me about your project or role',
              minLines: 5,
              maxLines: 10,
              maxLength: ContactViewModel.messageMax,
              keyboardType: TextInputType.multiline,
              enabled: enabled,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: vm.sending ? 'Sending…' : 'Send message',
              loading: vm.sending,
              icon: Icons.send_outlined,
              expand: !context.isSm,
              onPressed: () => _submit(vm),
            ),
          ),
          if (vm.status != null) ...[
            const SizedBox(height: 16),
            _StatusBox(message: vm.status!, success: vm.success, pal: pal),
          ],
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.message, required this.success, required this.pal});
  final String message;
  final bool success;
  final Palette pal;

  @override
  Widget build(BuildContext context) {
    final color = success ? pal.success : pal.danger;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(success ? Icons.check_circle_outline : Icons.error_outline, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(fontSize: 14, height: 1.4, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.pal.text),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({
    required this.types,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });
  final List<InquiryType> types;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c),
        );
    return DropdownButtonFormField<String>(
      initialValue: value,
      key: ValueKey(value),
      isExpanded: true,
      onChanged: enabled ? onChanged : null,
      dropdownColor: pal.bg,
      borderRadius: BorderRadius.circular(8),
      icon: Icon(Icons.expand_more, color: pal.muted),
      style: TextStyle(fontSize: 14, color: pal.text),
      hint: Text(
        'Choose a topic',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14, color: pal.muted.withValues(alpha: 0.75)),
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: pal.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: border(pal.border),
        enabledBorder: border(pal.border),
        disabledBorder: border(pal.border),
        focusedBorder: border(pal.accent),
      ),
      items: [
        for (final t in types)
          DropdownMenuItem(value: t.value, child: Text(t.label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
