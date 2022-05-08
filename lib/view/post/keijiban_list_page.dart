import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iwate_ch_community_web/model/keijiban.dart';
import 'package:iwate_ch_community_web/utils/dialog_utils.dart';
import 'package:iwate_ch_community_web/utils/firestore/keijiban_posts.dart';
import 'package:iwate_ch_community_web/utils/firestore/keijibans.dart';
import 'package:iwate_ch_community_web/utils/function_utils.dart';
import 'package:iwate_ch_community_web/utils/widget_utils.dart';
import 'package:iwate_ch_community_web/view/post/keijiban_post_page.dart';

class KeijibanListPage extends StatefulWidget {
  const KeijibanListPage({Key? key}) : super(key: key);

  @override
  _KeijibanListPageState createState() => _KeijibanListPageState();
}

class _KeijibanListPageState extends State<KeijibanListPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(FunctionUtils.instance.isDarkMode(context) ? 'images/iwate-ch-top.png' : 'images/iwate-ch-top.png', height: 55),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 2,
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
            children: [
              Center(child: WidgetUtils.instance.createOpacity()),
              StreamBuilder<QuerySnapshot>(
              stream: KeijibanFirestore.keijibanList.orderBy('created_time').snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index){
                        Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        Keijiban keijiban = Keijiban(
                            id: snapshot.data!.docs[index].id,
                            name: data['name'],
                            imagePath: data['image_path'],
                            isVisible: data['is_visible'],
                            createdTime: data['created_time']
                        );
                        return !keijiban.isVisible ? Container() : Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                              )
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 22,
                                foregroundImage: NetworkImage(keijiban.imagePath),
                              ),
                              title: Text(keijiban.name),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => KeijibanPostPage(keijiban: keijiban))),
                            ),
                          ),
                        );
                      }
                  );
                } else {
                  return Container();
                }
              }
          ),
            ]
        ),
      ),
    );
  }
}
