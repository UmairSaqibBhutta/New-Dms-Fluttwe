import 'package:dms_new_project/Screens/app_screens/doc_module/upload_doc_screen.dart';
import 'package:dms_new_project/configs/colors.dart';
import 'package:dms_new_project/configs/constants.dart';
import 'package:dms_new_project/configs/text_styles.dart';
import 'package:dms_new_project/helper_services/custom_loader.dart';
import 'package:dms_new_project/providers/doc_list_provider.dart';
import 'package:dms_new_project/services/doc_list_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper_services/navigation_services.dart';
import '../../../services/attach_doc_service.dart';
import 'doc_list_widget.dart';

class DocListScreen extends StatefulWidget {
  final int catId;

  DocListScreen({required this.catId});

  @override
  State<DocListScreen> createState() => _DocListScreenState();
}

class _DocListScreenState extends State<DocListScreen> {
  late DocumentsListService doc;

  final ScrollController docController = ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      docListHandler();
    });
    doc = Provider.of<DocumentsListService>(context, listen: false);
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    doc.pageNo=1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        iconTheme: iconTheme,
        title: Text(
          "Documents List",
          style: dashStyle,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
        return  docListHandler();
        },
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ListView.builder(
                  controller: docController,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: doc.docList!.length,
                  primary: false,
                  itemBuilder: (BuildContext, index) {
                    return DocListWidget(
                      doc: doc.docList![index],
                    );
                  })),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appColor,
        onPressed: () {
          NavigationServices.goNextAndKeepHistory(
              context: context,
              widget: AddNewDocumentsScreen(
                attribute: doc.docList![0]
                    .attribute!,
                catId: widget.catId,
              )
          );

        },
        child: Icon(Icons.add),
      ),
    );
  }

  docListHandler() async {
    CustomLoader.showLoader(context: context);
    await doc.getInitDoc(context: context, catId: widget.catId);
    setState(() {});
    CustomLoader.hideLoader(context);
    docController.addListener(() async {
      if (docController.position.maxScrollExtent == docController.offset) {
        doc.pageNo = doc.pageNo + 1;
        CustomLoader.showLoader(context: context);
        await doc.getMoreDocs(context: context, catId: widget.catId);
        setState(() {});
        CustomLoader.hideLoader(context);
      }
    });
  }
}
