import 'package:cached_network_image/cached_network_image.dart';
import 'package:edagang/models/biz_model.dart';
import 'package:edagang/scoped/main_scoped.dart';
import 'package:edagang/sign_in.dart';
import 'package:edagang/helper/constant.dart';
import 'package:edagang/utube/video_play.dart';
import 'package:edagang/widgets/SABTitle.dart';
import 'package:edagang/widgets/blur_icon.dart';
import 'package:edagang/widgets/html2text.dart';
import 'package:edagang/widgets/page_slide_right.dart';
import 'package:edagang/widgets/photo_viewer.dart';
import 'package:edagang/widgets/progressIndicator.dart';
import 'package:edagang/widgets/webview_f.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinDetailPage extends StatefulWidget {
  String bizId, bizName;
  FinDetailPage(this.bizId, this.bizName);

  @override
  _FinDetailPageState createState() => _FinDetailPageState();
}

const xpandedHeight = 195.0;

class _FinDetailPageState extends State<FinDetailPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController;

  bool isEnabled = true;
  Color color = Color(0xff2877EA);

  int _id,reftype;
  String company_name,overview,address,office_phone,office_fax,email,website,_logo,licno;
  List<Product> products = [];
  List<Award> awards = [];
  List<Cert> certs = [];

  Widget currentTab;
  int currentValue = 0;
  bool isLoading = false;

  AnimationController _animationController;
  Animation<Offset> _movieInformationSlidingAnimation;

  getDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      setState(() {
        print("product ID : "+widget.bizId);

        http.post(
            Uri.parse('https://finapp.e-dagang.asia/api/fintools/v2/details?business_id='+widget.bizId),
          headers: {'Authorization' : 'Bearer '+Constants.tokenGuest,'Content-Type': 'application/json',},
        ).then((response) {
          print('FINTOOLS DETAILS /////////////////');
          print('https://finapp.e-dagang.asia/api/fintools/v2/details?business_id='+widget.bizId);

          var resBody = json.decode(response.body);
          //print('Logo: '+resBody['data']['business']['logo']);
          //print('Product: '+resBody['data']['business']['product']['images']['file_path']);


          setState(() {

            List<Product> _product = [];
            resBody['data']['business']['product'].forEach((produk) {
              _product.add(
                new Product(
                  id: produk['id'],
                  business_id: produk['company_id'],
                  product_name: produk['product_name'],
                  product_desc: produk['description'],
                  overview: produk['overview'],
                  video_link: produk['video_link'],
                  file_path: produk['images'] == null ? 'null' : produk['images']['file_path'],
                )
              );
            });

            List<Award> _award = [];
            resBody['data']['business']['award'].forEach((awad) {
              _award.add(
                new Award(
                  id: awad['id'],
                  business_id: awad['business_id'],
                  award_desc: awad['award_desc'],
                  filename: awad['filename'] == null ? 'null' : awad['filename'],
                )
              );
            });

            var data = Home_business(
              id: resBody['data']['business']['id'],
              ref_type: resBody['data']['business']['ref_type'],
              company_name: resBody['data']['business']['company_name'].toString(),
              overview: resBody['data']['business']['overview'].toString(),
              address: resBody['data']['business']['address'].toString(),
              office_phone: resBody['data']['business']['office_phone'].toString(),
              office_fax: resBody['data']['business']['office_fax'] ?? '',
              email: resBody['data']['business']['email'].toString(),
              website: resBody['data']['business']['website'].toString(),
              logo: resBody['data']['business']['logo'],
              company_licno: resBody['data']['business']['company_licno'].toString(),
              product: _product,
              award: _award,
            );

            _id = data.id;
            reftype = data.ref_type;
            company_name = data.company_name.toUpperCase();
            overview = data.overview;
            address = data.address;
            office_phone = data.office_phone;
            office_fax = data.office_fax ?? '';
            email = data.email;
            website = data.website;
            _logo = data.logo;
            licno = data.company_licno;
            products = data.product;
            awards = data.award;

          });
          isLoading = false;
        });
      });
    } catch (Excepetion ) {
      print("error!");
    }
  }

  @override
  void initState() {
    FirebaseAnalytics().logEvent(name: 'Fintools_Product_'+widget.bizName,parameters:null);
    getDetails();
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2)) ..forward();
    _movieInformationSlidingAnimation =
        Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
                curve: Interval(0.25, 1.0, curve: Curves.fastOutSlowIn),
                parent: _animationController)
        );
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset > xpandedHeight - kToolbarHeight;
  }

  Future launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      print("Can't Launch ${url}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? buildCircularProgressIndicator() : CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: xpandedHeight,
              iconTheme: IconThemeData(
                color: Color(0xff084B8C),
              ),
              leading: Hero(
                  tag: "back",
                  child: InkWell(
                    onTap: () {Navigator.pop(context);},
                    splashColor: Color(0xffA0CCE8),
                    highlightColor: Color(0xffA0CCE8),
                    child: BlurIconLight(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Color(0xff084B8C),
                      ),
                    ),
                  )
              ),
              title: SABTs(
                child: Container(
                    child: Text(company_name ?? '',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 17 , fontWeight: FontWeight.w600,),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )
                ),
              ),
              flexibleSpace: _showTitle ? null : FlexibleSpaceBar(
                background: Column(
                    children: <Widget>[
                      Stack(
                        overflow: Overflow.visible,
                        alignment: Alignment.bottomLeft,
                        children: <Widget>[
                          Image.asset(
                            reftype == 1 ? 'assets/cartsinifinance3.png' : 'assets/cartsinifinance1.png', fit: BoxFit.fill,
                            height: 165,
                          ),
                          FractionalTranslation(
                            translation: Offset(0.1, 0.5),
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade500,
                                    blurRadius: 2.5,
                                    spreadRadius: 0.0,
                                    offset: Offset(2.5, 2.5),
                                  )
                                ],
                                //border: new Border.all(color: Colors.blue, width: 1.5,),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  //fit: BoxFit.fitHeight,
                                  imageUrl: _logo ?? '',
                                  imageBuilder: (context, imageProvider) => Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          alignment: Alignment.center,
                                          image: imageProvider,
                                          //fit: BoxFit.fitHeight,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(8.0),)
                                    ),
                                  ),
                                  //placeholder: (context, url) => Container(color: Colors.grey.shade200,),
                                  placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    color: Colors.transparent,
                                    child: Image.asset('assets/images/ed_logo_greys.png', width: 60,
                                      height: 60,),
                                  ),
                                  errorWidget: (context, url, error) => Icon(LineAwesomeIcons.file_image_o, size: 44, color: Color(0xffcecece),),
                                ),

                                /*CachedNetworkImage(
                                  imageUrl: _logo ?? "",
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error_outline),
                                ),*/

                                /*FadeInImage.assetNetwork(
                                  placeholder: _logo ?? "",
                                  image: _logo ?? "",
                                  fit: BoxFit.cover,
                                ),*/
                              ),
                            ),
                          ),
                          /*Positioned(
                            bottom: -16.0,
                            right: 16.0,
                            child: vr_ofis == 'null' && vr_room == 'null' ? Container() : Container(
                                alignment: Alignment.topRight,
                                child: virtualBtn(context, vr_ofis, vr_room)
                            ),
                          ),*/
                        ],
                      ),
                    ]
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.only(left: 8.0, top: 1.0, right: 8.0, bottom: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 2, right: 7, bottom: 0),
                                alignment: Alignment.topLeft,
                                child: Text(company_name ?? "",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 14, fontWeight: FontWeight.w700 ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 2, right: 7, bottom: 3),
                                child: Text("License: "+licno == null ? 'na' : licno,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.w500,),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 2, right: 7),
                                child: htmlText2(address),
                              ),
                            ],
                          ),
                        ),
                        _reqBtn(),
                      ],
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _animationController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CupertinoSegmentedControl(
                          selectedColor: Color(0xff2877EA),
                          borderColor: Color(0xff2877EA),
                          groupValue: currentValue,
                          children: const <int, Widget>{
                            0: Text('Overview', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),),
                            1: Text('Product', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),),
                            2: Text('Award', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),),
                          },
                          onValueChanged: (value) {
                            if (value == 0) {
                              currentTab = Padding(
                                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                                child: htmlText(overview),
                              );
                            } else if(value == 1) {
                              currentTab = Padding(
                                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                                child: _productList(widget.bizName),
                              );
                            } else {
                              currentTab = Padding(
                                padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                                child: _awardList(),
                              );
                            }
                            setState(() {
                              currentValue = value;
                            });
                          },
                        ),
                        currentTab ??
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                              child: htmlText(overview),
                            )
                      ],
                    ),
                    builder: (BuildContext context, Widget child) {
                      return Opacity(
                        opacity: _animationController.value,
                        child: FractionalTranslation(
                          translation: _movieInformationSlidingAnimation.value,
                          child: child,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: new Container(color: Colors.transparent),
            ),
          ]
      ),
    );
  }

  virtualBtn(BuildContext context, String vr1, String vr2) {
    if(vr1 == 'null' && vr2 == 'null') {
      return Container();
    } else if(vr1 != 'null' && vr2 == 'null') {
      return SizedBox(
        height: 32,
        child: RaisedButton(
          shape: StadiumBorder(),
          color: Colors.white,
          child: Text('VR OFFICE',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              textStyle: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600,),
            ),
          ),
          onPressed: () {launchURL(vr1);},
        ),
      );
    } else if(vr1 == 'null' && vr2 != 'null') {
      return SizedBox(
        height: 32,
        child: RaisedButton(
          shape: StadiumBorder(),
          color: Colors.white,
          child: Text('VR SHOWROOM',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              textStyle: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600,),
            ),
          ),
          onPressed: () {launchURL(vr2);},
        ),
      );
    } else if(vr1 != 'null' && vr2 != 'null') {
      return Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 32,
                child: RaisedButton(
                  shape: StadiumBorder(),
                  color: Colors.white,
                  child: Text('VR OFFICE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600,),
                    ),
                  ),
                  onPressed: () {launchURL(vr1);},
                ),
              ),

              SizedBox(width: 5,),

              SizedBox(
                height: 32,
                child: RaisedButton(
                  shape: StadiumBorder(),
                  color: Colors.white,
                  child: Text('VR SHOWROOM',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600,),
                    ),
                  ),
                  onPressed: () {launchURL(vr2);},
                ),
              )
            ],
          )
      );
    } else {
      return Container();
    }
  }

  Widget _reqBtn() {
    return ScopedModelDescendant<MainScopedModel>(builder: (context, child, model){
      //if(model.isAuthenticated){
      return Container(
        padding: EdgeInsets.only(left: 8.0, top: 3.0, right: 8.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    /*InkWell(
                      onTap: () {launch("tel://"+office_phone, );},
                      splashColor: Color(0xffA0CCE8),
                      highlightColor: Color(0xffA0CCE8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: color),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Text('CALL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    VerticalDivider(),*/

                    InkWell(
                      onTap: () async {
                        await FlutterShare.share(
                          title: 'Fintools',
                          text: '',
                          linkUrl: 'https://edagang.page.link/?link=https://finapp.e-dagang.asia/product/'+_id.toString(),
                          chooserTitle: widget.bizName,
                        );
                      },
                      splashColor: Color(0xffA0CCE8),
                      highlightColor: Color(0xffA0CCE8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, color: color),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Text('SHARE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
              ),
            ),
            RaisedButton(
              shape: StadiumBorder(),
              color: color,
              child: Text('REQUEST INFO',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,),
                ),
              ),
              onPressed: () {
                //Navigator.push(context, SlideRightRoute(page: WebviewWidget(data.webviewUrl, data.title)));
                model.isAuthenticated ? Navigator.push(context, SlideRightRoute(page: WebViewPage('https://fintools.e-dagang.asia/wv/reqform/' + model.getId().toString() + '/' + widget.bizId, widget.bizName))) : Navigator.push(context, SlideRightRoute(page: SignInOrRegister()));
              },
            ),
          ],
        ),
      );
      //}else{
      //  return Container();
      //}

    });

  }

  Widget _productList(String co) {
    if(products.length == 0) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: Text(
            "Not available.",
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
      );
    }else{
      return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: new SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey,
                      indent: 10.0,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var data = products[index];
                      var d1 = data.video_link != null ? data.video_link.split("/") : null;
                      var vlink = data.video_link != null ? d1[3].toString() : null;
                      return MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: InkWell(
                              onTap: () {
                                _viewSvcProduct(data.file_path, data.product_name, data.overview, widget.bizName, vlink);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 0.0, right: 7.0, top: 0.0),
                                          child: Text(
                                            data.product_name,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,),
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: EdgeInsets.only(right: 0.0, top: 0.0),
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            CupertinoIcons.chevron_forward,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 0.0, right: 7.0, bottom: 7.0),
                                    child: htmlText(data.product_desc),
                                  ),
                                ],
                              )
                          ),
                        )
                      );
                    },
                  )
                ]
            )
        ),
      );
    }
  }

  Widget _awardList() {
    if(awards.length == 0) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: Text(
            "Not available.",
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
      );
    }else{
      return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: new SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: awards.length,
                    itemBuilder: (context, index) {
                      var data = awards[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 60,
                              child: data.filename == 'null' ? Image.asset('assets/icons/ic_launcher_new.png', height: 28, width: 28, fit: BoxFit.cover,) : GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => PhotoViewer(imej: data.filename,),)
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: data.filename ?? "",
                                  fit: BoxFit.cover,
                                  //placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(LineAwesomeIcons.file_image_o, size: 44, color: Color(0xffcecece),),
                                ),

                                /*FadeInImage.assetNetwork(
                                  placeholder: cupertinoActivityIndicatorSmall,
                                  image: data.filename ?? '',
                                  fit: BoxFit.cover,
                                )*/
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: htmlText(data.award_desc),
                          ),
                        ],
                      );
                    },
                  )
                ]
            )
        ),
      );
    }
  }

  _viewSvcProduct(String image, String title, String oview, String biz, String vlink) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.001),
          child: GestureDetector(
            onTap: () {Navigator.pop(context);},
            child: DraggableScrollableSheet(
              initialChildSize: 0.90,
              minChildSize: 0.2,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(16),
                        child: Icon(
                          LineAwesomeIcons.close,
                          color: Colors.red[600],
                        ),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: Constants.padding,top: 0, right: Constants.padding,bottom: Constants.padding),
                                  //margin: EdgeInsets.only(top: Constants.padding),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      //SizedBox(height: 15,),
                                      Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: image == 'null' ? Container() : Container(
                                            decoration: new BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) => Container(
                                                  alignment: Alignment.center,
                                                  color: Colors.transparent,
                                                  child: Image.asset('assets/images/ed_logo_greys.png', width: 90,
                                                    height: 90,),
                                                ),
                                                imageUrl: image,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      biz.toLowerCase().contains('ta investment') ? SizedBox(height: 0,) : Text(title, style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600, color: Color(0xff2877EA)),),
                                      biz.toLowerCase().contains('ta investment') ? SizedBox(height: 0,) : SizedBox(height: 15,),
                                      vlink != null ? Card(
                                        margin: EdgeInsets.all(5.0),
                                        elevation: 0.5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 245,
                                          decoration: new BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(context, SlideRightRoute(page: VideoPlay(vlink.toString(), title)));
                                            },
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      //height: 155,
                                                      alignment: Alignment.center,
                                                      child: Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                                              child: CachedNetworkImage(imageUrl: 'http://img.youtube.com/vi/' + vlink + '/0.jpg',
                                                                placeholder: (context, url) => Container(
                                                                  alignment: Alignment.center,
                                                                  color: Colors.transparent,
                                                                  child: Image.asset('assets/images/ed_logo_greys.png', width: 90,
                                                                    height: 90,),
                                                                ),
                                                                errorWidget: (context, url, error) => Icon(LineAwesomeIcons.file_image_o, size: 44, color: Color(0xffcecece),),
                                                                fit: BoxFit.fill,
                                                                width: MediaQuery.of(context).size.width,
                                                                //height: 260,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: Icon(
                                                                CupertinoIcons.arrowtriangle_right_circle,
                                                                color: Colors.white, size: 50,),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                            ),
                                          ),
                                        ),
                                      ) : Container(),
                                      htmlText(oview),
                                      SizedBox(height: 22,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

}


