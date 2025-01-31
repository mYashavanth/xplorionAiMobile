import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';

class FeedBack extends StatefulWidget {
  const FeedBack({super.key});

  @override
  State<FeedBack> createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  TextEditingController feedBackController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: const Text(
          'Feedback',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send feedback',
                  style: TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 18,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Tell us what you love about the app, or what we could be doing better.',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  // padding: const EdgeInsets.only(left: 10),
                  height: 130,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextField(
                    maxLines: 4,
                    enableInteractiveSelection: false,
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    keyboardType: TextInputType.text,
                    controller: feedBackController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'Enter feedback',
                      hintStyle: TextStyle(
                        color: Color(0xFFCDCED7),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                        height: 0.08,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // shadows: const [
                    //   BoxShadow(
                    //     color: Color(0x661F1B1B),
                    //     blurRadius: 12,
                    //     offset: Offset(2, 2),
                    //     spreadRadius: 0,
                    //   ),
                    // ],
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/feedback_star.svg'),
                      const SizedBox(
                        width: 15,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Love our App?',
                            style: TextStyle(
                              color: Color(0xFF030917),
                              fontSize: 16,
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Share your experience by rating us on the app store!',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 10,
                              fontFamily: 'IBM Plex Sans',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          Text(
                            'Go to app store',
                            style: TextStyle(
                              color: Color(0xFF214EB0),
                              fontSize: 12,
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          // Navigator.of(context).pushNamed('/account_setup');
        },
        child: Container(
          margin: const EdgeInsets.all(15),
          width: double.maxFinite,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-1.00, 0.06),
              end: Alignment(1, -0.06),
              colors: [
                Color(0xFF0099FF),
                Color(0xFF54AB6A),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),),
          ),
          child: const Center(
            child: Text(
              'Submit feedback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
                height: 0.16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
