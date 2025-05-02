import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Xplorion AI – Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0099FF),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Effective Date: 22nd April 2025',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF54AB6A),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We at Xplorion AI care about your privacy—after all, it’s your adventure, your data. This Privacy Policy explains how we collect, use, and protect your information when you use our app. By using Xplorion AI, you agree to this policy.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. What We Collect (And Why)'),
            _buildSubSection('Location Data', [
              'What: Your device’s GPS-based location.',
              'Why: To recommend travel spots and experiences near you.',
              'Your Control: You can turn it off anytime in your device settings (though the app may not work as intended without it).',
            ]),
            _buildSubSection('Usage Data', [
              'What: How you interact with the app, pages you view, buttons you tap.',
              'Why: To improve recommendations and understand what explorers like you love.',
            ]),
            _buildSubSection('Device Info', [
              'What: Device type, OS version, crash reports.',
              'Why: To squash bugs and make the app smoother than your travel plans.',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('2. Do We Share Your Data?'),
            const Text(
              'We do not sell your data.\n\nWe may share basic, non-personal data with:',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            _buildBulletPoints([
              'Third-party services like map providers or review aggregators to show you helpful info.',
              'Analytics platforms to help us understand usage trends (no personally identifying info).',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('3. AI Recommendations'),
            _buildBulletPoints([
              'You should verify info independently before making bookings or decisions.',
              'We are not responsible for any inaccuracies in AI-generated content.',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Your Rights'),
            _buildBulletPoints([
              'Request deletion of your data.',
              'Ask what data we hold about you.',
              'Opt out of location tracking or notifications.',
            ]),
            const Text(
              'Just drop us a line at [your email address].',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('5. Data Storage & Security'),
            _buildBulletPoints([
              'Secure servers',
              'Encrypted communications',
              'Limited access to user info',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('6. Kids’ Privacy'),
            const Text(
              'Xplorion AI is not designed for children under 13. We don’t knowingly collect their data. If we do, we’ll delete it.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('7. Changes to This Policy'),
            const Text(
              'If we update this Privacy Policy, we’ll let you know (probably not by postcard though). Keep an eye on the app or our website for updates.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('8. Contact Us'),
            const Text(
              'Questions? Feedback? Found a hidden waterfall you want to share?\nEmail us at: [your email address]',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0099FF),
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildSubSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF54AB6A),
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 5),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 5),
              child: Text(
                '• $point',
                style: const TextStyle(
                  height: 1.5,
                  color: Color(0xFF333333),
                  fontFamily: 'Roboto',
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points
          .map((point) => Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 5),
                child: Text(
                  '• $point',
                  style: const TextStyle(
                    height: 1.5,
                    color: Color(0xFF333333),
                    fontFamily: 'Roboto',
                  ),
                ),
              ))
          .toList(),
    );
  }
}
