import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/start_up/login_page.dart';

class NoAccountPage extends StatefulWidget {
  const NoAccountPage({Key? key}) : super(key: key);

  @override
  _NoAccountPageState createState() => _NoAccountPageState();
}

class _NoAccountPageState extends State<NoAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Center(child: WidgetUtils.instance.createOpacity()),
            const LoginPage(),
            // Center(
            //   child: SizedBox(
            //     height: 500,
            //     width: 500,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Container(
            //           margin: const EdgeInsets.only(left:10.0),
            //           padding: const EdgeInsets.all(10.0),
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(8.0),
            //               color: Colors.grey.withOpacity(0.15)
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.only(left: 5.0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Center(
            //                   child: Column(
            //                     children: [
            //                       const Text('ログインはこちら'),
            //                       ElevatedButton(
            //                         onPressed: () {
            //                           Navigator.push(context, MaterialPageRoute(builder: (content) => const LoginPage()));
            //                         },
            //                         style: ElevatedButton.styleFrom(
            //                           primary: Colors.green,
            //                           onPrimary: Colors.white,
            //                           shape: RoundedRectangleBorder(
            //                             borderRadius: BorderRadius.circular(10),
            //                           ),
            //                         ),
            //                         child: Container(
            //                             height: 75,
            //                             width: 300,
            //                             alignment: Alignment.center,
            //                             child: const Text('ログインまたは新規登録はこちら')
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
          ]
      ),
    );
  }
}
