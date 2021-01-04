import 'package:cached_network_image/cached_network_image.dart';
import 'package:edagang/scoped/main_scoped.dart';
import 'package:edagang/screens/shop/shop_index.dart';
import 'package:edagang/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';

class CartHistory extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CartHistoryOrderPageState();
  }
}

class _CartHistoryOrderPageState extends State<CartHistory> {

  bool _loadingInProgress;

  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;
    _loadData();

  }

  Future _loadData() async {
    await new Future.delayed(new Duration(seconds: 5));
    setState(() {
      _loadingInProgress = false;
    });
  }

  Widget dateStatus(String txndate, String status) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.all(3),
        child: Text(
          txndate,
          style: GoogleFonts.lato(
            textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(3),
        child: Text(
          status,
          style: GoogleFonts.lato(
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,),
          ),
        ),
      )
    ]);
  }

  Widget amountRow(String title, String displayAmount) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(3),
            child: Text(
              title,
              style: GoogleFonts.lato(
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(3),
            child: Text(
              displayAmount,
              style: GoogleFonts.lato(
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,),
              ),
            ),
          )
        ]);
  }

  Widget itemsRow(String title, String displayAmount) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.all(2),
        child: Text(
          title,
          style: GoogleFonts.lato(
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w300,),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(2),
        child: Text(
          displayAmount,
          style: GoogleFonts.lato(
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w300,),
          ),
        ),
      )
    ]);
  }

  Widget orderDetailItems(MainScopedModel model) {
    return Container(
      margin: EdgeInsets.all(0.0),
      alignment: Alignment.topLeft,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: model.historyOrders.length,
        itemBuilder: (context, index) {
          var data = model.historyOrders[index];
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Card(
                elevation: 3,
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Order# '+data.order_no,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,),
                        ),
                      ),
                      dateStatus('Transaction date: '+data.payment_txn_date, data.payment_err_code == '00' ? 'PAID' : 'UNPAID'),
                      Padding(
                        padding: EdgeInsets.only(left: 0, right: 5),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: data.order_group.length,
                          itemBuilder: (context, index) {
                            var ogrp = data.order_group[index];
                            return Container(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.all(1),
                                            child: Text(
                                              ogrp.merchant_name,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,),
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 5, right: 5),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: ClampingScrollPhysics(),
                                              itemCount: ogrp.order_items.length,
                                              itemBuilder: (context, index) {
                                                var item = ogrp.order_items[index];

                                                return Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(2),
                                                              width: 50,
                                                              height: 50,
                                                              child: ClipRRect(
                                                                  borderRadius: new BorderRadius.circular(5.0),
                                                                  child: CachedNetworkImage(
                                                                    placeholder: (context, url) => Container(
                                                                      width: 40,
                                                                      height: 40,
                                                                      color: Colors.transparent,
                                                                      child: CupertinoActivityIndicator(radius: 15,),
                                                                    ),
                                                                    imageUrl: Constants.urlImage+item.main_image,
                                                                    width: 30,
                                                                    height: 30,
                                                                    fit: BoxFit.cover,
                                                                  )
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(2),
                                                              child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: <Widget>[
                                                                    Text(
                                                                      item.product_name,
                                                                      style: GoogleFonts.lato(
                                                                        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400,),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      item.quantity + ' x  RM' +item.price,
                                                                      style: GoogleFonts.lato(
                                                                        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400,),
                                                                      ),
                                                                    ),
                                                                  ]
                                                              ),
                                                            )
                                                          ]
                                                      )
                                                    ]
                                                );
                                              }))
                                    ]
                                )
                            );

                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: amountRow('Total ','RM'+data.total_price),
                      )
                    ],
                  ),
                )
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainScopedModel>(builder: (context, child, model)
    {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            "My Orders",
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff202020),),
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        body: _loadingInProgress ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) : model.historyOrders.length > 0 ? Container(
          color: const Color(0xffF4F7FA),
          child: CustomScrollView(slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: EdgeInsets.only(left: 3, right: 3),
                  child: orderDetailItems(model),
                )
              ])
            )
          ]),
        ) : _emptyContent(),
      );
    });
  }

  _emptyContent() {
    return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(CupertinoIcons.shopping_cart, color: Colors.red.shade500, size: 50,),
              //Image.asset('images/ic_qrcode3.png', width: 26, height: 26,),
              SizedBox(height: 20,),
              Text(
                'Empty.',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,),
                ),
              ),
              new FlatButton(
                color: Colors.transparent,
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context){return ShopIndexPage();}));
                },
                child: new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      "CONTINUE SHOPPING",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.deepOrange.shade600),
                      ),
                    )
                ),
              )
            ],
          ),
        )
    );
  }

}