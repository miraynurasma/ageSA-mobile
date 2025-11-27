import 'package:flutter/material.dart';
import 'application_preapply_page.dart';
import 'application_status_page.dart';
import 'application_approval_page.dart';

const Color kBorderGrey = Color(0xFFE3E6EC);

class ApplicationActionsPage extends StatelessWidget {
  const ApplicationActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Başvuru İşlemleri'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionCard(
            icon: Icons.assignment_outlined,
            title: 'Ön Başvuru Yap',
            subtitle: 'BES için ön başvurunu buradan yapabilirsin.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApplicationPreApplyPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.visibility_outlined,
            title: 'Başvuru Durumu',
            subtitle: 'Başvuru durumunu takip edebilirsin.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApplicationStatusPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.verified_outlined,
            title: 'Başvuru Onay',
            subtitle: 'Başvuru onayını tamamlayabilirsin.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApplicationApprovalPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
