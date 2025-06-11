import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Terms and Conditions',
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
              'Xplorion Ai – Terms and Conditions',
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
              'Welcome to Xplorion Ai! These Terms and Conditions (“Terms”) govern your use of the Xplorion Ai mobile application (“App”, “we”, “our”, or “us”). By accessing or using the App, you agree to be bound by these Terms.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. Use of the App'),
            _buildBulletPoints([
              'Use the App only for lawful purposes.',
              'Not use the App in a way that could harm, disrupt, or overburden our systems or services.',
              'Not copy, distribute, or exploit any part of the App without our written permission.',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('2. Location Access'),
            const Text(
              'To offer personalized suggestions, Xplorion Ai accesses your device’s location. By using the App, you consent to this access. You may disable location services via your device settings, but some features may not function properly.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('3. AI-Generated Content'),
            _buildBulletPoints([
              'Xplorion Ai does not guarantee the accuracy, completeness, or suitability of any suggestion.',
              'Always verify travel information independently before acting on suggestions.',
              'We are not liable for any loss or issue arising from reliance on AI-generated content.',
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('4. Third-Party Data'),
            const Text(
              'The app may display data such as reviews, hours, and pricing pulled from third-party sources like Google. We do not control the accuracy or availability of this information.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('5. Account & Security'),
            const Text(
              'You are responsible for maintaining the confidentiality of your account information. Notify us immediately of any unauthorized use.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('6. Intellectual Property'),
            const Text(
              'All content in the App, including logos, text, design, and AI models, is owned by Xplorion Ai and protected by applicable intellectual property laws.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('7. Changes to the App or Terms'),
            const Text(
              'We may update the App or these Terms at any time. Continued use after changes means you accept the new Terms. We recommend checking back periodically.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('8. Limitation of Liability'),
            const Text(
              'Xplorion Ai is provided “as is” without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the App.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('9. Termination'),
            const Text(
              'We may suspend or terminate your access at any time if you violate these Terms or misuse the App.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('10. Governing Law'),
            const Text(
              'These Terms are governed by the laws of [Your Country/State], and any disputes will be resolved under its jurisdiction.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Contact Us'),
            const Text(
              'If you have any questions or concerns about these Terms, please reach out to us at:\nEmail: [your email address]',
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
